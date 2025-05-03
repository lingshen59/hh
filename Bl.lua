-- Blox Fruit Auto Farm Script
-- Based on HoHo Hub interface

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Blox Fruit", "Ocean")

-- Variables globales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Configuración del auto farm
local Config = {
    AutoFarm = false,
    AutoFarmLevel = false,
    AutoFarmQuest = false,
    FarmMethod = "Single Quest",
    AutoTakeQuest = false,
    SelectedWeapon = "Melee",
    FarmDistance = 15, -- Distancia para flotar sobre el NPC
    AttackDistance = 25, -- Distancia máxima para atacar
    FarmSpeed = 150, -- Velocidad de movimiento hacia el NPC
    HitboxExpander = 5, -- Expandir el hitbox para golpear desde lejos
    CurrentQuest = "", -- Misión actual
    QuestMobName = "", -- Nombre del NPC de la misión actual
    AutoFarmBoss = false, -- Auto farm de jefes
    Auto2Sea = false, -- Auto completar requisitos para ir al segundo mar
    Auto3Sea = false, -- Auto completar requisitos para ir al tercer mar
    AutoSaber = false, -- Auto obtener Saber (espada del primer mar)
    AutoRandomFruit = false, -- Auto girar fruta aleatoria
    AutoCollectFruit = false, -- Auto recoger frutas que aparecen en el mar
    ShowFruitDistance = true, -- Mostrar distancia a la fruta más cercana
}

-- Crear las pestañas principales
local FarmConfig = Window:NewTab("FARM CONFIG")
local NormalFarm = Window:NewTab("NORMAL FARM")
local RaidEvent = Window:NewTab("RAID & EVENT")
local FirstSea = Window:NewTab("FIRST SEA")
local SecondSea = Window:NewTab("SECOND SEA")
local ThirdSea = Window:NewTab("THIRD SEA")
local RaceV4 = Window:NewTab("RACE V4")
local SeaEvent = Window:NewTab("SEA EVENT")
local Players = Window:NewTab("PLAYERS")
local Misc = Window:NewTab("MISC")

-- Sección de Farm Normal
local NormalFarmSection = NormalFarm:NewSection("NORMAL FARM")

-- Sección de Auto Farm Level
local AutoFarmLevelSection = NormalFarm:NewSection("=============AUTO FARM LEVEL=============")

-- Función para encontrar el NPC más cercano
local function GetNearestMob()
    local TargetDistance = math.huge
    local Target = nil
    
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            local Distance = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if Distance < TargetDistance then
                TargetDistance = Distance
                Target = v
            end
        end
    end
    
    return Target
end

-- Función para moverse hacia el NPC
local function TweenToPosition(targetPosition, speed)
    local Distance = (HumanoidRootPart.Position - targetPosition).Magnitude
    local Time = Distance / speed
    
    local Tween = TweenService:Create(
        HumanoidRootPart,
        TweenInfo.new(Time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(targetPosition)}
    )
    
    Tween:Play()
    return Tween
end

-- Función para expandir el hitbox del NPC
local function ExpandHitbox(npc, size)
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        npc.HumanoidRootPart.Size = Vector3.new(size, size, size)
        npc.HumanoidRootPart.Transparency = 0.8
        npc.HumanoidRootPart.CanCollide = false
    end
end

-- Función para atacar
local function Attack()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0, 0))
end

-- Función para obtener la información de la misión actual
local function GetQuestInfo()
    local QuestTitle = ""
    local QuestMob = ""
    
    -- Buscar el título de la misión en la interfaz del juego
    for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v.Name == "QuestTitle" and v:IsA("TextLabel") then
            QuestTitle = v.Text
            break
        end
    end
    
    -- Extraer el nombre del NPC de la misión
    if QuestTitle ~= "" then
        -- Ejemplo: "Defeat 5 Bandits" -> "Bandits"
        local mobName = QuestTitle:match("Defeat %d+ (.+)")
        if mobName then
            QuestMob = mobName
        end
    end
    
    return QuestTitle, QuestMob
end

-- Función para encontrar el NPC de la misión actual
local function GetQuestMob()
    local QuestTitle, QuestMob = GetQuestInfo()
    Config.CurrentQuest = QuestTitle
    Config.QuestMobName = QuestMob
    
    if QuestMob == "" then
        return GetNearestMob() -- Si no hay misión, atacar al más cercano
    end
    
    local TargetDistance = math.huge
    local Target = nil
    
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            -- Verificar si el nombre del NPC coincide con el de la misión
            if v.Name:find(QuestMob) then
                local Distance = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                if Distance < TargetDistance then
                    TargetDistance = Distance
                    Target = v
                end
            end
        end
    end
    
    -- Si no se encuentra el NPC de la misión, buscar el más cercano
    if not Target then
        return GetNearestMob()
    end
    
    return Target
