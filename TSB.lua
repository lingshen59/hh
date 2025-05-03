--[[
    The Strongest Battleground - Script para iPad
    Autor: Trae AI
    Versión: 1.0
    
    Características:
    - Auto Farming
    - Auto Combate
    - Teleportación
    - ESP (Visualización de jugadores y objetos)
    - Interfaz táctil optimizada para iPad
    - Administrador de Inventario
]]

-- Configuración Global
local TSB = {
    enabled = true,
    autoFarm = false,
    autoCombat = false,
    esp = false,
    version = "1.0",
    mobileUI = {
        enabled = true,
        scale = 1.2,
        buttonSize = 60,
        transparency = 0.7
    },
    farmSettings = {
        radius = 100,
        targetType = "NPC",
        ignoreList = {},
        priorityList = {}
    },
    combatSettings = {
        useSkill1 = true,
        useSkill2 = true,
        useSkill3 = true,
        useUltimate = true,
        useHealthPotion = true,
        healthPotionThreshold = 0.3 -- 30% de vida
    },
    espSettings = {
        showPlayers = true,
        showNPCs = true,
        showItems = true,
        showDistance = true,
        maxDistance = 1000,
        boxColor = Color3.fromRGB(255, 0, 0),
        textColor = Color3.fromRGB(255, 255, 255)
    }
}

-- Utilidades
local Utils = {}

function Utils.GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function Utils.IsVisible(target)
    local character = game.Players.LocalPlayer.Character
    if not character then return false end
    
    local ray = Ray.new(character.HumanoidRootPart.Position, target.Position - character.HumanoidRootPart.Position)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {character})
    
    return hit and hit:IsDescendantOf(target)
end

function Utils.GetClosestEntity(entityType, maxDistance)
    local character = game.Players.LocalPlayer.Character
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closest = nil
    local minDistance = maxDistance or 9999
    
    local entities = {}
    if entityType == "NPC" then
        entities = workspace.NPCs:GetChildren()
    elseif entityType == "Player" then
        entities = game.Players:GetPlayers()
    end
    
    for _, entity in pairs(entities) do
        if entityType == "Player" and entity == game.Players.LocalPlayer then
            continue
        end
        
        local entityHRP = nil
        if entityType == "NPC" then
            entityHRP = entity:FindFirstChild("HumanoidRootPart")
        else
            if entity.Character then
                entityHRP = entity.Character:FindFirstChild("HumanoidRootPart")
            end
        end
        
        if entityHRP then
            local distance = Utils.GetDistance(hrp.Position, entityHRP.Position)
            if distance < minDistance then
                minDistance = distance
                closest = entity
            end
        end
    end
    
    return closest, minDistance
end

-- Sistema de Auto Farming
local AutoFarm = {}

function AutoFarm.Initialize()
    print("Sistema de Auto Farming inicializado")
end

function AutoFarm.Start()
    if TSB.autoFarm then return end
    
    TSB.autoFarm = true
    print("Auto Farming activado")
    
    -- Iniciar bucle de farming
    coroutine.wrap(function()
        AutoFarm.FarmLoop()
    end)()
end

function AutoFarm.Stop()
    TSB.autoFarm = false
    print("Auto Farming desactivado")
end

function AutoFarm.FarmLoop()
    while TSB.autoFarm and TSB.enabled do
        local target, distance = Utils.GetClosestEntity(TSB.farmSettings.targetType, TSB.farmSettings.radius)
        
        if target then
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local targetHRP = nil
                
                if TSB.farmSettings.targetType == "NPC" then
                    targetHRP = target:FindFirstChild("HumanoidRootPart")
                else
                    if target.Character then
                        targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                    end
                end
                
                if humanoid and targetHRP then
                    -- Moverse hacia el objetivo
                    humanoid:MoveTo(targetHRP.Position)
                    
                    -- Esperar a estar en rango
                    if distance < 10 then
                        -- Atacar al objetivo
                        AutoCombat.AttackTarget(target)
                    end
                end
            end
        else
            -- No hay objetivos, buscar en otra área
            print("No se encontraron objetivos, buscando en otra área...")
        end
        
        wait(0.5) -- Esperar antes de la siguiente iteración
    end
