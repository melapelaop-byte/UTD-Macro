
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local CONFIG = {
    isAutoFarmActive = false,
    recordedActions = {},
    placedTowers = {},
    minimized = false,
    circlePosition = Vector3.new(11264.80, 22.77, 51.57),
    macroFolder = "UTD_Macros",
    configFile = "UTD_Config.json",
    currentMacroName = nil,
    waitForMoney = true,
    retryDetected = false,
    inGame = false
}

local TOWER_IDS = {
    ["1"] = "2215533182:4409",
    ["2"] = "2215533182:4867",
    ["3"] = "2215533182:4209",
    ["4"] = "2215533182:3907",
    ["5"] = "2215533182:3826",
    ["6"] = "2215533182:4119",
}

local TOWER_NAMES = {
    ["1"] = "Commando", ["2"] = "Rocketeer", ["3"] = "Ranger",
    ["4"] = "Militant", ["5"] = "Mortar", ["6"] = "Torre 6"
}

-- ====================================
-- FUNCIONES DE DETECCIÓN
-- ====================================

function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

function isInGame()
    return workspace:FindFirstChild("Map") ~= nil
end

-- ====================================
-- SISTEMA DE ARCHIVOS
-- ====================================

local function ensureFolderExists()
    if not isfolder(CONFIG.macroFolder) then
        makefolder(CONFIG.macroFolder)
    end
end

local function saveMacro(name, data)
    ensureFolderExists()
    writefile(CONFIG.macroFolder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
end

local function loadMacro(name)
    local path = CONFIG.macroFolder .. "/" .. name .. ".json"
    if isfile(path) then
        return HttpService:JSONDecode(readfile(path))
    end
    return nil
end

local function listMacros()
    ensureFolderExists()
    local files = listfiles(CONFIG.macroFolder)
    local macros = {}
    for _, file in ipairs(files) do
        local name = file:match("([^/\\]+)%.json$")
        if name then table.insert(macros, name) end
    end
    return macros
end

local function saveConfig()
    ensureFolderExists()
    local config = {
        currentMacroName = CONFIG.currentMacroName,
        waitForMoney = CONFIG.waitForMoney,
        isAutoFarmActive = CONFIG.isAutoFarmActive,
        recordedActionsCount = #CONFIG.recordedActions
    }
    writefile(CONFIG.configFile, HttpService:JSONEncode(config))
    print("💾 Config guardada")
end

local function loadConfig()
    if isfile(CONFIG.configFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG.configFile))
        end)
        
        if success then
            CONFIG.currentMacroName = data.currentMacroName
            CONFIG.waitForMoney = data.waitForMoney or true
            
            -- Cargar el macro guardado
            if CONFIG.currentMacroName then
                local macroData = loadMacro(CONFIG.currentMacroName)
                if macroData then
                    CONFIG.recordedActions = macroData
                    print("✅ Config restaurada: " .. CONFIG.currentMacroName)
                end
            end
            
            -- Reactivar auto-farm si estaba activo
            if data.isAutoFarmActive then
                task.delay(1, function()
                    startAutoFarm()
                end)
            end
        end
    end
end

