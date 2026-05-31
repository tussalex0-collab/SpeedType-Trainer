-- Advanced Roblox Aimbot & Visuals Script
-- Optimized for Smoothness and Aesthetics

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AimbotEnabled = true,
    TargetLockEnabled = false,
    AimKey = Enum.UserInputType.MouseButton2,
    LockKey = Enum.KeyCode.T,
    UIKey = Enum.KeyCode.Insert,
    FOVRadius = 100,
    Smoothness = 0.5,
    WallCheck = true,
    AutomaticTargetSwitch = true,
    TargetPart = "Head",
    UIVisible = true,
    -- ESP Settings
    ESPEnabled = true,
    ESPBoxes = true,
    ESPNames = true,
    ESPDistance = true,
    ESPColor = Color3.fromRGB(255, 0, 0)
}

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ADVANCED SCRIPT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Custom Dragging Logic
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Tabs
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 100, 1, -35)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabList = Instance.new("UIListLayout")
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabContainer

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -100, 1, -35)
ContentContainer.Position = UDim2.new(0, 100, 0, 35)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs = {}
local function CreateTab(name, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 12
    TabButton.LayoutOrder = order
    TabButton.Parent = TabContainer

    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, -20, 1, -20)
    ContentFrame.Position = UDim2.new(0, 10, 0, 10)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Visible = false
    ContentFrame.ScrollBarThickness = 2
    ContentFrame.Parent = ContentContainer

    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 8)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = ContentFrame

    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Frame.Visible = false
            t.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        ContentFrame.Visible = true
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    Tabs[name] = {Button = TabButton, Frame = ContentFrame}
    return ContentFrame
end

local AimbotTab = CreateTab("AIMBOT", 1)
local VisualsTab = CreateTab("VISUALS", 2)
local SettingsTab = CreateTab("SETTINGS", 3)

-- Show first tab by default
Tabs["AIMBOT"].Frame.Visible = true
Tabs["AIMBOT"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)

-- UI Components
local function CreateToggle(name, settingName, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 30)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.Text = "  " .. name .. ": " .. (Settings[settingName] and "ON" or "OFF")
    Button.TextColor3 = Settings[settingName] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 12
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        Button.Text = "  " .. name .. ": " .. (Settings[settingName] and "ON" or "OFF")
        Button.TextColor3 = Settings[settingName] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end)
end

local function CreateSlider(name, settingName, min, max, parent)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 45)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. tostring(Settings[settingName])
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, 0, 0, 6)
    SliderBG.Position = UDim2.new(0, 0, 0, 25)
    SliderBG.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SliderBG.Parent = Container

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Settings[settingName] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG

    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local value = min + (pos * (max - min))
        if max > 1 then value = math.floor(value) else value = math.floor(value * 100) / 100 end
        Settings[settingName] = value
        Label.Text = name .. ": " .. tostring(value)
    end

    local dragging = false
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Populate Aimbot Tab
CreateToggle("Enable Aimbot", "AimbotEnabled", AimbotTab)
CreateToggle("Wall Check", "WallCheck", AimbotTab)
CreateToggle("Auto Switch", "AutomaticTargetSwitch", AimbotTab)
CreateSlider("FOV Radius", "FOVRadius", 10, 800, AimbotTab)
CreateSlider("Smoothness", "Smoothness", 0, 1, AimbotTab)

-- Populate Visuals Tab
CreateToggle("Enable ESP", "ESPEnabled", VisualsTab)
CreateToggle("Show Boxes", "ESPBoxes", VisualsTab)
CreateToggle("Show Names", "ESPNames", VisualsTab)
CreateToggle("Show Distance", "ESPDistance", VisualsTab)

local function CreateDropdown(name, settingName, options, parent)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. Settings[settingName]
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 25)
    Btn.Position = UDim2.new(0, 0, 0, 20)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = "Switch"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 10
    Btn.Parent = Container

    local currIdx = 1
    for i, v in ipairs(options) do if v == Settings[settingName] then currIdx = i end end

    Btn.MouseButton1Click:Connect(function()
        currIdx = currIdx + 1
        if currIdx > #options then currIdx = 1 end
        Settings[settingName] = options[currIdx]
        Label.Text = name .. ": " .. Settings[settingName]
    end)
end

CreateDropdown("Target Part", "TargetPart", {"Head", "HumanoidRootPart", "Torso"}, AimbotTab)

-- Populate Settings Tab
local UIKeyLabel = Instance.new("TextLabel")
UIKeyLabel.Size = UDim2.new(1, 0, 0, 20)
UIKeyLabel.BackgroundTransparency = 1
UIKeyLabel.Text = "UI Key: " .. Settings.UIKey.Name
UIKeyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
UIKeyLabel.Font = Enum.Font.Gotham
UIKeyLabel.TextSize = 12
UIKeyLabel.Parent = SettingsTab

