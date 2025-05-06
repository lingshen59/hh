repeat wait() until game:IsLoaded()

-- Variables locales
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local titleLabel = Instance.new("TextLabel")
local buttonFrame = Instance.new("Frame")
local tpButton = Instance.new("TextButton")
local autoFarmButton = Instance.new("TextButton")
local autoBlockButton = Instance.new("TextButton")
local farmKillButton = Instance.new("TextButton")
local selectPlayerButton = Instance.new("TextButton")
local statusLabel = Instance.new("TextLabel")
local toggleGuiButton = Instance.new("TextButton") -- Botón para mostrar/ocultar la GUI

-- Variables para la funcionalidad
local selectedPlayer = nil
local isTPActive = false
local tpConnection = nil
local cameraConnection = nil
local isAutoBlockActive = false
local autoBlockConnection = nil
local isBlockSpyActive = false
local blockSpyConnection = nil

-- Configuración de la UI
screenGui.Name = "LingOnly"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Configuración del marco principal
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Título
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "LingOnly"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 22
titleLabel.Parent = mainFrame

-- Marco para botones
buttonFrame.Name = "ButtonFrame"
buttonFrame.Size = UDim2.new(1, -40, 1, -80)
buttonFrame.Position = UDim2.new(0, 20, 0, 60)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

-- Botón TP to Player
tpButton.Name = "TPButton"
tpButton.Size = UDim2.new(1, 0, 0, 45)
tpButton.Position = UDim2.new(0, 0, 0, 0)
tpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
tpButton.BorderSizePixel = 0
tpButton.Text = "TP to Player"
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.Font = Enum.Font.SourceSansBold
tpButton.TextSize = 18
tpButton.Parent = buttonFrame

-- Botón Auto Farm
autoFarmButton.Name = "AutoFarmButton"
autoFarmButton.Size = UDim2.new(1, 0, 0, 45)
autoFarmButton.Position = UDim2.new(0, 0, 0, 55)
autoFarmButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
autoFarmButton.BorderSizePixel = 0
autoFarmButton.Text = "Auto Farm"
autoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFarmButton.Font = Enum.Font.SourceSansBold
autoFarmButton.TextSize = 18
autoFarmButton.Parent = buttonFrame

-- Botón Auto Block
autoBlockButton.Name = "AutoBlockButton"
autoBlockButton.Size = UDim2.new(1, 0, 0, 45)
autoBlockButton.Position = UDim2.new(0, 0, 0, 110)
autoBlockButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
autoBlockButton.BorderSizePixel = 0
autoBlockButton.Text = "Auto Block"
autoBlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBlockButton.Font = Enum.Font.SourceSansBold
autoBlockButton.TextSize = 18
autoBlockButton.Parent = buttonFrame

-- Botón Farm Kill
farmKillButton.Name = "FarmKillButton"
farmKillButton.Size = UDim2.new(1, 0, 0, 45)
farmKillButton.Position = UDim2.new(0, 0, 0, 165)
farmKillButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
farmKillButton.BorderSizePixel = 0
farmKillButton.Text = "Farm Kill"
farmKillButton.TextColor3 = Color3.fromRGB(255, 255, 255)
farmKillButton.Font = Enum.Font.SourceSansBold
farmKillButton.TextSize = 18
farmKillButton.Parent = buttonFrame

-- Botón Select Player
selectPlayerButton.Name = "SelectPlayerButton"
selectPlayerButton.Size = UDim2.new(1, 0, 0, 45)
selectPlayerButton.Position = UDim2.new(0, 0, 0, 220)
selectPlayerButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
selectPlayerButton.BorderSizePixel = 0
selectPlayerButton.Text = "Select Player"
selectPlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
selectPlayerButton.Font = Enum.Font.SourceSansBold
selectPlayerButton.TextSize = 18
selectPlayerButton.Parent = buttonFrame

-- Etiqueta de estado
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 1, -40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Estado: Esperando selección de jugador"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 16
statusLabel.Parent = mainFrame

-- Botón para mostrar/ocultar la GUI (para iPad)
toggleGuiButton.Name = "ToggleGuiButton"
toggleGuiButton.Size = UDim2.new(0, 50, 0, 50)
toggleGuiButton.Position = UDim2.new(0, 10, 0, 10)
toggleGuiButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleGuiButton.BorderSizePixel = 0
toggleGuiButton.Text = "≡"
toggleGuiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleGuiButton.Font = Enum.Font.SourceSansBold
toggleGuiButton.TextSize = 30
toggleGuiButton.ZIndex = 10
toggleGuiButton.Parent = screenGui

