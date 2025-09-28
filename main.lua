-- DarkForge-X Ultimate Arsenal Cheat Suite
-- Silent Aim + Trigger Bot + Aimbot + Team Check + FOV Customization

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Konfigurace
local Settings = {
    SilentAim = {
        Enabled = false,
        TeamCheck = true,
        FOV = 80,
        FOVColor = Color3.fromRGB(0, 255, 0),
        HitChance = 100,
        Keybind = Enum.KeyCode.Q
    },
    
    TriggerBot = {
        Enabled = false,
        TeamCheck = true,
        Delay = 0.01,
        Keybind = Enum.KeyCode.T
    },
    
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        Smoothness = 0.1,
        Keybind = Enum.KeyCode.E,
        AimPart = "Head"
    },
    
    Visuals = {
        FOVCircle = true,
        ShowFOV = true
    }
}

-- Proměnné
local FOVCircle
local Connections = {}
local Target

-- Vytvoření FOV kruhu
local function CreateFOVCircle()
    if FOVCircle then FOVCircle:Remove() end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = Settings.Visuals.ShowFOV
    FOVCircle.Radius = Settings.SilentAim.FOV
    FOVCircle.Color = Settings.SilentAim.FOVColor
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- Funkce pro získání nejlepšího cíle
local function GetBestTarget()
    local bestTarget = nil
    local closestDistance = Settings.SilentAim.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local head = character:FindFirstChild("Head")
            
            if humanoid and head and humanoid.Health > 0 then
                -- Team Check
                if Settings.SilentAim.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                -- Výpočet pozice na obrazovce
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (mousePos - targetPos).Magnitude
                    
                    if distance <= closestDistance then
                        closestDistance = distance
                        bestTarget = character
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- SILENT AIM FUNKCE
local function SetupSilentAim()
    -- Hook na střelbu
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(...)
        local method = getnamecallmethod()
        local args = {...}
        
        if Settings.SilentAim.Enabled and method == "FireServer" then
            local target = GetBestTarget()
            
            if target and math.random(1, 100) <= Settings.SilentAim.HitChance then
                local head = target:FindFirstChild("Head")
                if head then
                    -- Uprav argumenty pro zásah hlavy
                    if args[2] then
                        args[2] = head.Position
                    end
                end
            end
        end
        
        return oldNamecall(unpack(args))
    end)
    
    setreadonly(mt, true)
end

-- TRIGGER BOT FUNKCE
local function SetupTriggerBot()
    Connections.TriggerBot = RunService.Heartbeat:Connect(function()
        if not Settings.TriggerBot.Enabled then return end
        
        local target = GetBestTarget()
        if target then
            -- Team Check pro Trigger Bot
            local player = Players:GetPlayerFromCharacter(target)
            if Settings.TriggerBot.TeamCheck and player and player.Team == LocalPlayer.Team then
                return
            end
            
            -- Simulace střelby
            wait(Settings.TriggerBot.Delay)
            local virtualInput = game:GetService("VirtualInputManager")
            virtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            wait(0.01)
            virtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end)
end

-- AIMBOT FUNKCE
local function SetupAimbot()
    Connections.Aimbot = RunService.Heartbeat:Connect(function()
        if not Settings.Aimbot.Enabled then return end
        
        local target = GetBestTarget()
        if target then
            -- Team Check pro Aimbot
            local player = Players:GetPlayerFromCharacter(target)
            if Settings.Aimbot.TeamCheck and player and player.Team == LocalPlayer.Team then
                return
            end
            
            local aimPart = target:FindFirstChild(Settings.Aimbot.AimPart)
            if aimPart then
                local screenPos = Camera:WorldToViewportPoint(aimPart.Position)
                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                local currentPos = Vector2.new(Mouse.X, Mouse.Y)
                
                -- Smooth aiming
                local newPos = currentPos:Lerp(targetPos, Settings.Aimbot.Smoothness)
                mousemoverel(newPos.X - currentPos.X, newPos.Y - currentPos.Y)
            end
        end
    end)
end

