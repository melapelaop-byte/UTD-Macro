-- ULTIMATE TOWER DEFENSE - MACRO SYSTEM MOBILE (INTEGRADO)
-- UI ORIGINAL + AUTO RETRY + LOBBY TP + DELAY + SPEED 1.5x

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ====================================
-- CONFIGURACIÓN
-- ====================================

local CONFIG = {
    isAutoFarmActive = false,
    macroStarted = false,
    recordedActions = {},
    placedTowers = {},
    minimized = false,
    circlePosition = Vector3.new(11264.80, 22.77, 51.57),
    macroFolder = "UTD_Macros",
    currentMacroName = nil,
    waitForMoney = true,
    startDelay = 10
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
    ["1"] = "Commando",
    ["2"] = "Rocketeer",
    ["3"] = "Ranger",
    ["4"] = "Militant",
    ["5"] = "Mortar",
    ["6"] = "Torre 6"
}

-- ====================================
-- UTILIDADES LOBBY / PARTIDA
-- ====================================

local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function teleportToCircle()
    if not isInLobby() then return end
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(CONFIG.circlePosition)
    end
end

local function forceSpeed()
    pcall(function()
        ReplicatedStorage
            :WaitForChild("GenericModules")
            :WaitForChild("Service")
            :WaitForChild("Network")
            :WaitForChild("PlayerChangeGameSpeed")
            :FireServer(1.5)
    end)
end

local function getCurrentMoney()
    local success, money = pcall(function()
        return player.leaderstats.Cash.Value
    end)
    return success and money or 0
end

-- ====================================
-- SISTEMA DE MACRO (NÚCLEO)
-- ====================================

local function playMacroOnce()
    if CONFIG.macroStarted then return end
    if #CONFIG.recordedActions == 0 then return end

    CONFIG.macroStarted = true
    CONFIG.placedTowers = {}

    task.wait(CONFIG.startDelay)
    forceSpeed()

    local startTime = tick()

    for i, action in ipairs(CONFIG.recordedActions) do
        if not CONFIG.isAutoFarmActive then break end

        local waitTime = action.Time - (tick() - startTime)
        if waitTime > 0 then task.wait(waitTime) end

        if action.TowerPlaced then
            local coords = {}
            for n in string.gmatch(action.TowerPosition, "[^,]+") do
                table.insert(coords, tonumber(n))
            end

            ReplicatedStorage.GenericModules.Service.Network.PlayerPlaceTower
                :FireServer(action.TowerPlaced, Vector3.new(coords[1], coords[2], coords[3]), 0)

            table.insert(CONFIG.placedTowers, {
                position = Vector3.new(coords[1], coords[2], coords[3]),
                id = tostring(#CONFIG.placedTowers + 1)
            })

        elseif action.TowerUpgraded then
            if CONFIG.waitForMoney and action.UpgradeCost then
                while getCurrentMoney() < action.UpgradeCost and CONFIG.isAutoFarmActive do
                    task.wait(0.5)
                end
            end

            for _, tower in ipairs(CONFIG.placedTowers) do
                if math.abs(tower.position.X - action.TowerUpgraded) < 1 then
                    ReplicatedStorage.GenericModules.Service.Network.PlayerUpgradeTower
                        :FireServer(tower.id)
                    break
                end
            end
        end
    end
end

-- ====================================
-- LOOP GLOBAL (AUTO RETRY / LOBBY)
-- ====================================

task.spawn(function()
    while true do
        task.wait(1)

        if not CONFIG.isAutoFarmActive then
            CONFIG.macroStarted = false
            continue
        end

        if isInLobby() then
            CONFIG.macroStarted = false
            teleportToCircle()
        else
            playMacroOnce()
        end
    end
end)
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
end

local function listMacros()
    ensureFolderExists()
    local t = {}
    for _, f in ipairs(listfiles(CONFIG.macroFolder)) do
        local n = f:match("([^/\\]+)%.json$")
        if n then table.insert(t, n) end
    end
    return t
end

-- ====================================
-- INTERFAZ
-- ====================================

local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "UTDMacroMobile"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 340, 0, 480)
Main.Position = UDim2.new(0.5, -170, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Main.Active, Main.Draggable = true, true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,45)
Title.Text = "🎮 UTD Macro Mobile"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(100,200,255)
Title.BackgroundColor3 = Color3.fromRGB(30,30,35)