end

-- Función para encontrar el NPC más cercano (como respaldo)
local function GetNearestMob()
    local TargetDistance = math.huge
    local Target = nil
    
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            local Distance = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if Distance < TargetDistance then
                TargetDistance = Distance
                Target = v
            end
        end
    end
    
    return Target
end

-- Función para encontrar el NPC que da la misión
local function FindQuestNPC()
    local NPCs = workspace:FindFirstChild("NPCs")
    if not NPCs then return nil end
    
    for _, v in pairs(NPCs:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("QuestBBG") then
            return v
        end
    end
    
    return nil
end

-- Función para aceptar una misión
local function AcceptQuest()
    local QuestNPC = FindQuestNPC()
    if not QuestNPC then return false end
    
    -- Moverse hacia el NPC de la misión
    local TargetPosition = QuestNPC.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
    local Tween = TweenToPosition(TargetPosition, Config.FarmSpeed)
    Tween.Completed:Wait()
    
    -- Interactuar con el NPC para aceptar la misión
    local args = {
        [1] = "StartQuest",
        [2] = QuestNPC.Name, -- Nombre del NPC
        [3] = 1 -- Nivel de la misión (normalmente 1)
    }
    
    -- Intentar llamar al evento remoto para aceptar la misión
    local questEvent = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
    if questEvent then
        questEvent:InvokeServer(unpack(args))
        wait(1)
        return true
    end
    
    return false
end

-- Función para moverse hacia el NPC
local function TweenToPosition(targetPosition, speed)
    local Distance = (HumanoidRootPart.Position - targetPosition).Magnitude
    local Time = Distance / speed
    
    local Tween = TweenService:Create(
        HumanoidRootPart,
        TweenInfo.new(Time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(targetPosition)}
    )
    
    Tween:Play()
    return Tween
end

-- Función para expandir el hitbox del NPC
local function ExpandHitbox(npc, size)
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        npc.HumanoidRootPart.Size = Vector3.new(size, size, size)
        npc.HumanoidRootPart.Transparency = 0.8
        npc.HumanoidRootPart.CanCollide = false
    end
end

-- Función para atacar
local function Attack()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0, 0))
end

-- Función para encontrar el jefe más cercano
local function GetNearestBoss()
    local TargetDistance = math.huge
    local Target = nil
    
    -- Lista de jefes conocidos en Blox Fruit
    local BossList = {"Saber Expert", "The Gorilla King", "Bobby", "Yeti", "The Saw", "Warden", "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Greybeard", "Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral", "Cursed Captain", "Darkbeard", "Order", "Tide Keeper", "Island Empress", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "Cake Queen", "rip_indra", "Cake Prince", "Stone", "Smoke Admiral", "Cursed Captain", "Darkbeard", "Order", "Tide Keeper", "Island Empress", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "Cake Queen", "rip_indra", "Cake Prince", "Stone"}
    
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            -- Verificar si es un jefe
            for _, bossName in pairs(BossList) do
                if v.Name:find(bossName) then
                    local Distance = (HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                    if Distance < TargetDistance then
                        TargetDistance = Distance
                        Target = v
                    end
                    break
                end
            end
        end
    end
    
    return Target
end

-- Función para teletransportarse a una ubicación
local function Teleport(position)
    if typeof(position) == "CFrame" then
        position = position.Position
    end
    
    local Distance = (HumanoidRootPart.Position - position).Magnitude
    local Speed = math.clamp(Distance / 5, 100, 500) -- Velocidad adaptativa
    
    local Tween = TweenService:Create(
        HumanoidRootPart,
        TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(position)}
    )
    
    Tween:Play()
    return Tween
end

-- Función para girar fruta aleatoria
local function SpinRandomFruit()
    local args = {
        [1] = "Cousin",
        [2] = "Buy"
    }
    
    local remoteFunction = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
    if remoteFunction then
        remoteFunction:InvokeServer(unpack(args))
        print("Fruta aleatoria girada con éxito")
        return true
    end
    
    return false
end

