-- Configurable settings
local Settings = {
AutoFarmEnabled = false,
InstantReloadEnabled = false,
AutoLootEnabled = false,
PrioritizeBossTitans = false,
TargetDistance = 50,
AttackCooldown = 0.4,
StaminaThreshold = 15,
RandomizationFactor = 0.2,
FakeInputChance = 0.15,
GearReloadInterval = 0.08,
LootRange = 30,
KillCount = 0}
-- Anti-cheat bypass variables
local lastActionTime = tick()
local actionInterval = 0.08
local spoofedClientId = HttpService:GenerateGuid(false)

-- GUI Setup
local function createGui()
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name ="AOTRUltimateHub"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 500)
Frame.Position = UDim2.new(0.5, -175, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text ="AOTR Ultimate Raid Farm Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextScaled = true
Title.Parent = Frame

local KillCounter = Instance.new("TextLabel")
KillCounter.Size = UDim2.new(1, 0, 0, 30)
KillCounter.Position = UDim2.new(0, 0, 0, 40)
KillCounter.Text ="Kills: 0"
KillCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
KillCounter.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KillCounter.TextScaled = true
KillCounter.Parent = Frame

local function createToggle(name, callback)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0, #Frame:GetChildren() * 45)
ToggleButton.Text = name .. ": OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Parent = Frame

local state = false
ToggleButton.MouseButton1Click:Connect(function()
state = not state
ToggleButton.Text = name .. (state and": ON" or": OFF")
callback(state)
end)
end

local function createSlider(name, min, max, default, callback)
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.9, 0, 0, 40)
SliderFrame.Position = UDim2.new(0.05, 0, 0, #Frame:GetChildren() * 45)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderFrame.Parent = Frame

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 0, 20)
Label.Text = name .. ":" .. default
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.BackgroundTransparency = 1
Label.TextScaled = true
Label.Parent = SliderFrame

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(1, 0, 0, 20)
Slider.Position = UDim2.new(0, 0, 0, 20)
Slider.Text = ""
Slider.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
Slider.Parent = SliderFrame

local value = default
Slider.MouseButton1Down:Connect(function()
local mouseConn
mouseConn = UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement then
local relativeX = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
value = min + (max - min) * relativeX
Label.Text = name .. ":" .. math.floor(value* 10) / 10
callback(value)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
mouseConn:Disconnect()
end
end)
end)
end

createToggle("Auto-Farm", function(state) Settings.AutoFarmEnabled = state end)
createToggle("Instant Reload", function(state) Settings.InstantReloadEnabled = state end)
createToggle("Auto-Loot", function(state) Settings.AutoLootEnabled = state end)
createToggle("Prioritize Boss Titans", function(state) Settings.PrioritizeBossTitans = state end)
createSlider("Target Distance", 10, 100, Settings.TargetDistance, function(value) Settings.TargetDistance = value end)
createSlider("Attack Cooldown", 0.1, 1, Settings.AttackCooldown, function(value) Settings.AttackCooldown = value end)
createSlider("Stamina Threshold", 10, 50, Settings.StaminaThreshold, function(value) Settings.StaminaThreshold = value end)
createSlider("Loot Range", 10, 50, Settings.LootRange, function(value) Settings.LootRange = value end)

return ScreenGui, KillCounter
end

-- Create GUI and get kill counter reference
local gui, KillCounter = createGui()

-- Find titans
local function findNearestTitan()
local closestTitan = nil
local closestDistance = math.huge
local playerPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position

for_, object in pairs(workspace:GetDescendants()) do
if object:IsA("Model") and object:FindFirstChild("TitanNape") then
local nape = object.TitanNape
local distance = (nape.Position - playerPos).Magnitude
local isBoss = object:FindFirstChild("BossTag") -- Hypothetical boss identifier
if (Settings.PrioritizeBossTitans and isBoss) or (not Settings.PrioritizeBossTitans and distance < closestDistance and distance < Settings.TargetDistance) then
closestTitan = nape
closestDistance = distance
end
end
end
return closestTitan
end

