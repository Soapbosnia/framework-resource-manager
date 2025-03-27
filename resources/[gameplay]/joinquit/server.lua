local color = _G.exports.utils.accentColor
local text = {"has joined the game", "has left the game", "{FF0000}died"}

local function outputMessage(player, messageType, reason)
    local hex = _G.exports.cache:get(player.id, "colorhex")
    local message = color.."~ "..hex..player.nickname..color.." "..text[messageType]

    if reason then
        message = message..color.." [{FFFFFF}"..reason..color.."]"
    end

	Chat.sendToAll(message)
    Console.log("["..player.id.."] ".._G.exports.utils:filterHex(message))
end

Event.on("onPlayerJoin", function(player)
    outputMessage(player, 1)
end)

Event.on("onPlayerQuit", function(player, reason)
    outputMessage(player, 2, reason)
end)

Event.on("onPlayerDied", function(player)
    outputMessage(player, 3)
end)