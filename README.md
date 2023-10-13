# Remote Controller Plugin
A plugin that allows you to trigger remote events and functions during play mode (aka runtime) AND pass any values, (aka arguments) to them. Good for testing your game's network security from an exploiter's perspective. Uses `loadstring()` and script injection.

Plugin: https://www.roblox.com/library/14802947348/Remote-Controller \
**ONLY WORKS AT RUNTIME (AKA PLAYMODE)** \
Source: https://www.roblox.com/library/15052192452/Remote-Controller-source

It does not appear in the marketplace or toolbox when searching, because of this: 
https://devforum.roblox.com/t/plugin-does-not-appear-in-creator-marketplace/2622917/3

# Setup
1. Install the plugin\
https://www.roblox.com/library/14802947348/Remote-Controller

2. Enable `LoadStringEnabled` in `ServerScriptService`

You can disable it when you're done using the plugin. See [Explanation](https://github.com/martytyty2098/Remote-Controller-Plugin#why-does-this-plugin-require-loadstringenabled)

<img width="394" alt="Screenshot_3" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/d0ed716b-9f70-413b-bf2d-84973217ca0e">

3. Allow script injection

Sounds scary, but this plugin can't work without it, see [Explanation](https://github.com/martytyty2098/Remote-Controller-Plugin#why-does-this-plugin-require-script-injection-premission)

<img width="360" alt="Screenshot_1" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/4a48bee7-28e5-49cf-9aa8-ca560a6301b0">

After you click "Allow" you might need to restart roblox studio.

# How to use
**Usage example:** https://youtu.be/6Avn_rB5Sso (1:20)

1. **AT RUNTIME (AKA PLAYMODE)** click on the plugin icon

<img width="120" alt="Screenshot_2" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/54023876-47e3-41b1-b33d-787781812ce4">

2. Select any `Remote Event` or `Remote Function` in the explorer

<img width="189" alt="Screenshot_4" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/030a3e13-39cc-4b07-95cc-fc30374f826b">

3. In the text box that appears, enter any valid value like this:

<img width="517" alt="Screenshot_5" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/a652f91e-c8c2-4782-86a0-c4e3f2381340">

Or like this:

<img width="516" alt="Screenshot_6" src="https://github.com/martytyty2098/Remote-Controller-Plugin/assets/108870368/ebe51014-6df1-44bd-8c30-410de5c559ba">

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