-- Move to target
local function moveToTarget(targetPos)
local character = LocalPlayer.Character
if not character or not character.HumanoidRootPart then return end

local humanoid = character.Humanoid
local rootPart = character.HumanoidRootPart
local direction = (targetPos - rootPart.Position).Unit

local randomOffset = Vector3.new(
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor),
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor),
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor)
)
humanoid:Move(direction + randomOffset, true)

local grappleEvent = ReplicatedStorage:FindFirstChild("GrappleEvent")
if grappleEvent and tick() - lastActionTime > actionInterval then
grappleEvent:FireServer(targetPos, { clientId = spoofedClientId })
lastActionTime = tick()
end
end

-- Attack titan nape
local function attackNape(titanNape)
local attackRemote = ReplicatedStorage:FindFirstChild("AttackRemote")
if attackRemote and tick() - lastActionTime > actionInterval then
attackRemote:FireServer(titanNape, { clientId = spoofedClientId })
lastActionTime = tick()
-- Increment kill count (assuming kill confirmation)
Settings.KillCount = Settings.KillCount + 1
KillCounter.Text ="Kills:" .. Settings.KillCount
end
end

-- Auto-loot
local function autoLoot()
if not Settings.AutoFarmEnabled then return end
local playerPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position
for_, object in pairs(workspace:GetDescendants()) do
if object:IsA("Part") and object.Name =="LootDrop" then -- Hypothetical loot identifier
local distance = (object.Position - playerPos).Magnitude
if distance < Settings.LootRange then
local lootRemote = ReplicatedStorage:FindFirstChild("LootRemote") -- Replace with actual remote
if lootRemote and tick() - lastActionTime > actionInterval then
lootRemote:FireServer(object, { clientId = spoofedClientId })
lastActionTime = tick()
end
end
end
end
end

-- Check stamina
local function checkStamina()
local stamina = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("StaminaValue")
return stamina and stamina.Value > Settings.StaminaThreshold
end

-- Simulate fake input
local function simulateFakeInput()
if math.random() < Settings.FakeInputChance then
local fakeMousePos = Vector2.new(
math.random(0, UserInputService:GetMouseLocation().X),
math.random(0, UserInputService:GetMouseLocation().Y)
)
local mouseEvent = ReplicatedStorage:FindFirstChild("MouseEvent")
if mouseEvent then
mouseEvent:FireServer(fakeMousePos)
end
end
end

-- Instant gear reload
local function instantGearReload()
if not Settings.InstantReloadEnabled then return end
local gearReloadRemote = ReplicatedStorage:FindFirstChild("GearReloadRemote")
local gasValue = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("GasValue")
if gearReloadRemote and tick() - lastActionTime > actionInterval then
gearReloadRemote:FireServer({ clientId = spoofedClientId, gasAmount = 100 })
lastActionTime = tick()
end
if gasValue then
gasValue.Value = 100
end
end