end

-- Sistema de Auto Combate
local AutoCombat = {}

function AutoCombat.Initialize()
    print("Sistema de Auto Combate inicializado")
end

function AutoCombat.Start()
    if TSB.autoCombat then return end
    
    TSB.autoCombat = true
    print("Auto Combate activado")
end

function AutoCombat.Stop()
    TSB.autoCombat = false
    print("Auto Combate desactivado")
end

function AutoCombat.AttackTarget(target)
    if not target or not TSB.autoCombat then return end
    
    -- Seleccionar objetivo
    local targetHRP = nil
    if TSB.farmSettings.targetType == "NPC" then
        targetHRP = target:FindFirstChild("HumanoidRootPart")
    else
        if target.Character then
            targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        end
    end
    
    if not targetHRP then return end
    
    -- Simular clic en el objetivo para seleccionarlo
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(
        targetHRP.Position.X, 
        targetHRP.Position.Y, 
        0, true, game, 1
    )
    
    wait(0.1)
    
    -- Usar habilidades según configuración
    if TSB.combatSettings.useSkill1 then
        -- Simular presionar botón de habilidad 1
        local skill1Button = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("CombatGUI").Skill1
        if skill1Button and skill1Button.Cooldown.Value <= 0 then
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                skill1Button.AbsolutePosition.X + skill1Button.AbsoluteSize.X/2,
                skill1Button.AbsolutePosition.Y + skill1Button.AbsoluteSize.Y/2,
                0, true, game, 1
            )
            wait(0.1)
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                skill1Button.AbsolutePosition.X + skill1Button.AbsoluteSize.X/2,
                skill1Button.AbsolutePosition.Y + skill1Button.AbsoluteSize.Y/2,
                0, false, game, 1
            )
        end
    end
    
    -- Implementar uso de otras habilidades de manera similar
    
    -- Comprobar salud para usar poción
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and TSB.combatSettings.useHealthPotion and 
           humanoid.Health / humanoid.MaxHealth < TSB.combatSettings.healthPotionThreshold then
            -- Simular uso de poción
            local potionButton = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("InventoryGUI").PotionButton
            if potionButton then
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                    potionButton.AbsolutePosition.X + potionButton.AbsoluteSize.X/2,
                    potionButton.AbsolutePosition.Y + potionButton.AbsoluteSize.Y/2,
                    0, true, game, 1
                )
                wait(0.1)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                    potionButton.AbsolutePosition.X + potionButton.AbsoluteSize.X/2,
                    potionButton.AbsolutePosition.Y + potionButton.AbsoluteSize.Y/2,
                    0, false, game, 1
                )
            end
        end
    end
end

-- Sistema de Teleportación
local Teleport = {}

Teleport.Locations = {
    ["Spawn"] = Vector3.new(0, 0, 0),
    ["Dungeon"] = Vector3.new(500, 10, 300),
    ["BossArea"] = Vector3.new(-200, 50, 800),
    ["Shop"] = Vector3.new(100, 0, -150)
}

function Teleport.To(locationName)
    local location = Teleport.Locations[locationName]
    
    if location then
        local character = game.Players.LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Teleportar al jugador
                hrp.CFrame = CFrame.new(location)
                print("Teleportado a: " .. locationName)
            end
        end
    else
        print("Ubicación no encontrada: " .. locationName)
    end
end

function Teleport.AddCustomLocation(name)
    local character = game.Players.LocalPlayer.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            Teleport.Locations[name] = hrp.Position
            print("Nueva ubicación añadida: " .. name)
        end
    end
end

-- Sistema ESP (Extra Sensory Perception)
local ESP = {}

function ESP.Initialize()
    print("Sistema ESP inicializado")
    
    -- Crear contenedor para elementos ESP
    ESP.Container = Instance.new("Folder")
    ESP.Container.Name = "ESPContainer"
    ESP.Container.Parent = game:GetService("CoreGui")
