-- Compact Hide and Seek Script with ESP, TP, Speed, and Minimizable GUI
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local espEnabled, speedMult, espObjs = false, 1, {}
local nameLabels = {}
local defaultWalkSpeed = 16 -- Guardar la velocidad predeterminada

-- Create GUI elements
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

-- Hacer el menú más grande (70% de la pantalla)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.7, 0, 0.7, 0)
main.Position = UDim2.new(0.15, 0, 0.15, 0)
main.BackgroundColor3, main.BorderSizePixel = Color3.fromRGB(30, 30, 30), 0
main.Active, main.Draggable = true, true

local title = Instance.new("TextButton", main) -- Cambiar a TextButton para minimizar al hacer clic
title.Size, title.Position = UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Hide and Seek"
title.TextColor3, title.TextSize = Color3.fromRGB(255, 255, 255), 20
title.Font = Enum.Font.SourceSansBold

-- Quitar el botón de minimizar ya que ahora se minimiza haciendo clic en el título
local close = Instance.new("TextButton", title)
close.Size, close.Position = UDim2.new(0, 40, 0, 40), UDim2.new(1, -40, 0, 0)
close.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
close.Text = "X"
close.TextColor3, close.TextSize = Color3.fromRGB(255, 255, 255), 20

-- Resto de elementos GUI (ajustados para el nuevo tamaño)
local espBtn = Instance.new("TextButton", main)
espBtn.Size = UDim2.new(0.4, 0, 0, 50)
espBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
espBtn.BackgroundColor3, espBtn.Text = Color3.fromRGB(60, 60, 60), "ESP: OFF"
espBtn.TextColor3, espBtn.TextSize = Color3.fromRGB(255, 255, 255), 18

-- Player selection dropdown for teleport
local playerDropdown = Instance.new("Frame", main)
playerDropdown.Size = UDim2.new(0.4, 0, 0, 50)
playerDropdown.Position = UDim2.new(0.55, 0, 0.15, 0)
playerDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
playerDropdown.BorderSizePixel = 0
playerDropdown.ClipsDescendants = true

local selectedPlayer = Instance.new("TextLabel", playerDropdown)
selectedPlayer.Size = UDim2.new(1, -50, 1, 0)
selectedPlayer.Position = UDim2.new(0, 10, 0, 0)
selectedPlayer.BackgroundTransparency = 1
selectedPlayer.Text = "Select Player"
selectedPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedPlayer.TextSize = 18
selectedPlayer.TextXAlignment = Enum.TextXAlignment.Left

local dropdownBtn = Instance.new("TextButton", playerDropdown)
dropdownBtn.Size = UDim2.new(0, 40, 0, 40)
dropdownBtn.Position = UDim2.new(1, -45, 0, 5)
dropdownBtn.BackgroundTransparency = 1
dropdownBtn.Text = "▼"
dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownBtn.TextSize = 18

local playerList = Instance.new("ScrollingFrame", main)
playerList.Size = UDim2.new(0.4, 0, 0.3, 0)
playerList.Position = UDim2.new(0.55, 0, 0.25, 0)
playerList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 6
playerList.Visible = false
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout", playerList)
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Padding = UDim.new(0, 4)

local tpBtn = Instance.new("TextButton", main)
tpBtn.Size = UDim2.new(0.4, 0, 0, 50)
tpBtn.Position = UDim2.new(0.55, 0, 0.6, 0)
tpBtn.BackgroundColor3, tpBtn.Text = Color3.fromRGB(60, 60, 60), "Teleport"
tpBtn.TextColor3, tpBtn.TextSize = Color3.fromRGB(255, 255, 255), 18

-- Modificar el botón de velocidad para incluir opción de reset
local spdBtn = Instance.new("TextButton", main)
spdBtn.Size = UDim2.new(0.4, 0, 0, 50)
spdBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
spdBtn.BackgroundColor3, spdBtn.Text = Color3.fromRGB(60, 60, 60), "Speed: Normal"
spdBtn.TextColor3, spdBtn.TextSize = Color3.fromRGB(255, 255, 255), 18

-- Añadir botón de vuelo
local flyBtn = Instance.new("TextButton", main)
flyBtn.Size = UDim2.new(0.4, 0, 0, 50)
flyBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flyBtn.Text = "Fly: OFF"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.TextSize = 18

-- Variables para el vuelo
local flying = false
local flySpeed = 1
local bodyVelocity = nil
local bodyGyro = nil
local jumpHeight = 10 -- Altura del salto en vuelo
local canJump = true -- Variable para controlar si puede saltar

