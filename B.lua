-- Bedwars Auto-Apuntado y ESP Script
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Configuración
local settings = {
    aimbot = {
        enabled = false,
        key = Enum.KeyCode.X,  -- Tecla para activar/desactivar el aimbot
        holdKey = Enum.KeyCode.E,  -- Tecla para mantener presionada y usar el aimbot
        teamCheck = true,  -- No apuntar a compañeros de equipo
        smoothness = 0.5,  -- Suavidad del movimiento (0.1-1)
        fov = 250,  -- Campo de visión para el aimbot
        maxDistance = 150,  -- Distancia máxima para apuntar
        targetPart = "HumanoidRootPart",  -- Parte del cuerpo a la que apuntar
        wallCheck = true,  -- Verificar si hay paredes entre el jugador y el objetivo
        swordOnly = true,  -- Solo activar cuando se tiene una espada equipada
        showFOV = true,  -- Mostrar círculo de FOV
        fovColor = Color3.fromRGB(255, 255, 255)  -- Color del círculo FOV
    },
    esp = {
        enabled = false,
        teamCheck = true,  -- No mostrar ESP para compañeros de equipo
        boxEsp = true,  -- Mostrar cajas alrededor de los jugadores
        nameEsp = true,  -- Mostrar nombres de los jugadores
        distanceEsp = true,  -- Mostrar distancia a los jugadores
        tracerEsp = true,  -- Mostrar líneas hacia los jugadores
        healthEsp = true,  -- Mostrar barra de salud
        boxColor = Color3.fromRGB(255, 0, 0),  -- Color de las cajas
        nameColor = Color3.fromRGB(255, 255, 255),  -- Color de los nombres
        distanceColor = Color3.fromRGB(0, 255, 0),  -- Color de la distancia
        tracerColor = Color3.fromRGB(255, 255, 0),  -- Color de las líneas
        healthColor = Color3.fromRGB(0, 255, 0)  -- Color de la barra de salud
    }
}

-- Variables
local espObjects = {}
local fovCircle = nil
local aimTarget = nil
local isAiming = false

