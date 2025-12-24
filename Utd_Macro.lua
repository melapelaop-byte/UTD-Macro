-- ULTIMATE TOWER DEFENSE - SISTEMA COMPLETO DE MACROS
-- Optimizado para Delta Executor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ====================================
-- CONFIGURACIÓN
-- ====================================

local config = {
    currentMap = nil,
    currentDifficulty = nil,
    isRecording = false,
    isPlaying = false,
    recordedActions = {},
    placedTowers = {},
    startTime = 0,
    minimized = false
}

-- IDs de torres
local towerTypeIds = {
    ["1"] = "2215533182:4409",
    ["2"] = "2215533182:4867",
    ["3"] = "2215533182:4209",
    ["4"] = "2215533182:3907",
    ["5"] = "2215533182:3826",
    ["6"] = "2215533182:4119"
}

local towerNames = {
    ["1"] = "Commando",
    ["2"] = "Rocketeer",
    ["3"] = "Ranger",
    ["4"] = "Militant",
    ["5"] = "Mortar",
    ["6"] = "Torre 6"
}

local mapList = {
    "Crossroads","Pizza Palace","Canals","Graveyard",
    "Abandoned Lab","Winter Outpost","Alien Mothership","Facility"
}

local difficultyList = {"Easy","Medium","Hard","Insane","Nightmare"}

-- ====================================
-- UI
-- ====================================

local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "UTDMacroSystem"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,550,0,600)
MainFrame.Position = UDim2.new(0.5,-275,0.5,-300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,50)
TitleBar.BackgroundColor3 = Color3.fromRGB(30,30,35)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,12)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1,-140,1,0)
TitleLabel.Position = UDim2.new(0,15,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎮 UTD Pro Macro System"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextColor3 = Color3.fromRGB(100,200,255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0,40,0,40)
MinimizeBtn.Position = UDim2.new(1,-90,0,5)
MinimizeBtn.Text = "—"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(70,130,180)
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0,8)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0,40,0,40)
CloseBtn.Position = UDim2.new(1,-45,0,5)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.BackgroundColor3 = Color3.fromRGB(220,50,50)
CloseBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,8)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Position = UDim2.new(0,0,0,50)
ContentFrame.Size = UDim2.new(1,0,1,-50)
ContentFrame.BackgroundTransparency = 1

-- ====================================
-- MACROS
-- ====================================

local MacroInput = Instance.new("TextBox", ContentFrame)
MacroInput.Size = UDim2.new(1,-20,0,200)
MacroInput.Position = UDim2.new(0,10,0,10)
MacroInput.MultiLine = true
MacroInput.ClearTextOnFocus = false
MacroInput.TextWrapped = true
MacroInput.TextYAlignment = Enum.TextYAlignment.Top
MacroInput.Font = Enum.Font.Code
MacroInput.TextSize = 12
MacroInput.PlaceholderText = "Pega aquí tu macro JSON..."
MacroInput.BackgroundColor3 = Color3.fromRGB(40,40,45)
MacroInput.TextColor3 = Color3.fromRGB(220,220,220)
Instance.new("UICorner", MacroInput).CornerRadius = UDim.new(0,8)

local function button(text,pos,color)
    local b = Instance.new("TextButton", ContentFrame)
    b.Size = UDim2.new(0,160,0,35)
    b.Position = pos
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local RecordBtn = button("🔴 Grabar", UDim2.new(0,10,0,220), Color3.fromRGB(220,50,50))
local PlayBtn   = button("▶️ Play",   UDim2.new(0,180,0,220), Color3.fromRGB(70,180,70))
local StopBtn   = button("⏹️ Stop",   UDim2.new(0,350,0,220), Color3.fromRGB(180,70,70))
local LoadBtn   = button("📥 Cargar", UDim2.new(0,10,0,270), Color3.fromRGB(70,130,180))
local ExportBtn = button("📤 Exportar",UDim2.new(0,180,0,270),Color3.fromRGB(100,70,180))
local ClearBtn  = button("🗑️ Limpiar", UDim2.new(0,350,0,270),Color3.fromRGB(150,80,50))

local StatusLabel = Instance.new("TextLabel", ContentFrame)
StatusLabel.Size = UDim2.new(1,-20,0,25)
StatusLabel.Position = UDim2.new(0,10,0,320)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Estado: Listo"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(180,180,180)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ====================================
-- FUNCIONES
-- ====================================

local function startRecording()
    config.isRecording = true
    config.recordedActions = {}
    config.startTime = tick()
    StatusLabel.Text = "🔴 Grabando..."
end

local function stopRecording()
    config.isRecording = false
    StatusLabel.Text = "Grabación detenida ("..#config.recordedActions.." acciones)"
end

local function loadMacro()
    local ok,data = pcall(function()
        return HttpService:JSONDecode(MacroInput.Text)
    end)
    if ok then
        config.recordedActions = data
        StatusLabel.Text = "✅ Macro cargado"
    else
        StatusLabel.Text = "❌ JSON inválido"
    end
end

local function exportMacro()
    MacroInput.Text = HttpService:JSONEncode(config.recordedActions)
    StatusLabel.Text = "📤 Macro exportado"
end

local function clearMacro()
    config.recordedActions = {}
    MacroInput.Text = ""
    StatusLabel.Text = "🗑️ Macro limpiado"
end

local function playMacro()
    if #config.recordedActions == 0 then return end
    config.isPlaying = true
    spawn(function()
        local start = tick()
        for _,a in ipairs(config.recordedActions) do
            if not config.isPlaying then break end
            task.wait(a.Time - (tick()-start))
            if a.TowerPlaced then
                local p = string.split(a.TowerPosition,",")
                ReplicatedStorage.Remotes.PlayerPlaceTower:FireServer(
                    towerTypeIds[a.TowerPlaced],
                    Vector3.new(tonumber(p[1]),tonumber(p[2]),tonumber(p[3]))
                )
            end
        end
        config.isPlaying = false
        StatusLabel.Text = "✅ Macro finalizado"
    end)
end

-- ====================================
-- BOTONES
-- ====================================

RecordBtn.MouseButton1Click:Connect(function()
    if config.isRecording then stopRecording() else startRecording() end
end)

PlayBtn.MouseButton1Click:Connect(playMacro)
StopBtn.MouseButton1Click:Connect(function() config.isPlaying=false end)
LoadBtn.MouseButton1Click:Connect(loadMacro)
ExportBtn.MouseButton1Click:Connect(exportMacro)
ClearBtn.MouseButton1Click:Connect(clearMacro)

MinimizeBtn.MouseButton1Click:Connect(function()
    config.minimized = not config.minimized
    ContentFrame.Visible = not config.minimized
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("✅ UTD PRO MACRO SYSTEM CARGADO")
