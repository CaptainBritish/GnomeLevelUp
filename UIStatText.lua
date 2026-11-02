local ADDON_NAME, ns = ...

-- Whole-word measurements use the existing bounded font cache.
function ns.InstallPopupStatMetrics(render, content, GetStatLine, MeasureStatText, GainCounterWidth)
    function render.StatWordMetrics(fs, data)
        local path, size, flags = fs:GetFont()
        local counting = ns.db and ns.db.emphasizeStatGains == true
        local threshold = ns.GetStatAbbreviationThreshold()
        local label = ns.GetStatDisplayLabel(data)
        local key = table.concat({tostring(path),tostring(size),tostring(flags),label,tostring(data.unit),tostring(data.old),tostring(data.new),tostring(counting),tostring(threshold),ns.GetLocale()}, "\031")
        if fs.statWordMetricKey == key then return fs.statWordWidths, fs.statWordNatural end
        local widths = {MeasureStatText(fs, label .. ":")+12, MeasureStatText(fs, ns.FormatStatTotal(data.old, data))+12,
            MeasureStatText(fs, "->")+12, MeasureStatText(fs, ns.FormatStatTotal(data.new, data)) + 12}
        if counting then
            widths[4] = math.max(widths[4], MeasureStatText(fs, ns.FormatStatTotal(data.old, data)) + 12)
            local digits = math.max(#ns.FormatStatInteger(math.abs(data.old)), #ns.FormatStatInteger(math.abs(data.new)))
            for digit = 0, 9 do
                local value = tonumber(string.rep(tostring(digit), digits)) or 0
                widths[4] = math.max(widths[4], MeasureStatText(fs, ns.FormatStatTotal(value, data)) + 12)
                if math.min(data.old,data.new) < 0 then widths[4] = math.max(widths[4],MeasureStatText(fs,ns.FormatStatTotal(-value, data))+12) end
            end
            if threshold and math.min(data.old,data.new)<threshold and math.max(data.old,data.new)>=threshold then
                widths[4] = math.max(widths[4],MeasureStatText(fs,ns.FormatStatTotal(threshold-1, data))+12)
            end
            widths[5] = GainCounterWidth(fs, data.new-data.old, data)
        end
        if counting and threshold and math.max(math.abs(data.old),math.abs(data.new)) >= 1100000
            and math.min(math.abs(data.old),math.abs(data.new)) < 1000000000 then
            local millions = math.min(999, math.max(1, math.floor(math.max(math.abs(data.old),math.abs(data.new))/1000000)))
            for digit=0,9 do
                widths[4]=math.max(widths[4],MeasureStatText(fs,ns.FormatStatTotal(millions*1000000+digit*111000, data))+12)
            end
        end
        local space = MeasureStatText(fs," ")
        local natural = space * (#widths-1)
        for _, width in ipairs(widths) do natural = natural + width end
        fs.statWordEndWidth = MeasureStatText(fs, counting and ns.FormatStatGain(data.new-data.old, data) or ns.FormatStatTotal(data.new, data))
        fs.statWordMetricKey, fs.statWordWidths, fs.statWordNatural = key, widths, natural
        fs.statWordSpace=space
        return widths, natural
    end

    function render.UpdateStatWordTargets(changes)
        local columns, space, endWidth = {}, 0, 0
        local function Include(fs,data)
            local widths=render.StatWordMetrics(fs,data)
            for i,width in ipairs(widths) do columns[i]=math.max(columns[i] or 0,width) end
            space=math.max(space,fs.statWordSpace or 0)
            endWidth=math.max(endWidth,fs.statWordEndWidth or 0)
        end
        if changes then
            for i,data in ipairs(changes) do
                local fs = content.statLinePool[i] or GetStatLine(i)
                Include(fs,data)
            end
        else
            for _,fs in ipairs(content.statLinePool) do
                if fs.statData then Include(fs,fs.statData) end
            end
        end
        local target=space*math.max(0,#columns-1)
        for _,width in ipairs(columns) do target=target+width end
        local trailing=math.max(0,(columns[#columns] or 0)-endWidth)
        local key=table.concat(columns,",")..":"..trailing
        for i,fs in ipairs(content.statLinePool) do
            if changes and i<=#changes or not changes and fs.statData then
                fs.statWordTarget,fs.statWordColumns,fs.statWordColumnKey,fs.statWordTrailing=target,columns,key,trailing
                fs.statTracking=0
            end
        end
    end
end
