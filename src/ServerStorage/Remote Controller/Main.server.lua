local folder = script.Parent
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 50, 100, 30)
local widget = plugin:CreateDockWidgetPluginGui("Remote Controller", widgetInfo)
widget.Title = "0 REMOTES SELECTED"
widget.AutoLocalize = false

-- a bar that will accept user input
local argsBar: TextBox = folder:WaitForChild("ArgsBar"):Clone()
argsBar.Parent = widget

local toolbar = plugin:CreateToolbar("martytyty2098")
local button = toolbar:CreateButton(
	"Remote Controller",
	"Super power to trigger remote events and functions at will", -- Trigger a remote event/function during play test
	"rbxassetid://14749933281"
)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

widget.Changed:Connect(function(property)
	if property == "Enabled" then
		button.Enabled = false
		button.Enabled = true
	end
end)

-- find all remote events/functions
for _, obj in pairs(game:GetDescendants()) do
	if obj:IsA("RemoteEvent") then
	end
end

local selectedButton: TextButton = nil

argsBar.FocusLost:Connect(function(enterPressed: boolean)
	if not enterPressed then
		return
	end

	local input = argsBar.ContentText
	local values = loadstring("return " .. "{" .. input .. "}")() -- pcall
	for i, v in pairs(values) do
		print(i, v, typeof(v))
	end
end)
