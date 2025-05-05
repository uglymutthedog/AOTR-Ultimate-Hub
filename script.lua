-- AOTR Ultimate Hub - Auto Raid Farm
-- Created by uglymutthedog

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- GUI Variables
local AOTRHub = Instance.new("ScreenGui")
local MainFrame
local Content
local AutoFarmStatus = false
local AutoRaidJoinStatus = false
local AutoAbilityStatus = false
local selectedRaid = "Raid 1"
local NPCFarmStatus = false
local selectedNPC = "Titans"

-- Configuration
local FARM_DISTANCE = 8
local RAID_CHECK_INTERVAL = 5
local HUB_VERSION = "1.0.0"

-- Create GUI Function
local function CreateGUI()
    -- Main GUI Setup
    AOTRHub.Name = "AOTRUltimateHub"
    AOTRHub.ResetOnSpawn = false
    AOTRHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if game:GetService("CoreGui"):FindFirstChild("AOTRUltimateHub") then
        game:GetService("CoreGui"):FindFirstChild("AOTRUltimateHub"):Destroy()
    end
    
    AOTRHub.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = AOTRHub
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "AOTR Ultimate Hub v" .. HUB_VERSION
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -35, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Parent = TitleBar
    
    -- Content Frame
    Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 1, -45)
    Content.Position = UDim2.new(0, 10, 0, 40)
    Content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 5
    Content.ScrollingDirection = Enum.ScrollingDirection.Y
    Content.CanvasSize = UDim2.new(0, 0, 2, 0)
    Content.Parent = MainFrame
    
    -- Create Auto Farm Section
    CreateSection("Auto Farm", 0.05)
    
    -- Auto Farm Toggle
    local AutoFarmToggle = CreateToggle("Auto Farm Enemies", 0.15, function(enabled)
        AutoFarmStatus = enabled
        if enabled then
            StartAutoFarm()
        end
    end)
    
    -- NPC Type Selection
    CreateLabel("Select NPC Type:", 0.25)
    
    local NPCDropdown = Instance.new("Frame")
    NPCDropdown.Name = "NPCDropdown"
    NPCDropdown.Size = UDim2.new(0.8, 0, 0, 30)
    NPCDropdown.Position = UDim2.new(0.1, 0, 0.3, 0)
    NPCDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    NPCDropdown.BorderSizePixel = 0
    NPCDropdown.Parent = Content
    
    local NPCSelection = Instance.new("TextButton")
    NPCSelection.Name = "NPCSelection"
    NPCSelection.Size = UDim2.new(1, 0, 1, 0)
    NPCSelection.BackgroundTransparency = 1
    NPCSelection.Text = selectedNPC
    NPCSelection.TextColor3 = Color3.fromRGB(255, 255, 255)
    NPCSelection.TextSize = 16
    NPCSelection.Font = Enum.Font.SourceSans
    NPCSelection.Parent = NPCDropdown
    
    local NPCTypes = {"Titans", "Hollows", "Bandits", "Marines"}
    local NPCDropdownMenu = Instance.new("Frame")
    NPCDropdownMenu.Name = "NPCDropdownMenu"
    NPCDropdownMenu.Size = UDim2.new(1, 0, 0, #NPCTypes * 30)
    NPCDropdownMenu.Position = UDim2.new(0, 0, 1, 0)
    NPCDropdownMenu.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    NPCDropdownMenu.BorderSizePixel = 0
    NPCDropdownMenu.Visible = false
    NPCDropdownMenu.ZIndex = 5
    NPCDropdownMenu.Parent = NPCDropdown
    
    for i, npcType in ipairs(NPCTypes) do
        local NPCOption = Instance.new("TextButton")
        NPCOption.Name = npcType .. "Option"
        NPCOption.Size = UDim2.new(1, 0, 0, 30)
        NPCOption.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        NPCOption.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        NPCOption.BorderSizePixel = 0
        NPCOption.Text = npcType
        NPCOption.TextColor3 = Color3.fromRGB(255, 255, 255)
        NPCOption.TextSize = 16
        NPCOption.Font = Enum.Font.SourceSans
        NPCOption.ZIndex = 6
        NPCOption.Parent = NPCDropdownMenu
        
        NPCOption.MouseButton1Click:Connect(function()
            selectedNPC = npcType
            NPCSelection.Text = selectedNPC
            NPCDropdownMenu.Visible = false
        end)
    end
    
    NPCSelection.MouseButton1Click:Connect(function()
        NPCDropdownMenu.Visible = not NPCDropdownMenu.Visible
    end)
    
    -- Create Raids Section
    CreateSection("Raid Farm", 0.45)
    
    -- Auto Join Raid Toggle
    local AutoRaidToggle = CreateToggle("Auto Join Raids", 0.55, function(enabled)
        AutoRaidJoinStatus = enabled
        if enabled then
            StartAutoRaidJoin()
        end
    end)
    
    -- Raid Selection
    CreateLabel("Select Raid:", 0.65)
    
    local RaidDropdown = Instance.new("Frame")
    RaidDropdown.Name = "RaidDropdown"
    RaidDropdown.Size = UDim2.new(0.8, 0, 0, 30)
    RaidDropdown.Position = UDim2.new(0.1, 0, 0.7, 0)
    RaidDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    RaidDropdown.BorderSizePixel = 0
    RaidDropdown.Parent = Content
    
    local RaidSelection = Instance.new("TextButton")
    RaidSelection.Name = "RaidSelection"
    RaidSelection.Size = UDim2.new(1, 0, 1, 0)
    RaidSelection.BackgroundTransparency = 1
    RaidSelection.Text = selectedRaid
    RaidSelection.TextColor3 = Color3.fromRGB(255, 255, 255)
    RaidSelection.TextSize = 16
    RaidSelection.Font = Enum.Font.SourceSans
    RaidSelection.Parent = RaidDropdown
    
    local RaidTypes = {"Raid 1", "Raid 2", "Raid 3", "Raid 4"}
    local RaidDropdownMenu = Instance.new("Frame")
    RaidDropdownMenu.Name = "RaidDropdownMenu"
    RaidDropdownMenu.Size = UDim2.new(1, 0, 0, #RaidTypes * 30)
    RaidDropdownMenu.Position = UDim2.new(0, 0, 1, 0)
    RaidDropdownMenu.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    RaidDropdownMenu.BorderSizePixel = 0
    RaidDropdownMenu.Visible = false
    RaidDropdownMenu.ZIndex = 5
    RaidDropdownMenu.Parent = RaidDropdown
    
    for i, raidType in ipairs(RaidTypes) do
        local RaidOption = Instance.new("TextButton")
        RaidOption.Name = raidType .. "Option"
        RaidOption.Size = UDim2.new(1, 0, 0, 30)
        RaidOption.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        RaidOption.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        RaidOption.BorderSizePixel = 0
        RaidOption.Text = raidType
        RaidOption.TextColor3 = Color3.fromRGB(255, 255, 255)
        RaidOption.TextSize = 16
        RaidOption.Font = Enum.Font.SourceSans
        RaidOption.ZIndex = 6
        RaidOption.Parent = RaidDropdownMenu
        
        RaidOption.MouseButton1Click:Connect(function()
            selectedRaid = raidType
            RaidSelection.Text = selectedRaid
            RaidDropdownMenu.Visible = false
        end)
    end
    
    RaidSelection.MouseButton1Click:Connect(function()
        RaidDropdownMenu.Visible = not RaidDropdownMenu.Visible
    end)
    
    -- Auto Ability Section
    CreateSection("Auto Abilities", 0.85)
    
    -- Auto Ability Toggle
    local AutoAbilityToggle = CreateToggle("Auto Use Abilities", 0.95, function(enabled)
        AutoAbilityStatus = enabled
        if enabled then
            StartAutoAbility()
        end
    end)
    
    -- Player Stats Section
    CreateSection("Player Stats", 1.25)
    
    -- Speed
    CreateLabel("Walk Speed:", 1.35)
    
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.Size = UDim2.new(0.8, 0, 0, 20)
    SpeedSlider.Position = UDim2.new(0.1, 0, 1.4, 0)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Parent = Content
    
    local SpeedValue = Instance.new("TextLabel")
    SpeedValue.Name = "SpeedValue"
    SpeedValue.Size = UDim2.new(0, 40, 0, 20)
    SpeedValue.Position = UDim2.new(0.9, 0, 1.4, 0)
    SpeedValue.BackgroundTransparency = 1
    SpeedValue.Text = "16"
    SpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedValue.TextSize = 14
    SpeedValue.Font = Enum.Font.SourceSans
    SpeedValue.Parent = Content
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "SliderButton"
    SliderButton.Size = UDim2.new(0.1, 0, 1, 0)
    SliderButton.Position = UDim2.new(0, 0, 0, 0)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.BorderSizePixel = 0
    SliderButton.Text = ""
    SliderButton.Parent = SpeedSlider
    
    local sliderDragging = false
    
    SliderButton.MouseButton1Down:Connect(function()
        sliderDragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)
    
    SpeedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
            
            local function updateSlider()
                if not sliderDragging then return end
                
                local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                local relativeX = mouse.X - SpeedSlider.AbsolutePosition.X
                local percentage = math.clamp(relativeX / SpeedSlider.AbsoluteSize.X, 0, 1)
                
                SliderButton.Position = UDim2.new(percentage, 0, 0, 0)
                
                local speed = math.floor(16 + (percentage * 84)) -- 16 to 100
                SpeedValue.Text = tostring(speed)
                
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speed
                end
            end
            
            updateSlider()
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not sliderDragging then
                    connection:Disconnect()
                    return
                end
                updateSlider()
            end)
        end
    end)
    
    -- Jump Power
    CreateLabel("Jump Power:", 1.5)
    
    local JumpSlider = Instance.new("Frame")
    JumpSlider.Name = "JumpSlider"
    JumpSlider.Size = UDim2.new(0.8, 0, 0, 20)
    JumpSlider.Position = UDim2.new(0.1, 0, 1.55, 0)
    JumpSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    JumpSlider.BorderSizePixel = 0
    JumpSlider.Parent = Content
    
    local JumpValue = Instance.new("TextLabel")
    JumpValue.Name = "JumpValue"
    JumpValue.Size = UDim2.new(0, 40, 0, 20)
    JumpValue.Position = UDim2.new(0.9, 0, 1.55, 0)
    JumpValue.BackgroundTransparency = 1
    JumpValue.Text = "50"
    JumpValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    JumpValue.TextSize = 14
    JumpValue.Font = Enum.Font.SourceSans
    JumpValue.Parent = Content
    
    local JumpSliderButton = Instance.new("TextButton")
    JumpSliderButton.Name = "JumpSliderButton"
    JumpSliderButton.Size = UDim2.new(0.1, 0, 1, 0)
    JumpSliderButton.Position = UDim2.new(0, 0, 0, 0)
    JumpSliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    JumpSliderButton.BorderSizePixel = 0
    JumpSliderButton.Text = ""
    JumpSliderButton.Parent = JumpSlider
    
    local jumpSliderDragging = false
    
    JumpSliderButton.MouseButton1Down:Connect(function()
        jumpSliderDragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            jumpSliderDragging = false
        end
    end)
    
    JumpSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            jumpSliderDragging = true
            
            local function updateJumpSlider()
                if not jumpSliderDragging then return end
                
                local mouse = game:GetService('Players').LocalPlayer:GetMouse()
                local relativeX = mouse.X - JumpSlider.AbsolutePosition.X
                local percentage = math.clamp(relativeX / JumpSlider.AbsoluteSize.X, 0, 1)
                
                JumpSliderButton.Position = UDim2.new(percentage, 0, 0, 0)
                
                local jump = math.floor(50 + (percentage * 200)) -- 50 to 250
                JumpValue.Text = tostring(jump)
                
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.JumpPower = jump
                end
            end
            
            updateJumpSlider()
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not jumpSliderDragging then
                    connection:Disconnect()
                    return
                end
                updateJumpSlider()
            end)
        end
    end)
    
    -- Extra Features Section
    CreateSection("Extra Features", 1.7)
    
    -- No Fall Damage
    CreateToggle("No Fall Damage", 1.8, function(enabled)
        -- Connect to the appropriate game event for fall damage
        if enabled then
            -- This is a placeholder - you need to find the actual fall damage event
            -- Example: game.ReplicatedStorage.FallDamage.OnClientEvent:Connect(function() return false end)
            print("No Fall Damage Enabled")
            
            -- Hook into character events to prevent fall damage
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        else
            print("No Fall Damage Disabled")
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end)
    
    -- Infinite Stamina
    CreateToggle("Infinite Stamina", 1.9, function(enabled)
        -- This is a placeholder - you need to find the actual stamina system
        print("Infinite Stamina " .. (enabled and "Enabled" or "Disabled"))
        -- Example: if there's a stamina value that gets reduced
        -- game:GetService("RunService").Heartbeat:Connect(function()
        --     if enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stamina") then
        --         LocalPlayer.Character.Stamina.Value = 100
        --     end
        -- end)
    end)
    
    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        AOTRHub:Destroy()
        AutoFarmStatus = false
        AutoRaidJoinStatus = false
        AutoAbilityStatus = false
    end)
    
    -- Toggle GUI visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if input.KeyCode == Enum.KeyCode.RightControl and not processed then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    -- Initial notification
    local notification = Instance.new("Message")
    notification.Text = "AOTR Ultimate Hub Loaded! Press Right Control to toggle GUI."
    notification.Parent = workspace
    game:GetService("Debris"):AddItem(notification, 5)
