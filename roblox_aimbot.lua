-- Roblox Aimbot & Target Lock Script (Third Person)
-- Developed for a private test environment

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
    UIVisible = true
}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 420)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = Settings.UIVisible
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Aimbot & Lock Settings"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = MainFrame

local function CreateToggle(name, settingName, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 30)
    Button.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(60, 150, 60) or Color3.fromRGB(150, 60, 60)
    Button.Text = name .. ": " .. (Settings[settingName] and "ON" or "OFF")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.Parent = parent

    Button.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        Button.Text = name .. ": " .. (Settings[settingName] and "ON" or "OFF")
        Button.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(60, 150, 60) or Color3.fromRGB(150, 60, 60)
    end)
    return Button
end

local function CreateSlider(name, settingName, min, max, parent)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Text = name .. ": " .. tostring(Settings[settingName])
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.Parent = Container

    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, 0, 0, 10)
    SliderBG.Position = UDim2.new(0, 0, 0, 25)
    SliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBG.Parent = Container

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Settings[settingName] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG

    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local value = min + (pos * (max - min))
        if max > 10 then value = math.floor(value) end
        if settingName == "Smoothness" then value = math.floor(value * 100) / 100 end
        Settings[settingName] = value
        Label.Text = name .. ": " .. tostring(value)
    end

    local dragging = false
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

CreateToggle("Aimbot Enabled", "AimbotEnabled", MainFrame)
CreateToggle("Wall Check", "WallCheck", MainFrame)
CreateToggle("Auto Switch", "AutomaticTargetSwitch", MainFrame)
CreateSlider("FOV Radius", "FOVRadius", 10, 800, MainFrame)
CreateSlider("Smoothness", "Smoothness", 0, 1, MainFrame)

local AimKeyLabel = Instance.new("TextLabel")
AimKeyLabel.Size = UDim2.new(1, -10, 0, 20)
AimKeyLabel.BackgroundTransparency = 1
AimKeyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AimKeyLabel.Text = "Aim Key: " .. Settings.AimKey.Name
AimKeyLabel.Font = Enum.Font.SourceSans
AimKeyLabel.TextSize = 14
AimKeyLabel.Parent = MainFrame

local LockKeyLabel = Instance.new("TextLabel")
LockKeyLabel.Size = UDim2.new(1, -10, 0, 20)
LockKeyLabel.BackgroundTransparency = 1
LockKeyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
LockKeyLabel.Text = "Lock Key: " .. Settings.LockKey.Name
LockKeyLabel.Font = Enum.Font.SourceSans
LockKeyLabel.TextSize = 14
LockKeyLabel.Parent = MainFrame

local function CreateKeybindButton(name, settingName, parent, label)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 30)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.Text = "Change " .. name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.Parent = parent

    local changing = false
    Button.MouseButton1Click:Connect(function()
        changing = true
        Button.Text = "Press any key..."
    end)

    UserInputService.InputBegan:Connect(function(input)
        if changing then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Settings[settingName] = input.KeyCode
                changing = false
                Button.Text = "Change " .. name
                label.Text = name .. ": " .. input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                Settings[settingName] = input.UserInputType
                changing = false
                Button.Text = "Change " .. name
                label.Text = name .. ": " .. input.UserInputType.Name
            end
        end
    end)
end

CreateKeybindButton("Aim Key", "AimKey", MainFrame, AimKeyLabel)
CreateKeybindButton("Lock Key", "LockKey", MainFrame, LockKeyLabel)

-- FOV Circle
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 2
FOVCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FOVCircle

local function IsVisible(targetHead)
    if not Settings.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetHead.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, targetHead.Position - Camera.CFrame.Position, params)
    return result == nil
end

local function GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = Settings.FOVRadius
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance and IsVisible(head) then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local currentAimbotTarget = nil
local currentLockTarget = nil

RunService.RenderStepped:Connect(function()
    -- UI Logic
    MainFrame.Visible = Settings.UIVisible

    -- FOV Circle Logic
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
    FOVCircle.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)
    FOVCircle.Visible = Settings.AimbotEnabled

    if Settings.AimbotEnabled then
        -- 1. Aimbot Logic (Camera Interpolation)
        local isAiming = false
        if typeof(Settings.AimKey) == "EnumItem" then
            if Settings.AimKey.EnumType == Enum.UserInputType then
                isAiming = UserInputService:IsMouseButtonPressed(Settings.AimKey)
            else
                isAiming = UserInputService:IsKeyDown(Settings.AimKey)
            end
        end

        if isAiming then
            if not currentAimbotTarget or not currentAimbotTarget.Character or not currentAimbotTarget.Character:FindFirstChild("Head") then
                currentAimbotTarget = GetClosestTarget()
            elseif Settings.AutomaticTargetSwitch then
                local head = currentAimbotTarget.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if not onScreen or dist > Settings.FOVRadius or not IsVisible(head) then
                    currentAimbotTarget = GetClosestTarget()
                end
            end

            if currentAimbotTarget and currentAimbotTarget.Character and currentAimbotTarget.Character:FindFirstChild("Head") then
                local head = currentAimbotTarget.Character.Head
                local targetCFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 - Settings.Smoothness)
            end
        else
            currentAimbotTarget = nil
        end

        -- 2. Target Lock Logic (Cursor Snapping, Camera Free)
        if Settings.TargetLockEnabled then
            if not currentLockTarget or not currentLockTarget.Character or not currentLockTarget.Character:FindFirstChild("Head") then
                currentLockTarget = GetClosestTarget()
            elseif Settings.AutomaticTargetSwitch then
                local head = currentLockTarget.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                -- We check visibility but maybe lock should stay even if obscured? Requirement says "snaps précisément", usually means while visible.
                if not onScreen or dist > Settings.FOVRadius or not IsVisible(head) then
                    currentLockTarget = GetClosestTarget()
                end
            end

            if currentLockTarget and currentLockTarget.Character and currentLockTarget.Character:FindFirstChild("Head") then
                local head = currentLockTarget.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- Executor specific cursor movement if available
                    if mousemoverel then
                        local delta = Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()
                        mousemoverel(delta.X, delta.Y)
                    elseif setrbxclipboard then -- Just a check for some common executor functions to assume it might work
                        -- If we can't move mouse with standard API, we can't fully satisfy "camera remains free"
                        -- unless the game uses the mouse cursor position for aiming (like in some shooters).
                    end
                end
            end
        else
            currentLockTarget = nil
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.UIKey then
        Settings.UIVisible = not Settings.UIVisible
    end

    local isLockKey = false
    if typeof(Settings.LockKey) == "EnumItem" then
        if Settings.LockKey.EnumType == Enum.KeyCode then
            isLockKey = (input.KeyCode == Settings.LockKey)
        elseif Settings.LockKey.EnumType == Enum.UserInputType then
            isLockKey = (input.UserInputType == Settings.LockKey)
        end
    end
    if isLockKey then
        Settings.TargetLockEnabled = not Settings.TargetLockEnabled
    end
end)