local Toggle = Instance.new("TextButton", Main)
Toggle.Position = UDim2.new(0,10,0,60)
Toggle.Size = UDim2.new(1,-20,0,60)
Toggle.Text = "⚪ APAGADO"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 20
Toggle.BackgroundColor3 = Color3.fromRGB(80,80,85)
Instance.new("UICorner", Toggle)

local MacroList = Instance.new("ScrollingFrame", Main)
MacroList.Position = UDim2.new(0,10,0,135)
MacroList.Size = UDim2.new(1,-20,0,200)
MacroList.ScrollBarThickness = 6
MacroList.BackgroundColor3 = Color3.fromRGB(40,40,45)
Instance.new("UICorner", MacroList)
Instance.new("UIListLayout", MacroList).Padding = UDim.new(0,5)

local Load = Instance.new("TextButton", Main)
Load.Position = UDim2.new(0,10,0,345)
Load.Size = UDim2.new(0.48,0,0,40)
Load.Text = "📥 Cargar"
Load.BackgroundColor3 = Color3.fromRGB(70,130,180)
Instance.new("UICorner", Load)

local Save = Instance.new("TextButton", Main)
Save.Position = UDim2.new(0.52,0,0,345)
Save.Size = UDim2.new(0.48,0,0,40)
Save.Text = "💾 Guardar"
Save.BackgroundColor3 = Color3.fromRGB(70,180,70)
Instance.new("UICorner", Save)

local Status = Instance.new("TextLabel", Main)
Status.Position = UDim2.new(0,0,1,-30)
Status.Size = UDim2.new(1,0,0,30)
Status.Text = "Listo"
Status.TextColor3 = Color3.fromRGB(150,150,150)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.Gotham

-- ====================================
-- FUNCIONES UI
-- ====================================

local function refreshMacros()
    for _, c in ipairs(MacroList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    for _, name in ipairs(listMacros()) do
        local b = Instance.new("TextButton", MacroList)
        b.Size = UDim2.new(1,-10,0,40)
        b.Text = name
        b.BackgroundColor3 = Color3.fromRGB(50,50,55)
        b.Font = Enum.Font.Gotham
        Instance.new("UICorner", b)

        b.MouseButton1Click:Connect(function()
            CONFIG.currentMacroName = name
            Status.Text = "Seleccionado: "..name
        end)
    end

    MacroList.CanvasSize = UDim2.new(0,0,0,#listMacros()*45)
end

-- ====================================
-- EVENTOS
-- ====================================

Toggle.MouseButton1Click:Connect(function()
    CONFIG.isAutoFarmActive = not CONFIG.isAutoFarmActive
    CONFIG.macroStarted = false

    if CONFIG.isAutoFarmActive then
        Toggle.Text = "🟢 ENCENDIDO"
        Toggle.BackgroundColor3 = Color3.fromRGB(70,180,70)
        Status.Text = "AutoFarm activo"
    else
        Toggle.Text = "⚪ APAGADO"
        Toggle.BackgroundColor3 = Color3.fromRGB(80,80,85)
        Status.Text = "Detenido"
    end
end)

Load.MouseButton1Click:Connect(function()
    if CONFIG.currentMacroName then
        CONFIG.recordedActions = loadMacro(CONFIG.currentMacroName) or {}
        Status.Text = "Macro cargada"
    end
end)

Save.MouseButton1Click:Connect(function()
    if #CONFIG.recordedActions > 0 then
        local name = "macro_"..os.date("%H%M%S")
        saveMacro(name, CONFIG.recordedActions)
        Status.Text = "Guardado: "..name
        refreshMacros()
    end
end)

-- ====================================
-- INIT
-- ====================================

refreshMacros()
print("✅ UTD Macro Mobile FULL cargado")