-- Hook FireServer
local oldFireServer
oldFireServer = hookfunction(game:GetService("ReplicatedStorage").FireServer, function(remote, ...)
local args = {...}
if type(args[ трагитани1]) =="Vector3" then
args[1] = args[1] + Vector3.new(
math.random(-0.1, 0.1),
math.random(-0.1, 0.1),
math.random(-0.1, 0.1)
)
end
args[#args + 1] = { clientId = spoofedClientId, timestamp = tick() + math.random(-0.05, 0.05) }
return oldFireServer(remote, unpack(args))
end)

-- Main loop
RunService.Heartbeat:Connect(function()
if not Settings.AutoFarmEnabled then return end
if not LocalPlayer.Character or not LocalPlayer.Character.Humanoid then return end
if not checkStamina() then return end

simulateFakeInput()
instantGearReload()
autoLoot()

local titanNape = findNearestTitan()
if titanNape then
moveToTarget(titanNape.Position)
attackNape(titanNape)
wait(Settings.AttackCooldown + math.random(0, Settings.RandomizationFactor))
end
end)

print("AOTR Ultimate Raid Farm Hub Loaded")-- Configurable settings
local Settings = {
AutoFarmEnabled = false,
InstantReloadEnabled = false,
AutoLootEnabled = false,
PrioritizeBossTitans = false,
TargetDistance = 50,
AttackCooldown = 0.4,
StaminaThreshold = 15,
RandomizationFactor = 0.2,
FakeInputChance = 0.15,
GearReloadInterval = 0.08,
LootRange = 30,
KillCount = 0}
-- Anti-cheat bypass variables
local lastActionTime = tick()
local actionInterval = 0.08
local spoofedClientId = HttpService:GenerateGuid(false)

-- GUI Setup
local function createGui()
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name ="AOTRUltimateHub"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 500)
Frame.Position = UDim2.new(0.5, -175, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text ="AOTR Ultimate Raid Farm Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextScaled = true
Title.Parent = Frame

local KillCounter = Instance.new("TextLabel")
KillCounter.Size = UDim2.new(1, 0, 0, 30)
KillCounter.Position = UDim2.new(0, 0, 0, 40)
KillCounter.Text ="Kills: 0"
KillCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
KillCounter.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KillCounter.TextScaled = true
KillCounter.Parent = Frame

local function createToggle(name, callback)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0, #Frame:GetChildren() * 45)
ToggleButton.Text = name .. ": OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Parent = Frame

local state = false
ToggleButton.MouseButton1Click:Connect(function()
state = not state
ToggleButton.Text = name .. (state and": ON" or": OFF")
callback(state)
end)
end

local function createSlider(name, min, max, default, callback)
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.9, 0, 0, 40)
SliderFrame.Position = UDim2.new(0.05, 0, 0, #Frame:GetChildren() * 45)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderFrame.Parent = Frame

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 0, 20)
Label.Text = name .. ":" .. default
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.BackgroundTransparency = 1
Label.TextScaled = true
Label.Parent = SliderFrame

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(1, 0, 0, 20)
Slider.Position = UDim2.new(0, 0, 0, 20)
Slider.Text = ""
Slider.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
Slider.Parent = SliderFrame

local value = default
Slider.MouseButton1Down:Connect(function()
local mouseConn
mouseConn = UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement then
local relativeX = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
value = min + (max - min) * relativeX
Label.Text = name .. ":" .. math.floor(value* 10) / 10
callback(value)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
mouseConn:Disconnect()
end
end)
end)
end

createToggle("Auto-Farm", function(state) Settings.AutoFarmEnabled = state end)
createToggle("Instant Reload", function(state) Settings.InstantReloadEnabled = state end)
createToggle("Auto-Loot", function(state) Settings.AutoLootEnabled = state end)
createToggle("Prioritize Boss Titans", function(state) Settings.PrioritizeBossTitans = state end)
createSlider("Target Distance", 10, 100, Settings.TargetDistance, function(value) Settings.TargetDistance = value end)
createSlider("Attack Cooldown", 0.1, 1, Settings.AttackCooldown, function(value) Settings.AttackCooldown = value end)
createSlider("Stamina Threshold", 10, 50, Settings.StaminaThreshold, function(value) Settings.StaminaThreshold = value end)
createSlider("Loot Range", 10, 50, Settings.LootRange, function(value) Settings.LootRange = value end)

return ScreenGui, KillCounter
end

-- Create GUI and get kill counter reference
local gui, KillCounter = createGui()

-- Find titans
local function findNearestTitan()
local closestTitan = nil
local closestDistance = math.huge
local playerPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position

for_, object in pairs(workspace:GetDescendants()) do
if object:IsA("Model") and object:FindFirstChild("TitanNape") then
local nape = object.TitanNape
local distance = (nape.Position - playerPos).Magnitude
local isBoss = object:FindFirstChild("BossTag") -- Hypothetical boss identifier
if (Settings.PrioritizeBossTitans and isBoss) or (not Settings.PrioritizeBossTitans and distance < closestDistance and distance < Settings.TargetDistance) then
closestTitan = nape
closestDistance = distance
end
end
end
return closestTitan
end

