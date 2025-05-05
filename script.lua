-- AOTR Ultimate Hub
-- Created by uglymutthedog

-- Initialization
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Create main GUI
local AOTRHub = Instance.new("ScreenGui")
AOTRHub.Name = "AOTRUltimateHub"
AOTRHub.ResetOnSpawn = false
AOTRHub.Parent = game:GetService("CoreGui")

-- Create main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = AOTRHub

-- Create title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "AOTR Ultimate Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = TitleBar

-- Main content
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Content.BorderSizePixel = 0
Content.Parent = MainFrame

-- Add a simple feature - Speed Hack
local SpeedHackFrame = Instance.new("Frame")
SpeedHackFrame.Name = "SpeedHackFrame"
SpeedHackFrame.Size = UDim2.new(0.9, 0, 0, 80)
SpeedHackFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
SpeedHackFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedHackFrame.BorderSizePixel = 0
SpeedHackFrame.Parent = Content

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, 0, 0, 30)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Player Speed"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 16
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.Parent = SpeedHackFrame

local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Name = "SpeedToggle"
SpeedToggle.Size = UDim2.new(0.3, 0, 0, 30)
SpeedToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedToggle.Text = "Toggle"
SpeedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedToggle.TextSize = 14
SpeedToggle.Font = Enum.Font.SourceSans
SpeedToggle.Parent = SpeedHackFrame

local SpeedValue = Instance.new("TextBox")
SpeedValue.Name = "SpeedValue"
SpeedValue.Size = UDim2.new(0.3, 0, 0, 30)
SpeedValue.Position = UDim2.new(0.6, 0, 0.5, 0)
SpeedValue.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedValue.Text = "16"
SpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedValue.TextSize = 14
SpeedValue.Font = Enum.Font.SourceSans
SpeedValue.Parent = SpeedHackFrame

-- Add another feature - Jump Power
local JumpFrame = Instance.new("Frame")
JumpFrame.Name = "JumpFrame"
JumpFrame.Size = UDim2.new(0.9, 0, 0, 80)
JumpFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
JumpFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
JumpFrame.BorderSizePixel = 0
JumpFrame.Parent = Content

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Name = "JumpLabel"
JumpLabel.Size = UDim2.new(1, 0, 0, 30)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump Power"
JumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpLabel.TextSize = 16
JumpLabel.Font = Enum.Font.SourceSansBold
JumpLabel.Parent = JumpFrame

local JumpToggle = Instance.new("TextButton")
JumpToggle.Name = "JumpToggle"
JumpToggle.Size = UDim2.new(0.3, 0, 0, 30)
JumpToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
JumpToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
JumpToggle.Text = "Toggle"
JumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpToggle.TextSize = 14
JumpToggle.Font = Enum.Font.SourceSans
JumpToggle.Parent = JumpFrame

local JumpValue = Instance.new("TextBox")
JumpValue.Name = "JumpValue"
JumpValue.Size = UDim2.new(0.3, 0, 0, 30)
JumpValue.Position = UDim2.new(0.6, 0, 0.5, 0)
JumpValue.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
JumpValue.Text = "50"
JumpValue.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpValue.TextSize = 14
JumpValue.Font = Enum.Font.SourceSans
JumpValue.Parent = JumpFrame

-- Add another feature - ESP
local ESPFrame = Instance.new("Frame")
ESPFrame.Name = "ESPFrame"
ESPFrame.Size = UDim2.new(0.9, 0, 0, 80)
ESPFrame.Position = UDim2.new(0.05, 0, 0.55, 0)
ESPFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ESPFrame.BorderSizePixel = 0
ESPFrame.Parent = Content

local ESPLabel = Instance.new("TextLabel")
ESPLabel.Name = "ESPLabel"
ESPLabel.Size = UDim2.new(1, 0, 0, 30)
ESPLabel.BackgroundTransparency = 1
ESPLabel.Text = "Player ESP"
ESPLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPLabel.TextSize = 16
ESPLabel.Font = Enum.Font.SourceSansBold
ESPLabel.Parent = ESPFrame

local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(0.6, 0, 0, 30)
ESPToggle.Position = UDim2.new(0.2, 0, 0.5, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ESPToggle.Text = "Toggle ESP"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 14
ESPToggle.Font = Enum.Font.SourceSans
ESPToggle.Parent = ESPFrame

-- Feature implementations
local speedEnabled = false
SpeedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        local speed = tonumber(SpeedValue.Text) or 16
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
    else
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

SpeedValue.FocusLost:Connect(function(enterPressed)
    if enterPressed and speedEnabled then
        local speed = tonumber(SpeedValue.Text) or 16
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
    end
end)

local jumpEnabled = false
JumpToggle.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    if jumpEnabled then
        JumpToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        local jump = tonumber(JumpValue.Text) or 50
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = jump
        end
    else
        JumpToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end
end)

JumpValue.FocusLost:Connect(function(enterPressed)
    if enterPressed and jumpEnabled then
        local jump = tonumber(JumpValue.Text) or 50
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = jump
        end
    end
end)

-- ESP functionality
local espEnabled = false
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local esp = Instance.new("BillboardGui")
    esp.Name = "ESP"
    esp.Size = UDim2.new(0, 200, 0, 50)
    esp.StudsOffset = Vector3.new(0, 3, 0)
    esp.AlwaysOnTop = true
    esp.Adornee = player.Character:WaitForChild("HumanoidRootPart")
    
    local espLabel = Instance.new("TextLabel")
    espLabel.Size = UDim2.new(1, 0, 1, 0)
    espLabel.BackgroundTransparency = 1
    espLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    espLabel.TextStrokeTransparency = 0
    espLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    espLabel.TextSize = 14
    espLabel.Font = Enum.Font.SourceSansBold
    espLabel.Text = player.Name
    espLabel.Parent = esp
    
    espObjects[player.Name] = esp
    esp.Parent = player.Character:WaitForChild("HumanoidRootPart")
    
    player.CharacterRemoving:Connect(function()
        if espObjects[player.Name] then
            espObjects[player.Name]:Destroy()
            espObjects[player.Name] = nil
        end
    end)
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    
    if espEnabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createESP(player)
            end
        end
        
        Players.PlayerAdded:Connect(function(player)
            if espEnabled then
                player.CharacterAdded:Connect(function()
                    if espEnabled then
                        createESP(player)
                    end
                end)
            end
        end)
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        
        for _, esp in pairs(espObjects) do
            if esp then esp:Destroy() end
        end
        espObjects = {}
    end
end)

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    AOTRHub:Destroy()
    
    -- Clean up any loops or connections here
    speedEnabled = false
    jumpEnabled = false
    espEnabled = false
    
    for _, esp in pairs(espObjects) do
        if esp then esp:Destroy() end
    end
    espObjects = {}
end)

-- Notify on load
local notification = Instance.new("Message")
notification.Text = "AOTR Ultimate Hub Loaded! Press K to toggle."
notification.Parent = workspace
game:GetService("Debris"):AddItem(notification, 3)

-- Keybind to toggle the GUI
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.K and not processed then
        guiVisible = not guiVisible
        MainFrame.Visible = guiVisible
    end
end)

print("AOTR Ultimate Hub loaded successfully!")