-- Función para detectar y recoger frutas en el mar
local function CollectFruits()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            if v.Name:find("Fruit") then
                -- Es una fruta, moverse hacia ella y recogerla
                local fruitPosition = v.Handle.Position
                local Tween = Teleport(fruitPosition)
                Tween.Completed:Wait()
                
                -- Intentar recoger la fruta
                firetouchinterest(HumanoidRootPart, v.Handle, 0)
                wait(0.1)
                firetouchinterest(HumanoidRootPart, v.Handle, 1)
                
                print("Fruta recogida: " .. v.Name)
                return true
            end
        end
    end
    
    return false
end

-- Función para encontrar la fruta más cercana y su distancia
local function GetNearestFruit()
    local ClosestFruit = nil
    local ClosestDistance = math.huge
    local FruitName = ""
    
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            if v.Name:find("Fruit") then
                local Distance = (HumanoidRootPart.Position - v.Handle.Position).Magnitude
                if Distance < ClosestDistance then
                    ClosestDistance = Distance
                    ClosestFruit = v
                    FruitName = v.Name
                end
            end
        end
    end
    
    return ClosestFruit, ClosestDistance, FruitName
end

-- Crear GUI para mostrar la distancia de la fruta
local FruitDistanceGUI = Instance.new("ScreenGui")
FruitDistanceGUI.Name = "FruitDistanceGUI"
FruitDistanceGUI.ResetOnSpawn = false
FruitDistanceGUI.Parent = game.CoreGui

local FruitDistanceFrame = Instance.new("Frame")
FruitDistanceFrame.Name = "FruitDistanceFrame"
FruitDistanceFrame.Size = UDim2.new(0, 200, 0, 50)
FruitDistanceFrame.Position = UDim2.new(0.5, -100, 0, 10) -- Posición en la parte superior central
FruitDistanceFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FruitDistanceFrame.BackgroundTransparency = 0.5
FruitDistanceFrame.BorderSizePixel = 0
FruitDistanceFrame.Visible = false
FruitDistanceFrame.Parent = FruitDistanceGUI

local FruitDistanceText = Instance.new("TextLabel")
FruitDistanceText.Name = "FruitDistanceText"
FruitDistanceText.Size = UDim2.new(1, 0, 1, 0)
FruitDistanceText.BackgroundTransparency = 1
FruitDistanceText.Text = "No hay frutas cercanas"
FruitDistanceText.TextColor3 = Color3.fromRGB(255, 255, 255)
FruitDistanceText.TextSize = 16
FruitDistanceText.Font = Enum.Font.SourceSansBold
FruitDistanceText.Parent = FruitDistanceFrame

-- Función para actualizar la información de la fruta más cercana
local function UpdateFruitDistance()
    if not Config.ShowFruitDistance then
        FruitDistanceFrame.Visible = false
        return
    end
    
    local Fruit, Distance, FruitName = GetNearestFruit()
    
    if Fruit then
        FruitDistanceFrame.Visible = true
        FruitDistanceText.Text = FruitName .. ": " .. math.floor(Distance) .. " m"
        
        -- Cambiar color según la distancia
        if Distance < 100 then
            FruitDistanceText.TextColor3 = Color3.fromRGB(0, 255, 0) -- Verde si está cerca
        elseif Distance < 500 then
            FruitDistanceText.TextColor3 = Color3.fromRGB(255, 255, 0) -- Amarillo si está a distancia media
        else
            FruitDistanceText.TextColor3 = Color3.fromRGB(255, 0, 0) -- Rojo si está lejos
        end
    else
        FruitDistanceFrame.Visible = false
    end
end

-- Iniciar bucle para actualizar la distancia de la fruta
spawn(function()
    while wait(1) do -- Actualizar cada segundo
        UpdateFruitDistance()
    end
end)

-- Función para obtener Saber (espada del primer mar)
local function GetSaber()
    -- Coordenadas de la cueva de Saber
    local saberCavePosition = Vector3.new(-1458.89502, 29.8870335, -50.633564)
    
    -- Teletransportarse a la cueva
    local Tween = Teleport(saberCavePosition)
    Tween.Completed:Wait()
    
    -- Buscar el NPC de Saber Expert
    for _, v in pairs(workspace.NPCs:GetChildren()) do
        if v.Name == "Saber Expert" then
            -- Moverse hacia el NPC
            local npcPosition = v.HumanoidRootPart.Position
            local Tween = Teleport(npcPosition)
            Tween.Completed:Wait()
            
            -- Interactuar con el NPC
            local args = {
                [1] = "BuyItem",
                [2] = "Saber"
            }
            
            local remoteFunction = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
            if remoteFunction then
                remoteFunction:InvokeServer(unpack(args))
                print("Saber obtenido con éxito")
                return true
            end
        end
    end
    
    return false
end