-- Move to target
local function moveToTarget(targetPos)
local character = LocalPlayer.Character
if not character or not character.HumanoidRootPart then return end

local humanoid = character.Humanoid
local rootPart = character.HumanoidRootPart
local direction = (targetPos - rootPart.Position).Unit

local randomOffset = Vector3.new(
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor),
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor),
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor)
)
humanoid:Move(direction + randomOffset, true)

local grappleEvent = ReplicatedStorage:FindFirstChild("GrappleEvent")
if grappleEvent and tick() - lastActionTime > actionInterval then
grappleEvent:FireServer(targetPos, { clientId = spoofedClientId })
lastActionTime = tick()
end
end

-- Attack titan nape
local function attackNape(titanNape)
local attackRemote = ReplicatedStorage:FindFirstChild("AttackRemote")
if attackRemote and tick() - lastActionTime > actionInterval then
attackRemote:FireServer(titanNape, { clientId = spoofedClientId })
lastActionTime = tick()
-- Increment kill count (assuming kill confirmation)
Settings.KillCount = Settings.KillCount + 1
KillCounter.Text ="Kills:" .. Settings.KillCount
end
end

-- Auto-loot
local function autoLoot()
if not Settings.AutoFarmEnabled then return end
local playerPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position
for_, object in pairs(workspace:GetDescendants()) do
if object:IsA("Part") and object.Name =="LootDrop" then -- Hypothetical loot identifier
local distance = (object.Position - playerPos).Magnitude
if distance < Settings.LootRange then
local lootRemote = ReplicatedStorage:FindFirstChild("LootRemote") -- Replace with actual remote
if lootRemote and tick() - lastActionTime > actionInterval then
lootRemote:FireServer(object, { clientId = spoofedClientId })
lastActionTime = tick()
end
end
end
end
end

-- Check stamina
local function checkStamina()
local stamina = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("StaminaValue")
return stamina and stamina.Value > Settings.StaminaThreshold
end

-- Simulate fake input
local function simulateFakeInput()
if math.random() < Settings.FakeInputChance then
local fakeMousePos = Vector2.new(
math.random(0, UserInputService:GetMouseLocation().X),
math.random(0, UserInputService:GetMouseLocation().Y)
)
local mouseEvent = ReplicatedStorage:FindFirstChild("MouseEvent")
if mouseEvent then
mouseEvent:FireServer(fakeMousePos)
end
end
end

-- Instant gear reload
local function instantGearReload()
if not Settings.InstantReloadEnabled then return end
local gearReloadRemote = ReplicatedStorage:FindFirstChild("GearReloadRemote")
local gasValue = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("GasValue")
if gearReloadRemote and tick() - lastActionTime > actionInterval then
gearReloadRemote:FireServer({ clientId = spoofedClientId, gasAmount = 100 })
lastActionTime = tick()
end
if gasValue then
gasValue.Value = 100
end
end