-- Crear GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BedwarsAimbotGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- Panel principal
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 250, 0, 300)
main.Position = UDim2.new(0, 20, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

-- Título
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.BorderSizePixel = 0
title.Text = "Bedwars Aimbot & ESP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = main

-- Botón de cierre
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = main

-- Contenedor de opciones
local optionsContainer = Instance.new("Frame")
optionsContainer.Name = "OptionsContainer"
optionsContainer.Size = UDim2.new(1, 0, 1, -30)
optionsContainer.Position = UDim2.new(0, 0, 0, 30)
optionsContainer.BackgroundTransparency = 1
optionsContainer.Parent = main

-- Botón de Aimbot
local aimbotBtn = Instance.new("TextButton")
aimbotBtn.Name = "AimbotBtn"
aimbotBtn.Size = UDim2.new(0.9, 0, 0, 40)
aimbotBtn.Position = UDim2.new(0.05, 0, 0, 10)
aimbotBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
aimbotBtn.BorderSizePixel = 0
aimbotBtn.Text = "Aimbot: OFF"
aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotBtn.TextSize = 16
aimbotBtn.Font = Enum.Font.SourceSansBold
aimbotBtn.Parent = optionsContainer

-- Botón de ESP
local espBtn = Instance.new("TextButton")
espBtn.Name = "ESPBtn"
espBtn.Size = UDim2.new(0.9, 0, 0, 40)
espBtn.Position = UDim2.new(0.05, 0, 0, 60)
espBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
espBtn.BorderSizePixel = 0
espBtn.Text = "ESP: OFF"
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.TextSize = 16
espBtn.Font = Enum.Font.SourceSansBold
espBtn.Parent = optionsContainer

-- Botón de Team Check
local teamCheckBtn = Instance.new("TextButton")
teamCheckBtn.Name = "TeamCheckBtn"
teamCheckBtn.Size = UDim2.new(0.9, 0, 0, 40)
teamCheckBtn.Position = UDim2.new(0.05, 0, 0, 110)
teamCheckBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
teamCheckBtn.BorderSizePixel = 0
teamCheckBtn.Text = "Team Check: ON"
teamCheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teamCheckBtn.TextSize = 16
teamCheckBtn.Font = Enum.Font.SourceSansBold
teamCheckBtn.Parent = optionsContainer

-- Botón de Wall Check
local wallCheckBtn = Instance.new("TextButton")
wallCheckBtn.Name = "WallCheckBtn"
wallCheckBtn.Size = UDim2.new(0.9, 0, 0, 40)
wallCheckBtn.Position = UDim2.new(0.05, 0, 0, 160)
wallCheckBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
wallCheckBtn.BorderSizePixel = 0
wallCheckBtn.Text = "Wall Check: ON"
wallCheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
wallCheckBtn.TextSize = 16
wallCheckBtn.Font = Enum.Font.SourceSansBold
wallCheckBtn.Parent = optionsContainer

-- Botón de Sword Only
local swordOnlyBtn = Instance.new("TextButton")
swordOnlyBtn.Name = "SwordOnlyBtn"
swordOnlyBtn.Size = UDim2.new(0.9, 0, 0, 40)
swordOnlyBtn.Position = UDim2.new(0.05, 0, 0, 210)
swordOnlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
swordOnlyBtn.BorderSizePixel = 0
swordOnlyBtn.Text = "Sword Only: ON"
swordOnlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
swordOnlyBtn.TextSize = 16
swordOnlyBtn.Font = Enum.Font.SourceSansBold
swordOnlyBtn.Parent = optionsContainer

-- Función para verificar si el jugador tiene una espada equipada
local function hasSwordEquipped()
    local character = player.Character
    if not character then return false end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return false end
    
    -- Verificar si el nombre de la herramienta contiene "sword" (puede variar según el juego)
    return tool.Name:lower():find("sword") ~= nil
end

-- Función para verificar si un jugador es un compañero de equipo
local function isTeammate(targetPlayer)
    if not settings.aimbot.teamCheck then return false end
    
    -- Verificar si el jugador tiene el mismo equipo
    return targetPlayer.Team == player.Team
end

-- Función para verificar si hay una pared entre el jugador y el objetivo
local function isWallBetween(targetPosition)
    if not settings.aimbot.wallCheck then return false end
    
    local character = player.Character
    if not character then return true end
    
    local rayOrigin = character.HumanoidRootPart.Position
    local rayDirection = (targetPosition - rayOrigin).Unit
    local rayDistance = (targetPosition - rayOrigin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character, targetPosition.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection * rayDistance, raycastParams)
    return raycastResult ~= nil
end

-- Función para obtener el objetivo más cercano
local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = settings.aimbot.fov
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local mousePos = UIS:GetMouseLocation()
    
    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        if targetPlayer ~= player and not isTeammate(targetPlayer) then
            local targetCharacter = targetPlayer.Character
            if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") and targetCharacter:FindFirstChild("Humanoid") and targetCharacter.Humanoid.Health > 0 then
                local targetPosition = targetCharacter[settings.aimbot.targetPart].Position
                local screenPosition, onScreen = camera:WorldToScreenPoint(targetPosition)
                
                if onScreen then
                    local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude
                    local realDistance = (character.HumanoidRootPart.Position - targetPosition).Magnitude
                    
                    if distance < shortestDistance and realDistance < settings.aimbot.maxDistance and not isWallBetween(targetPosition) then
                        closestPlayer = targetPlayer
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Función para crear el círculo FOV
local function createFOVCircle()
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = settings.aimbot.showFOV and settings.aimbot.enabled
    fovCircle.Radius = settings.aimbot.fov
    fovCircle.Color = settings.aimbot.fovColor
    fovCircle.Thickness = 1
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.NumSides = 60
end

-- Función para actualizar el círculo FOV
local function updateFOVCircle()
    if fovCircle then
        fovCircle.Position = UIS:GetMouseLocation()
        fovCircle.Radius = settings.aimbot.fov
        fovCircle.Visible = settings.aimbot.showFOV and settings.aimbot.enabled
    end
end

-- Función para limpiar el ESP
local function clearESP()
    for _, obj in pairs(espObjects) do
        for _, item in pairs(obj) do
            if item.Remove then
                item:Remove()
            end
        end
    end
    espObjects = {}
end

-- Función para crear ESP para un jugador
local function createESPForPlayer(targetPlayer)
    if targetPlayer == player or (settings.esp.teamCheck and isTeammate(targetPlayer)) then
        return
    end
    
    local targetCharacter = targetPlayer.Character
    if not targetCharacter or not targetCharacter:FindFirstChild("HumanoidRootPart") or not targetCharacter:FindFirstChild("Humanoid") then
        return
    end
    
    local espObject = {}
    
    -- Crear caja ESP
    if settings.esp.boxEsp then
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = settings.esp.boxColor
        box.Thickness = 1
        box.Transparency = 1
        box.Filled = false
        espObject.box = box
    end
    
    -- Crear nombre ESP
    if settings.esp.nameEsp then
        local name = Drawing.new("Text")
        name.Visible = false
        name.Color = settings.esp.nameColor
        name.Size = 18
        name.Center = true
        name.Outline = true
        name.OutlineColor = Color3.new(0, 0, 0)
        name.Text = targetPlayer.Name
        espObject.name = name
    end
    
    -- Crear distancia ESP
    if settings.esp.distanceEsp then
        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Color = settings.esp.distanceColor
        distance.Size = 16
        distance.Center = true
        distance.Outline = true
        distance.OutlineColor = Color3.new(0, 0, 0)
        espObject.distance = distance
    end
    
    -- Crear tracer ESP
    if settings.esp.tracerEsp then
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Color = settings.esp.tracerColor
        tracer.Thickness = 1
        tracer.Transparency = 1
        espObject.tracer = tracer
    end
    
    -- Crear barra de salud ESP
    if settings.esp.healthEsp then
        local healthBar = Drawing.new("Square")
        healthBar.Visible = false
        healthBar.Color = settings.esp.healthColor
        healthBar.Thickness = 1
        healthBar.Transparency = 1
        healthBar.Filled = true
        espObject.healthBar = healthBar
        
        local healthBarOutline = Drawing.new("Square")
        healthBarOutline.Visible = false
        healthBarOutline.Color = Color3.new(0, 0, 0)
        healthBarOutline.Thickness = 1
        healthBarOutline.Transparency = 1
        healthBarOutline.Filled = false
        espObject.healthBarOutline = healthBarOutline
    end
    
    espObjects[targetPlayer] = espObject
end

-- Función para actualizar ESP
local function updateESP()
    for targetPlayer, espObject in pairs(espObjects) do
        local targetCharacter = targetPlayer.Character
        if not targetCharacter or not targetCharacter:FindFirstChild("HumanoidRootPart") or not targetCharacter:FindFirstChild("Humanoid") or targetCharacter.Humanoid.Health <= 0 then
            -- Limpiar ESP si el jugador no es válido
            for _, item in pairs(espObject) do
                if item.Remove then
                    item.Visible = false
                end
            end
            continue
        end
        
        local humanoidRootPart = targetCharacter.HumanoidRootPart
        local humanoid = targetCharacter.Humanoid
        local head = targetCharacter:FindFirstChild("Head")
        
        if not head then continue end
        
        local headPosition = head.Position
        local rootPosition = humanoidRootPart.Position
        local screenHeadPosition, onScreenHead = camera:WorldToScreenPoint(headPosition)
        local screenRootPosition, onScreenRoot = camera:WorldToScreenPoint(rootPosition)
        
        if not onScreenHead and not onScreenRoot then
            -- Ocultar ESP si el jugador no está en pantalla
            for _, item in pairs(espObject) do
                if item.Visible ~= nil then
                    item.Visible = false
                end
            end
            continue
        end
        
        -- Calcular tamaño de la caja ESP
        local distance = (camera.CFrame.Position - rootPosition).Magnitude
        local size = 1 / (distance / 10) * 2
        local boxSize = Vector2.new(size * 900, size * 2000)
        local boxPosition = Vector2.new(screenHeadPosition.X - boxSize.X / 2, screenHeadPosition.Y - boxSize.Y / 2)
        
        -- Actualizar caja ESP
        if espObject.box then
            espObject.box.Size = boxSize
            espObject.box.Position = boxPosition
            espObject.box.Visible = settings.esp.enabled
        end
        
        -- Actualizar nombre ESP
        if espObject.name then
            espObject.name.Position = Vector2.new(screenHeadPosition.X, screenHeadPosition.Y - boxSize.Y / 2 - 15)
            espObject.name.Visible = settings.esp.enabled
        end
        
        -- Actualizar distancia ESP
        if espObject.distance then
            espObject.distance.Text = math.floor(distance) .. " studs"
            espObject.distance.Position = Vector2.new(screenHeadPosition.X, screenHeadPosition.Y + boxSize.Y / 2 + 5)
            espObject.distance.Visible = settings.esp.enabled
        end
        
        -- Actualizar tracer ESP
        if espObject.tracer then
            espObject.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
            espObject.tracer.To = Vector2.new(screenRootPosition.X, screenRootPosition.Y)
            espObject.tracer.Visible = settings.esp.enabled
        end
        
        -- Actualizar barra de salud ESP
        if espObject.healthBar and espObject.healthBarOutline then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = boxSize.Y * healthPercent
            local barPosition = Vector2.new(boxPosition.X - 8, boxPosition.Y + (boxSize.Y - barHeight))
            
            espObject.healthBarOutline.Size = Vector2.new(5, boxSize.Y)
            espObject.healthBarOutline.Position = Vector2.new(boxPosition.X - 8, boxPosition.Y)
            espObject.healthBarOutline.Visible = settings.esp.enabled
            
            espObject.healthBar.Size = Vector2.new(3, barHeight)
            espObject.healthBar.Position = Vector2.new(boxPosition.X - 7, barPosition.Y)
            espObject.healthBar.Color = Color3.fromRGB(
                255 * (1 - healthPercent),
                255 * healthPercent,
                0
            )
            espObject.healthBar.Visible = settings.esp.enabled
        end
    end
end

-- Función para actualizar el aimbot
local function updateAimbot()
    if not settings.aimbot.enabled then return end
    
    -- Verificar si se debe usar el aimbot
    local shouldAim = UIS:IsKeyDown(settings.aimbot.holdKey)
    
    -- Verificar si se requiere tener una espada equipada
    if settings.aimbot.swordOnly and not hasSwordEquipped() then
        shouldAim = false
    end
    
    if shouldAim then
        -- Obtener el objetivo más cercano
        aimTarget = getClosestTarget()
        
        if aimTarget then
            local targetCharacter = aimTarget.Character
            if targetCharacter and targetCharacter:FindFirstChild(settings.aimbot.targetPart) then
                local targetPosition = targetCharacter[settings.aimbot.targetPart].Position
                local screenPosition, onScreen = camera:WorldToScreenPoint(targetPosition)
                
                if onScreen then
                    -- Calcular la posición del mouse
                    local mousePosition = UIS:GetMouseLocation()
                    local moveX = (screenPosition.X - mousePosition.X) * settings.aimbot.smoothness
                    local moveY = (screenPosition.Y - mousePosition.Y) * settings.aimbot.smoothness
                    
                    -- Mover el mouse
                    mousemoverel(moveX, moveY)
                end
            end
        end
    end
end

-- Conectar eventos
closeBtn.MouseButton1Click:Connect(function()
    clearESP()
    if fovCircle then fovCircle:Remove() end
    gui:Destroy()
end)

aimbotBtn.MouseButton1Click:Connect(function()
    settings.aimbot.enabled = not settings.aimbot.enabled
    aimbotBtn.Text = "Aimbot: " .. (settings.aimbot.enabled and "ON" or "OFF")
    
    if settings.aimbot.showFOV then
        if not fovCircle then
            createFOVCircle()
        else
            fovCircle.Visible = settings.aimbot.enabled
        end
    end
end)

espBtn.MouseButton1Click:Connect(function()
    settings.esp.enabled = not settings.esp.enabled
    espBtn.Text = "ESP: " .. (settings.esp.enabled and "ON" or "OFF")
    
    if not settings.esp.enabled then
        clearESP()
    end
end)

teamCheckBtn.MouseButton1Click:Connect(function()
    settings.aimbot.teamCheck = not settings.aimbot.teamCheck
    settings.esp.teamCheck = settings.aimbot.teamCheck
    teamCheckBtn.Text = "Team Check: " .. (settings.aimbot.teamCheck and "ON" or "OFF")
    
    clearESP()
end)

wallCheckBtn.MouseButton1Click:Connect(function()
    settings.aimbot.wallCheck = not settings.aimbot.wallCheck
    wallCheckBtn.Text = "Wall Check: " .. (settings.aimbot.wallCheck and "ON" or "OFF")
end)

swordOnlyBtn.MouseButton1Click:Connect(function()
    settings.aimbot.swordOnly = not settings.aimbot.swordOnly
    swordOnlyBtn.Text = "Sword Only: " .. (settings.aimbot.swordOnly and "ON" or "OFF")
end)

-- Inicializar
createFOVCircle()

-- Bucle principal
RunService.RenderStepped:Connect(function()
    updateFOVCircle()
    
    -- Actualizar ESP
    if settings.esp.enabled then
        -- Crear ESP para nuevos jugadores
        for _, targetPlayer in pairs(game.Players:GetPlayers()) do
            if not espObjects[targetPlayer] then
                createESPForPlayer(targetPlayer)
            end
        end
        
        -- Actualizar ESP existente
        updateESP()
    end
    
    -- Actualizar aimbot
    updateAimbot()
end)

-- Mensaje de inicio
print("Bedwars Aimbot & ESP cargado correctamente!")