end

-- Helper Functions
function CreateSection(title, yPos)
    local Section = Instance.new("Frame")
    Section.Name = title .. "Section"
    Section.Size = UDim2.new(0.9, 0, 0, 30)
    Section.Position = UDim2.new(0.05, 0, yPos, 0)
    Section.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Section.BorderSizePixel = 0
    Section.Parent = Content
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "SectionTitle"
    SectionTitle.Size = UDim2.new(1, 0, 1, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionTitle.TextSize = 18
    SectionTitle.Font = Enum.Font.SourceSansBold
    SectionTitle.Parent = Section
    
    return Section
end

function CreateLabel(text, yPos)
    local Label = Instance.new("TextLabel")
    Label.Name = text .. "Label"
    Label.Size = UDim2.new(0.8, 0, 0, 20)
    Label.Position = UDim2.new(0.1, 0, yPos, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 16
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Content
    
    return Label
end

function CreateToggle(text, yPos, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = text .. "Frame"
    ToggleFrame.Size = UDim2.new(0.8, 0, 0, 30)
    ToggleFrame.Position = UDim2.new(0.1, 0, yPos, 0)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = Content
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "ToggleLabel"
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 16
    ToggleLabel.Font = Enum.Font.SourceSans
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 20)
    ToggleButton.Position = UDim2.new(1, -60, 0.5, -10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Parent = ToggleFrame
    
    local enabled = false
    
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
        ToggleButton.Text = enabled and "ON" or "OFF"
        callback(enabled)
    end)
    
    return ToggleButton
end

-- Auto Farm Functions
function GetNearestNPC()
    local nearest = nil
    local minDistance = math.huge
    
    -- Determine which NPCs to target based on selection
    local npcFolder
    if selectedNPC == "Titans" then
        npcFolder = workspace:FindFirstChild("Titans") or workspace:FindFirstChild("NPCs")
    elseif selectedNPC == "Hollows" then
        npcFolder = workspace:FindFirstChild("Hollows") or workspace:FindFirstChild("NPCs")
    elseif selectedNPC == "Bandits" then
        npcFolder = workspace:FindFirstChild("Bandits") or workspace:FindFirstChild("NPCs")
    elseif selectedNPC == "Marines" then
        npcFolder = workspace:FindFirstChild("Marines") or workspace:FindFirstChild("NPCs")
    end
    
    -- If no specific folder found, try generic NPC folders
    if not npcFolder then
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Folder") and (v.Name:find("NPC") or v.Name:find("Enemy") or v.Name:find("Mob")) then
                npcFolder = v
                break
            end
        end
    end
    
    if not npcFolder then return nil end
    
    for _, npc in pairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            local distance = (HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearest = npc
            end
        end
    end
    
    return nearest
end

function StartAutoFarm()
    spawn(function()
        while AutoFarmStatus do
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.CharacterAdded:Wait()
                Character = LocalPlayer.Character
                Humanoid = Character:WaitForChild("Humanoid")
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            end
            
            local target = GetNearestNPC()
            
            if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                -- Teleport behind the NPC
                HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, FARM_DISTANCE)
                
                -- Attack the NPC
                Attack(target)
            end
            
            wait(0.1)
        end
    end)
end

function Attack(target)
    -- Try to find the attack remote or function
    -- This is game-specific and you'll need to update this based on how attacks work in AOTR
    
    -- Attempt 1: Using mouse clicks
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0, 0))
    
    -- Attempt 2: Using attack remotes (placeholder)
    local attackRemote = ReplicatedStorage:FindFirstChild("Attack") or ReplicatedStorage:FindFirstChild("Combat") or ReplicatedStorage:FindFirstChild("CombatRemote")
    if attackRemote and attackRemote:IsA("RemoteEvent") then
        attackRemote:FireServer(target)
    end
    
    -- Attempt 3: Using tools in character
    if Character:FindFirstChildOfClass("Tool") then
        local tool = Character:FindFirstChildOfClass("Tool")
        if tool:FindFirstChild("Attack") and tool.Attack:IsA("RemoteEvent") then
            tool.Attack:FireServer(target)
        end
    end
end

-- Auto Raid Functions
function StartAutoRaidJoin()
    spawn(function()
        while AutoRaidJoinStatus do
            -- Find and attempt to join a raid
            local raidNPC = FindRaidNPC()
            
            if raidNPC then
                -- Teleport to the raid NPC
                HumanoidRootPart.CFrame = raidNPC.HumanoidRootPart.CFrame
                
                -- Attempt to interact with the NPC
                InteractWithRaidNPC(raidNPC)
            end
            
            wait(RAID_CHECK_INTERVAL)
        end
    