-- Hook FireServer
local oldFireServer
oldFireServer = hookfunction(game:GetService("ReplicatedStorage").FireServer, function(remote, ...)
local args = {...}
if type(args[ трагитани1]) =="Vector3" then
args[1] = args[1] + Vector3.new(
math.random(-0.1, 0.1),
math.random(-0.1, 0.1),
math.random(-0.1, 0.1)
)
end
args[#args + 1] = { clientId = spoofedClientId, timestamp = tick() + math.random(-0.05, 0.05) }
return oldFireServer(remote, unpack(args))
end)

-- Main loop
RunService.Heartbeat:Connect(function()
if not Settings.AutoFarmEnabled then return end
if not LocalPlayer.Character or not LocalPlayer.Character.Humanoid then return end
if not checkStamina() then return end

simulateFakeInput()
instantGearReload()
autoLoot()

local titanNape = findNearestTitan()
if titanNape then
moveToTarget(titanNape.Position)
attackNape(titanNape)
wait(Settings.AttackCooldown + math.random(0, Settings.RandomizationFactor))
end
end)

print("AOTR Ultimate Raid Farm Hub Loaded")-- Configurable settings
local Settings = {
AutoFarmEnabled = false,
InstantReloadEnabled = false,
AutoLootEnabled = false,
PrioritizeBossTitans = false,
TargetDistance = 50,
AttackCooldown = 0.4,
StaminaThreshold = 15,
RandomizationFactor = 0.2,
FakeInputChance = 0.15,
GearReloadInterval = 0.08,
LootRange = 30,
KillCount = 0}
-- Anti-cheat bypass variables
local lastActionTime = tick()
local actionInterval = 0.08
local spoofedClientId = HttpService:GenerateGuid(false)

-- GUI Setup
local function createGui()
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name ="AOTRUltimateHub"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 500)
Frame.Position = UDim2.new(0.5, -175, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text ="AOTR Ultimate Raid Farm Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextScaled = true
Title.Parent = Frame

local KillCounter = Instance.new("TextLabel")
KillCounter.Size = UDim2.new(1, 0, 0, 30)
KillCounter.Position = UDim2.new(0, 0, 0, 40)
KillCounter.Text ="Kills: 0"
KillCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
KillCounter.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KillCounter.TextScaled = true
KillCounter.Parent = Frame

local function createToggle(name, callback)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0, #Frame:GetChildren() * 45)
ToggleButton.Text = name .. ": OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Parent = Frame

local state = false
ToggleButton.MouseButton1Click:Connect(function()
state = not state
ToggleButton.Text = name .. (state and": ON" or": OFF")
callback(state)
end)
end

local function createSlider(name, min, max, default, callback)
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.9, 0, 0, 40)
SliderFrame.Position = UDim2.new(0.05, 0, 0, #Frame:GetChildren() * 45)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderFrame.Parent = Frame

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 0, 20)
Label.Text = name .. ":" .. default
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.BackgroundTransparency = 1
Label.TextScaled = true
Label.Parent = SliderFrame

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(1, 0, 0, 20)
Slider.Position = UDim2.new(0, 0, 0, 20)
Slider.Text = ""
Slider.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
Slider.Parent = SliderFrame

local value = default
Slider.MouseButton1Down:Connect(function()
local mouseConn
mouseConn = UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement then
local relativeX = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
value = min + (max - min) * relativeX
Label.Text = name .. ":" .. math.floor(value* 10) / 10
callback(value)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
mouseConn:Disconnect()
end
end)
end)
end

createToggle("Auto-Farm", function(state) Settings.AutoFarmEnabled = state end)
createToggle("Instant Reload", function(state) Settings.InstantReloadEnabled = state end)
createToggle("Auto-Loot", function(state) Settings.AutoLootEnabled = state end)
createToggle("Prioritize Boss Titans", function(state) Settings.PrioritizeBossTitans = state end)
createSlider("Target Distance", 10, 100, Settings.TargetDistance, function(value) Settings.TargetDistance = value end)
createSlider("Attack Cooldown", 0.1, 1, Settings.AttackCooldown, function(value) Settings.AttackCooldown = value end)
createSlider("Stamina Threshold", 10, 50, Settings.StaminaThreshold, function(value) Settings.StaminaThreshold = value end)
createSlider("Loot Range", 10, 50, Settings.LootRange, function(value) Settings.LootRange = value end)

return ScreenGui, KillCounter
end

-- Create GUI and get kill counter reference
local gui, KillCounter = createGui()

-- Find titans
local function findNearestTitan()
local closestTitan = nil
local closestDistance = math.huge
local playerPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position

for_, object in pairs(workspace:GetDescendants()) do
if object:IsA("Model") and object:FindFirstChild("TitanNape") then
local nape = object.TitanNape
local distance = (nape.Position - playerPos).Magnitude
local isBoss = object:FindFirstChild("BossTag") -- Hypothetical boss identifier
if (Settings.PrioritizeBossTitans and isBoss) or (not Settings.PrioritizeBossTitans and distance < closestDistance and distance < Settings.TargetDistance) then
closestTitan = nape
closestDistance = distance
end
end
end
return closestTitan
end

-- Move to target
local function moveToTarget(targetPos)
local character = LocalPlayer.Character
if not character or not character.HumanoidRootPart then return end

