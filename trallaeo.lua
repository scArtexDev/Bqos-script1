-- Bqos Scripts - Ultimate Arsenal Cheat Suite
-- Silent Aim + Trigger Bot + Aimbot + Team Check

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Configuration
local Settings = {
    SilentAim = {
        Enabled = false,
        TeamCheck = true,
        FOV = 80,
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
    }
}

-- Variables
local Connections = {}
local Target

-- Function to get best target
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
                
                -- Calculate screen position
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

-- SILENT AIM FUNCTION
local function SetupSilentAim()
    -- Hook shooting function
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
                    -- Modify arguments for headshot
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

-- TRIGGER BOT FUNCTION
local function SetupTriggerBot()
    Connections.TriggerBot = RunService.Heartbeat:Connect(function()
        if not Settings.TriggerBot.Enabled then return end
        
        local target = GetBestTarget()
        if target then
            -- Team Check for Trigger Bot
            local player = Players:GetPlayerFromCharacter(target)
            if Settings.TriggerBot.TeamCheck and player and player.Team == LocalPlayer.Team then
                return
            end
            
            -- Simulate shooting
            wait(Settings.TriggerBot.Delay)
            local virtualInput = game:GetService("VirtualInputManager")
            virtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            wait(0.01)
            virtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end)
end