end

function ESP.Toggle()
    TSB.esp = not TSB.esp
    print("ESP " .. (TSB.esp and "activado" or "desactivado"))
    
    if not TSB.esp then
        -- Limpiar elementos ESP
        ESP.Container:ClearAllChildren()
    end
end

function ESP.Update()
    if not TSB.esp then return end
    
    -- Limpiar elementos ESP anteriores
    ESP.Container:ClearAllChildren()
    
    local character = game.Players.LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Dibujar ESP para jugadores
    if TSB.espSettings.showPlayers then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local playerHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if playerHRP then
                    local distance = Utils.GetDistance(hrp.Position, playerHRP.Position)
                    
                    if distance <= TSB.espSettings.maxDistance then
                        ESP.CreateBox(player.Character, TSB.espSettings.boxColor)
                        
                        if TSB.espSettings.showDistance then
                            ESP.CreateLabel(player.Character, player.Name .. " [" .. math.floor(distance) .. "m]", TSB.espSettings.textColor)
                        else
                            ESP.CreateLabel(player.Character, player.Name, TSB.espSettings.textColor)
                        end
                    end
                end
            end
        end
    end
    
    -- Dibujar ESP para NPCs
    if TSB.espSettings.showNPCs then
        for _, npc in pairs(workspace.NPCs:GetChildren()) do
            local npcHRP = npc:FindFirstChild("HumanoidRootPart")
            if npcHRP then
                local distance = Utils.GetDistance(hrp.Position, npcHRP.Position)
                
                if distance <= TSB.espSettings.maxDistance then
                    ESP.CreateBox(npc, Color3.fromRGB(0, 255, 0))
                    
                    if TSB.espSettings.showDistance then
                        ESP.CreateLabel(npc, npc.Name .. " [" .. math.floor(distance) .. "m]", TSB.espSettings.textColor)
                    else
                        ESP.CreateLabel(npc, npc.Name, TSB.espSettings.textColor)
                    end
                end
            end
        end
    end
    
    -- Dibujar ESP para objetos
    if TSB.espSettings.showItems then
        for _, item in pairs(workspace.Items:GetChildren()) do
            local distance = Utils.GetDistance(hrp.Position, item.Position)
            
            if distance <= TSB.espSettings.maxDistance then
                ESP.CreateBox(item, Color3.fromRGB(255, 255, 0))
                
                if TSB.espSettings.showDistance then
                    ESP.CreateLabel(item, item.Name .. " [" .. math.floor(distance) .. "m]", TSB.espSettings.textColor)
                else
                    ESP.CreateLabel(item, item.Name, TSB.espSettings.textColor)
                end
            end
        end
    end
end

function ESP.CreateBox(model, color)
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = model
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = model:GetExtentsSize()
    box.Color3 = color
    box.Transparency = 0.7
    box.Parent = ESP.Container
end