local humanoid = character.Humanoid
local rootPart = character.HumanoidRootPart
local direction = (targetPos - rootPart.Position).Unit

local randomOffset = Vector3.new(
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor),
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor),
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor)
)
humanoid:Move(direction + randomOffset, true)

local grappleEvent = ReplicatedStorage:FindFirstChild("GrappleEvent")
if grappleEvent and tick() - lastActionTime > actionInterval then
grappleEvent:FireServer(targetPos, { clientId = spoofedClientId })
lastActionTime = tick()
end
end

-- Attack titan nape
local function attackNape(titanNape)
local attackRemote = ReplicatedStorage:FindFirstChild("AttackRemote")
if attackRemote and tick() - lastActionTime > actionInterval then
attackRemote:FireServer(titanNape, { clientId = spoofedClientId })
lastActionTime = tick()
-- Increment kill count (assuming kill confirmation)
Settings.KillCount = Settings.KillCount + 1
KillCounter.Text ="Kills:" .. Settings.KillCount
end
end

-- Auto-loot
local function autoLoot()
if not Settings.AutoFarmEnabled then return end
local playerPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position
for_, object in pairs(workspace:GetDescendants()) do
if object:IsA("Part") and object.Name =="LootDrop" then -- Hypothetical loot identifier
local distance = (object.Position - playerPos).Magnitude
if distance < Settings.LootRange then
local lootRemote = ReplicatedStorage:FindFirstChild("LootRemote") -- Replace with actual remote
if lootRemote and tick() - lastActionTime > actionInterval then
lootRemote:FireServer(object, { clientId = spoofedClientId })
lastActionTime = tick()
end
end
end
end
end

-- Check stamina
local function checkStamina()
local stamina = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("StaminaValue")
return stamina and stamina.Value > Settings.StaminaThreshold
end

-- Simulate fake input
local function simulateFakeInput()
if math.random() < Settings.FakeInputChance then
local fakeMousePos = Vector2.new(
math.random(0, UserInputService:GetMouseLocation().X),
math.random(0, UserInputService:GetMouseLocation().Y)
)
local mouseEvent = ReplicatedStorage:FindFirstChild("MouseEvent")
if mouseEvent then
mouseEvent:FireServer(fakeMousePos)
end
end
end

-- Instant gear reload
local function instantGearReload()
if not Settings.InstantReloadEnabled then return end
local gearReloadRemote = ReplicatedStorage:FindFirstChild("GearReloadRemote")
local gasValue = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("GasValue")
if gearReloadRemote and tick() - lastActionTime > actionInterval then
gearReloadRemote:FireServer({ clientId = spoofedClientId, gasAmount = 100 })
lastActionTime = tick()
end
if gasValue then
gasValue.Value = 100
end
end

