local rootPath = getResourcePath("data").."/data"
local luaKeywords = {
    ["and"] = true,
    ["break"] = true,
    ["do"] = true,
    ["else"] = true,
    ["elseif"] = true,
    ["end"] = true,
    ["false"] = true,
    ["for"] = true,
    ["function"] = true,
    ["if"] = true,
    ["in"] = true,
    ["local"] = true,
    ["nil"] = true,
    ["not"] = true,
    ["or"] = true,
    ["repeat"] = true,
    ["return"] = true,
    ["then"] = true,
    ["true"] = true,
    ["until"] = true,
    ["while"] = true,
}

local function serializeImpl(t, tTracking, sIndent)
    local sType = type(t)
    if (sType == "table") then
        if (tTracking[t] ~= nil) then
            error("Cannot serialize table with recursive entries", 0)
        end

        tTracking[t] = true

        if (next(t) == nil) then
            return "{}"
        else
            local sResult = "{\n"
            local sSubIndent = sIndent.."  "
            local tSeen = {}

            for k, v in ipairs(t) do
                tSeen[k] = true
                sResult = sResult..sSubIndent..serializeImpl(v, tTracking, sSubIndent)..",\n"
            end

            for k, v in pairs(t) do
                if (not tSeen[k]) then
                    local sEntry

                    if (type(k) == "string" and not luaKeywords[k] and string.match( k, "^[%a_][%a%d_]*$" )) then
                        sEntry = k.." = "..serializeImpl(v, tTracking, sSubIndent)..",\n"
                    else
                        sEntry = "["..serializeImpl(k, tTracking, sSubIndent).."] = "..serializeImpl(v, tTracking, sSubIndent)..",\n"
                    end

                    sResult = sResult..sSubIndent..sEntry
                end
            end
            sResult = sResult..sIndent.."}"
            return sResult
        end
    elseif (sType == "string") then
        return string.format("%q", t)
    elseif (sType == "number" or sType == "boolean" or sType == "nil") then
        return tostring(t)
    else
        error("Cannot serialize type "..sType, 0)
    end
end

function serializeTable(t)
    local tracking = {}
    return serializeImpl(t, tracking, "")
end

local function loadTable(tableName)
    local filePath = rootPath.."/"..tableName..".lua"
    if fileExists(filePath) then
        return dofile(filePath)
    end
    return {}
end

local function saveTable(tableName, data)
    local filePath = rootPath.."/"..tableName..".lua"
    local file = io.open(filePath, "w")
    
    if file then
        file:write("return "..serializeTable(data))
        file:close()
    end
end

function getData(tableName, index)
    local data = loadTable(tableName)
    return data[index]
end

function setData(tableName, index, value)
    local data = loadTable(tableName)
    
    data[index] = value
    saveTable(tableName, data)
end

exports = {
    get = getData,
    set = setData
}