function ESP.CreateLabel(model, text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESP.Container
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard
end

-- Administrador de Inventario
local InventoryManager = {}

function InventoryManager.Initialize()
    print("Administrador de Inventario inicializado")
end

function InventoryManager.AutoSell(itemTypes)
    print("Vendiendo automáticamente items...")
    
    -- Implementar lógica para vender automáticamente
    -- Esto dependerá de la estructura específica del juego
end

function InventoryManager.AutoEquipBest()
    print("Equipando mejores items...")
    
    -- Implementar lógica para equipar automáticamente
    -- Esto dependerá de la estructura específica del juego
end

-- Interfaz de Usuario Móvil
local MobileUI = {}

function MobileUI.Initialize()
    print("Interfaz Móvil inicializada")
    
    -- Crear interfaz principal
    MobileUI.CreateMainUI()
end

function MobileUI.CreateMainUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TSBMobileUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Panel principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainPanel"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = TSB.mobileUI.transparency
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.BackgroundTransparency = 0.5
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "TSB Script v" .. TSB.version
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Botón de cierre
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BackgroundTransparency = 0.3
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)
    
    -- Contenedor de botones
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, 0, 1, -40)
    buttonContainer.Position = UDim2.new(0, 0, 0, 40)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    -- Crear botones de funciones
    MobileUI.CreateButton(buttonContainer, "AutoFarm", "Auto Farm", UDim2.new(0.5, -5, 0, 50), UDim2.new(0, 0, 0, 10), function()
        if TSB.autoFarm then
            AutoFarm.Stop()
        else
            AutoFarm.Start()
        end
    end)
    
    MobileUI.CreateButton(buttonContainer, "AutoCombat", "Auto Combate", UDim2.new(0.5, -5, 0, 50), UDim2.new(0.5, 5, 0, 10), function()
        if TSB.autoCombat then
            AutoCombat.Stop()
        else
            AutoCombat.Start()
        end
    end)
    
    MobileUI.CreateButton(buttonContainer, "ESP", "ESP", UDim2.new(0.5, -5, 0, 50), UDim2.new(0, 0, 0, 70), function()
        ESP.Toggle()
    end)
    
    MobileUI.CreateButton(buttonContainer, "Teleport", "Teleport", UDim2.new(0.5, -5, 0, 50), UDim2.new(0.5, 5, 0, 70), function()
        MobileUI.ShowTeleportMenu()
    end)
    
    MobileUI.CreateButton(buttonContainer, "Inventory", "Inventario", UDim2.new(0.5, -5, 0, 50), UDim2.new(0, 0, 0, 130), function()
        InventoryManager.AutoEquipBest()
    end)
    
    MobileUI.CreateButton(buttonContainer, "Settings", "Ajustes", UDim2.new(0.5, -5, 0, 50), UDim2.new(0.5, 5, 0, 130), function()
        MobileUI.ShowSettingsMenu()
    end)
    
    -- Botón flotante para mostrar/ocultar la interfaz
    local floatingButton = Instance.new("TextButton")
    floatingButton.Name = "FloatingButton"
    floatingButton.Size = UDim2.new(0, 50, 0, 50)
    floatingButton.Position = UDim2.new(0.02, 0, 0.2, 0)
    floatingButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    floatingButton.BackgroundTransparency = 0.3
    floatingButton.BorderSizePixel = 0
    floatingButton.Text = "TSB"
    floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingButton.TextSize = 16
    floatingButton.Font = Enum.Font.SourceSansBold
    floatingButton.Parent = screenGui
    
    floatingButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
end

