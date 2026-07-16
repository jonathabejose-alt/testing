--[[
	UILibrary.lua
	Librería de UI para Roblox Studio (tema oscuro + acento morado)

	USO BÁSICO:
	local UILibrary = require(path.to.UILibrary)

	local Window = UILibrary:CreateWindow({
		Title = "Mi Panel",
		SubTitle = "usuario123 | v1.0"
	})

	local Tab = Window:AddTab("General")

	Tab:AddToggle({
		Text = "Activado",
		Default = false,
		Callback = function(value)
			print("Toggle:", value)
		end
	})

	Tab:AddSlider({
		Text = "Velocidad",
		Min = 0,
		Max = 100,
		Default = 50,
		Callback = function(value)
			print("Slider:", value)
		end
	})

	Tab:AddDropdown({
		Text = "Modo",
		Options = {"Fácil", "Normal", "Difícil"},
		Default = "Normal",
		Callback = function(value)
			print("Dropdown:", value)
		end
	})
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Paleta de colores
local Theme = {
	Background = Color3.fromRGB(20, 20, 24),
	Sidebar = Color3.fromRGB(15, 15, 18),
	Section = Color3.fromRGB(26, 26, 31),
	Accent = Color3.fromRGB(139, 122, 234),
	AccentDim = Color3.fromRGB(90, 80, 160),
	Text = Color3.fromRGB(235, 235, 240),
	SubText = Color3.fromRGB(150, 150, 160),
	Stroke = Color3.fromRGB(40, 40, 46),
	ToggleOff = Color3.fromRGB(45, 45, 52),
}

local function tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.18, Enum.EasingStyle.Quad), props):Play()
end

local function makeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end

local function makeStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = thickness or 1
	s.Parent = parent
	return s
end

