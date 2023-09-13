-- This converts the user's input, which is a base string, into actual data types that Roblox can understand.
local receive: RemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("__plugin_LoadStringBridge")
receive.OnServerInvoke = function(player: Player, code: string)
	local success, response = pcall(loadstring("return {" .. code .. "}"))
	return success and response or nil
end