function MobileUI.CreateButton(parent, name, text, size, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.SourceSansBold
    button.Parent = parent
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

function MobileUI.ShowTeleportMenu()
    -- Implementar menú de teleportación
    local screenGui = game:GetService("CoreGui"):FindFirstChild("TSBMobileUI")
    if not screenGui then return end
    
    -- Eliminar menú anterior si existe
    local oldMenu = screenGui:FindFirstChild("TeleportMenu")
    if oldMenu then oldMenu:Destroy() end
    
    local teleportMenu = Instance.new("Frame")
    teleportMenu.Name = "TeleportMenu"
    teleportMenu.Size = UDim2.new(0, 250, 0, 300)
    teleportMenu.Position = UDim2.new(0.5, -125, 0.5, -150)
    teleportMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    teleportMenu.BackgroundTransparency = 0.2
    teleportMenu.BorderSizePixel = 0
    teleportMenu.Parent = screenGui
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.BackgroundTransparency = 0.5
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Teleportación"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = teleportMenu
    
    -- Botón de cierre
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BackgroundTransparency = 0.3
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = teleportMenu
    
    closeButton.MouseButton1Click:Connect(function()
        teleportMenu:Destroy()
    end)
    
    -- Contenedor de ubicaciones
    local locationsContainer = Instance.new("ScrollingFrame")
    locationsContainer.Name = "LocationsContainer"
    locationsContainer.Size = UDim2.new(1, -20, 1, -100)
    locationsContainer.Position = UDim2.new(0, 10, 0, 50)
    locationsContainer.BackgroundTransparency = 1
    locationsContainer.ScrollBarThickness = 6
    locationsContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Se ajustará automáticamente
    locationsContainer.Parent = teleportMenu
    
    -- Crear botones para cada ubicación
    local yOffset = 0
    for name, _ in pairs(Teleport.Locations) do
        local button = MobileUI.CreateButton(locationsContainer, name, name, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, yOffset), function()
            Teleport.To(name)
            teleportMenu:Destroy()
        end)
        
        yOffset = yOffset + 50
    end
    
    -- Ajustar tamaño del canvas
    locationsContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    
    -- Botón para añadir ubicación actual
    local addButton = Instance.new("TextButton")
    addButton.Name = "AddLocationButton"
    addButton.Size = UDim2.new(1, -20, 0, 40)
    addButton.Position = UDim2.new(0, 10, 1, -50)
    addButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    addButton.BackgroundTransparency = 0.3
    addButton.BorderSizePixel = 0
    addButton.Text = "Añadir Ubicación Actual"
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.TextSize = 16
    addButton.Font = Enum.Font.SourceSansBold
    addButton.Parent = teleportMenu
    
    addButton.MouseButton1Click:Connect(function()
        -- Mostrar diálogo para ingresar nombre
        MobileUI.ShowInputDialog("Nombre de la ubicación", function(name)
            if name and name ~= "" then
                Teleport.AddCustomLocation(name)
                teleportMenu:Destroy()
                MobileUI.ShowTeleportMenu() -- Recargar menú con la nueva ubicación
            end
        end)
    end)
end