-- Función para seleccionar jugador
local function createPlayerSelection()
    -- Crear UI para selección de jugador
    local selectionGui = Instance.new("ScreenGui")
    local selectionFrame = Instance.new("Frame")
    local selectionTitle = Instance.new("TextLabel")
    local playerListFrame = Instance.new("ScrollingFrame")
    local closeButton = Instance.new("TextButton")
    local UIListLayout = Instance.new("UIListLayout")
    
    selectionGui.Name = "PlayerSelectionGui"
    selectionGui.ResetOnSpawn = false
    selectionGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    selectionGui.Parent = player:WaitForChild("PlayerGui")
    
    selectionFrame.Name = "SelectionFrame"
    selectionFrame.Size = UDim2.new(0, 250, 0, 300)
    selectionFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
    selectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    selectionFrame.BorderSizePixel = 0
    selectionFrame.Active = true
    selectionFrame.Draggable = true
    selectionFrame.Parent = selectionGui
    
    selectionTitle.Name = "SelectionTitle"
    selectionTitle.Size = UDim2.new(1, 0, 0, 30)
    selectionTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    selectionTitle.BorderSizePixel = 0
    selectionTitle.Text = "Seleccionar Jugador"
    selectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectionTitle.Font = Enum.Font.SourceSansBold
    selectionTitle.TextSize = 18
    selectionTitle.Parent = selectionFrame
    
    playerListFrame.Name = "PlayerListFrame"
    playerListFrame.Size = UDim2.new(1, -20, 1, -80)
    playerListFrame.Position = UDim2.new(0, 10, 0, 40)
    playerListFrame.BackgroundTransparency = 1
    playerListFrame.BorderSizePixel = 0
    playerListFrame.ScrollBarThickness = 6
    playerListFrame.Parent = selectionFrame
    
    UIListLayout.Parent = playerListFrame
    UIListLayout.SortOrder = Enum.SortOrder.Name
    UIListLayout.Padding = UDim.new(0, 5)
    
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 80, 0, 30)
    closeButton.Position = UDim2.new(0.5, -40, 1, -35)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Cerrar"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 16
    closeButton.Parent = selectionFrame
    
    -- Llenar la lista de jugadores
    local function updatePlayerList()
        -- Limpiar lista actual
        for _, child in pairs(playerListFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Añadir jugadores
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player then
                local playerButton = Instance.new("TextButton")
                playerButton.Name = plr.Name
                playerButton.Size = UDim2.new(1, -10, 0, 30)
                playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                playerButton.BorderSizePixel = 0
                playerButton.Text = plr.Name
                playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                playerButton.Font = Enum.Font.SourceSans
                playerButton.TextSize = 16
                playerButton.Parent = playerListFrame
                
                playerButton.MouseButton1Click:Connect(function()
                    selectedPlayer = plr
                    statusLabel.Text = "Estado: Jugador seleccionado - " .. plr.Name
                    selectionGui:Destroy()
                end)
            end
        end
        
        -- Ajustar tamaño del scrolling frame
        playerListFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end
    
    updatePlayerList()
    
    -- Actualizar lista cuando un jugador entra o sale
    game.Players.PlayerAdded:Connect(function()
        if selectionGui.Parent then
            updatePlayerList()
        end
    end)
    
    game.Players.PlayerRemoving:Connect(function(plr)
        if selectionGui.Parent then
            updatePlayerList()
        end
        
        if selectedPlayer == plr then
            selectedPlayer = nil
            statusLabel.Text = "Estado: Jugador seleccionado desconectado"
            if isTPActive then
                isTPActive = false
                if tpConnection then
                    tpConnection:Disconnect()
                    tpConnection = nil
                end
                if cameraConnection then
                    cameraConnection:Disconnect()
                    cameraConnection = nil
                end
                -- Restaurar cámara a la configuración normal
                workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
                tpButton.Text = "TP to Player"
                tpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            end
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        selectionGui:Destroy()
    end)
end

-- Función para activar/desactivar TP al jugador
local function toggleTP()
    if not selectedPlayer then
        statusLabel.Text = "Estado: Selecciona un jugador primero"
        return
    end
    
    isTPActive = not isTPActive
    
    if isTPActive then
        statusLabel.Text = "Estado: TP activo a " .. selectedPlayer.Name
        tpButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        tpButton.Text = "Stop TP"
        
        -- Crear conexión para el TP constante
        tpConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
            end
        end)
        
        -- Configurar la cámara para seguir al jugador seleccionado
        if selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = selectedPlayer.Character.Humanoid
            
            -- Crear conexión para mantener la cámara en el jugador seleccionado
            cameraConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                    workspace.CurrentCamera.CameraSubject = selectedPlayer.Character.Humanoid
                end
            end)
        end
    else
        statusLabel.Text = "Estado: TP desactivado"
        tpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        tpButton.Text = "TP to Player"
        
        if tpConnection then
            tpConnection:Disconnect()
            tpConnection = nil
        end
        
        if cameraConnection then
            cameraConnection:Disconnect()
            cameraConnection = nil
        end
        
        -- Restaurar cámara a la configuración normal
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
        end
    end
