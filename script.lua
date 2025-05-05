-- AOTR Farming Assistant
-- This script helps automate basic farming tasks

local FarmingAssistant = {}

-- Configuration
FarmingAssistant.Settings = {
    FarmingEnabled = true,
    CollectResources = true,
    AutoAttack = true,
    MovementPattern = "circular", -- "circular", "zigzag", "random"
    FarmRadius = 100,
    RefreshRate = 0.5, -- seconds
    TargetPriority = {"Mob1", "Mob2", "Mob3"}
}

-- Main functionality
function FarmingAssistant:Initialize()
    print("Farming Assistant initialized")
    self.Running = true
    self.PlayerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    self.StartPosition = self.PlayerPosition
    
    -- Connect events
    self:ConnectEvents()
    
    -- Start main loop
    spawn(function()
        self:MainLoop()
    end)
end

function FarmingAssistant:ConnectEvents()
    -- Add event connections here
    game.Players.LocalPlayer.Character.Humanoid.Died:Connect(function()
        print("Character died, pausing farming")
        self.Running = false
        wait(5)
        self.Running = true
    end)
end

function FarmingAssistant:MainLoop()
    while wait(self.Settings.RefreshRate) do
        if not self.Running or not self.Settings.FarmingEnabled then continue end
        
        -- Update player position
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            self.PlayerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        end
        
        -- Find targets
        local targets = self:FindTargets()
        
        -- Collect resources if enabled
        if self.Settings.CollectResources then
            self:CollectNearbyResources()
        end
        
        -- Attack enemies if enabled
        if self.Settings.AutoAttack and #targets > 0 then
            self:AttackTarget(targets[1])
        else
            -- Move according to pattern if no targets
            self:MoveInPattern()
        end
    end
end

function FarmingAssistant:FindTargets()
    local targets = {}
    -- Find enemies in workspace
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            -- Check if it's an enemy
            if v:FindFirstChild("EnemyTag") and 
               (v.HumanoidRootPart.Position - self.PlayerPosition).Magnitude < self.Settings.FarmRadius then
                table.insert(targets, v)
            end
        end
    end
    
    -- Sort by priority and distance
    table.sort(targets, function(a, b)
        local priorityA = table.find(self.Settings.TargetPriority, a.Name) or 999
        local priorityB = table.find(self.Settings.TargetPriority, b.Name) or 999
        
        if priorityA == priorityB then
            return (a.HumanoidRootPart.Position - self.PlayerPosition).Magnitude < 
                   (b.HumanoidRootPart.Position - self.PlayerPosition).Magnitude
        end
        
        return priorityA < priorityB
    end)
    
    return targets
end

function FarmingAssistant:AttackTarget(target)
    -- Move to target
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:MoveTo(target.HumanoidRootPart.Position)
    end
    
    -- Use attack ability
    local args = {
        [1] = "Attack",
        [2] = target
    }
    game:GetService("ReplicatedStorage").RemoteEvents.CombatEvent:FireServer(unpack(args))
end

function FarmingAssistant:CollectNearbyResources()
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("ResourceTag") and 
           (v.Position - self.PlayerPosition).Magnitude < 15 then
            local args = {
                [1] = "Collect",
                [2] = v
            }
            game:GetService("ReplicatedStorage").RemoteEvents.ResourceEvent:FireServer(unpack(args))
        end
    end
end

function FarmingAssistant:MoveInPattern()
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local time = tick() % 10
    local targetPos = self.StartPosition
    
    if self.Settings.MovementPattern == "circular" then
        local angle = time * (math.pi/5)
        local offset = Vector3.new(
            math.cos(angle) * self.Settings.FarmRadius / 2,
            0,
            math.sin(angle) * self.Settings.FarmRadius / 2
        )
        targetPos = self.StartPosition + offset
    elseif self.Settings.MovementPattern == "zigzag" then
        local progress = (time % 5) / 5
        local direction = math.floor(time / 5) % 2 == 0 and 1 or -1
        local offset = Vector3.new(
            direction * self.Settings.FarmRadius * (progress - 0.5),
            0,
            progress * self.Settings.FarmRadius
        )
        targetPos = self.StartPosition + offset
    elseif self.Settings.MovementPattern == "random" then
        if time % 3 < 0.1 then
            self.RandomTarget = self.StartPosition + Vector3.new(
                (math.random() - 0.5) * self.Settings.FarmRadius,
                0,
                (math.random() - 0.5) * self.Settings.FarmRadius
            )
        end
        targetPos = self.RandomTarget or self.StartPosition
    end
    
    humanoid:MoveTo(targetPos)
end

function FarmingAssistant:Toggle()
    self.Settings.FarmingEnabled = not self.Settings.FarmingEnabled
    print("Farming " .. (self.Settings.FarmingEnabled and "enabled" or "disabled"))
end

-- UI Components (Simple)
function FarmingAssistant:CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FarmingAssistantUI"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 100)
    Frame.Position = UDim2.new(0.85, -100, 0.1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "Farming Assistant"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Parent = Frame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.5, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Text = "Toggle Farming"
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.TextSize = 16
    ToggleButton.Parent = Frame
    
    ToggleButton.MouseButton1Click:Connect(function()
        self:Toggle()
        ToggleButton.BackgroundColor3 = self.Settings.FarmingEnabled and 
            Color3.fromRGB(65, 155, 65) or Color3.fromRGB(65, 65, 65)
    end)
end

-- Initialize the farming assistant
FarmingAssistant:Initialize()
FarmingAssistant:CreateUI()

return FarmingAssistant