-- ====================================
-- INTERFAZ MÓVIL
-- ====================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UTDMacroMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎮 UTD Macro"
TitleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -75, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -45)
ContentFrame.Position = UDim2.new(0, 0, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local AutoFarmToggle = Instance.new("TextButton")
AutoFarmToggle.Size = UDim2.new(1, -20, 0, 60)
AutoFarmToggle.Position = UDim2.new(0, 10, 0, 10)
AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
AutoFarmToggle.Text = "⚪ APAGADO"
AutoFarmToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoFarmToggle.TextSize = 20
AutoFarmToggle.Font = Enum.Font.GothamBold
AutoFarmToggle.Parent = ContentFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = AutoFarmToggle

local MacroSection = Instance.new("Frame")
MacroSection.Size = UDim2.new(1, -20, 0, 180)
MacroSection.Position = UDim2.new(0, 10, 0, 80)
MacroSection.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MacroSection.BorderSizePixel = 0
MacroSection.Parent = ContentFrame

local MacroCorner = Instance.new("UICorner")
MacroCorner.CornerRadius = UDim.new(0, 10)
MacroCorner.Parent = MacroSection

local MacroLabel = Instance.new("TextLabel")
MacroLabel.Size = UDim2.new(1, -20, 0, 30)
MacroLabel.Position = UDim2.new(0, 10, 0, 5)
MacroLabel.BackgroundTransparency = 1
MacroLabel.Text = "📂 Macros:"
MacroLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
MacroLabel.TextSize = 14
MacroLabel.Font = Enum.Font.GothamSemibold
MacroLabel.TextXAlignment = Enum.TextXAlignment.Left
MacroLabel.Parent = MacroSection

local MacroList = Instance.new("ScrollingFrame")
MacroList.Size = UDim2.new(1, -20, 0, 90)
MacroList.Position = UDim2.new(0, 10, 0, 40)
MacroList.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MacroList.BorderSizePixel = 0
MacroList.ScrollBarThickness = 6
MacroList.Parent = MacroSection

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 8)
ListCorner.Parent = MacroList

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = MacroList

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.48, 0, 0, 35)
LoadBtn.Position = UDim2.new(0, 10, 0, 140)
LoadBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
LoadBtn.Text = "📥 Cargar"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.TextSize = 14
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.Parent = MacroSection

local LoadCorner = Instance.new("UICorner")
LoadCorner.CornerRadius = UDim.new(0, 8)
LoadCorner.Parent = LoadBtn

local DeleteBtn = Instance.new("TextButton")
DeleteBtn.Size = UDim2.new(0.48, 0, 0, 35)
DeleteBtn.Position = UDim2.new(0.52, 0, 0, 140)
DeleteBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
DeleteBtn.Text = "🗑️ Borrar"
DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DeleteBtn.TextSize = 14
DeleteBtn.Font = Enum.Font.GothamBold
DeleteBtn.Parent = MacroSection

local DeleteCorner = Instance.new("UICorner")
DeleteCorner.CornerRadius = UDim.new(0, 8)
DeleteCorner.Parent = DeleteBtn

local ActionSection = Instance.new("Frame")
ActionSection.Size = UDim2.new(1, -20, 0, 180)
ActionSection.Position = UDim2.new(0, 10, 0, 270)
ActionSection.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ActionSection.BorderSizePixel = 0
ActionSection.Parent = ContentFrame

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 10)
ActionCorner.Parent = ActionSection

local ActionLabel = Instance.new("TextLabel")
ActionLabel.Size = UDim2.new(1, -20, 0, 30)
ActionLabel.Position = UDim2.new(0, 10, 0, 5)
ActionLabel.BackgroundTransparency = 1
ActionLabel.Text = "⚙️ Acciones:"
ActionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ActionLabel.TextSize = 14
ActionLabel.Font = Enum.Font.GothamSemibold
ActionLabel.TextXAlignment = Enum.TextXAlignment.Left
ActionLabel.Parent = ActionSection

local PasteBtn = Instance.new("TextButton")
PasteBtn.Size = UDim2.new(1, -20, 0, 40)
PasteBtn.Position = UDim2.new(0, 10, 0, 40)
PasteBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 180)
PasteBtn.Text = "📋 Pegar Macro"
PasteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PasteBtn.TextSize = 15
PasteBtn.Font = Enum.Font.GothamBold
PasteBtn.Parent = ActionSection

local PasteCorner = Instance.new("UICorner")
PasteCorner.CornerRadius = UDim.new(0, 8)
PasteCorner.Parent = PasteBtn

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(1, -20, 0, 40)
SaveBtn.Position = UDim2.new(0, 10, 0, 90)
SaveBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
SaveBtn.Text = "💾 Guardar Actual"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.TextSize = 15
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.Parent = ActionSection

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 8)
SaveCorner.Parent = SaveBtn

