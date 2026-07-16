--[[
	EvoUILibrary.lua
	Librería de UI estilo "evohub" (Tema oscuro + acento morado)
	
	USO BÁSICO:
	local UILibrary = loadstring(game:HttpGet("..."))() -- O si es un ModuleScript: require(...)

	local Window = UILibrary:CreateWindow({
		Title = "evohub",
		SubTitle = "user | alpha"
	})

	local Tab = Window:AddTab("Rage")

	Tab:AddToggle({
		Text = "Enabled",
		Default = true,
		Callback = function(value)
			print("Toggle:", value)
		end
	})

	Tab:AddSlider({
		Text = "Hitchance",
		Min = 0,
		Max = 100,
		Default = 50,
		Callback = function(value)
			print("Slider:", value)
		end
	})
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Paleta de colores de la imagen (EvoHub)
local Theme = {
	Background = Color3.fromRGB(18, 18, 20),
	Sidebar = Color3.fromRGB(18, 18, 20),
	Section = Color3.fromRGB(22, 22, 24),
	Accent = Color3.fromRGB(140, 110, 255), -- El morado de la imagen
	AccentDim = Color3.fromRGB(90, 80, 160),
	Text = Color3.fromRGB(235, 235, 240),
	SubText = Color3.fromRGB(150, 150, 160),
	Stroke = Color3.fromRGB(35, 35, 40),
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

local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary:CreateWindow(config)
	config = config or {}

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "EvoUILibrary"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 760, 0, 450)
	Main.Position = UDim2.new(0.5, -380, 0.5, -225)
	Main.BackgroundColor3 = Theme.Background
	Main.BorderSizePixel = 0
	Main.Parent = ScreenGui
	makeCorner(Main, 6)

	-- Barra superior (arrastrable)
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	TopBar.BackgroundColor3 = Theme.Background
	TopBar.BorderSizePixel = 0
	TopBar.Parent = Main

	-- Línea divisoria fina
	local Divider = Instance.new("Frame")
	Divider.Size = UDim2.new(1, 0, 0, 1)
	Divider.Position = UDim2.new(0, 0, 1, 0)
	Divider.BackgroundColor3 = Theme.Stroke
	Divider.BorderSizePixel = 0
	Divider.Parent = TopBar

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = config.Title or "evohub"
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.TextSize = 16
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TopBar

	local SubTitleLabel = Instance.new("TextLabel")
	SubTitleLabel.BackgroundTransparency = 1
	SubTitleLabel.Position = UDim2.new(0, 85, 0, 0)
	SubTitleLabel.Size = UDim2.new(0, 200, 0, 40)
	SubTitleLabel.Font = Enum.Font.Gotham
	SubTitleLabel.Text = " | " .. (config.SubTitle or "")
	SubTitleLabel.TextColor3 = Theme.SubText
	SubTitleLabel.TextSize = 12
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

	-- Top Tabs (Rage, Visuals, Misc)
	local TopTabsContainer = Instance.new("Frame")
	TopTabsContainer.Size = UDim2.new(0, 300, 1, 0)
	TopTabsContainer.Position = UDim2.new(0, 110, 0, 0)
	TopTabsContainer.BackgroundTransparency = 1
	TopTabsContainer.Parent = TopBar

	local TopTabsList = Instance.new("UIListLayout")
	TopTabsList.FillDirection = Enum.FillDirection.Horizontal
	TopTabsList.HorizontalAlignment = Enum.HorizontalAlignment.Left
	TopTabsList.SortOrder = Enum.SortOrder.LayoutOrder
	TopTabsList.Parent = TopTabsContainer

	-- Sidebar de categorías laterales
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Position = UDim2.new(0, 0, 0, 40)
	Sidebar.Size = UDim2.new(0, 130, 1, -40)
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

	-- Contenedor de contenido principal
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Position = UDim2.new(0, 130, 0, 40)
	Content.Size = UDim2.new(1, -130, 1, -40)
	Content.BackgroundTransparency = 1
	Content.Parent = Main

	-- Info del usuario en el fondo del sidebar
	local BuildInfo = Instance.new("TextLabel")
	BuildInfo.Size = UDim2.new(1, -20, 0, 40)
	BuildInfo.Position = UDim2.new(0, 10, 1, -45)
	BuildInfo.BackgroundTransparency = 1
	BuildInfo.Font = Enum.Font.Gotham
	BuildInfo.Text = "build: alpha\nuser: " .. LocalPlayer.Name
	BuildInfo.TextColor3 = Theme.SubText
	BuildInfo.TextSize = 11
	BuildInfo.TextXAlignment = Enum.TextXAlignment.Left
	BuildInfo.Parent = Sidebar

	local Window = setmetatable({}, UILibrary)
	Window.ScreenGui = ScreenGui
	Window.Sidebar = Sidebar
	Window.Content = Content
	Window.TopTabsContainer = TopTabsContainer
	Window.Tabs = {}
	Window.CurrentTopTab = nil
	Window.CurrentCategory = nil

	-- Función interna para agregar un Top Tab
	function Window:AddTopTab(name)
		local TabButton = Instance.new("TextButton")
		TabButton.Name = name
		TabButton.Size = UDim2.new(0, 90, 1, 0)
		TabButton.BackgroundTransparency = 1
		TabButton.AutoButtonColor = false
		TabButton.Font = Enum.Font.GothamBold
		TabButton.Text = name
		TabButton.TextColor3 = Theme.SubText
		TabButton.TextSize = 14
		TabButton.Parent = self.TopTabsContainer

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.new(0, 30, 0, 2)
		Indicator.Position = UDim2.new(0.5, -15, 1, -2)
		Indicator.BackgroundColor3 = Theme.Accent
		Indicator.BorderSizePixel = 0
		Indicator.Visible = false
		Indicator.Parent = TabButton

		-- Contenedor específico para este Top Tab
		local TabPage = Instance.new("Frame")
		TabPage.Name = name .. "Page"
		TabPage.Size = UDim2.new(1, 0, 1, 0)
		TabPage.BackgroundTransparency = 1
		TabPage.Visible = false
		TabPage.Parent = Content

		local Tab = {}
		Tab.Button = TabButton
		Tab.Page = TabPage
		Tab.Indicator = Indicator
		Tab.Categories = {}
		Tab.CurrentCategory = nil

		local function selectTopTab()
			for _, t in pairs(Window.Tabs) do
				t.Page.Visible = false
				t.Indicator.Visible = false
				tween(t.Button, {TextColor3 = Theme.SubText})
			end
			TabPage.Visible = true
			Indicator.Visible = true
			tween(TabButton, {TextColor3 = Theme.Text})
			Window.CurrentTopTab = Tab
		end

		TabButton.MouseButton1Click:Connect(selectTopTab)
		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then
			selectTopTab()
		end

		-- ELEMENTO: Sidebar Category (Dentro del Top Tab)
		function Tab:AddCategory(name)
			local CatButton = Instance.new("TextButton")
			CatButton.Name = name
			CatButton.Size = UDim2.new(1, -10, 0, 32)
			CatButton.BackgroundTransparency = 1
			CatButton.AutoButtonColor = false
			CatButton.Font = Enum.Font.Gotham
			CatButton.Text = "   " .. name
			CatButton.TextColor3 = Theme.SubText
			CatButton.TextSize = 14
			CatButton.TextXAlignment = Enum.TextXAlignment.Left
			CatButton.Parent = Sidebar

			local SelectBar = Instance.new("Frame")
			SelectBar.Size = UDim2.new(0, 3, 0, 16)
			SelectBar.Position = UDim2.new(0, 0, 0.5, -8)
			SelectBar.BackgroundColor3 = Theme.Accent
			SelectBar.BorderSizePixel = 0
			SelectBar.Visible = false
			SelectBar.Parent = CatButton

			-- Contenedor de opciones de esta categoría
			local CategoryPage = Instance.new("Frame")
			CategoryPage.Name = name .. "Category"
			CategoryPage.Size = UDim2.new(1, 0, 1, 0)
			CategoryPage.BackgroundTransparency = 1
			CategoryPage.Visible = false
			CategoryPage.Parent = TabPage

			-- Layout para el contenido de la categoría (dos columnas)
			local LayoutContainer = Instance.new("Frame")
			LayoutContainer.Size = UDim2.new(1, -20, 1, -20)
			LayoutContainer.Position = UDim2.new(0, 10, 0, 10)
			LayoutContainer.BackgroundTransparency = 1
			LayoutContainer.Parent = CategoryPage

			local Col1 = Instance.new("Frame")
			Col1.Size = UDim2.new(0.5, -10, 1, 0)
			Col1.BackgroundTransparency = 1
			Col1.Parent = LayoutContainer

			local Col2 = Instance.new("Frame")
			Col2.Size = UDim2.new(0.5, -10, 1, 0)
			Col2.Position = UDim2.new(0.5, 0, 0, 0)
			Col2.BackgroundTransparency = 1
			Col2.Parent = LayoutContainer

			local CategoryObj = {}
			CategoryObj.Button = CatButton
			CategoryObj.Page = CategoryPage
			CategoryObj.Col1 = Col1
			CategoryObj.Col2 = Col2

			local function selectCategory()
				for _, c in pairs(Tab.Categories) do
					c.Page.Visible = false
					c.SelectBar.Visible = false
					tween(c.Button, {TextColor3 = Theme.SubText})
				end
				CategoryPage.Visible = true
				SelectBar.Visible = true
				tween(CatButton, {TextColor3 = Theme.Text})
				Tab.CurrentCategory = CategoryObj
			end

			CatButton.MouseButton1Click:Connect(selectCategory)
			table.insert(Tab.Categories, CategoryObj)

			if #Tab.Categories == 1 then
				selectCategory()
			end

			-- ELEMENTOS UI DENTRO DE LA CATEGORÍA

			function CategoryObj:AddSection(title, column)
				local parent = column == 2 and Col2 or Col1
				local Section = Instance.new("Frame")
				Section.Size = UDim2.new(1, 0, 0, 25)
				Section.BackgroundTransparency = 1
				Section.Parent = parent

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Size = UDim2.new(1, 0, 1, 0)
				Label.Font = Enum.Font.GothamBold
				Label.Text = title
				Label.TextColor3 = Theme.Text
				Label.TextSize = 14
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Section

				local Line = Instance.new("Frame")
				Line.Size = UDim2.new(1, 0, 0, 1)
				Line.Position = UDim2.new(0, 0, 1, 0)
				Line.BackgroundColor3 = Theme.Stroke
				Line.Parent = Label
				return Section
			end

			function CategoryObj:AddToggle(opt)
				opt = opt or {}
				local state = opt.Default or false
				local parent = opt.Column == 2 and Col2 or Col1

				local Holder = Instance.new("Frame")
				Holder.Size = UDim2.new(1, 0, 0, 25)
				Holder.BackgroundTransparency = 1
				Holder.Parent = parent

				local Box = Instance.new("Frame")
				Box.Size = UDim2.new(0, 12, 0, 12)
				Box.Position = UDim2.new(0, 0, 0.5, -6)
				Box.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
				Box.Parent = Holder

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.new(0, 20, 0, 0)
				Label.Size = UDim2.new(1, -20, 1, 0)
				Label.Font = Enum.Font.Gotham
				Label.Text = opt.Text or "Toggle"
				Label.TextColor3 = Theme.Text
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Holder

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

			function CategoryObj:AddSlider(opt)
				opt = opt or {}
				local min = opt.Min or 0
				local max = opt.Max or 100
				local value = opt.Default or min
				local parent = opt.Column == 2 and Col2 or Col1

				local Holder = Instance.new("Frame")
				Holder.Size = UDim2.new(1, 0, 0, 35)
				Holder.BackgroundTransparency = 1
				Holder.Parent = parent

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Size = UDim2.new(0.7, 0, 0, 20)
				Label.Font = Enum.Font.Gotham
				Label.Text = opt.Text or "Slider"
				Label.TextColor3 = Theme.Text
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Holder

				local ValueLabel = Instance.new("TextLabel")
				ValueLabel.BackgroundTransparency = 1
				ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
				ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
				ValueLabel.Font = Enum.Font.Gotham
				ValueLabel.Text = tostring(value) .. "%"
				ValueLabel.TextColor3 = Theme.SubText
				ValueLabel.TextSize = 12
				ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValueLabel.Parent = Holder

				local Track = Instance.new("Frame")
				Track.Position = UDim2.new(0, 0, 0, 25)
				Track.Size = UDim2.new(1, 0, 0, 3)
				Track.BackgroundColor3 = Theme.ToggleOff
				Track.Parent = Holder

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
				Fill.BackgroundColor3 = Theme.Accent
				Fill.Parent = Track

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

			function CategoryObj:AddDropdown(opt)
				opt = opt or {}
				local options = opt.Options or {}
				local selected = opt.Default or options[1]
				local open = false
				local parent = opt.Column == 2 and Col2 or Col1

				local Holder = Instance.new("Frame")
				Holder.Size = UDim2.new(1, 0, 0, 25)
				Holder.BackgroundTransparency = 1
				Holder.Parent = parent

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Size = UDim2.new(0.6, 0, 1, 0)
				Label.Font = Enum.Font.Gotham
				Label.Text = opt.Text or "Dropdown"
				Label.TextColor3 = Theme.Text
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Holder

				local SelectedLabel = Instance.new("TextLabel")
				SelectedLabel.BackgroundTransparency = 1
				SelectedLabel.Position = UDim2.new(0.6, 0, 0, 0)
				SelectedLabel.Size = UDim2.new(0.4, 0, 1, 0)
				SelectedLabel.Font = Enum.Font.Gotham
				SelectedLabel.Text = tostring(selected)
				SelectedLabel.TextColor3 = Theme.Accent
				SelectedLabel.TextSize = 12
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

			function CategoryObj:AddLabel(text, column)
				local parent = column == 2 and Col2 or Col1
				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 20)
				Label.BackgroundTransparency = 1
				Label.Font = Enum.Font.Gotham
				Label.Text = text
				Label.TextColor3 = Theme.SubText
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = parent
				return Label
			end

			return CategoryObj
		end

		return Tab
	end

	return Window
end

return UILibrary