-- AIMBOT FUNCTION
local function SetupAimbot()
    Connections.Aimbot = RunService.Heartbeat:Connect(function()
        if not Settings.Aimbot.Enabled then return end
        
        local target = GetBestTarget()
        if target then
            -- Team Check for Aimbot
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

-- GUI MENU (FIXED VERSION)
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BqosScripts_Menu"
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 350)
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.Text = "BQOS SCRIPTS v1.0"
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
    SilentAimToggle.Size = UDim2.new(0.4, 0, 0, 30)
    SilentAimToggle.Position = UDim2.new(0.05, 0, 0.16, 0)
    SilentAimToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    SilentAimToggle.Text = "Silent Aim: OFF"
    SilentAimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentAimToggle.TextSize = 12
    SilentAimToggle.Font = Enum.Font.Gotham
    SilentAimToggle.Parent = MainFrame

    local TeamCheckToggle = Instance.new("TextButton")
    TeamCheckToggle.Size = UDim2.new(0.4, 0, 0, 30)
    TeamCheckToggle.Position = UDim2.new(0.55, 0, 0.16, 0)
    TeamCheckToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    TeamCheckToggle.Text = "Team Check: ON"
    TeamCheckToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeamCheckToggle.TextSize = 12
    TeamCheckToggle.Font = Enum.Font.Gotham
    TeamCheckToggle.Parent = MainFrame

    -- FOV SETTINGS
    local FOVText = Instance.new("TextLabel")
    FOVText.Size = UDim2.new(0.4, 0, 0, 20)
    FOVText.Position = UDim2.new(0.05, 0, 0.25, 0)
    FOVText.BackgroundTransparency = 1
    FOVText.Text = "FOV: " .. Settings.SilentAim.FOV
    FOVText.TextColor3 = Color3.fromRGB(255, 255, 255)
    FOVText.TextSize = 12
    FOVText.Font = Enum.Font.Gotham
    FOVText.Parent = MainFrame

    local FOVSlider = Instance.new("TextBox")
    FOVSlider.Size = UDim2.new(0.4, 0, 0, 25)
    FOVSlider.Position = UDim2.new(0.55, 0, 0.25, 0)
    FOVSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    FOVSlider.Text = tostring(Settings.SilentAim.FOV)
    FOVSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    FOVSlider.TextSize = 12
    FOVSlider.PlaceholderText = "Enter FOV"
    FOVSlider.Parent = MainFrame

    -- TRIGGER BOT SECTION
    local TriggerSection = Instance.new("TextLabel")
    TriggerSection.Size = UDim2.new(0.9, 0, 0, 20)
    TriggerSection.Position = UDim2.new(0.05, 0, 0.35, 0)
    TriggerSection.BackgroundTransparency = 1
    TriggerSection.Text = "TRIGGER BOT"
    TriggerSection.TextColor3 = Color3.fromRGB(255, 255, 0)
    TriggerSection.TextSize = 14
    TriggerSection.Font = Enum.Font.GothamBold
    TriggerSection.Parent = MainFrame

    local TriggerToggle = Instance.new("TextButton")
    TriggerToggle.Size = UDim2.new(0.8, 0, 0, 30)
    TriggerToggle.Position = UDim2.new(0.1, 0, 0.41, 0)
    TriggerToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    TriggerToggle.Text = "Trigger Bot: OFF"
    TriggerToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TriggerToggle.TextSize = 12
    TriggerToggle.Font = Enum.Font.Gotham
    TriggerToggle.Parent = MainFrame

    -- AIMBOT SECTION
    local AimbotSection = Instance.new("TextLabel")
    AimbotSection.Size = UDim2.new(0.9, 0, 0, 20)
    AimbotSection.Position = UDim2.new(0.05, 0, 0.52, 0)
    AimbotSection.BackgroundTransparency = 1
    AimbotSection.Text = "AIMBOT"
    AimbotSection.TextColor3 = Color3.fromRGB(255, 0, 255)
    AimbotSection.TextSize = 14
    AimbotSection.Font = Enum.Font.GothamBold
    AimbotSection.Parent = MainFrame

    local AimbotToggle = Instance.new("TextButton")
    AimbotToggle.Size = UDim2.new(0.8, 0, 0, 30)
    AimbotToggle.Position = UDim2.new(0.1, 0, 0.58, 0)
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    AimbotToggle.Text = "Aimbot: OFF"
    AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotToggle.TextSize = 12
    AimbotToggle.Font = Enum.Font.Gotham
    AimbotToggle.Parent = MainFrame

    -- KEYBINDS SECTION
    local KeybindsSection = Instance.new("TextLabel")
    KeybindsSection.Size = UDim2.new(0.9, 0, 0, 20)
    KeybindsSection.Position = UDim2.new(0.05, 0, 0.69, 0)
    KeybindsSection.BackgroundTransparency = 1
    KeybindsSection.Text = "KEYBINDS"
    KeybindsSection.TextColor3 = Color3.fromRGB(0, 255, 0)
    KeybindsSection.TextSize = 14
    KeybindsSection.Font = Enum.Font.GothamBold
    KeybindsSection.Parent = MainFrame

    local KeybindsText = Instance.new("TextLabel")
    KeybindsText.Size = UDim2.new(0.9, 0, 0, 60)
    KeybindsText.Position = UDim2.new(0.05, 0, 0.75, 0)
    KeybindsText.BackgroundTransparency = 1
    KeybindsText.Text = "Q = Silent Aim\nT = Trigger Bot\nE = Aimbot\nINSERT = Hide Menu"
    KeybindsText.TextColor3 = Color3.fromRGB(200, 200, 200)
    KeybindsText.TextSize = 11
    KeybindsText.TextWrapped = true
    KeybindsText.Font = Enum.Font.Gotham
    KeybindsText.Parent = MainFrame

    -- BUTTON FUNCTIONS
    SilentAimToggle.MouseButton1Click:Connect(function()
        Settings.SilentAim.Enabled = not Settings.SilentAim.Enabled
        SilentAimToggle.BackgroundColor3 = Settings.SilentAim.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        SilentAimToggle.Text = "Silent Aim: " .. (Settings.SilentAim.Enabled and "ON" or "OFF")
        print("Silent Aim: " .. (Settings.SilentAim.Enabled and "ENABLED" or "DISABLED"))
    end)

    TeamCheckToggle.MouseButton1Click:Connect(function()
        Settings.SilentAim.TeamCheck = not Settings.SilentAim.TeamCheck
        Settings.TriggerBot.TeamCheck = Settings.SilentAim.TeamCheck
        Settings.Aimbot.TeamCheck = Settings.SilentAim.TeamCheck
        TeamCheckToggle.BackgroundColor3 = Settings.SilentAim.TeamCheck and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(255, 100, 0)
        TeamCheckToggle.Text = "Team Check: " .. (Settings.SilentAim.TeamCheck and "ON" or "OFF")
        print("Team Check: " .. (Settings.SilentAim.TeamCheck and "ENABLED" or "DISABLED"))
    end)

    TriggerToggle.MouseButton1Click:Connect(function()
        Settings.TriggerBot.Enabled = not Settings.TriggerBot.Enabled
        TriggerToggle.BackgroundColor3 = Settings.TriggerBot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        TriggerToggle.Text = "Trigger Bot: " .. (Settings.TriggerBot.Enabled and "ON" or "OFF")
        print("Trigger Bot: " .. (Settings.TriggerBot.Enabled and "ENABLED" or "DISABLED"))
    end)

    AimbotToggle.MouseButton1Click:Connect(function()
        Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
        AimbotToggle.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        AimbotToggle.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
        print("Aimbot: " .. (Settings.Aimbot.Enabled and "ENABLED" or "DISABLED"))
    end)

    FOVSlider.FocusLost:Connect(function()
        local newFOV = tonumber(FOVSlider.Text)
        if newFOV and newFOV >= 10 and newFOV <= 500 then
            Settings.SilentAim.FOV = newFOV
            FOVText.Text = "FOV: " .. newFOV
            print("FOV updated to: " .. newFOV)
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
            print("Silent Aim: " .. (Settings.SilentAim.Enabled and "ENABLED" or "DISABLED"))
        elseif input.KeyCode == Settings.TriggerBot.Keybind then
            Settings.TriggerBot.Enabled = not Settings.TriggerBot.Enabled
            TriggerToggle.BackgroundColor3 = Settings.TriggerBot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            TriggerToggle.Text = "Trigger Bot: " .. (Settings.TriggerBot.Enabled and "ON" or "OFF")
            print("Trigger Bot: " .. (Settings.TriggerBot.Enabled and "ENABLED" or "DISABLED"))
        elseif input.KeyCode == Settings.Aimbot.Keybind then
            Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
            AimbotToggle.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            AimbotToggle.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
            print("Aimbot: " .. (Settings.Aimbot.Enabled and "ENABLED" or "DISABLED"))
        elseif input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
            print("Menu: " .. (MainFrame.Visible and "VISIBLE" or "HIDDEN"))
        end
    end)

    return ScreenGui
end

-- INITIALIZATION
SetupSilentAim()
SetupTriggerBot()
SetupAimbot()
CreateGUI()

print("======================================")
print("BQOS SCRIPTS!")
print("======================================")
print("Silent Aim: Shoot near = hit head")
print("Trigger Bot: Auto shoot when aiming at enemy")
print("Aimbot: Automatic aiming")
print("Team Check: Ignore teammates")
print("======================================")
print("Q = Silent Aim | T = Trigger Bot")
print("E = Aimbot | INSERT = Hide Menu")
print("======================================")
