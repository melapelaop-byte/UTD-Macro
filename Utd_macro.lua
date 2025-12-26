-- ULTIMATE TOWER DEFENSE - MACRO SYSTEM MOBILE COMPLETO
-- Con PERSISTENCIA DE CONFIGURACIÓN entre ejecuciones
-- Delta Mobile Compatible

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ====================================
-- CONFIGURACIÓN CON PERSISTENCIA
-- ====================================

local CONFIG = {
    isAutoFarmActive = false,
    recordedActions = {},
    placedTowers = {},
    minimized = false,
    circlePosition = Vector3.new(11264.80, 22.77, 51.57),
    macroFolder = "UTD_Macros",
    configFile = "UTD_Config.json",
    currentMacroName = nil,
    
    -- Opciones persistentes
    macroStarted = false,
    hasSetSpeed = false,
    autoRetry = true,
    startDelay = 10
}

-- ====================================
-- GUARDAR/CARGAR CONFIG
-- ====================================

local function saveConfig()
    local data = {
        isAutoFarmActive = CONFIG.isAutoFarmActive,
        currentMacroName = CONFIG.currentMacroName,
        autoRetry = CONFIG.autoRetry,
        startDelay = CONFIG.startDelay,
        recordedActions = CONFIG.recordedActions,
        minimized = CONFIG.minimized
    }
    writefile(CONFIG.configFile, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(CONFIG.configFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG.configFile))
        end)
        
        if success and data then
            CONFIG.isAutoFarmActive = data.isAutoFarmActive or false
            CONFIG.currentMacroName = data.currentMacroName
            CONFIG.autoRetry = data.autoRetry ~= nil and data.autoRetry or true
            CONFIG.startDelay = data.startDelay or 10
            CONFIG.recordedActions = data.recordedActions or {}
            CONFIG.minimized = data.minimized or false
            return true
        end
    end
    return false
end

-- ====================================
-- FUNCIONES DE ESTADO
-- ====================================

local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function isInGame()
    return workspace:FindFirstChild("Map") ~= nil
end

local function resetRun()
    CONFIG.macroStarted = false
    CONFIG.hasSetSpeed = false
    CONFIG.placedTowers = {}
end

-- ====================================
-- TP AL CÍRCULO
-- ====================================

local function tpToCircle()
    if not isInLobby() then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local cf = CFrame.new(CONFIG.circlePosition + Vector3.new(0, 3, 0))
    for i = 1, 6 do
        pcall(function()
            hrp.CFrame = cf
            hrp.Velocity = Vector3.zero
        end)
        task.wait(0.25)
    end
end

-- ====================================
-- VELOCIDAD 1.5x AUTOMÁTICA
-- ====================================

local function setSpeed()
    if CONFIG.hasSetSpeed then return end
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return end

    for _, v in ipairs(gui:GetDescendants()) do
        if v:IsA("TextButton") and v.Text:find("x") then
            pcall(function()
                v:Activate()
            end)
            CONFIG.hasSetSpeed = true
            break
        end
    end
end

-- ====================================
-- AUTO RETRY
-- ====================================

local function autoRetry()
    if not CONFIG.autoRetry then return end
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return end

    for _, v in ipairs(gui:GetDescendants()) do
        if v:IsA("TextButton") and (v.Text:lower():find("reintentar") or v.Text:lower():find("retry")) then
            pcall(function()
                v:Activate()
            end)
            resetRun()
            return
        end
    end
end

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
-- EJECUTAR MACRO
-- ====================================

local function playMacro()
    if #CONFIG.recordedActions == 0 then return end

    task.spawn(function()
        local start = tick()
        for _, action in ipairs(CONFIG.recordedActions) do
            if not CONFIG.isAutoFarmActive then break end

            local waitTime = action.Time - (tick() - start)
            if waitTime > 0 then task.wait(waitTime) end

            pcall(function()
                if action.TowerPlaced then
                    ReplicatedStorage.GenericModules.Service.Network.PlayerPlaceTower
                        :FireServer(action.TowerPlaced, action.TowerPosition, 0)

                elseif action.TowerUpgraded then
                    ReplicatedStorage.GenericModules.Service.Network.PlayerUpgradeTower
                        :FireServer(action.TowerUpgraded)
                end
            end)
        end
    end)
end

-- ====================================
-- INTERFAZ MÓVIL COMPACTA
-- ====================================

-- Verificar si ya existe la GUI
local existingGui = player.PlayerGui:FindFirstChild("UTDMacroMobile")
if existingGui then
    existingGui:Destroy()
    task.wait(0.1)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UTDMacroMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 520)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -260)
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
TitleLabel.Text = "🎮 UTD Macro Pro"
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

-- Toggle Auto-Farm
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

