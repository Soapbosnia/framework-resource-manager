local accentColor = "{00AAFF}"

function toHex(red, green, blue)
	if (red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) then
		return nil
	end
	return string.format("%.2X%.2X%.2X", red, green, blue)
end

function filterHex(input)
    return input:gsub("{%x%x%x%x%x%x}", "")
end

function resolveFilePath(filePath, resourceName)
    if (filePath:sub(1, 1) == ":") then
        local targetResource, subPath = filePath:match("^:([^/]+)/(.+)$")
		local resourceData = getResourceFromName(targetResource)

        if (targetResource and resourceData) then
            return resourceData.path.."/"..subPath
        end
    else
        return getResourceFromName(resourceName).path.."/"..filePath
    end
    return nil
end

exports = {
    toHex = toHex,
    filterHex = filterHex,
	resolveFilePath = resolveFilePath,
    accentColor = accentColor
}