local RetryBtn = Instance.new("TextButton")
RetryBtn.Size = UDim2.new(1, -20, 0, 35)
RetryBtn.Position = UDim2.new(0, 10, 0, 140)
RetryBtn.BackgroundColor3 = Color3.fromRGB(220, 160, 50)
RetryBtn.Text = "🔄 Marcar Retry"
RetryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RetryBtn.TextSize = 14
RetryBtn.Font = Enum.Font.GothamBold
RetryBtn.Parent = ActionSection

local RetryCorner = Instance.new("UICorner")
RetryCorner.CornerRadius = UDim.new(0, 8)
RetryCorner.Parent = RetryBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 460)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Listo"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = ContentFrame

-- ====================================
-- FUNCIONES PRINCIPALES
-- ====================================

function updateStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color or Color3.fromRGB(150, 150, 150)
end

function refreshMacroList()
    for _, child in ipairs(MacroList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local macros = listMacros()
    for i, name in ipairs(macros) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.Parent = MacroList
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        -- Resaltar si es el macro actual
        if name == CONFIG.currentMacroName then
            btn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        end
        
        btn.MouseButton1Click:Connect(function()
            CONFIG.currentMacroName = name
            for _, b in ipairs(MacroList:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
            saveConfig()
        end)
    end
    
    MacroList.CanvasSize = UDim2.new(0, 0, 0, #macros * 45)
end

function getCurrentMoney()
    local success, money = pcall(function()
        return player.leaderstats.Cash.Value or 0
    end)
    return success and money or 0
end

function teleportToCircle()
    if not isInLobby() then
        updateStatus("⚠️ No estás en lobby", Color3.fromRGB(255, 150, 50))
        return
    end
    
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(CONFIG.circlePosition)
            updateStatus("📍 TP al círculo", Color3.fromRGB(100, 200, 255))
        end
    end)
end

function placeTower(towerTypeId, position)
    pcall(function()
        local towerGameId = TOWER_IDS[towerTypeId]
        ReplicatedStorage:WaitForChild("GenericModules")
            :WaitForChild("Service")
            :WaitForChild("Network")
            :WaitForChild("PlayerPlaceTower")
            :FireServer(towerGameId, Vector3.new(position.X, position.Y, position.Z), 0)
    end)
end

function upgradeTower(towerId)
    pcall(function()
        ReplicatedStorage:WaitForChild("GenericModules")
            :WaitForChild("Service")
            :WaitForChild("Network")
            :WaitForChild("PlayerUpgradeTower")
            :FireServer(towerId)
    end)
end

function playMacro()
    if #CONFIG.recordedActions == 0 then
        updateStatus("⚠️ No hay macro", Color3.fromRGB(255, 150, 50))
        return
    end
    
    -- Delay inicial de 5 segundos
    updateStatus("⏳ Esperando 5 seg...", Color3.fromRGB(255, 200, 50))
    wait(5)
    
    CONFIG.placedTowers = {}
    local startTime = tick()
    
    for i, action in ipairs(CONFIG.recordedActions) do
        if not CONFIG.isAutoFarmActive then break end
        if not isInGame() then break end
        
        local targetTime = action.Time
        local waitTime = targetTime - (tick() - startTime)
        if waitTime > 0 then wait(waitTime) end
        
        if action.TowerPlaced then
            local towerId = action.TowerPlaced
            local towerName = TOWER_NAMES[towerId] or "Torre"
            local posStr = action.TowerPosition
            
            local coords = {}
            for coord in string.gmatch(posStr, "[^,]+") do
                table.insert(coords, tonumber(coord))
            end
            
            local position = Vector3.new(coords[1], coords[2], coords[3])
            
            updateStatus("▶️ " .. towerName .. " " .. i .. "/" .. #CONFIG.recordedActions, Color3.fromRGB(100, 200, 255))
            placeTower(towerId, position)
            
            table.insert(CONFIG.placedTowers, {
                position = position,
                id = tostring(#CONFIG.placedTowers + 1)
            })
            
            wait(0.3) -- Delay entre acciones
            
        elseif action.TowerUpgraded then
            local towerX = action.TowerUpgraded
            local upgradeCost = action.UpgradeCost or 0
            
            if CONFIG.waitForMoney and upgradeCost > 0 then
                local waitStart = tick()
                while getCurrentMoney() < upgradeCost and CONFIG.isAutoFarmActive do
                    updateStatus("💰 $" .. upgradeCost, Color3.fromRGB(255, 200, 50))
                    wait(0.5)
                    if tick() - waitStart > 60 then break end
                end
            end
            
            local targetTower = nil
            for _, tower in ipairs(CONFIG.placedTowers) do
                if math.abs(tower.position.X - towerX) < 1 then
                    targetTower = tower
                    break
                end
            end
            
            if targetTower then
                updateStatus("⬆️ Upgrade " .. i .. "/" .. #CONFIG.recordedActions, Color3.fromRGB(100, 255, 100))
                upgradeTower(targetTower.id)
            end
            
            wait(0.3) -- Delay entre acciones
        end
    end
    
    updateStatus("✅ Macro completado", Color3.fromRGB(100, 255, 100))
end

function autoFarmLoop()
    spawn(function()
        while CONFIG.isAutoFarmActive do
            -- Si estamos en lobby, TP al círculo
            if isInLobby() then
                updateStatus("📍 En lobby, TP...", Color3.fromRGB(100, 200, 255))
                teleportToCircle()
                
                -- Esperar a que nos manden a la partida
                repeat
                    wait(1)
                until isInGame() or not CONFIG.isAutoFarmActive
                
                if not CONFIG.isAutoFarmActive then break end
                updateStatus("✅ En partida", Color3.fromRGB(100, 255, 100))
            end
            
            -- Si estamos en partida, ejecutar macro
            if isInGame() and CONFIG.isAutoFarmActive then
                CONFIG.inGame = true
                playMacro()
                
                -- Esperar a que termine la partida o detectar retry
                repeat
                    wait(1)
                until not isInGame() or CONFIG.retryDetected or not CONFIG.isAutoFarmActive
                
                if CONFIG.retryDetected then
                    updateStatus("🔄 Retry detectado", Color3.fromRGB(255, 200, 50))
                    CONFIG.retryDetected = false
                    wait(2)
                    -- Volver a ejecutar macro
                else
                    -- Volver al lobby
                    updateStatus("🔄 Volviendo a lobby...", Color3.fromRGB(255, 200, 50))
                    wait(3)
                end
                
                CONFIG.inGame = false
            end
            
            wait(1)
        end
    end)
end

function startAutoFarm()
    if #CONFIG.recordedActions == 0 then
        updateStatus("⚠️ No hay macro cargado", Color3.fromRGB(255, 150, 50))
        return
    end
    
    CONFIG.isAutoFarmActive = true
    AutoFarmToggle.Text = "🟢 ENCENDIDO"
    AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
    AutoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    updateStatus("🟢 Auto-Farm activo", Color3.fromRGB(100, 255, 100))
    saveConfig()
    autoFarmLoop()
end

function stopAutoFarm()
    CONFIG.isAutoFarmActive = false
    AutoFarmToggle.Text = "⚪ APAGADO"
    AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
    AutoFarmToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    updateStatus("⏹️ Detenido", Color3.fromRGB(150, 150, 150))
    saveConfig()
end

function toggleMinimize()
    CONFIG.minimized = not CONFIG.minimized
    if CONFIG.minimized then
        MainFrame:TweenSize(UDim2.new(0, 340, 0, 45), "Out", "Quad", 0.3, true)
        ContentFrame.Vis
