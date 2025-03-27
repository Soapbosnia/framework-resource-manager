local commands = {}

function registerCommand(name, handler)
	commands[name] = handler
end

function removeCommand(name, handler)
	commands[name] = nil
end

Event.on("onChatCommand", function (player, message, command, args)
	local commandHandler = commands[command]

	if (not commandHandler) then
		return
	end

	commandHandler(player, message, command, args)
    Console.log("[GAMEMODE] Player "..player.nickname.." used command: \""..command.."\". ("..message..")")
end)

Event.on("onChatMessage", function(player, message)
    local hex = _G.exports.cache:get(player.id, "colorhex")
    local text = hex..player.nickname..": {FFFFFF}"..message

    Chat.sendToAll(text)
    Console.log("[CHAT] ".._G.exports.utils:filterHex(text))
end)

exports = {
    registerCommand = registerCommand,
	removeCommand = removeCommand
}