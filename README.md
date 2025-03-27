# Framework Resource Manager
## Setup


1. Extract repo contents to *'/gamemode/server/'*.
2. Add *'manager.lua'* to *'/gamemode/manifest.json'* as a server script.
3. Modify *'/gamemode/server/autostart.lua'* to your needs.

## Resource management
**A list of functions and variables that the resource manager exports globally by default.**
`getResources()` | Returns a table containing all resources, indexed by their name, value being the resource's data.

`refreshResources()` | Scans the resource directory, unloads broken resources, loads newly added ones.

`startResource(resourceName)` | Starts the aforementioned resource.

`stopResource(resourceName)` | Stops the aforementioned resource.

`restartResource(resourceName)` | Restarts the aforementioned resource.

`unloadResource(resourceName)` | Stops and unloads the aforementioned resource.


`getResourceFromName(resourceName)` | Returns the aforementioned resource's data (.path, .state, .manifest...)

`getResourceState(resourceName)` | Returns the aforementioned resource's state (0 = loaded, 1 = running)

`getResourcePath(resourceName)` | Returns the aforementioned resource's path on the drive.


`fileExists(path)` | Checks whether a file exists on the provided path.

`cwd` | Returns the current working directory of the server scripts (/gamemode/server/)

## Features
#### Resource state tracking
The resource manager emits 2 custom events, one when a resource is started, other when a resource is stopped.
Every single resource has a `thisResource` variable declared in it's own scope, so for example doing `print(thisResource)` in the `i-love-framework` resource will output `i-love-framework` to the console, while doing the same thing in the `hello` resource outputs.. you guessed it, `hello`.

**Start**
```lua
Event.on("onResourceStart", function(startedResource)
	print(startedResource)
end)
```

**Stop**
```lua
Event.on("onResourceStop", function(stoppedResource)
	print(stoppedResource)
end)
```

#### Exports
Exports are globally callable user-defined functions and variables which can be added to any script-file of a resource.
Example:

*/resources/hello/server.lua*:
```lua
-- Define our message.
local message = "Greetings :)"

-- Define the function that other scripts will be able to call on demand.
function getHelloMessage()
	return message
end

exports = {
	get = getHelloMessage, -- Export our 'getHelloMessage' function as 'get'
	ninePlusTen = 21 -- Export a random variable we've set.
}
```
*/resources/player-greet/server.lua*:
```lua
Event.on("onPlayerConnected", function(player)
	local greetMessage = _G.exports.hello:get() -- Call the 'get' function (method) from the 'hello' resource.
	local result = _G.exports.hello.ninePlusTen -- Get the value of our exported variable 'ninePlusTen'
	
	Chat.sendToAll(player.name.." | "..greetMessage) -- Output the joined player's name and greet message to chat.
	Chat.sendToAll("9 + 10 = "..result) -- Outputs something magnificent to chat.
end)
```

### Pre-included resources
The resource manager ships with a few resources I've cooked up for you guys.


**Cache**

Allows you, *the developer*, to cache anything on **anything** you want.

Usage:

`_G.exports.cache:set(index, key, value)` | Sets the cache on the specified key of the index.

`_G.exports.cache:get(index)` or `_G.exports.cache:get(index, key)` | Returns all data from the index or only a specific key.

`_G.exports.cache:clear(index)` | Clears all data from an index.


**Data**

As the name suggests, it's a mini database system used for storing data that's 'there to stay', written to a file, and kept for a unknown period of time, or permanently.

Usage:

`_G.exports.data:set(tableName, key, value)` | Sets the data on the specified table for the key.

`_G.exports.data:get(tableName, key)` | Retrieves the data from the table, on the specified key.


**Chats**

As the name suggests, it's the default chat, with command handling.

Usage:

`_G.exports.chats:registerCommand(commandName, handlerFunction)` | Binds the specified command to the provided handler function.

`_G.exports.chats:removeCommand(commandName, handlerFunction)` | Removes and unbinds the command from the handler function.


**Utils**

Contains some useful utilities for developers.

Usage:

`_G.exports.utils.accentColor` | Accent color which you can, but do not need to use server-wide for messages.

`_G.exports.utils:toHex(r, g, b)` | Converts an R, G, B color to hex code. (eg. 255, 255, 255 to "FFFFFF")

`_G.exports.utils:filterHex(string)` | Removes hex codes from the provided string.

 `_G.exports.utils:resolveFilePath(filePath, resourceName)` | Gets the absolute path of a file in a resource. For example, accessing files outside the current resource is done by appending the ":" prefix at the start of the path (":hello/test.txt")

**IMPORTANT NOTE: The included resources were NOT written for MafiaMP but for another project that uses the Mafia Framework, I cannot guarantee that they'll all work.**
