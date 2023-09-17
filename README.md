# Remote-Controller-Plugin
A plugin that allows you to trigger remote events and functions during play mode (aka runtime) AND pass any values, aka arguments to them. Good for testing your game's network security from an exploiter's perspective. Uses `loadstring()` and script injection.\
Plugin: https://www.roblox.com/library/14802947348/Remote-Controller

# Instruction
1. Install the plugin\
https://www.roblox.com/library/14802947348/Remote-Controller \
or download the model file in releases.

2. Enable `LoadStringEnabled` in `ServerScriptService`\
You can disable it when you're done using the plugin.
<img width="394" alt="Screenshot_3" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/b6a571a1-d5cb-4ecb-a47d-7deaa227debd">

3. Allow script injection\
Sounds scary, but this plugin can't work without it, see Explanation.

# Explanation
### Why does this plugin require `LoadStringEnabled`?
Because to convert raw user input which is basic string, the plugin needs to feed that string to `loadstring()` function, so that it can spit out actual values of datatypes that Roblox can understand.\
For example:
```
local userInput = "Vector3.new(1,2,3)"
print(userInput, typeof(userInput)) -- output: Vector3.new(1,2,3) string
local processedInput = loadstring("return " .. userInput)()
print(processedInput, typeof(processedInput)) -- output: 1, 2, 3 Vector3
```
It is true that `LoadStringEnabled` can empower exploiters in your game, but you are absolutely fine as long as you disable it before you publish your game to Roblox.

### Why does this plugin require Script Injection premission?
Because even with `LoadStringEnabled` enabled, `loadstring()` still cant be run on the client, it works only on the server while all plugins run purely on the client.
To tackle this issue, i made it so that plugin creates a server script in `ServerScriptService` and a remote function in `ReplicatedStorage` **before** runtime. And when the plugin needs to use `loadstring()` to process the user's input, it sends that input, which is a string, through that remote function, so the server script can run `loadstring()` on the server and return the actual processed values back to the client as a table.