-- Función para completar requisitos del segundo mar
local function Complete2SeaRequirements()
    -- Verificar nivel (necesitas nivel 700+ para ir al segundo mar)
    if LocalPlayer.Data.Level.Value < 700 then
        print("Necesitas nivel 700 para ir al segundo mar. Activando auto farm...")
        Config.AutoFarmLevel = true
        return false
    end
    
    -- Buscar al NPC para ir al segundo mar
    for _, v in pairs(workspace.NPCs:GetChildren()) do
        if v.Name == "Military Soldier" then
            -- Moverse hacia el NPC
            local npcPosition = v.HumanoidRootPart.Position
            local Tween = Teleport(npcPosition)
            Tween.Completed:Wait()
            
            -- Interactuar con el NPC
            local args = {
                [1] = "TravelDressrosa"
            }
            
            local remoteFunction = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
            if remoteFunction then
                remoteFunction:InvokeServer(unpack(args))
                print("Viaje al segundo mar completado")
                return true
            end
        end
    end
    
    return false
end

-- Función para completar requisitos del tercer mar
local function Complete3SeaRequirements()
    -- Verificar nivel (necesitas nivel 1500+ para ir al tercer mar)
    if LocalPlayer.Data.Level.Value < 1500 then
        print("Necesitas nivel 1500 para ir al tercer mar. Activando auto farm...")
        Config.AutoFarmLevel = true
        return false
    end
    
    -- Buscar al NPC para ir al tercer mar
    for _, v in pairs(workspace.NPCs:GetChildren()) do
        if v.Name == "Marine Captain" then
            -- Moverse hacia el NPC
            local npcPosition = v.HumanoidRootPart.Position
            local Tween = Teleport(npcPosition)
            Tween.Completed:Wait()
            
            -- Interactuar con el NPC
            local args = {
                [1] = "TravelZou"
            }
            
            local remoteFunction = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
            if remoteFunction then
                remoteFunction:InvokeServer(unpack(args))
                print("Viaje al tercer mar completado")
                return true
            end
        end
    end
    
    return false
end

-- Función principal de auto farm
local function AutoFarm()
    if not Config.AutoFarm then return end
    
    -- Si está activado el auto-quest, verificar si tenemos una misión activa
    if Config.AutoTakeQuest then
        local QuestTitle, _ = GetQuestInfo()
        if QuestTitle == "" then
            -- No tenemos misión, intentar aceptar una
            AcceptQuest()
            wait(1) -- Esperar a que se actualice la interfaz
        end
    end
    
    -- Obtener el NPC objetivo según la misión actual
    local Target = GetQuestMob()
    if Target then
        -- Expandir hitbox para poder golpear desde lejos
        ExpandHitbox(Target, Config.HitboxExpander)
        
        -- Posición sobre el NPC
        local TargetPosition = Target.HumanoidRootPart.Position + Vector3.new(0, Config.FarmDistance, 0)
        
        -- Moverse hacia la posición
        local Tween = TweenToPosition(TargetPosition, Config.FarmSpeed)
        
        -- Esperar a que termine el movimiento
        Tween.Completed:Wait()
        
        -- Mirar hacia el NPC
        HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, Vector3.new(Target.HumanoidRootPart.Position.X, HumanoidRootPart.Position.Y, Target.HumanoidRootPart.Position.Z))
        
        -- Atacar si estamos lo suficientemente cerca
        local Distance = (HumanoidRootPart.Position - Target.HumanoidRootPart.Position).Magnitude
        if Distance <= Config.AttackDistance then
            Attack()
        end
    end
end

-- Función de auto farm para jefes
local function AutoFarmBoss()
    if not Config.AutoFarmBoss then return end
    
    -- Obtener el jefe más cercano
    local Boss = GetNearestBoss()
    if Boss then
        -- Expandir hitbox para poder golpear desde lejos
        ExpandHitbox(Boss, Config.HitboxExpander * 2) -- Hitbox más grande para jefes
        
        -- Posición sobre el jefe
        local TargetPosition = Boss.HumanoidRootPart.Position + Vector3.new(0, Config.FarmDistance, 0)
        
        -- Moverse hacia la posición
        local Tween = TweenToPosition(TargetPosition, Config.FarmSpeed)
        
        -- Esperar a que termine el movimiento
        Tween.Completed:Wait()
        
        -- Mirar hacia el jefe
        HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, Vector3.new(Boss.HumanoidRootPart.Position.X, HumanoidRootPart.Position.Y, Boss.HumanoidRootPart.Position.Z))
        
        -- Atacar si estamos lo suficientemente cerca
        local Distance = (HumanoidRootPart.Position - Boss.HumanoidRootPart.Position).Magnitude
        if Distance <= Config.AttackDistance * 1.5 then -- Mayor distancia para jefes
            Attack()
        end
    end