end

-- Función para activar/desactivar Auto Block (adaptada para iPad)
local function toggleAutoBlock()
    isAutoBlockActive = not isAutoBlockActive
    
    if isAutoBlockActive then
        statusLabel.Text = "Estado: Auto Block activado"
        autoBlockButton.BackgroundColor3 = Color3.fromRGB(150, 75, 0)
        autoBlockButton.Text = "Stop Auto Block"
        
        -- Crear conexión para el Auto Block
        autoBlockConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                -- Detectar jugadores cercanos
                local nearbyPlayers = {}
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance <= 15 then -- Distancia de detección
                            table.insert(nearbyPlayers, plr)
                        end
                    end
                end
                
                -- Verificar si algún jugador cercano está atacando
                for _, plr in ipairs(nearbyPlayers) do
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        local humanoid = plr.Character.Humanoid
                        local animation = humanoid:GetPlayingAnimationTracks()
                        
                        for _, anim in ipairs(animation) do
                            local animName = anim.Animation.Name:lower()
                            -- Detectar animaciones de ataque (ajustar según el juego)
                            if animName:find("attack") or animName:find("punch") or animName:find("kick") or animName:find("combo") then
                                -- Cancelar nuestro ataque si estamos atacando
                                local playerAnim = player.Character.Humanoid:GetPlayingAnimationTracks()
                                for _, pAnim in ipairs(playerAnim) do
                                    local pAnimName = pAnim.Animation.Name:lower()
                                    if pAnimName:find("attack") or pAnimName:find("punch") or pAnimName:find("kick") or pAnimName:find("combo") then
                                        pAnim:Stop()
                                    end
                                end
                                
                                -- Intentar activar el bloqueo directamente
                                -- Buscar el evento de bloqueo en el juego
                                local blockEvent = nil
                                
                                -- Intentar encontrar el evento de bloqueo en ReplicatedStorage
                                for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                                    if v:IsA("RemoteEvent") and (v.Name:lower():find("block") or v.Name:lower():find("defend")) then
                                        blockEvent = v
                                        break
                                    end
                                end
                                
                                -- Si encontramos el evento, activarlo
                                if blockEvent then
                                    blockEvent:FireServer(true)
                                else
                                    -- Si no encontramos el evento, intentar simular la tecla F
                                    -- Esto es menos efectivo en iPad, pero intentamos de todas formas
                                    local vim = game:GetService("VirtualInputManager")
                                    vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                                    wait(0.1)
                                    vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                                end
                                
                                break
                            end
                        end
                    end
                end
            end
        end)
    else
        statusLabel.Text = "Estado: Auto Block desactivado"
        autoBlockButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        autoBlockButton.Text = "Auto Block"
        
        if autoBlockConnection then
            autoBlockConnection:Disconnect()
            autoBlockConnection = nil
        end
    end
end

-- Conectar funcionalidad a los botones
tpButton.MouseButton1Click:Connect(toggleTP)
selectPlayerButton.MouseButton1Click:Connect(createPlayerSelection)
autoBlockButton.MouseButton1Click:Connect(toggleAutoBlock)

autoFarmButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "Estado: Auto Farm (Función no implementada)"
end)

farmKillButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "Estado: Farm Kill (Función no implementada)"
end)

-- Función para mostrar/ocultar la GUI (para iPad)
local guiVisible = true
toggleGuiButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
end)

-- Manejar cuando el jugador seleccionado se desconecta
game.Players.PlayerRemoving:Connect(function(plr)
    if selectedPlayer == plr then
        selectedPlayer = nil
        statusLabel.Text = "Estado: Jugador seleccionado desconectado"
        if isTPActive then
            isTPActive = false
            if tpConnection then
                tpConnection:Disconnect()
                tpConnection = nil
            end
            if cameraConnection then
                cameraConnection:Disconnect()
                cameraConnection = nil
            end
            -- Restaurar cámara a la configuración normal
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
            end
            tpButton.Text = "TP to Player"
            tpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        end
    end
end)

-- Función para activar/desactivar Block Spy
local function toggleBlockSpy()
    isBlockSpyActive = not isBlockSpyActive
    
    if isBlockSpyActive then
        statusLabel.Text = "Estado: Block Spy activado - Usa block para detectar"
        autoBlockButton.BackgroundColor3 = Color3.fromRGB(150, 75, 0)
        autoBlockButton.Text = "Stop Block Spy"
        
        -- Crear una tabla para almacenar los métodos originales
        local originalMethods = {}
        
        -- Función para interceptar llamadas a métodos
        local function hookMethod(object, methodName)
            if not originalMethods[object] then
                originalMethods[object] = {}
            end
            
            originalMethods[object][methodName] = object[methodName]
            
            object[methodName] = function(...)
                local args = {...}
                print("Método detectado: " .. methodName)
                print("Objeto: " .. tostring(object))
                for i, arg in ipairs(args) do
                    print("Argumento " .. i .. ": " .. tostring(arg))
                end
                
                statusLabel.Text = "Block detectado: " .. methodName
                
                return originalMethods[object][methodName](...)
            end
        end
        
        -- Monitorear eventos de entrada
        blockSpyConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed then
                if input.KeyCode == Enum.KeyCode.F then  -- Suponiendo que F es la tecla de bloqueo
                    print("Tecla de bloqueo presionada (F)")
                    
                    -- Intentar capturar eventos del personaje
                    if player.Character then
                        print("Monitoreando eventos del personaje...")
                        
                        -- Monitorear eventos comunes de bloqueo
                        for _, v in pairs(player.Character:GetDescendants()) do
                            if v:IsA("RemoteEvent") then
                                print("RemoteEvent encontrado: " .. v:GetFullName())
                                
                                -- Monitorear FireServer
                                hookMethod(v, "FireServer")
                            end
                            
                            if v:IsA("Animation") or v:IsA("AnimationTrack") then
                                print("Animación encontrada: " .. v:GetFullName())
                            end
                        end
                        
                        -- Monitorear eventos del Humanoid
                        if player.Character:FindFirstChild("Humanoid") then
                            local humanoid = player.Character.Humanoid
                            
                            -- Monitorear animaciones que se reproducen
                            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                                print("Animación activa: " .. track.Name .. " (ID: " .. track.Animation.AnimationId .. ")")
                            end
                            
                            -- Monitorear eventos de estado
                            hookMethod(humanoid, "ChangeState")
                        end
                    end
                    
                    -- Monitorear eventos del ReplicatedStorage
                    for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                        if v:IsA("RemoteEvent") and (v.Name:lower():find("block") or v.Name:lower():find("defend")) then
                            print("Posible RemoteEvent de bloqueo: " .. v:GetFullName())
                            hookMethod(v, "FireServer")
                        end
                    end
                end
            end
        end)
        
    else
        statusLabel.Text = "Estado: Block Spy desactivado"
        autoBlockButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        autoBlockButton.Text = "Block Spy"
        
        if blockSpyConnection then
            blockSpyConnection:Disconnect()
            blockSpyConnection = nil
        end
    end
end

autoBlockButton.MouseButton1Click:Connect(toggleBlockSpy)

-- Limpiar conexiones cuando el script se detiene
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if tpConnection then
        tpConnection:Disconnect()
        tpConnection = nil
    end
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    if blockSpyConnection then
        blockSpyConnection:Disconnect()
        blockSpyConnection = nil
    end
end)

print("LingOnly Scripts cargado correctamente para iPad")
