local cwd = io.popen("cd"):read("*l").."/gamemode/server"
local autostart = dofile(cwd.."/autostart.lua")
local resources = {}
local globals = {}
local exports = {}
_G.exports = exports

-------------
-- Helpers --
-------------
local function sendInfo(message)
    Console.log(message)
end

function fileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function scanDirectory(directory, foundResources)
    local handle = io.popen('dir "'..directory..'" /b /ad')
    
    if (not handle) then
        return
    end

    for folderName in handle:lines() do
        local fullPath = directory.."/"..folderName
        local manifestPath = fullPath.."/manifest.lua"

        if fileExists(manifestPath) then
            table.insert(foundResources, fullPath)
        else
            scanDirectory(fullPath, foundResources)
        end
    end

    handle:close()
end

local function parseManifest(resourcePath)
    local manifestPath = resourcePath.."/manifest.lua"
    local exists = fileExists(manifestPath)
    if (not exists) then
        return {false, "Missing 'manifest.lua'"}
    end

    local manifest = dofile(manifestPath)
    if (not manifest) then
        return {false, "Invalid 'manifest.lua'"}
    end

    local valid = true
    local errors = {}
    for i=1, #manifest.files do
        local entry = manifest.files[i]
        local filePath = resourcePath.."/"..entry.path

        if (not fileExists(filePath)) then
            errors[#errors+1] = "Missing "..entry.type.." at '"..entry.path.."'"
            valid = false
        end
    end

    if (not valid) then
        return {false, errors, true}
    end

    return {true, manifest}
end

---------------------------------
-- Globally exported functions --
---------------------------------
function getResources()
    return resources
end

function startResource(resourceName)
    local resource = resources[resourceName]

    if (not resource) then
        sendInfo("Failed to start '"..resourceName.."', resource not found.")
        return false
    end

    if (resource.state == 1) then
        sendInfo("Failed to start resource '"..resourceName.."' since it's already running.")
        return false
    end

    resource.state = 1
    exports[resourceName] = {}
    resource.environment.exports = exports[resourceName]
    resource.environment.thisResource = resourceName
    setmetatable(resource.environment, {__index = function(_, key)
        return globals[key] or _G[key]
    end})

    for _, entry in ipairs(resource.manifest.files) do
        if (entry.type == "script") then
            local scriptPath = resource.path.."/"..entry.path
            
            if (not fileExists(scriptPath)) then
                sendInfo("Failed to start '"..resourceName.."'")
                sendInfo("Missing script file at '"..scriptPath.."'")
                return false
            end

            local chunk, err = loadfile(scriptPath, "bt", resource.environment)
            if (not chunk) then
                sendInfo("Failed to load script '"..scriptPath.."' in resource '"..resourceName.."'")
                sendInfo(err)
                return false
            end

            local success, runtimeError = pcall(chunk)
            if (not success) then
                sendInfo("Runtime error at '"..scriptPath.."' in resource '"..resourceName.."'")
                return false
            end
        end
    end

    local function wrapFunction(fn)
        return function(self, ...)
            return fn(...)
        end
    end

    for key, value in pairs(resource.environment.exports) do
        if (type(value) == "function") then
            resource.environment.exports[key] = wrapFunction(value)
        end
    end

    exports[resourceName] = resource.environment.exports
    Event.emit("onResourceStart", resourceName)
    sendInfo("Started resource: "..resourceName)
    return true
end

function stopResource(resourceName)
    local resource = resources[resourceName]

    if (not resource) then
        sendInfo("Failed to stop '"..resourceName.."', resource not found.")
        return false
    end

    if (resource.state == 0) then
        sendInfo("Failed to stop '"..resourceName.."' since it's already stopped.")
        return false
    end

    Event.emit("onResourceStop", resourceName)
    exports[resourceName] = nil
    resource.environment = {}
    resource.state = 0

    sendInfo("Stopped resource: "..resourceName)
    return true
end

function unloadResource(name)
    stopResource(name)
    resources[name] = nil
end

function restartResource(resourceName)
    if stopResource(resourceName) then
        return startResource(resourceName)
    end
    return false
end

function getResourceFromName(resourceName)
    return resources[resourceName]
end

function getResourceState(resourceName)
    local resource = resources[resourceName]
    return resource and resource.state
end

function getResourcePath(resourceName)
    local resource = resources[resourceName]
    return resource and resource.path
end

function refreshResources()
    local loaded = 0
    local failed = 0
    local found = {}

    scanDirectory(cwd.."/resources", found)

    for _, resourcePath in ipairs(found) do
        local resourceName = resourcePath:match("([^/]+)$")
        local resource = resources[resourceName]
        local manifest = parseManifest(resourcePath)

        if manifest[1] then
            if (not resource) then
                resources[resourceName] = {name = resourceName, path = resourcePath, manifest = manifest[2], environment = {}, state = 0}
            end

            loaded = loaded + 1
        else
            if resource then
                unloadResource(resourceName)
            end

            if manifest[3] then
                sendInfo("Failed loading "..resourceName)

                for i=1, #manifest[2] do
                    sendInfo(manifest[2][i].." in resource '"..resourceName.."'")
                end
            else
                sendInfo(manifest[2].." in resource '"..resourceName.."'")
            end

            failed = failed + 1
        end
    end

    return loaded, failed
end

----------------------
-- Exported globals --
----------------------
globals.getResources = getResources
globals.refreshResources = refreshResources
globals.startResource = startResource
globals.stopResource = stopResource
globals.unloadResource = unloadResource
globals.restartResource = restartResource
globals.getResourceFromName = getResourceFromName
globals.getResourceState = getResourceState
globals.getResourcePath = getResourcePath
globals.fileExists = fileExists
globals.cwd = cwd

----------------
-- Main event --
----------------
Event.on("onGamemodeLoaded", function()
    local loaded, failed = refreshResources()
    
    for i=1, #autostart do
        local name = autostart[i]

        if resources[name] then
            startResource(name)
        end
    end

    sendInfo("Loaded "..loaded.." resources"..(failed > 0 and ", "..failed.." failed." or ""))
end)