-- Función para activar/desactivar vuelo
local function toggleFly()
    flying = not flying
    flyBtn.Text = flying and "Fly: ON" or "Fly: OFF"
    
    if flying then
        -- Activar vuelo
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        -- Desactivar gravedad
        if char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
        
        -- Crear objetos de vuelo
        bodyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        bodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart)
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.CFrame = char.HumanoidRootPart.CFrame
        
        -- Iniciar bucle de vuelo
        spawn(function()
            local isJumping = false
            local jumpStart = 0
            local spacePressed = false
            
            while flying and char and char:FindFirstChild("HumanoidRootPart") and bodyVelocity and bodyGyro do
                local camera = workspace.CurrentCamera
                local moveDir = Vector3.new(0, 0, 0)
                
                -- Controles de vuelo
                if UIS:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + camera.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - camera.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - camera.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + camera.CFrame.RightVector
                end
                
                -- Control de salto mejorado para múltiples saltos
                if UIS:IsKeyDown(Enum.KeyCode.Space) then
                    if not spacePressed then
                        spacePressed = true
                        -- Iniciar un nuevo salto cada vez que se presiona espacio
                        isJumping = true
                        jumpStart = tick()
                    end
                    
                    if isJumping then
                        -- Calcular la fuerza del salto basado en el tiempo
                        local jumpTime = tick() - jumpStart
                        local jumpForce = math.min(jumpHeight, jumpHeight * (1 - jumpTime/0.5))
                        
                        if jumpForce > 0 then
                            moveDir = moveDir + Vector3.new(0, jumpForce, 0)
                        else
                            isJumping = false
                        end
                    end
                else
                    spacePressed = false
                    -- Permitir un nuevo salto cuando se suelta la tecla espacio
                    if not isJumping then
                        canJump = true
                    end
                end
                
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDir = moveDir - Vector3.new(0, 5, 0)
                end
                
                -- Normalizar y aplicar velocidad
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * (defaultWalkSpeed * 2 * flySpeed)
                end
                
                bodyVelocity.Velocity = moveDir
                bodyGyro.CFrame = CFrame.new(char.HumanoidRootPart.Position, char.HumanoidRootPart.Position + camera.CFrame.LookVector)
                
                wait()
            end
            
            -- Limpiar si el bucle termina
            if bodyVelocity and bodyVelocity.Parent then
                bodyVelocity:Destroy()
            end
            if bodyGyro and bodyGyro.Parent then
                bodyGyro:Destroy()
            end
            
            -- Restaurar estado normal
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    else
        -- Desactivar vuelo
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
        
        -- Restaurar estado normal
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

-- Mejorar el botón minimizado para que sea más visible
local minBtn = Instance.new("TextButton", gui)
minBtn.Size = UDim2.new(0, 60, 0, 60)
minBtn.Position = UDim2.new(0, 20, 0, 20)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minBtn.BorderSizePixel = 2
minBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Text = "+"
minBtn.TextColor3, minBtn.TextSize = Color3.fromRGB(255, 255, 255), 30
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
            btn.Size = UDim2.new(1, -12, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = p.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 18
            btn.BorderSizePixel = 0
            
            btn.MouseButton1Click:Connect(function()
                selectedPlayer.Text = p.Name
                selectedPlayerObject = p
                playerList.Visible = false
                dropdownBtn.Text = "▼"
            end)
            
            ySize = ySize + 44
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

-- Función de velocidad mejorada con ciclo que incluye velocidad normal y del "it"
local function toggleSpeed()
    -- Guardar la velocidad actual si es la primera vez
    if player.Character and player.Character:FindFirstChild("Humanoid") and speedMult == 1 then
        defaultWalkSpeed = player.Character.Humanoid.WalkSpeed
    end
    
    -- Ciclo de velocidades: Normal -> "It" (x1.2) -> x2 -> Normal
    if speedMult == 1 then
        speedMult = 1.2
        spdBtn.Text = "Speed: It"
    elseif speedMult == 1.2 then
        speedMult = 2
        spdBtn.Text = "Speed: x2"
    else
        speedMult = 1
        spdBtn.Text = "Speed: Normal"
    end
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if speedMult == 1 then
            player.Character.Humanoid.WalkSpeed = defaultWalkSpeed
        else
            player.Character.Humanoid.WalkSpeed = defaultWalkSpeed * speedMult
        end
    end
end

-- Connect buttons
espBtn.MouseButton1Click:Connect(toggleESP)
tpBtn.MouseButton1Click:Connect(teleport)
spdBtn.MouseButton1Click:Connect(toggleSpeed)
flyBtn.MouseButton1Click:Connect(toggleFly)  -- Ahora la función ya está definida

-- Mejorar la funcionalidad de minimizar/expandir - ahora usando el título
title.MouseButton1Click:Connect(function() 
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
    
    -- Desactivar vuelo al cerrar
    if flying then
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
    
    -- Restaurar velocidad original al cerrar
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = defaultWalkSpeed
    end
end)

-- Capturar la velocidad original al iniciar y aplicar velocidad cuando el personaje aparece
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    -- Asegurarse de capturar la velocidad original sin modificaciones
    wait(0.5) -- Esperar un momento para que el juego establezca la velocidad base
    defaultWalkSpeed = hum.WalkSpeed -- Guardar la velocidad predeterminada
    
    if speedMult == 1 then
        hum.WalkSpeed = defaultWalkSpeed
    else
        hum.WalkSpeed = defaultWalkSpeed * speedMult
    end
end)

-- Soporte para dispositivos táctiles
local function setupTouchControls()
    local touchStartPos = nil
    local frameStartPos = nil
    local isDragging = false
    
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStartPos = input.Position
            frameStartPos = main.Position
            isDragging = true
        end
    end)
    
    main.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - touchStartPos
            main.Position = UDim2.new(
                frameStartPos.X.Scale, 
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale,
                frameStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    -- También para el botón minimizado
    minBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStartPos = input.Position
            frameStartPos = minBtn.Position
            isDragging = true
        end
    end)
    
    minBtn.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - touchStartPos
            minBtn.Position = UDim2.new(
                frameStartPos.X.Scale, 
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale,
                frameStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    minBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
end

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

-- Capturar la velocidad original al iniciar
if player.Character and player.Character:FindFirstChild("Humanoid") then
    wait(0.5) -- Esperar un momento para que el juego establezca la velocidad base
    defaultWalkSpeed = player.Character.Humanoid.WalkSpeed
end

-- Initial player list update
updatePlayerList()

-- Setup touch controls
setupTouchControls()