local function CreateKeybind(name, settingName, parent, label)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = "Set " .. name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.Parent = parent

    local changing = false
    Btn.MouseButton1Click:Connect(function()
        changing = true
        Btn.Text = "Press Key..."
    end)

    UserInputService.InputBegan:Connect(function(input)
        if changing then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Settings[settingName] = input.KeyCode
                changing = false
                Btn.Text = "Set " .. name
                label.Text = name .. ": " .. input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                Settings[settingName] = input.UserInputType
                changing = false
                Btn.Text = "Set " .. name
                label.Text = name .. ": " .. input.UserInputType.Name
            end
        end
    end)
end
CreateKeybind("UI Key", "UIKey", SettingsTab, UIKeyLabel)

-- Animation Logic
local function ToggleUI()
    Settings.UIVisible = not Settings.UIVisible
    if Settings.UIVisible then
        MainFrame.Visible = true
        MainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
        MainFrame.BackgroundTransparency = 1
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -200, 0.5, -150), BackgroundTransparency = 0}):Play()
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -200, 0.5, -100), BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function() if not Settings.UIVisible then MainFrame.Visible = false end end)
    end
end

-- Initial Animation
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
MainFrame.BackgroundTransparency = 1
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -200, 0.5, -150), BackgroundTransparency = 0}):Play()

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.UIKey then ToggleUI() end
    if input.KeyCode == Settings.LockKey then Settings.TargetLockEnabled = not Settings.TargetLockEnabled end
end)

-- Logic
local FOVCircle = Instance.new("Frame")
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 1
FOVCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Parent = ScreenGui
local FOVCircleCorner = Instance.new("UICorner")
FOVCircleCorner.CornerRadius = UDim.new(1, 0)
FOVCircleCorner.Parent = FOVCircle

local function IsVisible(part)
    if not Settings.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return result == nil
end

local function GetTarget()
    local closest, dist = nil, Settings.FOVRadius
    local mouse = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.TargetPart) then
            local part = p.Character[Settings.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local d = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                if d < dist and IsVisible(part) then
                    dist = d
                    closest = p
                end
            end
        end
    end
    return closest
end

-- ESP Logic
local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ESP"
ESPContainer.Parent = ScreenGui

local function UpdateESP()
    ESPContainer:ClearAllChildren()
    if not Settings.ESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local screenPos = Vector2.new(pos.X, pos.Y)
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude

                if Settings.ESPBoxes then
                    local size = (Vector2.new(2000, 2000) / pos.Z)
                    local box = Instance.new("Frame")
                    box.Size = UDim2.new(0, size.X, 0, size.Y)
                    box.Position = UDim2.new(0, screenPos.X - size.X/2, 0, screenPos.Y - size.Y/2)
                    box.BackgroundTransparency = 1
                    box.BorderSizePixel = 1
                    box.BorderColor3 = Settings.ESPColor
                    box.Parent = ESPContainer
                end

                if Settings.ESPNames or Settings.ESPDistance then
                    local label = Instance.new("TextLabel")
                    label.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - 20)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 10
                    local text = ""
                    if Settings.ESPNames then text = p.Name end
                    if Settings.ESPDistance then text = text .. " [" .. math.floor(distance) .. "m]" end
                    label.Text = text
                    label.Parent = ESPContainer
                end
            end
        end
    end
end

local currentTarget = nil
RunService.RenderStepped:Connect(function(dt)
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
    FOVCircle.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)
    FOVCircle.Visible = Settings.AimbotEnabled

    UpdateESP()

    if Settings.AimbotEnabled then
        local aiming = false
        if typeof(Settings.AimKey) == "EnumItem" then
            if Settings.AimKey.EnumType == Enum.UserInputType then aiming = UserInputService:IsMouseButtonPressed(Settings.AimKey)
            else aiming = UserInputService:IsKeyDown(Settings.AimKey) end
        end

        if aiming or Settings.TargetLockEnabled then
            if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild(Settings.TargetPart) then
                currentTarget = GetTarget()
            elseif Settings.AutomaticTargetSwitch then
                local part = currentTarget.Character[Settings.TargetPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                local d = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                if not onScreen or d > Settings.FOVRadius or not IsVisible(part) then currentTarget = GetTarget() end
            end

            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild(Settings.TargetPart) then
                local part = currentTarget.Character[Settings.TargetPart]
                local targetCF = CFrame.new(Camera.CFrame.Position, part.Position)

                -- Fixing Shakiness: Use DeltaTime for smooth interpolation
                local alpha = 1 - math.pow(Settings.Smoothness, dt * 60)
                if Settings.TargetLockEnabled then alpha = 1 end
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)

                -- Handle Target Lock Snapping (if possible via executor)
                if Settings.TargetLockEnabled and mousemoverel then
                    local pos = Camera:WorldToViewportPoint(part.Position)
                    local delta = Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()
                    mousemoverel(delta.X, delta.Y)
                end
            end
        else
            currentTarget = nil
        end
    end
end)
