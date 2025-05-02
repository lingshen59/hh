-- Compact Hide and Seek Script with ESP, TP, Speed, and Minimizable GUI
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local espEnabled, speedMult, espObjs = false, 1, {}

-- Create GUI elements
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size, main.Position = UDim2.new(0, 200, 0, 180), UDim2.new(0.5, -100, 0.5, -90)
main.BackgroundColor3, main.BorderSizePixel = Color3.fromRGB(30, 30, 30), 0
main.Active, main.Draggable = true, true

local title = Instance.new("TextLabel", main)
title.Size, title.Position = UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 0)
title.BackgroundColor3, title.Text = Color3.fromRGB(50, 50, 50), "Hide and Seek"
title.TextColor3, title.TextSize = Color3.fromRGB(255, 255, 255), 16

local mini = Instance.new("TextButton", title)
mini.Size, mini.Position = UDim2.new(0, 25, 0, 25), UDim2.new(1, -50, 0, 0)
mini.BackgroundTransparency, mini.Text = 1, "-"
mini.TextColor3, mini.TextSize = Color3.fromRGB(255, 255, 255), 20

local close = Instance.new("TextButton", title)
close.Size, close.Position = UDim2.new(0, 25, 0, 25), UDim2.new(1, -25, 0, 0)
close.BackgroundTransparency, close.Text = 1, "X"
close.TextColor3, close.TextSize = Color3.fromRGB(255, 255, 255), 16

local espBtn = Instance.new("TextButton", main)
espBtn.Size, espBtn.Position = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 35)
espBtn.BackgroundColor3, espBtn.Text = Color3.fromRGB(60, 60, 60), "ESP: OFF"
espBtn.TextColor3, espBtn.TextSize = Color3.fromRGB(255, 255, 255), 14

local tpBtn = Instance.new("TextButton", main)
tpBtn.Size, tpBtn.Position = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 75)
tpBtn.BackgroundColor3, tpBtn.Text = Color3.fromRGB(60, 60, 60), "Teleport"
tpBtn.TextColor3, tpBtn.TextSize = Color3.fromRGB(255, 255, 255), 14

local spdBtn = Instance.new("TextButton", main)
spdBtn.Size, spdBtn.Position = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 115)
spdBtn.BackgroundColor3, spdBtn.Text = Color3.fromRGB(60, 60, 60), "Speed: 1x"
spdBtn.TextColor3, spdBtn.TextSize = Color3.fromRGB(255, 255, 255), 14

local minBtn = Instance.new("TextButton", gui)
minBtn.Size, minBtn.Position = UDim2.new(0, 40, 0, 40), UDim2.new(0, 10, 0, 10)
minBtn.BackgroundColor3, minBtn.Text = Color3.fromRGB(50, 50, 50), "+"
minBtn.TextColor3, minBtn.TextSize = Color3.fromRGB(255, 255, 255), 20
minBtn.Visible, minBtn.Draggable = false, true

-- ESP function
local function refreshESP()
    -- Clear existing ESP
    for _, obj in pairs(espObjs) do if obj and obj.Parent then obj:Destroy() end end
    espObjs = {}
    
    if espEnabled then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = Instance.new("Highlight")
                h.FillColor, h.OutlineColor = Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0)
                h.FillTransparency, h.Parent = 0.5, p.Character
                table.insert(espObjs, h)
            end
        end
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    refreshESP()
end

-- TP function
local function teleport()
    local nearest, minDist = nil, math.huge
    local myPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return end
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myPos.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then minDist, nearest = dist, p end
        end
    end
    
    if nearest then
        player.Character.HumanoidRootPart.CFrame = nearest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end

-- Speed function
local function toggleSpeed()
    speedMult = speedMult == 1 and 2 or (speedMult == 2 and 4 or 1)
    spdBtn.Text = "Speed: " .. speedMult .. "x"
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16 * speedMult
    end
end

-- Connect buttons
espBtn.MouseButton1Click:Connect(toggleESP)
tpBtn.MouseButton1Click:Connect(teleport)
spdBtn.MouseButton1Click:Connect(toggleSpeed)

-- Minimize/expand
mini.MouseButton1Click:Connect(function() main.Visible, minBtn.Visible = false, true end)
minBtn.MouseButton1Click:Connect(function() main.Visible, minBtn.Visible = true, false end)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
    for _, obj in pairs(espObjs) do if obj and obj.Parent then obj:Destroy() end end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Apply speed when character spawns
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = 16 * speedMult
end)

-- Auto-refresh ESP and TP every 5 seconds
spawn(function()
    while wait(5) do
        if gui.Parent then  -- Check if GUI still exists
            refreshESP()    -- Refresh ESP to detect new players
        else
            break           -- Stop the loop if GUI is destroyed
        end
    end
end)
