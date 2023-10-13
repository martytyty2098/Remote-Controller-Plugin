# Remote Controller Plugin
A plugin that allows you to trigger remote events and functions during play mode (aka runtime) AND pass any values, (aka arguments) to them. Good for testing your game's network security from an exploiter's perspective. Uses `loadstring()` and script injection.

Plugin: https://www.roblox.com/library/14802947348/Remote-Controller \
**ONLY WORKS AT RUNTIME (AKA PLAYMODE)**

It does not appear in the marketplace or toolbox when searching, because of this: 
https://devforum.roblox.com/t/plugin-does-not-appear-in-creator-marketplace/2622917/3

# Setup
1. Install the plugin\
https://www.roblox.com/library/14802947348/Remote-Controller \
or download the source in releases.

2. Enable `LoadStringEnabled` in `ServerScriptService`

You can disable it when you're done using the plugin. See [Explanation](https://github.com/martytyty2098/Remote-Controller-Plugin/edit/main/README.md#why-does-this-plugin-require-loadstringenabled)

<img width="394" alt="Screenshot_3" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/b6a571a1-d5cb-4ecb-a47d-7deaa227debd">

3. Allow script injection

Sounds scary, but this plugin can't work without it, see [Explanation](https://github.com/martytyty2098/Remote-Controller-Plugin/edit/main/README.md#why-does-this-plugin-require-script-injection-premission)

<img width="360" alt="Screenshot_1" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/317d8e64-5fc2-4b98-a71a-b792df4beb17">

After you click "Allow" you might need to restart roblox studio.

# How to use
**Usage example:** https://youtube.com

1. **AT RUNTIME (AKA PLAYMODE)** click on the plugin icon

<img width="120" alt="Screenshot_2" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/b2a1676e-3941-4d3e-97a4-b1911a17a970">

2. Select any `Remote Event` or `Remote Function` in the explorer

<img width="189" alt="Screenshot_4" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/f35f4e70-6fc4-4a35-bb05-da4cb6d7f5a1">

3. In the text box that appears, enter any valid value like this:

<img width="517" alt="Screenshot_5" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/47d8b2ed-2c3f-4b49-bac0-aedc19870e8e">

Or like this:

<img width="516" alt="Screenshot_6" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/ebee9bda-5226-49bd-b918-e8dcae734383">

4. Then click green button on the bottom or press enter on keyboard.

# Explanation
### Why does this plugin require `LoadStringEnabled`?
Because to convert raw user input which is basic string, the plugin needs to feed that string to `loadstring()` function, so that it can spit out actual values of datatypes that Roblox can understand.

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
To tackle this issue, i made it so that plugin creates a [server script](https://github.com/martytyty2098/Remote-Controller-Plugin/blob/main/src/ServerStorage/Remote%20Controller/__plugin_LoadStringExecution.server.lua) in `ServerScriptService` and a remote function in `ReplicatedStorage` **before** runtime. And when the plugin needs to use `loadstring()` to process the user's input, it sends that input, which is a string, through that remote function, so the [server script](https://github.com/martytyty2098/Remote-Controller-Plugin/blob/main/src/ServerStorage/Remote%20Controller/__plugin_LoadStringExecution.server.lua) can run `loadstring()` on the server and return the actual processed values back to the client as a table.