local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary:CreateWindow(config)
	config = config or {}

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "UILibraryGui"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 620, 0, 420)
	Main.Position = UDim2.new(0.5, -310, 0.5, -210)
	Main.BackgroundColor3 = Theme.Background
	Main.BorderSizePixel = 0
	Main.Parent = ScreenGui
	makeCorner(Main, 8)
	makeStroke(Main, Theme.Stroke, 1)

	-- Barra superior (arrastrable)
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	TopBar.BackgroundColor3 = Theme.Sidebar
	TopBar.BorderSizePixel = 0
	TopBar.Parent = Main
	makeCorner(TopBar, 8)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0, 16, 0, 0)
	TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = config.Title or "UI Library"
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.TextSize = 15
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TopBar

	local SubTitleLabel = Instance.new("TextLabel")
	SubTitleLabel.BackgroundTransparency = 1
	SubTitleLabel.Position = UDim2.new(0, 16, 0, 20)
	SubTitleLabel.Size = UDim2.new(0.6, 0, 0, 16)
	SubTitleLabel.Font = Enum.Font.Gotham
	SubTitleLabel.Text = config.SubTitle or ""
	SubTitleLabel.TextColor3 = Theme.SubText
	SubTitleLabel.TextSize = 11
	SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	SubTitleLabel.Parent = TopBar

	-- Arrastrar ventana
	do
		local dragging, dragStart, startPos
		TopBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = Main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	-- Sidebar de tabs
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Position = UDim2.new(0, 0, 0, 40)
	Sidebar.Size = UDim2.new(0, 150, 1, -40)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main

	local SidebarList = Instance.new("UIListLayout")
	SidebarList.Padding = UDim.new(0, 4)
	SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarList.Parent = Sidebar

	local SidebarPadding = Instance.new("UIPadding")
	SidebarPadding.PaddingTop = UDim.new(0, 10)
	SidebarPadding.PaddingLeft = UDim.new(0, 10)
	SidebarPadding.Parent = Sidebar

	-- Contenedor de contenido
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Position = UDim2.new(0, 150, 0, 40)
	Content.Size = UDim2.new(1, -150, 1, -40)
	Content.BackgroundTransparency = 1
	Content.Parent = Main

	local Window = setmetatable({}, UILibrary)
	Window.ScreenGui = ScreenGui
	Window.Sidebar = Sidebar
	Window.Content = Content
	Window.Tabs = {}
	Window.CurrentTab = nil

	function Window:AddTab(name)
		local TabButton = Instance.new("TextButton")
		TabButton.Name = name
		TabButton.Size = UDim2.new(1, -10, 0, 32)
		TabButton.BackgroundColor3 = Theme.Sidebar
		TabButton.BackgroundTransparency = 1
		TabButton.AutoButtonColor = false
		TabButton.Font = Enum.Font.Gotham
		TabButton.Text = "   " .. name
		TabButton.TextColor3 = Theme.SubText
		TabButton.TextSize = 13
		TabButton.TextXAlignment = Enum.TextXAlignment.Left
		TabButton.Parent = Sidebar
		makeCorner(TabButton, 6)

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.new(0, 3, 0, 16)
		Indicator.Position = UDim2.new(0, 0, 0.5, -8)
		Indicator.BackgroundColor3 = Theme.Accent
		Indicator.BorderSizePixel = 0
		Indicator.Visible = false
		Indicator.Parent = TabButton
		makeCorner(Indicator, 2)

		local TabPage = Instance.new("ScrollingFrame")
		TabPage.Name = name .. "Page"
		TabPage.Size = UDim2.new(1, -20, 1, -20)
		TabPage.Position = UDim2.new(0, 10, 0, 10)
		TabPage.BackgroundTransparency = 1
		TabPage.BorderSizePixel = 0
		TabPage.ScrollBarThickness = 4
		TabPage.ScrollBarImageColor3 = Theme.Accent
		TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
		TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
		TabPage.Visible = false
		TabPage.Parent = Content

		local PageList = Instance.new("UIListLayout")
		PageList.Padding = UDim.new(0, 10)
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Parent = TabPage

		local Tab = {}
		Tab.Button = TabButton
		Tab.Page = TabPage
		Tab.Indicator = Indicator

		local function selectTab()
			for _, t in pairs(Window.Tabs) do
				t.Page.Visible = false
				t.Indicator.Visible = false
				tween(t.Button, {TextColor3 = Theme.SubText})
			end
			TabPage.Visible = true
			Indicator.Visible = true
			tween(TabButton, {TextColor3 = Theme.Text})
			Window.CurrentTab = Tab
		end

		TabButton.MouseButton1Click:Connect(selectTab)
		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then
			selectTab()
		end

		-- Elementos de la tab
		function Tab:AddSection(title)
			local Section = Instance.new("Frame")
			Section.Size = UDim2.new(1, 0, 0, 30)
			Section.BackgroundTransparency = 1
			Section.Parent = TabPage

			local Label = Instance.new("TextLabel")
			Label.BackgroundTransparency = 1
			Label.Size = UDim2.new(1, 0, 1, 0)
			Label.Font = Enum.Font.GothamBold
			Label.Text = title
			Label.TextColor3 = Theme.Text
			Label.TextSize = 14
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Section

			return Section
		end

		function Tab:AddToggle(opt)
			opt = opt or {}
			local state = opt.Default or false

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, 32)
			Holder.BackgroundColor3 = Theme.Section
			Holder.Parent = TabPage
			makeCorner(Holder, 6)

			local Label = Instance.new("TextLabel")
			Label.BackgroundTransparency = 1
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.Size = UDim2.new(1, -60, 1, 0)
			Label.Font = Enum.Font.Gotham
			Label.Text = opt.Text or "Toggle"
			Label.TextColor3 = Theme.Text
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Holder

			local Box = Instance.new("Frame")
			Box.Size = UDim2.new(0, 16, 0, 16)
			Box.Position = UDim2.new(1, -30, 0.5, -8)
			Box.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
			Box.Parent = Holder
			makeCorner(Box, 4)

			local Button = Instance.new("TextButton")
			Button.BackgroundTransparency = 1
			Button.Size = UDim2.new(1, 0, 1, 0)
			Button.Text = ""
			Button.Parent = Holder

			Button.MouseButton1Click:Connect(function()
				state = not state
				tween(Box, {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff})
				if opt.Callback then
					opt.Callback(state)
				end
			end)

			return Holder
		end

		function Tab:AddSlider(opt)
			opt = opt or {}
			local min = opt.Min or 0
			local max = opt.Max or 100
			local value = opt.Default or min

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, 46)
			Holder.BackgroundColor3 = Theme.Section
			Holder.Parent = TabPage
			makeCorner(Holder, 6)

			local Label = Instance.new("TextLabel")
			Label.BackgroundTransparency = 1
			Label.Position = UDim2.new(0, 12, 0, 6)
			Label.Size = UDim2.new(0.6, 0, 0, 16)
			Label.Font = Enum.Font.Gotham
			Label.Text = opt.Text or "Slider"
			Label.TextColor3 = Theme.Text
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Holder

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Position = UDim2.new(1, -60, 0, 6)
			ValueLabel.Size = UDim2.new(0, 48, 0, 16)
			ValueLabel.Font = Enum.Font.Gotham
			ValueLabel.Text = tostring(value)
			ValueLabel.TextColor3 = Theme.SubText
			ValueLabel.TextSize = 12
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.Parent = Holder

			local Track = Instance.new("Frame")
			Track.Position = UDim2.new(0, 12, 0, 30)
			Track.Size = UDim2.new(1, -24, 0, 4)
			Track.BackgroundColor3 = Theme.ToggleOff
			Track.Parent = Holder
			makeCorner(Track, 2)

			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Fill.Parent = Track
			makeCorner(Fill, 2)

			local dragging = false
			local function updateFromInput(x)
				local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				value = math.floor(min + (max - min) * rel)
				Fill.Size = UDim2.new(rel, 0, 1, 0)
				ValueLabel.Text = tostring(value)
				if opt.Callback then
					opt.Callback(value)
				end
			end

			Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					updateFromInput(input.Position.X)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateFromInput(input.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			return Holder
		end

		function Tab:AddDropdown(opt)
			opt = opt or {}
			local options = opt.Options or {}
			local selected = opt.Default or options[1]
			local open = false

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, 0, 0, 32)
			Holder.BackgroundColor3 = Theme.Section
			Holder.ClipsDescendants = false
			Holder.Parent = TabPage
			makeCorner(Holder, 6)

			local Label = Instance.new("TextLabel")
			Label.BackgroundTransparency = 1
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.Size = UDim2.new(0.5, 0, 1, 0)
			Label.Font = Enum.Font.Gotham
			Label.Text = opt.Text or "Dropdown"
			Label.TextColor3 = Theme.Text
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Holder

			local SelectedLabel = Instance.new("TextLabel")
			SelectedLabel.BackgroundTransparency = 1
			SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
			SelectedLabel.Size = UDim2.new(0.45, 0, 1, 0)
			SelectedLabel.Font = Enum.Font.Gotham
			SelectedLabel.Text = tostring(selected)
			SelectedLabel.TextColor3 = Theme.Accent
			SelectedLabel.TextSize = 13
			SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
			SelectedLabel.Parent = Holder

			local Button = Instance.new("TextButton")
			Button.BackgroundTransparency = 1
			Button.Size = UDim2.new(1, 0, 1, 0)
			Button.Text = ""
			Button.Parent = Holder

			local OptionsFrame = Instance.new("Frame")
			OptionsFrame.Position = UDim2.new(0, 0, 1, 4)
			OptionsFrame.Size = UDim2.new(1, 0, 0, #options * 26)
			OptionsFrame.BackgroundColor3 = Theme.Section
			OptionsFrame.Visible = false
			OptionsFrame.ZIndex = 5
			OptionsFrame.Parent = Holder
			makeCorner(OptionsFrame, 6)
			makeStroke(OptionsFrame, Theme.Stroke, 1)

			local OptList = Instance.new("UIListLayout")
			OptList.SortOrder = Enum.SortOrder.LayoutOrder
			OptList.Parent = OptionsFrame

			for _, optionValue in ipairs(options) do
				local OptButton = Instance.new("TextButton")
				OptButton.Size = UDim2.new(1, 0, 0, 26)
				OptButton.BackgroundTransparency = 1
				OptButton.Font = Enum.Font.Gotham
				OptButton.Text = tostring(optionValue)
				OptButton.TextColor3 = Theme.SubText
				OptButton.TextSize = 12
				OptButton.ZIndex = 6
				OptButton.Parent = OptionsFrame

				OptButton.MouseButton1Click:Connect(function()
					selected = optionValue
					SelectedLabel.Text = tostring(optionValue)
					OptionsFrame.Visible = false
					open = false
					if opt.Callback then
						opt.Callback(optionValue)
					end
				end)
			end

			Button.MouseButton1Click:Connect(function()
				open = not open
				OptionsFrame.Visible = open
			end)

			return Holder
		end

		function Tab:AddLabel(text)
			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, 0, 0, 20)
			Label.BackgroundTransparency = 1
			Label.Font = Enum.Font.Gotham
			Label.Text = text
			Label.TextColor3 = Theme.SubText
			Label.TextSize = 12
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = TabPage
			return Label
		end

		return Tab
	end

	-- Búsqueda simple (barra superior derecha, opcional)
	function Window:AddSearchBar()
		local SearchBox = Instance.new("TextBox")
		SearchBox.Size = UDim2.new(0, 160, 0, 26)
		SearchBox.Position = UDim2.new(1, -172, 0, 7)
		SearchBox.BackgroundColor3 = Theme.Section
		SearchBox.PlaceholderText = "Buscar..."
		SearchBox.Text = ""
		SearchBox.TextColor3 = Theme.Text
		SearchBox.PlaceholderColor3 = Theme.SubText
		SearchBox.Font = Enum.Font.Gotham
		SearchBox.TextSize = 12
		SearchBox.ClearTextOnFocus = false
		SearchBox.Parent = TopBar
		makeCorner(SearchBox, 6)
		makeStroke(SearchBox, Theme.Stroke, 1)
		return SearchBox
	end

	return Window
end

return UILibrary
