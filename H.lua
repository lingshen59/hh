-- Compact Hide and Seek Script with ESP, TP, Speed, and Minimizable GUI
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local espEnabled, speedMult, espObjs = false, 1, {}
local nameLabels = {}

-- Create GUI elements
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size, main.Position = UDim2.new(0, 200, 0, 250), UDim2.new(0.5, -100, 0.5, -125)
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

-- Player selection dropdown for teleport
local playerDropdown = Instance.new("Frame", main)
playerDropdown.Size, playerDropdown.Position = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 75)
playerDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
playerDropdown.BorderSizePixel = 0
playerDropdown.ClipsDescendants = true

local selectedPlayer = Instance.new("TextLabel", playerDropdown)
selectedPlayer.Size = UDim2.new(1, -30, 1, 0)
selectedPlayer.Position = UDim2.new(0, 5, 0, 0)
selectedPlayer.BackgroundTransparency = 1
selectedPlayer.Text = "Select Player"
selectedPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedPlayer.TextSize = 14
selectedPlayer.TextXAlignment = Enum.TextXAlignment.Left

local dropdownBtn = Instance.new("TextButton", playerDropdown)
dropdownBtn.Size = UDim2.new(0, 25, 0, 25)
dropdownBtn.Position = UDim2.new(1, -25, 0, 2)
dropdownBtn.BackgroundTransparency = 1
dropdownBtn.Text = "▼"
dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownBtn.TextSize = 14

local playerList = Instance.new("ScrollingFrame", main)
playerList.Size = UDim2.new(0.9, 0, 0, 100)
playerList.Position = UDim2.new(0.05, 0, 0, 110)
playerList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.Visible = false
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout", playerList)
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Padding = UDim.new(0, 2)

local tpBtn = Instance.new("TextButton", main)
tpBtn.Size, tpBtn.Position = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 215)
tpBtn.BackgroundColor3, tpBtn.Text = Color3.fromRGB(60, 60, 60), "Teleport"
tpBtn.TextColor3, tpBtn.TextSize = Color3.fromRGB(255, 255, 255), 14

local spdBtn = Instance.new("TextButton", main)
spdBtn.Size, spdBtn.Position = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 175)
spdBtn.BackgroundColor3, spdBtn.Text = Color3.fromRGB(60, 60, 60), "Speed: 1x"
spdBtn.TextColor3, spdBtn.TextSize = Color3.fromRGB(255, 255, 255), 14

local minBtn = Instance.new("TextButton", gui)
minBtn.Size, minBtn.Position = UDim2.new(0, 40, 0, 40), UDim2.new(0, 10, 0, 10)
minBtn.BackgroundColor3, minBtn.Text = Color3.fromRGB(50, 50, 50), "+"
minBtn.TextColor3, minBtn.TextSize = Color3.fromRGB(255, 255, 255), 20
minBtn.Visible, minBtn.Draggable = false, true

-- Function to update player list
local selectedPlayerObject = nil
local function updatePlayerList()
    -- Clear existing buttons
    for _, child in pairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Add player buttons
    local ySize = 0
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton", playerList)
            btn.Size = UDim2.new(1, -8, 0, 25)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = p.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14
            btn.BorderSizePixel = 0
            
            btn.MouseButton1Click:Connect(function()
                selectedPlayer.Text = p.Name
                selectedPlayerObject = p
                playerList.Visible = false
            end)
            
            ySize = ySize + 27
        end
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, ySize)
end

-- Toggle dropdown
dropdownBtn.MouseButton1Click:Connect(function()
    updatePlayerList()
    playerList.Visible = not playerList.Visible
    dropdownBtn.Text = playerList.Visible and "▲" or "▼"
end)

-- ESP function with names
local function refreshESP()
    -- Clear existing ESP
    for _, obj in pairs(espObjs) do if obj and obj.Parent then obj:Destroy() end end
    espObjs = {}
    
    -- Clear name labels
    for _, label in pairs(nameLabels) do if label and label.Parent then label:Destroy() end end
    nameLabels = {}
    
    if espEnabled then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                -- Add highlight
                local h = Instance.new("Highlight")
                h.FillColor, h.OutlineColor = Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0)
                h.FillTransparency, h.Parent = 0.5, p.Character
                table.insert(espObjs, h)
                
                -- Add name label
                if p.Character:FindFirstChild("Head") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.Adornee = p.Character.Head
                    billboard.AlwaysOnTop = true
                    
                    local nameLabel = Instance.new("TextLabel", billboard)
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = p.Name
                    nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    nameLabel.TextSize = 20
                    nameLabel.Font = Enum.Font.SourceSansBold
                    
                    billboard.Parent = game.CoreGui
                    table.insert(nameLabels, billboard)
                end
            end
        end
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    refreshESP()
end

-- TP function to selected player
local function teleport()
    if selectedPlayerObject and selectedPlayerObject.Character and 
       selectedPlayerObject.Character:FindFirstChild("HumanoidRootPart") and
       player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = selectedPlayerObject.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    else
        -- Fallback to nearest player if none selected
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
mini.MouseButton1Click:Connect(function() 
    main.Visible = false
    minBtn.Visible = true
    playerList.Visible = false
end)

minBtn.MouseButton1Click:Connect(function() 
    main.Visible = true
    minBtn.Visible = false
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
    for _, obj in pairs(espObjs) do if obj and obj.Parent then obj:Destroy() end end
    for _, label in pairs(nameLabels) do if label and label.Parent then label:Destroy() end end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Apply speed when character spawns
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = 16 * speedMult
end)

-- Auto-refresh ESP and player list every 5 seconds
spawn(function()
    while wait(5) do
        if gui.Parent then  -- Check if GUI still exists
            refreshESP()    -- Refresh ESP to detect new players
            if playerList.Visible then
                updatePlayerList() -- Update player list if visible
            end
        else
            break           -- Stop the loop if GUI is destroyed
        end
    end
end)

-- Initial player list update
updatePlayerList()
