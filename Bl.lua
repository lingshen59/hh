-- Blox Fruit Auto Farm Script
-- Based on HoHo Hub interface

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("HoHo Hub Blox Fruit", "Ocean")

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

-- Checkbox para Auto Farm Level
AutoFarmLevelSection:NewToggle("Auto farm your current level quests", "Auto farmea las misiones de tu nivel actual", function(state)
    if state then
        print("Auto Farm Level Activado")
        -- Aquí va la lógica del auto farm
    else
        print("Auto Farm Level Desactivado")
    end
end)

-- Toggle para Auto Farm Level
AutoFarmLevelSection:NewToggle("AUTO FARM LEVEL", "Activa/Desactiva el auto farm de nivel", function(state)
    if state then
        print("Auto Farm Level Principal Activado")
    else
        print("Auto Farm Level Principal Desactivado")
    end
end)

-- Toggle para Auto Farm Level (segundo)
AutoFarmLevelSection:NewToggle("Auto Farm Level", "Activa/Desactiva el auto farm de nivel", function(state)
    if state then
        print("Auto Farm Level Secundario Activado")
    else
        print("Auto Farm Level Secundario Desactivado")
    end
end)

-- Dropdown para Select Method Farm
AutoFarmLevelSection:NewDropdown("Select Method Farm", "Selecciona el método de farmeo", {"Single Quest", "Multiple Quests"}, function(selected)
    print("Método seleccionado: " .. selected)
end)

-- Toggle para Farm Level Take Quest
AutoFarmLevelSection:NewToggle("Farm Level Take Quest", "Toma automáticamente las misiones", function(state)
    if state then
        print("Auto Take Quest Activado")
    else
        print("Auto Take Quest Desactivado")
    end
end)

-- Dropdown para Select Weapon
AutoFarmLevelSection:NewDropdown("Select Weapon", "Selecciona el arma para farmear", {"Melee", "Sword", "Gun", "Fruit"}, function(selected)
    print("Arma seleccionada: " .. selected)
end)

-- Sección de Auto Farm Quest
local AutoFarmQuestSection = NormalFarm:NewSection("=============AUTO FARM QUEST=============")

-- Checkbox para Auto Farm Selected Quest
AutoFarmQuestSection:NewToggle("Auto farm selected quest", "Auto farmea la misión seleccionada", function(state)
    if state then
        print("Auto Farm Quest Activado")
        -- Aquí va la lógica del auto farm de misiones
    else
        print("Auto Farm Quest Desactivado")
    end
end)

-- Función principal para iniciar el script
local function StartScript()
    print("Script de Blox Fruit iniciado correctamente")
    
    -- Aquí iría la lógica principal del script
    while wait() do
        -- Loop principal para el auto farm
        if getgenv().AutoFarm then
            -- Lógica del auto farm
        end
    end
end

-- Iniciar el script
StartScript()