-- GUI MENU
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Bqos-script"
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.Text = "BQOS-SCRIPT"
    Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    -- SILENT AIM SECTION
    local SilentAimSection = Instance.new("TextLabel")
    SilentAimSection.Size = UDim2.new(0.9, 0, 0, 20)
    SilentAimSection.Position = UDim2.new(0.05, 0, 0.1, 0)
    SilentAimSection.BackgroundTransparency = 1
    SilentAimSection.Text = "SILENT AIM"
    SilentAimSection.TextColor3 = Color3.fromRGB(0, 255, 255)
    SilentAimSection.TextSize = 14
    SilentAimSection.Font = Enum.Font.GothamBold
    SilentAimSection.Parent = MainFrame

    local SilentAimToggle = Instance.new("TextButton")
    SilentAimToggle.Size = UDim2.new(0.4, 0, 0, 25)
    SilentAimToggle.Position = UDim2.new(0.05, 0, 0.15, 0)
    SilentAimToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    SilentAimToggle.Text = "Silent Aim: OFF"
    SilentAimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentAimToggle.TextSize = 12
    SilentAimToggle.Font = Enum.Font.Gotham
    SilentAimToggle.Parent = MainFrame

    local TeamCheckToggle = Instance.new("TextButton")
    TeamCheckToggle.Size = UDim2.new(0.4, 0, 0, 25)
    TeamCheckToggle.Position = UDim2.new(0.5, 0, 0.15, 0)
    TeamCheckToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    TeamCheckToggle.Text = "Team Check: ON"
    TeamCheckToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeamCheckToggle.TextSize = 12
    TeamCheckToggle.Font = Enum.Font.Gotham
    TeamCheckToggle.Parent = MainFrame

    -- FOV SETTINGS
    local FOVText = Instance.new("TextLabel")
    FOVText.Size = UDim2.new(0.4, 0, 0, 20)
    FOVText.Position = UDim2.new(0.05, 0, 0.22, 0)
    FOVText.BackgroundTransparency = 1
    FOVText.Text = "FOV: " .. Settings.SilentAim.FOV
    FOVText.TextColor3 = Color3.fromRGB(255, 255, 255)
    FOVText.TextSize = 12
    FOVText.Font = Enum.Font.Gotham
    FOVText.Parent = MainFrame

    local FOVSlider = Instance.new("TextBox")
    FOVSlider.Size = UDim2.new(0.4, 0, 0, 20)
    FOVSlider.Position = UDim2.new(0.5, 0, 0.22, 0)
    FOVSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    FOVSlider.Text = tostring(Settings.SilentAim.FOV)
    FOVSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    FOVSlider.TextSize = 12
    FOVSlider.PlaceholderText = "FOV Value"
    FOVSlider.Parent = MainFrame

    -- TRIGGER BOT SECTION
    local TriggerSection = Instance.new("TextLabel")
    TriggerSection.Size = UDim2.new(0.9, 0, 0, 20)
    TriggerSection.Position = UDim2.new(0.05, 0, 0.3, 0)
    TriggerSection.BackgroundTransparency = 1
    TriggerSection.Text = "TRIGGER BOT"
    TriggerSection.TextColor3 = Color3.fromRGB(255, 255, 0)
    TriggerSection.TextSize = 14
    TriggerSection.Font = Enum.Font.GothamBold
    TriggerSection.Parent = MainFrame

    local TriggerToggle = Instance.new("TextButton")
    TriggerToggle.Size = UDim2.new(0.4, 0, 0, 25)
    TriggerToggle.Position = UDim2.new(0.05, 0, 0.35, 0)
    TriggerToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    TriggerToggle.Text = "Trigger Bot: OFF"
    TriggerToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TriggerToggle.TextSize = 12
    TriggerToggle.Font = Enum.Font.Gotham
    TriggerToggle.Parent = MainFrame

    -- AIMBOT SECTION
    local AimbotSection = Instance.new("TextLabel")
    AimbotSection.Size = UDim2.new(0.9, 0, 0, 20)
    AimbotSection.Position = UDim2.new(0.05, 0, 0.45, 0)
    AimbotSection.BackgroundTransparency = 1
    AimbotSection.Text = "AIMBOT"
    AimbotSection.TextColor3 = Color3.fromRGB(255, 0, 255)
    AimbotSection.TextSize = 14
    AimbotSection.Font = Enum.Font.GothamBold
    AimbotSection.Parent = MainFrame

    local AimbotToggle = Instance.new("TextButton")
    AimbotToggle.Size = UDim2.new(0.4, 0, 0, 25)
    AimbotToggle.Position = UDim2.new(0.05, 0, 0.5, 0)
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    AimbotToggle.Text = "Aimbot: OFF"
    AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotToggle.TextSize = 12
    AimbotToggle.Font = Enum.Font.Gotham
    AimbotToggle.Parent = MainFrame

    -- KEYBINDS SECTION
    local KeybindsSection = Instance.new("TextLabel")
    KeybindsSection.Size = UDim2.new(0.9, 0, 0, 20)
    KeybindsSection.Position = UDim2.new(0.05, 0, 0.6, 0)
    KeybindsSection.BackgroundTransparency = 1
    KeybindsSection.Text = "KEYBINDS"
    KeybindsSection.TextColor3 = Color3.fromRGB(0, 255, 0)
    KeybindsSection.TextSize = 14
    KeybindsSection.Font = Enum.Font.GothamBold
    KeybindsSection.Parent = MainFrame

    local KeybindsText = Instance.new("TextLabel")
    KeybindsText.Size = UDim2.new(0.9, 0, 0, 60)
    KeybindsText.Position = UDim2.new(0.05, 0, 0.65, 0)
    KeybindsText.BackgroundTransparency = 1
    KeybindsText.Text = "Q = Silent Aim\nT = Trigger Bot\nE = Aimbot\nInsert = Hide Menu"
    KeybindsText.TextColor3 = Color3.fromRGB(200, 200, 200)
    KeybindsText.TextSize = 11
    KeybindsText.TextWrapped = true
    KeybindsText.Font = Enum.Font.Gotham
    KeybindsText.Parent = MainFrame

    -- FUNKCE PRO TLAČÍTKA
    SilentAimToggle.MouseButton1Click:Connect(function()
        Settings.SilentAim.Enabled = not Settings.SilentAim.Enabled
        SilentAimToggle.BackgroundColor3 = Settings.SilentAim.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        SilentAimToggle.Text = "Silent Aim: " .. (Settings.SilentAim.Enabled and "ON" or "OFF")
    end)

    TeamCheckToggle.MouseButton1Click:Connect(function()
        Settings.SilentAim.TeamCheck = not Settings.SilentAim.TeamCheck
        Settings.TriggerBot.TeamCheck = Settings.SilentAim.TeamCheck
        Settings.Aimbot.TeamCheck = Settings.SilentAim.TeamCheck
        TeamCheckToggle.BackgroundColor3 = Settings.SilentAim.TeamCheck and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(255, 100, 0)
        TeamCheckToggle.Text = "Team Check: " .. (Settings.SilentAim.TeamCheck and "ON" or "OFF")
    end)

    TriggerToggle.MouseButton1Click:Connect(function()
        Settings.TriggerBot.Enabled = not Settings.TriggerBot.Enabled
        TriggerToggle.BackgroundColor3 = Settings.TriggerBot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        TriggerToggle.Text = "Trigger Bot: " .. (Settings.TriggerBot.Enabled and "ON" or "OFF")
    end)

    AimbotToggle.MouseButton1Click:Connect(function()
        Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
        AimbotToggle.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        AimbotToggle.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    end)

    FOVSlider.FocusLost:Connect(function()
        local newFOV = tonumber(FOVSlider.Text)
        if newFOV and newFOV >= 10 and newFOV <= 500 then
            Settings.SilentAim.FOV = newFOV
            FOVText.Text = "FOV: " .. newFOV
            if FOVCircle then
                FOVCircle.Radius = newFOV
            end
        else
            FOVSlider.Text = tostring(Settings.SilentAim.FOV)
        end
    end)

    -- KEYBINDS
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Settings.SilentAim.Keybind then
            Settings.SilentAim.Enabled = not Settings.SilentAim.Enabled
            SilentAimToggle.BackgroundColor3 = Settings.SilentAim.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            SilentAimToggle.Text = "Silent Aim: " .. (Settings.SilentAim.Enabled and "ON" or "OFF")
        elseif input.KeyCode == Settings.TriggerBot.Keybind then
            Settings.TriggerBot.Enabled = not Settings.TriggerBot.Enabled
            TriggerToggle.BackgroundColor3 = Settings.TriggerBot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            TriggerToggle.Text = "Trigger Bot: " .. (Settings.TriggerBot.Enabled and "ON" or "OFF")
        elseif input.KeyCode == Settings.Aimbot.Keybind then
            Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
            AimbotToggle.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            AimbotToggle.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
        elseif input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
            if FOVCircle then
                FOVCircle.Visible = MainFrame.Visible and Settings.Visuals.ShowFOV
            end
        end
    end)

    return ScreenGui
end

-- INICIALIZACE
CreateFOVCircle()
SetupSilentAim()
SetupTriggerBot()
SetupAimbot()
CreateGUI()

print("======================================")
print("Bqos-script!")
print("======================================")
print("SILENT AIM")
print("Trigger Bot")
print("Aimbot")
print("Team Check")
print("======================================")
print("Q = Silent Aim | T = Trigger Bot")
print("E = Aimbot | Insert = Hide Menu")
print("======================================")
