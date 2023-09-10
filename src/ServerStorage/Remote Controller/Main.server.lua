local folder = script.Parent
local gui = folder:WaitForChild("RemoteControllerGui"):Clone()
-- frame that will contain all remote events/functions in the game
local scrollingFrame = gui:WaitForChild("ScrollingFrame")
-- a bar that will accept user input
local argsBar = gui:WaitForChild("ArgsBar")
-- a table where each text button is binded to a remote event/function
local buttons = {} -- TextButton = RemoteEvent

local function UpdateCanvasSize(Canvas, Constraint)
	Canvas.CanvasSize = UDim2.new(0, Constraint.AbsoluteContentSize.X, 0, Constraint.AbsoluteContentSize.Y + 20)
end

scrollingFrame.ChildAdded:Connect(function()
	UpdateCanvasSize(scrollingFrame, scrollingFrame.UIGridLayout)
end)

-- create a button for every remote event/function in the game and bind them together inside a table
for _, obj in pairs(game:GetDescendants()) do
	if obj:IsA("RemoteEvent") then
		local button = gui.ExampleButton:Clone()
		button.Text = obj.Name
		button.Parent = scrollingFrame
		buttons[button] = obj
	end
end

local selectedButton: TextButton = nil

for currButton: TextButton, remote in pairs(buttons) do
	currButton.Activated:Connect(function()
		if selectedButton then
			selectedButton.BackgroundTransparency = 1
		end
		selectedButton = currButton
		selectedButton.BackgroundTransparency = 0
		argsBar.Visible = true
	end)
	currButton.MouseEnter:Connect(function()
		if selectedButton == currButton then
			return
		end
		currButton.BackgroundTransparency = 0.5
	end)
	currButton.MouseLeave:Connect(function()
		if selectedButton == currButton then
			return
		end
		currButton.BackgroundTransparency = 1
	end)
end

argsBar.FocusLost:Connect(function(enterPressed: boolean)
	if not enterPressed then
		return
	end
	local input = argsBar.ContentText
	local values = gui.SendLoadStringRequest:InvokeServer(input)
	for i, v in pairs(values) do
		print(i, v, typeof(v))
	end
end)