-- Opciones
local OptionsFrame = Instance.new("Frame")
OptionsFrame.Size = UDim2.new(1, -20, 0, 80)
OptionsFrame.Position = UDim2.new(0, 10, 0, 80)
OptionsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
OptionsFrame.BorderSizePixel = 0
OptionsFrame.Parent = ContentFrame

local OptionsCorner = Instance.new("UICorner")
OptionsCorner.CornerRadius = UDim.new(0, 10)
OptionsCorner.Parent = OptionsFrame

local RetryToggle = Instance.new("TextButton")
RetryToggle.Size = UDim2.new(1, -20, 0, 30)
RetryToggle.Position = UDim2.new(0, 10, 0, 10)
RetryToggle.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
RetryToggle.Text = "🔄 Auto-Retry: ON"
RetryToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RetryToggle.TextSize = 14
RetryToggle.Font = Enum.Font.GothamBold
RetryToggle.Parent = OptionsFrame

local RetryCorner = Instance.new("UICorner")
RetryCorner.CornerRadius = UDim.new(0, 6)
RetryCorner.Parent = RetryToggle

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(1, -20, 0, 30)
DelayLabel.Position = UDim2.new(0, 10, 0, 45)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "⏱️ Delay: " .. CONFIG.startDelay .. "s"
DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DelayLabel.TextSize = 14
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = OptionsFrame

-- Sección Macros
local MacroSection = Instance.new("Frame")
MacroSection.Size = UDim2.new(1, -20, 0, 180)
MacroSection.Position = UDim2.new(0, 10, 0, 170)
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
ActionSection.Size = UDim2.new(1, -20, 0, 100)
ActionSection.Position = UDim2.new(0, 10, 0, 360)
ActionSection.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ActionSection.BorderSizePixel = 0
ActionSection.Parent = ContentFrame

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 10)
ActionCorner.Parent = ActionSection

local PasteBtn = Instance.new("TextButton")
PasteBtn.Size = UDim2.new(1, -20, 0, 40)
PasteBtn.Position = UDim2.new(0, 10, 0, 10)
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
SaveBtn.Position = UDim2.new(0, 10, 0, 55)
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
StatusLabel.Position = UDim2.new(0, 10, 0, 470)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Listo"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = ContentFrame

-- ====================================
-- FUNCIONES UI
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
        
        -- Resaltar el macro actual
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

function updateUIFromConfig()
    -- Actualizar botón Auto-Farm
    if CONFIG.isAutoFarmActive then
        AutoFarmToggle.Text = "🟢 ENCENDIDO"
        AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
        AutoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        AutoFarmToggle.Text = "⚪ APAGADO"
        AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
        AutoFarmToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    
    -- Actualizar botón Auto-Retry
    if CONFIG.autoRetry then
        RetryToggle.Text = "🔄 Auto-Retry: ON"
        RetryToggle.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
    else
        RetryToggle.Text = "⏸️ Auto-Retry: OFF"
        RetryToggle.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
    end
    
    -- Actualizar delay
    DelayLabel.Text = "⏱️ Delay: " .. CONFIG.startDelay .. "s"
    
    -- Actualizar minimizado
    if CONFIG.minimized then
        MainFrame.Size = UDim2.new(0, 340, 0, 45)
        ContentFrame.Visible = false
        MinimizeBtn.Text = "□"
    end
end

function startAutoFarm()
    CONFIG.isAutoFarmActive = true
    AutoFarmToggle.Text = "🟢 ENCENDIDO"
    AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
    AutoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    updateStatus("🟢 Activo", Color3.fromRGB(100, 255, 100))
    saveConfig()
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
        ContentFrame.Visible = false
        MinimizeBtn.Text = "□"
    else
        MainFrame:TweenSize(UDim2.new(0, 340, 0, 520), "Out", "Quad", 0.3, true)
        ContentFrame.Visible = true
        MinimizeBtn.Text = "—"
    end
    saveConfig()
end

-- ====================================
-- EVENTOS UI
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

RetryToggle.MouseButton1Click:Connect(function()
    CONFIG.autoRetry = not CONFIG.autoRetry
    if CONFIG.autoRetry then
        RetryToggle.Text = "🔄 Auto-Retry: ON"
        RetryToggle.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
    else
        RetryToggle.Text = "⏸️ Auto-Retry: OFF"
        RetryToggle.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
    end
    saveConfig()
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
        saveConfig()
    else
        updateStatus("❌ Error", Color3.fromRGB(255, 100, 100))
    end
end)

DeleteBtn.MouseButton1Click:Connect(function()
    if not CONFIG.currentMacroName then
        updateStatus("⚠️ Selecciona macro", Color3.fromRGB(255, 150, 50))
        return
    end

    