-- Hook FireServer
local oldFireServer
oldFireServer = hookfunction(game:GetService("ReplicatedStorage").FireServer, function(remote, ...)
local args = {...}
if type(args[ трагитани1]) =="Vector3" then
args[1] = args[1] + Vector3.new(
math.random(-0.1, 0.1),
math.random(-0.1, 0.1),
math.random(-0.1, 0.1)
)
end
args[#args + 1] = { clientId = spoofedClientId, timestamp = tick() + math.random(-0.05, 0.05) }
return oldFireServer(remote, unpack(args))
end)

-- Main loop
RunService.Heartbeat:Connect(function()
if not Settings.AutoFarmEnabled then return end
if not LocalPlayer.Character or not LocalPlayer.Character.Humanoid then return end
if not checkStamina() then return end

simulateFakeInput()
instantGearReload()
autoLoot()

local titanNape = findNearestTitan()
if titanNape then
moveToTarget(titanNape.Position)
attackNape(titanNape)
wait(Settings.AttackCooldown + math.random(0, Settings.RandomizationFactor))
end
end)

print("AOTR Ultimate Raid Farm Hub Loaded")-- Configurable settings
local Settings = {
AutoFarmEnabled = false,
InstantReloadEnabled = false,
AutoLootEnabled = false,
PrioritizeBossTitans = false,
TargetDistance = 50,
AttackCooldown = 0.4,
StaminaThreshold = 15,
RandomizationFactor = 0.2,
FakeInputChance = 0.15,
GearReloadInterval = 0.08,
LootRange = 30,
KillCount = 0}
-- Anti-cheat bypass variables
local lastActionTime = tick()
local actionInterval = 0.08
local spoofedClientId = HttpService:GenerateGuid(false)

-- GUI Setup
local function createGui()
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name ="AOTRUltimateHub"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 500)
Frame.Position = UDim2.new(0.5, -175, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text ="AOTR Ultimate Raid Farm Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextScaled = true
Title.Parent = Frame

local KillCounter = Instance.new("TextLabel")
KillCounter.Size = UDim2.new(1, 0, 0, 30)
KillCounter.Position = UDim2.new(0, 0, 0, 40)
KillCounter.Text ="Kills: 0"
KillCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
KillCounter.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KillCounter.TextScaled = true
KillCounter.Parent = Frame

local function createToggle(name, callback)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0, #Frame:GetChildren() * 45)
ToggleButton.Text = name .. ": OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Parent = Frame

local state = false
ToggleButton.MouseButton1Click:Connect(function()
state = not state
ToggleButton.Text = name .. (state and": ON" or": OFF")
callback(state)
end)
end

local function createSlider(name, min, max, default, callback)
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.9, 0, 0, 40)
SliderFrame.Position = UDim2.new(0.05, 0, 0, #Frame:GetChildren() * 45)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderFrame.Parent = Frame

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 0, 20)
Label.Text = name .. ":" .. default
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.BackgroundTransparency = 1
Label.TextScaled = true
Label.Parent = SliderFrame

local Slider = Instance.new("TextButton")
Slider.Size = UDim2.new(1, 0, 0, 20)
Slider.Position = UDim2.new(0, 0, 0, 20)
Slider.Text = ""
Slider.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
Slider.Parent = SliderFrame

local value = default
Slider.MouseButton1Down:Connect(function()
local mouseConn
mouseConn = UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement then
local relativeX = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
value = min + (max - min) * relativeX
Label.Text = name .. ":" .. math.floor(value* 10) / 10
callback(value)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
mouseConn:Disconnect()
end
end)
end)
end

createToggle("Auto-Farm", function(state) Settings.AutoFarmEnabled = state end)
createToggle("Instant Reload", function(state) Settings.InstantReloadEnabled = state end)
createToggle("Auto-Loot", function(state) Settings.AutoLootEnabled = state end)
createToggle("Prioritize Boss Titans", function(state) Settings.PrioritizeBossTitans = state end)
createSlider("Target Distance", 10, 100, Settings.TargetDistance, function(value) Settings.TargetDistance = value end)
createSlider("Attack Cooldown", 0.1, 1, Settings.AttackCooldown, function(value) Settings.AttackCooldown = value end)
createSlider("Stamina Threshold", 10, 50, Settings.StaminaThreshold, function(value) Settings.StaminaThreshold = value end)
createSlider("Loot Range", 10, 50, Settings.LootRange, function(value) Settings.LootRange = value end)

return ScreenGui, KillCounter
end

-- Create GUI and get kill counter reference
local gui, KillCounter = createGui()

-- Find titans
local function findNearestTitan()
local closestTitan = nil
local closestDistance = math.huge
local playerPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position

for_, object in pairs(workspace:GetDescendants()) do
if object:IsA("Model") and object:FindFirstChild("TitanNape") then
local nape = object.TitanNape
local distance = (nape.Position - playerPos).Magnitude
local isBoss = object:FindFirstChild("BossTag") -- Hypothetical boss identifier
if (Settings.PrioritizeBossTitans and isBoss) or (not Settings.PrioritizeBossTitans and distance < closestDistance and distance < Settings.TargetDistance) then
closestTitan = nape
closestDistance = distance
end
end
end
return closestTitan
end