end

-- Checkbox para Auto Farm Level
AutoFarmLevelSection:NewToggle("Auto farm your current level quests", "Auto farmea las misiones de tu nivel actual", function(state)
    Config.AutoFarm = state
    Config.AutoFarmLevel = state
    Config.AutoTakeQuest = state -- Activar también el auto-quest
    
    if state then
        print("Auto Farm Level Activado")
        
        -- Iniciar el bucle de auto farm
        spawn(function()
            while Config.AutoFarm do
                AutoFarm()
                wait(0.1)
            end
        end)
    else
        print("Auto Farm Level Desactivado")
    end
end)

-- Toggle para Auto Farm Level
AutoFarmLevelSection:NewToggle("AUTO FARM LEVEL", "Activa/Desactiva el auto farm de nivel", function(state)
    Config.AutoFarmLevel = state
    
    if state then
        print("Auto Farm Level Principal Activado")
        -- Lógica específica para el auto farm de nivel
    else
        print("Auto Farm Level Principal Desactivado")
    end
end)

-- Toggle para Auto Farm Level (segundo)
AutoFarmLevelSection:NewToggle("Auto Farm Level", "Activa/Desactiva el auto farm de nivel", function(state)
    Config.AutoFarmLevel = state
    
    if state then
        print("Auto Farm Level Secundario Activado")
    else
        print("Auto Farm Level Secundario Desactivado")
    end
end)

-- Dropdown para Select Method Farm
AutoFarmLevelSection:NewDropdown("Select Method Farm", "Selecciona el método de farmeo", {"Single Quest", "Multiple Quests"}, function(selected)
    Config.FarmMethod = selected
    print("Método seleccionado: " .. selected)
end)

-- Toggle para Farm Level Take Quest
AutoFarmLevelSection:NewToggle("Farm Level Take Quest", "Toma automáticamente las misiones", function(state)
    Config.AutoTakeQuest = state
    
    if state then
        print("Auto Take Quest Activado")
        
        -- Iniciar bucle para tomar misiones
        spawn(function()
            while Config.AutoTakeQuest do
                local QuestTitle, _ = GetQuestInfo()
                if QuestTitle == "" then
                    -- No tenemos misión, intentar aceptar una
                    AcceptQuest()
                end
                wait(5) -- Comprobar cada 5 segundos si necesitamos una nueva misión
            end
        end)
    else
        print("Auto Take Quest Desactivado")
    end
end)

-- Dropdown para Select Weapon
AutoFarmLevelSection:NewDropdown("Select Weapon", "Selecciona el arma para farmear", {"Melee", "Sword", "Gun", "Fruit"}, function(selected)
    Config.SelectedWeapon = selected
    print("Arma seleccionada: " .. selected)
    
    -- Equipar el arma seleccionada
    spawn(function()
        -- Aquí iría la lógica para equipar el arma seleccionada
        -- Por ejemplo, buscar en el inventario y equipar
    end)
end)

-- Sección de Auto Farm Quest
local AutoFarmQuestSection = NormalFarm:NewSection("=============AUTO FARM QUEST=============")

-- Checkbox para Auto Farm Selected Quest
AutoFarmQuestSection:NewToggle("Auto farm selected quest", "Auto farmea la misión seleccionada", function(state)
    Config.AutoFarmQuest = state
    
    if state then
        print("Auto Farm Quest Activado")
        
        -- Iniciar bucle para farmear misiones específicas
        spawn(function()
            while Config.AutoFarmQuest do
                AutoFarm()
                wait(0.1)
            end
        end)
    else
        print("Auto Farm Quest Desactivado")
    end
end)

-- Función para manejar la reconexión del personaje
LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Reiniciar el auto farm si estaba activado
    if Config.AutoFarm then
        wait(1)
        spawn(function()
            while Config.AutoFarm do
                AutoFarm()
                wait(0.1)
            end
        end)
    end
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
    wait(1)
end)

-- Función principal para iniciar el script
local function StartScript()
    print("Script de Blox Fruit iniciado correctamente")
    
    -- Comprobar si estamos en el juego correcto
    if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then
        warn("Este script está diseñado para Blox Fruit. Por favor, ejecuta el script en el juego correcto.")
        return
    end
    
    -- Inicializar el script
    print("Script inicializado correctamente. ¡Disfruta del auto farm!")
end

-- Iniciar el script
StartScript()
