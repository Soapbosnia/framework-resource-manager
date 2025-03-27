local color = _G.exports.utils.accentColor

local function sendError(player, message)
    Chat.sendToPlayer(player, "{FF0000}"..message)
end

function startScript(player, message, command, args)
    local name = args[1]
    if (not name) then 
        return 
    end

    local exists = getResourceFromName(name)
    if (not exists) then
        return sendError(player, "Resource not found!")
    end

    local state = getResourceState(name)
    if (state == 1) then
        return sendError(player, "Resource "..name.." is already running!")
    end

    startResource(name)
    Chat.sendToPlayer(player, color.."~ {FFFFFF}"..name..color.." started!")
end

function stopScript(player, message, command, args)
    local name = args[1]
    if (not name) then 
        return 
    end

    local exists = getResourceFromName(name)
    if (not exists) then
        return sendError(player, "Resource not found!")
    end

    local state = getResourceState(name)
    if (state == 0) then
        return sendError(player, "Resource "..name.." is not running!")
    end

    stopResource(name)
    Chat.sendToPlayer(player, color.."~ {FFFFFF}"..name..color.." stopped!")
end

function restartScript(player, message, command, args)
    local name = args[1]
    if (not name) then 
        return 
    end

    local exists = getResourceFromName(name)
    if (not exists) then
        return sendError(player, "Resource not found!")
    end

    local state = getResourceState(name)
    if (state == 0) then
        return sendError(player, "Resource "..name.." is not running!")
    end

    restartResource(name)
    Chat.sendToPlayer(player, color.."~ {FFFFFF}"..name..color.." restarted!")
end

function refreshScripts(player)
    refreshResources()
end

Event.on("onResourceStart", function(resource)
    if (resource == thisResource) then
        _G.exports.chats:registerCommand("start", startScript)
        _G.exports.chats:registerCommand("stop", stopScript)
        _G.exports.chats:registerCommand("restart", restartScript)
        _G.exports.chats:registerCommand("refresh", refreshScripts)
    end
end)

Event.on("onResourceStop", function(resource)
    if (resource == thisResource) then
        _G.exports.chats:removeCommand("start", startScript)
        _G.exports.chats:removeCommand("stop", stopScript)
        _G.exports.chats:removeCommand("restart", restartScript)
        _G.exports.chats:removeCommand("refresh", refreshScripts)
    end
end)