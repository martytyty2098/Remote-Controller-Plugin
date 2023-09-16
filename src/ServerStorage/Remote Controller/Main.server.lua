local folder = script.Parent
local selection = game:GetService("Selection")
local run = game:GetService("RunService")

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 50, 100, 30)
local widget = plugin:CreateDockWidgetPluginGui("Remote Controller", widgetInfo)
widget.Title = "Remote Controller"
widget.AutoLocalize = false

local scroll: ScrollingFrame = folder:WaitForChild("ScrollingFrame")
scroll.Parent = widget

-- a bar that will accept user input
local argsBar: TextBox = scroll:WaitForChild("ArgsBar")

-- a button that will activate the whole thing
local fireButton: TextButton = folder:WaitForChild("FireButton"):Clone()
fireButton.Parent = widget

local toolbar = plugin:CreateToolbar("Exploiter mode")
local button = toolbar:CreateButton(
	"Remote Controller",
	"Super power to trigger remote events and functions at will, use at runtime",
	"rbxassetid://14749933281"
)

-- will run in play mode (aka runtime)
local function atRuntime()
	if run:IsServer() then
		return
	end

	button.Click:Connect(function()
		widget.Enabled = not widget.Enabled
	end)

	widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		if widget.Enabled then
			button:SetActive(true)
		else
			button:SetActive(false)
		end
	end)

	argsBar:GetPropertyChangedSignal("Text"):Connect(function()
		local fontWidth = argsBar.TextBounds.X / string.len(argsBar.ContentText)
		local cursorPosX = argsBar.CursorPosition * fontWidth

		-- expand the scrolling frame as it runs out of space
		if argsBar.TextBounds.X + fontWidth >= scroll.AbsoluteCanvasSize.X then
			scroll.CanvasSize = UDim2.new(0, argsBar.TextBounds.X * 2, 0, scroll.CanvasSize.Y.Scale)
		end

		-- adjust canvas position if the cursor goes out of bounds
		if
			cursorPosX < scroll.CanvasPosition.X + fontWidth * 3
			or cursorPosX > scroll.CanvasPosition.X + scroll.AbsoluteWindowSize.X
		then
			scroll.CanvasPosition = Vector2.new(cursorPosX - scroll.AbsoluteWindowSize.X / 2, 0)
		end
	end)

	-- if the button becomes too small, might as well just remove it
	fireButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if fireButton.AbsoluteSize.Y < 15 then
			fireButton.Visible = false
			scroll.Size = UDim2.fromScale(scroll.Size.X.Scale, 1)
		elseif fireButton.AbsoluteSize.Y > 20 then
			fireButton.Visible = true
			scroll.Size = UDim2.fromScale(scroll.Size.X.Scale, 0.8)
		end
	end)

	local selectedEvents: { RemoteEvent } = {}
	local selectedFunctions: { RemoteFunction } = {}
	local eventAmount = 0
	local functionAmount = 0

	-- get all selected remote events/functions
	selection.SelectionChanged:Connect(function()
		table.clear(selectedEvents)
		table.clear(selectedFunctions)
		eventAmount = 0
		functionAmount = 0

		local selected = selection:Get()

		for _, obj in pairs(selected) do
			if obj.ClassName == "RemoteEvent" then
				table.insert(selectedEvents, obj)
				eventAmount += 1
			elseif obj.ClassName == "RemoteFunction" then
				table.insert(selectedFunctions, obj)
				functionAmount += 1
			end
		end

		if eventAmount == 0 and functionAmount == 0 then
			fireButton.Text = "NO EVENTS OR FUNCTIONS SELECTED"
		else
			fireButton.Text = string.format(
				"ACTIVATE ON %d EVENT%s AND %d FUNCTION%s",
				eventAmount,
				eventAmount == 1 and "" or "S",
				functionAmount,
				functionAmount == 1 and "" or "S"
			)
		end
	end)

	-- will be used to execute loadstring on the server
	-- loadstring() is used to convert the user's raw input, which is a basic string, into actual data types that roblox can understand
	local sendLoadString: RemoteFunction = game:GetService("ReplicatedStorage")
		:WaitForChild("__plugin_LoadStringBridge")

	local TriggerAll = function()
		if run:IsServer() then
			warn("Remote Controller plugin must be used on the client, not server")
		end
		-- table of values or nil if the user's input is bad, for example syntax typo like this: Vectoe3.new()
		local values = sendLoadString:InvokeServer(argsBar.ContentText)
		if not values then
			warn(
				"Remote Controller Plugin error: Invalid user input, possible syntax typo\n\tInput:",
				argsBar.ContentText
			)
			return
		end

		for _, v in pairs(selectedEvents) do
			v:FireServer(table.unpack(values))
		end
		for _, v in pairs(selectedFunctions) do
			v:InvokeServer(table.unpack(values))
		end
	end

	fireButton.Activated:Connect(TriggerAll)
	argsBar.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			TriggerAll()
		end
	end)
end

-- if not in play mode
if not run:IsRunning() then
	button.Enabled = false

	-- wait if studio hasn't loaded yet
	while #game:GetService("Players"):GetChildren() <= 0 do
		task.wait()
	end

	-- runs every second in studio, don't worry, performance impact is not that bad
	while true do
		task.wait(1)
		if run:IsRunning() then
			continue
		end

		-- create necessary things if they don't exist
		if not game:GetService("ServerScriptService"):FindFirstChild("__plugin_LoadStringExecution") then
			local executor: Script = folder:WaitForChild("__plugin_LoadStringExecution"):Clone()
			executor.Enabled = true
			executor.Parent = game:GetService("ServerScriptService")
		end
		if not game:GetService("ReplicatedStorage"):FindFirstChild("__plugin_LoadStringBridge") then
			local bridge: RemoteFunction = folder:WaitForChild("__plugin_LoadStringBridge"):Clone()
			bridge.Parent = game:GetService("ReplicatedStorage")
		end

		-- disable widget if it lingers after runtime
		if not run:IsRunning() and widget.Enabled then
			widget.Enabled = false
		end
	end
else
	atRuntime()
end
