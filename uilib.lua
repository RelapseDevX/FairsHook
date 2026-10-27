-- ============================================================================
-- Trident Survival | amongushook Style UI Library (Reconstructed)
-- ============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Original Theme Colors (from source)
local Theme = {
    BackColor = Color3.fromRGB(25, 25, 28),
    TopBar = Color3.fromRGB(35, 35, 40),
    UpperContainer = Color3.fromRGB(40, 40, 45),
    InnerContainer = Color3.fromRGB(30, 30, 35),
    InteractableBackground = Color3.fromRGB(45, 45, 55),
    InteractableOutline = Color3.fromRGB(100, 100, 100),
    Accent = Color3.fromRGB(130, 130, 180),
    TextColor = Color3.fromRGB(230, 230, 235),
    SubTextColor = Color3.fromRGB(160, 160, 170),
}

-- Utility function for creating instances
local function new(className, properties, children)
    local instance = Instance.new(className)
    for key, value in pairs(properties) do
        instance[key] = value
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

-- ============================================================================
-- Library Core
-- ============================================================================
local Library = {}
Library.__index = Library

function Library.new(title)
    local self = setmetatable({}, Library)
    self.Title = title or "amongus.hook"
    self.Tabs = {}
    self.ActiveTab = nil

    -- Main ScreenGui
    local screenGui = new("ScreenGui", {
        Name = "AmongusHookUI",
        Parent = PlayerGui,
        ResetOnSpawn = false,
    })

    -- Main Frame (Draggable)
    local mainFrame = new("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.1, 50, 0.2, 50),
        BackgroundColor3 = Theme.BackColor,
        BorderColor3 = Theme.InteractableOutline,
        BorderSizePixel = 1,
        Active = true,
        Draggable = true,
        Parent = screenGui,
    })

    -- Top Bar
    local topBar = new("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.TopBar,
        Parent = mainFrame,
    })
    new("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = Theme.TextColor,
        TextSize = 14,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })

    -- Content Container
    local contentContainer = new("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -10, 1, -40),
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundColor3 = Theme.UpperContainer,
        Parent = mainFrame,
    })

    -- Tab Bar (Left side)
    local tabBar = new("Frame", {
        Name = "TabBar",
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundColor3 = Theme.InnerContainer,
        Parent = contentContainer,
    })
    local tabList = new("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabBar,
    })

    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.TabBar = tabBar
    self.TabList = tabList
    self.ContentContainer = contentContainer

    return self
end

-- Add a new tab
function Library:AddTab(name)
    local tab = { Name = name, Buttons = {} }

    -- Tab Button
    local tabButton = new("TextButton", {
        Name = name .. "TabButton",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.InteractableBackground,
        Text = "  " .. name,
        TextColor3 = Theme.TextColor,
        TextSize = 13,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TabBar,
    })

    -- Tab Content Frame
    local tabContent = new("ScrollingFrame", {
        Name = name .. "Content",
        Size = UDim2.new(1, -110, 1, 0),
        Position = UDim2.new(0, 105, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.ContentContainer,
    })
    local tabLayout = new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabContent,
    })

    -- Handle tab selection
    tabButton.MouseButton1Click:Connect(function()
        for _, otherTab in pairs(self.Tabs) do
            otherTab.Content.Visible = false
            otherTab.Button.BackgroundColor3 = Theme.InteractableBackground
        end
        tabContent.Visible = true
        tabButton.BackgroundColor3 = Theme.Accent
        self.ActiveTab = tab
    end)

    tab.Button = tabButton
    tab.Content = tabContent
    tab.Layout = tabLayout

    table.insert(self.Tabs, tab)

    -- Auto-select first tab
    if #self.Tabs == 1 then
        tabButton:GetPropertyChangedSignal("Parent"):Wait() -- small delay
        task.wait()
        tabButton:Fire("MouseButton1Click")
    end

    return tab
end

-- ============================================================================
-- Components
-- ============================================================================

-- Button
function Library:AddButton(tab, text, callback)
    local button = new("TextButton", {
        Name = text .. "Button",
        Size = UDim2.new(1, -10, 0, 28),
        BackgroundColor3 = Theme.InteractableBackground,
        Text = "  " .. text,
        TextColor3 = Theme.TextColor,
        TextSize = 13,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tab.Content,
    })

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = Theme.Accent }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = Theme.InteractableBackground }):Play()
    end)
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    table.insert(tab.Buttons, button)
    return button
end

-- Toggle
function Library:AddToggle(tab, text, default, callback)
    local toggleFrame = new("Frame", {
        Name = text .. "ToggleFrame",
        Size = UDim2.new(1, -10, 0, 28),
        BackgroundColor3 = Theme.InteractableBackground,
        Parent = tab.Content,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = "  " .. text,
        TextColor3 = Theme.TextColor,
        TextSize = 13,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame,
    })

    local toggleButton = new("TextButton", {
        Size = UDim2.new(0, 30, 0, 18),
        Position = UDim2.new(1, -35, 0.5, -9),
        BackgroundColor3 = default and Theme.Accent or Theme.InteractableOutline,
        Text = "",
        Parent = toggleFrame,
    })

    local toggled = default or false
    local function updateToggle()
        TweenService:Create(toggleButton, TweenInfo.new(0.1), {
            BackgroundColor3 = toggled and Theme.Accent or Theme.InteractableOutline
        }):Play()
        if callback then callback(toggled) end
    end

    toggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
    end)

    table.insert(tab.Buttons, toggleFrame)
    return toggleFrame
end

-- Slider
function Library:AddSlider(tab, text, min, max, default, callback)
    local sliderFrame = new("Frame", {
        Name = text .. "SliderFrame",
        Size = UDim2.new(1, -10, 0, 45),
        BackgroundColor3 = Theme.InteractableBackground,
        Parent = tab.Content,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -10, 0, 16),
        Position = UDim2.new(0, 5, 0, 2),
        BackgroundTransparency = 1,
        Text = "  " .. text,
        TextColor3 = Theme.TextColor,
        TextSize = 13,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sliderFrame,
    })

    local sliderBar = new("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 28),
        BackgroundColor3 = Theme.InnerContainer,
        Parent = sliderFrame,
    })

    local sliderFill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        Parent = sliderBar,
    })

    local sliderKnob = new("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 0, 0.5, -5),
        BackgroundColor3 = Theme.TextColor,
        Parent = sliderBar,
    })

    local valueLabel = new("TextLabel", {
        Size = UDim2.new(0, 30, 0, 16),
        Position = UDim2.new(1, -35, 0, 2),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Theme.SubTextColor,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = sliderFrame,
    })

    local dragging = false
    local function updateSlider(input)
        local barPos = sliderBar.AbsolutePosition.X
        local barSize = sliderBar.AbsoluteSize.X
        local relativeX = math.clamp((input.Position.X - barPos) / barSize, 0, 1)
        local value = math.floor(min + (max - min) * relativeX + 0.5)
        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        sliderKnob.Position = UDim2.new(relativeX, -5, 0.5, -5)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    table.insert(tab.Buttons, sliderFrame)
    return sliderFrame
end

-- ============================================================================
-- Example Usage
-- ============================================================================
-- local myUI = Library.new("amongus.hook")
-- local mainTab = myUI:AddTab("Main")
-- myUI:AddButton(mainTab, "Execute Script", function() print("Script Executed!") end)
-- myUI:AddToggle(mainTab, "Aimbot", false, function(state) print("Aimbot:", state) end)
-- myUI:AddSlider(mainTab, "FOV", 10, 500, 120, function(val) print("FOV:", val) end)