function MobileUI.ShowSettingsMenu()
    -- Implementar menú de configuración
    local screenGui = game:GetService("CoreGui"):FindFirstChild("TSBMobileUI")
    if not screenGui then return end
    
    -- Eliminar menú anterior si existe
    local oldMenu = screenGui:FindFirstChild("SettingsMenu")
    if oldMenu then oldMenu:Destroy() end
    
    local settingsMenu = Instance.new("Frame")
    settingsMenu.Name = "SettingsMenu"
    settingsMenu.Size = UDim2.new(0, 250, 0, 300)
    settingsMenu.Position = UDim2.new(0.5, -125, 0.5, -150)
    settingsMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    settingsMenu.BackgroundTransparency = 0.2
    settingsMenu.BorderSizePixel = 0
    settingsMenu.Parent = screenGui
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.BackgroundTransparency = 0.5
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Configuración"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = settingsMenu
    
    -- Botón de cierre
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BackgroundTransparency = 0.3
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = settingsMenu
    
    closeButton.MouseButton1Click:Connect(function()
        settingsMenu:Destroy()
    end)
    
    -- Contenedor de configuraciones
    local settingsContainer = Instance.new("ScrollingFrame")
    settingsContainer.Name = "SettingsContainer"
    settingsContainer.Size = UDim2.new(1, -20, 1, -50)
    settingsContainer.Position = UDim2.new(0, 10, 0, 50)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.ScrollBarThickness = 6
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Se ajustará automáticamente
    settingsContainer.Parent = settingsMenu
    
    -- Crear opciones de configuración
    local yOffset = 0
    
    -- Opción de transparencia de UI
    local transparencyLabel = Instance.new("TextLabel")
    transparencyLabel.Size = UDim2.new(1, -10, 0, 30)
    transparencyLabel.Position = UDim2.new(0, 5, 0, yOffset)
    transparencyLabel.BackgroundTransparency = 1
    transparencyLabel.Text = "Transparencia UI: " .. TSB.mobileUI.transparency
    transparencyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    transparencyLabel.TextSize = 14
    transparencyLabel.TextXAlignment = Enum.TextXAlignment.Left
    transparencyLabel.Font = Enum.Font.SourceSans
    transparencyLabel.Parent = settingsContainer
    
    yOffset = yOffset + 30
    
    local transparencySlider = Instance.new("Frame")
    transparencySlider.Size = UDim2.new(1, -10, 0, 20)
    transparencySlider.Position = UDim2.new(0, 5, 0, yOffset)
    transparencySlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    transparencySlider.BorderSizePixel = 0
    transparencySlider.Parent = settingsContainer
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 20, 1, 0)
    sliderButton.Position = UDim2.new(TSB.mobileUI.transparency, 0, 0, 0)
    sliderButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    sliderButton.BorderSizePixel = 0
    sliderButton.Text = ""
    sliderButton.Parent = transparencySlider
    
    -- Lógica del slider
    local isDragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        isDragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    transparencySlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            
            local mousePos = input.Position.X
            local sliderPos = transparencySlider.AbsolutePosition.X
            local sliderWidth = transparencySlider.AbsoluteSize.X
            
            local relativePos = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            sliderButton.Position = UDim2.new(relativePos, 0, 0, 0)
            
            TSB.mobileUI.transparency = relativePos
            transparencyLabel.Text = "Transparencia UI: " .. string.format("%.2f", TSB.mobileUI.transparency)
            
            -- Actualizar transparencia de la UI
            local mainPanel = screenGui:FindFirstChild("MainPanel")
            if mainPanel then
                mainPanel.BackgroundTransparency = TSB.mobileUI.transparency
            end
        end
    end)
    
    transparencySlider.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = transparencySlider.AbsolutePosition.X
            local sliderWidth = transparencySlider.AbsoluteSize.X
            
            local relativePos = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            sliderButton.Position = UDim2.new(relativePos, 0, 0, 0)
            
            TSB.mobileUI.transparency = relativePos
            transparencyLabel.Text = "Transparencia UI: " .. string.format("%.2f", TSB.mobileUI.transparency)
            
            -- Actualizar transparencia de la UI
            local mainPanel = screenGui:FindFirstChild("MainPanel")
            if mainPanel then
                mainPanel.BackgroundTransparency = TSB.mobileUI.transparency
            end
        end
    end)
    
    yOffset = yOffset + 30
    
    -- Otras opciones de configuración
    -- Tamaño de botones
    local buttonSizeLabel = Instance.new("TextLabel")
    buttonSizeLabel.Size = UDim2.new(1, -10, 0, 30)
    buttonSizeLabel.Position = UDim2.new(0, 5, 0, yOffset)
    buttonSizeLabel.BackgroundTransparency = 1
    buttonSizeLabel.Text = "Tamaño de botones: " .. TSB.mobileUI.buttonSize
    buttonSizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonSizeLabel.TextSize = 14
    buttonSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    buttonSizeLabel.Font = Enum.Font.SourceSans
    buttonSizeLabel.Parent = settingsContainer
    
    yOffset = yOffset + 30
    
    local buttonSizeSlider = Instance.new("Frame")
    buttonSizeSlider.Size = UDim2.new(1, -10, 0, 20)
    buttonSizeSlider.Position = UDim2.new(0, 5, 0, yOffset)
    buttonSizeSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    buttonSizeSlider.BorderSizePixel = 0
    buttonSizeSlider.Parent = settingsContainer
    
    local buttonSizeSliderButton = Instance.new("TextButton")
    buttonSizeSliderButton.Size = UDim2.new(0, 20, 1, 0)
    buttonSizeSliderButton.Position = UDim2.new((TSB.mobileUI.buttonSize - 40) / 60, 0, 0, 0) -- Rango de 40 a 100
    buttonSizeSliderButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    buttonSizeSliderButton.BorderSizePixel = 0
    buttonSizeSliderButton.Text = ""
    buttonSizeSliderButton.Parent = buttonSizeSlider
    
    -- Lógica del slider de tamaño de botones
    local isButtonSizeDragging = false
    
    buttonSizeSliderButton.MouseButton1Down:Connect(function()
        isButtonSizeDragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isButtonSizeDragging = false
        end
    end)
    
    buttonSizeSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isButtonSizeDragging = true
            
            local mousePos = input.Position.X
            local sliderPos = buttonSizeSlider.AbsolutePosition.X
            local sliderWidth = buttonSizeSlider.AbsoluteSize.X
            
            local relativePos = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            buttonSizeSliderButton.Position = UDim2.new(relativePos, 0, 0, 0)
            
            TSB.mobileUI.buttonSize = math.floor(40 + relativePos * 60)
            buttonSizeLabel.Text = "Tamaño de botones: " .. TSB.mobileUI.buttonSize
        end
    end)
    
    buttonSizeSlider.InputChanged:Connect(function(input)
        if isButtonSizeDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = buttonSizeSlider.AbsolutePosition.X
            local sliderWidth = buttonSizeSlider.AbsoluteSize.X
            
            local relativePos = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            buttonSizeSliderButton.Position = UDim2.new(relativePos, 0, 0, 0)
            
            TSB.mobileUI.buttonSize = math.floor(40 + relativePos * 60)
            buttonSizeLabel.Text = "Tamaño de botones: " .. TSB.mobileUI.buttonSize
        end
    end)
    
    yOffset = yOffset + 40
    
    -- Ajustar tamaño del canvas
    settingsContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