-- Move to target
local function moveToTarget(targetPos)
local character = LocalPlayer.Character
if not character or not character.HumanoidRootPart then return end

local humanoid = character.Humanoid
local rootPart = character.HumanoidRootPart
local direction = (targetPos - rootPart.Position).Unit

local randomOffset = Vector3.new(
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor),
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor),
math.random(-Settings.RandomizationFactor, Settings.RandomizationFactor)
)
humanoid:Move(direction + randomOffset, true)

local grappleEvent = ReplicatedStorage:FindFirstChild("GrappleEvent")
if grappleEvent and tick() - lastActionTime > actionInterval then
grappleEvent:FireServer(targetPos, { clientId = spoofedClientId })
lastActionTime = tick()
end
end

-- Attack titan nape
local function attackNape(titanNape)
local attackRemote = ReplicatedStorage:FindFirstChild("AttackRemote")
if attackRemote and tick() - lastActionTime > actionInterval then
attackRemote:FireServer(titanNape, { clientId = spoofedClientId })
lastActionTime = tick()
-- Increment kill count (assuming kill confirmation)
Settings.KillCount = Settings.KillCount + 1
KillCounter.Text ="Kills:" .. Settings.KillCount
end
end

-- Auto-loot
local function autoLoot()
if not Settings.AutoFarmEnabled then return end
local playerPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position
for_, object in pairs(workspace:GetDescendants()) do
if object:IsA("Part") and object.Name =="LootDrop" then -- Hypothetical loot identifier
local distance = (object.Position - playerPos).Magnitude
if distance < Settings.LootRange then
local lootRemote = ReplicatedStorage:FindFirstChild("LootRemote") -- Replace with actual remote
if lootRemote and tick() - lastActionTime > actionInterval then
lootRemote:FireServer(object, { clientId = spoofedClientId })
lastActionTime = tick()
end
end
end
end
end

-- Check stamina
local function checkStamina()
local stamina = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("StaminaValue")
return stamina and stamina.Value > Settings.StaminaThreshold
end

-- Simulate fake input
local function simulateFakeInput()
if math.random() < Settings.FakeInputChance then
local fakeMousePos = Vector2.new(
math.random(0, UserInputService:GetMouseLocation().X),
math.random(0, UserInputService:GetMouseLocation().Y)
)
local mouseEvent = ReplicatedStorage:FindFirstChild("MouseEvent")
if mouseEvent then
mouseEvent:FireServer(fakeMousePos)
end
end
end

-- Instant gear reload
local function instantGearReload()
if not Settings.InstantReloadEnabled then return end
local gearReloadRemote = ReplicatedStorage:FindFirstChild("GearReloadRemote")
local gasValue = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("GasValue")
if gearReloadRemote and tick() - lastActionTime > actionInterval then
gearReloadRemote:FireServer({ clientId = spoofedClientId, gasAmount = 100 })
lastActionTime = tick()
end
if gasValue then
gasValue.Value = 100
end
end

-- Hook FireServer
local oldFireServer
oldFireServer = hookfunction(game:GetService("ReplicatedStorage").FireServer, function(remote, ...)
local args = {...}
if type(args[ трагитани1]) =="Vector3" then
args[1] = args[1] + Vector3.new(
math.random(-0.1, 0.1),
math.random(-0.1, 0.1),
math.random(-0.1, 0.1)
)
end
args[#args + 1] = { clientId = spoofedClientId, timestamp = tick() + math.random(-0.05, 0.05) }
return oldFireServer(remote, unpack(args))
end)

-- Main loop
RunService.Heartbeat:Connect(function()
if not Settings.AutoFarmEnabled then return end
if not LocalPlayer.Character or not LocalPlayer.Character.Humanoid then return end
if not checkStamina() then return end

simulateFakeInput()
instantGearReload()
autoLoot()

local titanNape = findNearestTitan()
if titanNape then
moveToTarget(titanNape.Position)
attackNape(titanNape)
wait(Settings.AttackCooldown + math.random(0, Settings.RandomizationFactor))
end
end)

print("AOTR Ultimate Raid Farm Hub Loaded")
