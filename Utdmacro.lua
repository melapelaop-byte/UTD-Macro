-- ULTIMATE TOWER DEFENSE - MACRO SYSTEM MOBILE
-- Optimizado para pantallas táctiles (Delta Mobile)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ====================================
-- CONFIGURACIÓN
-- ====================================

local CONFIG = {
    isAutoFarmActive = false,
    recordedActions = {},
    placedTowers = {},
    minimized = false,
    circlePosition = Vector3.new(11264.80, 22.77, 51.57),
    macroFolder = "UTD_Macros",
    currentMacroName = nil,
    waitForMoney = true
}

local TOWER_IDS = {
    ["1"] = "2215533182:4409",  -- Commando
    ["2"] = "2215533182:4867",  -- Rocketeer
    ["3"] = "2215533182:4209",  -- Ranger
    ["4"] = "2215533182:3907",  -- Militant
    ["5"] = "2215533182:3826",  -- Mortar
    ["6"] = "2215533182:4119",  -- Torre 6
}

local TOWER_NAMES = {
    ["1"] = "Commando", ["2"] = "Rocketeer", ["3"] = "Ranger",
    ["4"] = "Militant", ["5"] = "Mortar", ["6"] = "Torre 6"
}

-- ====================================
-- FUNCIONES DE ARCHIVOS
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

-- ====================================
-- INTERFAZ MÓVIL COMPACTA
-- ====================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UTDMacroMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame Principal (más pequeño)
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

-- Barra de título
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

-- Botón Minimizar
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

-- Botón Cerrar
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

-- Contenedor
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -45)
ContentFrame.Position = UDim2.new(0, 0, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Toggle Auto-Farm (GRANDE Y VISIBLE)
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

-- Sección Macros
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
MacroLabel.Text = "📂 Macros Guardados:"
MacroLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
MacroLabel.TextSize = 14
MacroLabel.Font = Enum.Font.GothamSemibold
MacroLabel.TextXAlignment = Enum.TextXAlignment.Left
MacroLabel.Parent = MacroSection

-- Lista de macros
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

-- Botones de macro
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

-- Sección Acciones
local ActionSection = Instance.new("Frame")
ActionSection.Size = UDim2.new(1, -20, 0, 140)
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

-- Label de estado
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 420)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Listo"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = ContentFrame

-- ====================================
-- FUNCIONES
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
        
        btn.MouseButton1Click:Connect(function()
            CONFIG.currentMacroName = name
            for _, b in ipairs(MacroList:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
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
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(CONFIG.circlePosition)
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

function playMacroLoop()
    if #CONFIG.recordedActions == 0 then
        updateStatus("⚠️ No hay macro", Color3.fromRGB(255, 150, 50))
        return
    end
    
    spawn(function()
        while CONFIG.isAutoFarmActive do
            CONFIG.placedTowers = {}
            local startTime = tick()
            
            for i, action in ipairs(CONFIG.recordedActions) do
                if not CONFIG.isAutoFarmActive then break end
                
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
                    
                    wait(0.2)
                    
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
                end
                
                wait(0.05)
            end
            
            updateStatus("✅ Completado", Color3.fromRGB(100, 255, 100))
            wait(5)
            
            if CONFIG.isAutoFarmActive then
                updateStatus("🔄 Auto-retry...", Color3.fromRGB(255, 200, 50))
                teleportToCircle()
                wait(2)
            end
        end
    end)
end

function startAutoFarm()
    CONFIG.isAutoFarmActive = true
    AutoFarmToggle.Text = "🟢 ENCENDIDO"
    AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
    AutoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    updateStatus("🟢 Activo", Color3.fromRGB(100, 255, 100))
    playMacroLoop()
end

function stopAutoFarm()
    CONFIG.isAutoFarmActive = false
    AutoFarmToggle.Text = "⚪ APAGADO"
    AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
    AutoFarmToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    updateStatus("⏹️ Detenido", Color3.fromRGB(150, 150, 150))
end

function toggleMinimize()
    CONFIG.minimized = not CONFIG.minimized
    if CONFIG.minimized then
        MainFrame:TweenSize(UDim2.new(0, 340, 0, 45), "Out", "Quad", 0.3, true)
        ContentFrame.Visible = false
        MinimizeBtn.Text = "□"
    else
        MainFrame:TweenSize(UDim2.new(0, 340, 0, 480), "Out", "Quad", 0.3, true)
        ContentFrame.Visible = true
        MinimizeBtn.Text = "—"
    end
end

-- ====================================
-- EVENTOS
-- ====================================

MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)

CloseBtn.MouseButton1Click:Connect(function()
    stopAutoFarm()
    ScreenGui:Destroy()
end)

AutoFarmToggle.MouseButton1Click:Connect(function()
    if CONFIG.isAutoFarmActive then
        stopAutoFarm()
    else
        startAutoFarm()
    end
end)

LoadBtn.MouseButton1Click:Connect(function()
    if not CONFIG.currentMacroName then
        updateStatus("⚠️ Selecciona macro", Color3.fromRGB(255, 150, 50))
        return
    end
    
    local data = loadMacro(CONFIG.currentMacroName)
    if data then
        CONFIG.recordedActions = data
        updateStatus("✅ " .. CONFIG.currentMacroName, Color3.fromRGB(100, 255, 100))
    else
        updateStatus("❌ Error", Color3.fromRGB(255, 100, 100))
    end
end)

DeleteBtn.MouseButton1Click:Connect(function()
    if not CONFIG.currentMacroName then
        updateStatus("⚠️ Selecciona macro", Color3.fromRGB(255, 150, 50))
        return
    end
    
    local path = CONFIG.macroFolder .. "/" .. CONFIG.currentMacroName .. ".json"
    if isfile(path) then
        delfile(path)
    end
    CONFIG.currentMacroName = nil
    updateStatus("🗑️ Eliminado", Color3.fromRGB(150, 150, 150))
    refreshMacroList()
end)

PasteBtn.MouseButton1Click:Connect(function()
    local clipboard = getclipboard and getclipboard() or ""
    if clipboard == "" then
        updateStatus("⚠️ Portapapeles vacío", Color3.fromRGB(255, 150, 50))
        return
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(clipboard)
    end)
    
    if success then
        CONFIG.recordedActions = data
        updateStatus("✅ " .. #data .. " acciones", Color3.fromRGB(100, 255, 100))
    else
        updateStatus("❌ JSON inválido", Color3.fromRGB(255, 100, 100))
    end
end)

SaveBtn.MouseButton1Click:Connect(function()
    if #CONFIG.recordedActions == 0 then
        updateStatus("⚠️ No hay macro", Color3.fromRGB(255, 150, 50))
        return
    end
    
    local name = "macro_" .. os.date("%H%M%S")
    saveMacro(name, CONFIG.recordedActions)
    updateStatus("💾 " .. name, Color3.fromRGB(100, 255, 100))
    refreshMacroList()
end)

-- ====================================
-- INICIALIZACIÓN
-- ====================================

refreshMacroList()
updateStatus("✅ Listo", Color3.fromRGB(100, 255, 100))
print("✅ UTD Macro Mobile cargado")