end

function MobileUI.ShowInputDialog(title, callback)
    local screenGui = game:GetService("CoreGui"):FindFirstChild("TSBMobileUI")
    if not screenGui then return end
    
    -- Eliminar diálogo anterior si existe
    local oldDialog = screenGui:FindFirstChild("InputDialog")
    if oldDialog then oldDialog:Destroy() end
    
    local dialog = Instance.new("Frame")
    dialog.Name = "InputDialog"
    dialog.Size = UDim2.new(0, 250, 0, 150)
    dialog.Position = UDim2.new(0.5, -125, 0.5, -75)
    dialog.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dialog.BackgroundTransparency = 0.2
    dialog.BorderSizePixel = 0
    dialog.Parent = screenGui
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.BackgroundTransparency = 0.5
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = dialog
    
    -- Campo de texto
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 0, 30)
    textBox.Position = UDim2.new(0, 10, 0, 60)
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    textBox.BackgroundTransparency = 0.3
    textBox.BorderSizePixel = 0
    textBox.Text = ""
    textBox.PlaceholderText = "Ingrese texto aquí..."
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 16
    textBox.Font = Enum.Font.SourceSans
    textBox.Parent = dialog
    
    -- Botones
    local confirmButton = Instance.new("TextButton")
    confirmButton.Size = UDim2.new(0.45, 0, 0, 30)
    confirmButton.Position = UDim2.new(0.05, 0, 1, -40)
    confirmButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    confirmButton.BackgroundTransparency = 0.3
    confirmButton.BorderSizePixel = 0
    confirmButton.Text = "Confirmar"
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.TextSize = 16
    confirmButton.Font = Enum.Font.SourceSansBold
    confirmButton.Parent = dialog
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0.45, 0, 0, 30)
    cancelButton.Position = UDim2.new(0.5, 0, 1, -40)
    cancelButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
    cancelButton.BackgroundTransparency = 0.3
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "Cancelar"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 16
    cancelButton.Font = Enum.Font.SourceSansBold
    cancelButton.Parent = dialog
    
    confirmButton.MouseButton1Click:Connect(function()
        callback(textBox.Text)
        dialog:Destroy()
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
end

-- Inicialización del Script
local function Initialize()
    print("Inicializando TSB Script v" .. TSB.version)
    
    -- Inicializar todos los sistemas
    AutoFarm.Initialize()
    AutoCombat.Initialize()
    ESP.Initialize()
    InventoryManager.Initialize()
    MobileUI.Initialize()
    
    print("TSB Script inicializado correctamente!")
end

-- Bucle principal
local function MainLoop()
    while true do
        if TSB.enabled then
            -- Actualizar ESP
            ESP.Update()
        end
        
        wait(0.1) -- Esperar antes de la siguiente iteración
    end
end

-- Iniciar script
Initialize()
coroutine.wrap(MainLoop)()
