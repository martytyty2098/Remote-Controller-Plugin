local folder = script.Parent
local selection = game:GetService("Selection")
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 50, 100, 30)
local widget = plugin:CreateDockWidgetPluginGui("Remote Controller", widgetInfo)
widget.Title = "0 EVENTS AND 0 FUNCTIONS SELECTED"
widget.AutoLocalize = false

-- a bar that will accept user input
local argsBar: TextBox = folder:WaitForChild("ArgsBar"):Clone()
argsBar.Parent = widget

local toolbar = plugin:CreateToolbar("martytyty2098")
local button = toolbar:CreateButton(
	"Remote Controller",
	"Super power to trigger remote events and functions at will",
	"rbxassetid://14749933281"
)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

widget.Changed:Connect(function(property)
	if property == "Enabled" then
		button.Enabled = false
		button.Enabled = true
		if widget.Enabled then
			button:SetActive(true)
		else
			button:SetActive(false)
		end
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
	widget.Title = string.format("%u EVENTS AND %u FUNCTIONS SELECTED", eventAmount, functionAmount)
end)

argsBar.FocusLost:Connect(function(enterPressed: boolean)
	if not enterPressed then
		return
	end

	local input = argsBar.ContentText
	local values = loadstring("return " .. "{" .. input .. "}")() -- pcall
	for i, v in pairs(values) do
		print(i, v, typeof(v))
	end
	print("Events:")
	for i, v in pairs(selectedEvents) do
		print(i, v)
	end
	print("Functions:")
	for i, v in pairs(selectedFunctions) do
		print(i, v)
	end
end)
