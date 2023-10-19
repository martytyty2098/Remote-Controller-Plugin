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

-- a button that will activate all selected remotes
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

		-- expand the scrolling frame as it runs out of space or shrink it back
		if
			argsBar.TextBounds.X + fontWidth >= scroll.AbsoluteCanvasSize.X
			or argsBar.TextBounds.X < scroll.AbsoluteCanvasSize.X / 2
		then
			scroll.CanvasSize = UDim2.new(0, argsBar.TextBounds.X * 1.5, 0, scroll.CanvasSize.Y.Scale)
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
			scroll.Size = UDim2.fromScale(scroll.Size.X.Scale, 0.7)
		end
	end)

	local selectedEvents: { RemoteEvent } = {}
	local selectedFunctions: { RemoteFunction } = {}

	-- get all selected remote events/functions
	selection.SelectionChanged:Connect(function()
		table.clear(selectedEvents)
		table.clear(selectedFunctions)

		local selected = selection:Get()

		for _, obj in pairs(selected) do
			if obj.ClassName == "RemoteEvent" then
				table.insert(selectedEvents, obj)
			elseif obj.ClassName == "RemoteFunction" then
				table.insert(selectedFunctions, obj)
			end
		end

		if #selectedEvents == 0 and #selectedFunctions == 0 then
			fireButton.Text = "NO EVENTS OR FUNCTIONS SELECTED"
		else
			fireButton.Text = string.format(
				"ACTIVATE ON %d EVENT%s AND %d FUNCTION%s",
				#selectedEvents,
				#selectedEvents == 1 and "" or "S",
				#selectedFunctions,
				#selectedFunctions == 1 and "" or "S"
			)
		end
	end)

	local TriggerAllRemotes = function()
		if run:IsServer() then
			warn("Remote Controller plugin must be used on the client, not server")
		end

		-- not mine: https://devforum.roblox.com/t/vlua-loadstring-reimplemented-in-lua/2495756
		local vLua_loadstring = require(folder:WaitForChild("Loadstring"))
		local success, values = pcall(vLua_loadstring("return {" .. argsBar.ContentText .. "}"))

		if not success then
			warn(
				"Remote Controller Plugin error: Invalid user input, possible syntax typo\nInput:",
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

	fireButton.Activated:Connect(TriggerAllRemotes)
	argsBar.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			TriggerAllRemotes()
		end
	end)
end

-- if in play mode
if run:IsRunning() then
	atRuntime()
else
	button.Enabled = false

	-- disable gui if it lingers after runtime
	while true do
		task.wait(1)
		if widget.Enabled then
			widget.Enabled = false
		end
	end
end
