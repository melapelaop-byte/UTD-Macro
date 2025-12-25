-- ULTIMATE TOWER DEFENSE - SISTEMA COMPLETO DE MACROS PRO
-- Optimizado para Delta Executor con Auto-Retry y Guardado

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ====================================
-- CONFIGURACIÓN
-- ====================================

local CONFIG = {
    currentMap = nil,
    currentDifficulty = nil,
    isRecording = false,
    isAutoFarmActive = false,
    recordedActions = {},
    placedTowers = {},
    startTime = 0,
    minimized = false,

    circlePosition = Vector3.new(11264.80, 22.77, 51.57),

    macroFolder = "UTD_Macros",
    configFile = "UTD_Config.json",
    currentMacroName = nil,
    waitForMoney = true
}

-- ====================================
-- TORRES
-- ====================================

local TOWER_IDS = {
    ["1"] = "2215533182:4409",
    ["2"] = "2215533182:4867",
    ["3"] = "2215533182:4209",
    ["4"] = "2215533182:3907",
    ["5"] = "2215533182:3826",
    ["6"] = "2215533182:4119"
}

local TOWER_NAMES = {
    ["1"] = "Commando",
    ["2"] = "Rocketeer",
    ["3"] = "Ranger",
    ["4"] = "Militant",
    ["5"] = "Mortar",
    ["6"] = "Torre 6"
}

local MAP_LIST = {
    "Crossroads","Pizza Palace","Canals","Graveyard",
    "Abandoned Lab","Winter Outpost","Alien Mothership","Facility"
}

local DIFFICULTY_LIST = {"Easy","Medium","Hard","Insane","Nightmare"}

-- ====================================
-- SISTEMA DE ARCHIVOS
-- ====================================

local function ensureFolder()
    if not isfolder(CONFIG.macroFolder) then
        makefolder(CONFIG.macroFolder)
    end
end

local function saveMacro(name,data)
    ensureFolder()
    writefile(CONFIG.macroFolder.."/"..name..".json",HttpService:JSONEncode(data))
end

local function loadMacro(name)
    local path = CONFIG.macroFolder.."/"..name..".json"
    if isfile(path) then
        return HttpService:JSONDecode(readfile(path))
    end
end

local function deleteMacro(name)
    local path = CONFIG.macroFolder.."/"..name..".json"
    if isfile(path) then delfile(path) end
end

local function listMacros()
    ensureFolder()
    local t = {}
    for _,f in ipairs(listfiles(CONFIG.macroFolder)) do
        local n = f:match("([^/\\]+)%.json$")
        if n then table.insert(t,n) end
    end
    return t
end

local function saveConfig()
    writefile(CONFIG.configFile,HttpService:JSONEncode({
        lastMap = CONFIG.currentMap,
        lastDifficulty = CONFIG.currentDifficulty,
        lastMacro = CONFIG.currentMacroName,
        waitForMoney = CONFIG.waitForMoney
    }))
end

local function loadConfig()
    if isfile(CONFIG.configFile) then
        local d = HttpService:JSONDecode(readfile(CONFIG.configFile))
        CONFIG.currentMap = d.lastMap
        CONFIG.currentDifficulty = d.lastDifficulty
        CONFIG.currentMacroName = d.lastMacro
        CONFIG.waitForMoney = d.waitForMoney ~= false
    end
end

-- ====================================
-- UTILIDADES DE JUEGO
-- ====================================

local function getCurrentMoney()
    local ls = player:FindFirstChild("leaderstats")
    return ls and ls:FindFirstChild("Cash") and ls.Cash.Value or 0
end

local function teleportToCircle()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(CONFIG.circlePosition)
    end
end

local function placeTower(id,pos)
    ReplicatedStorage.Remotes.PlayerPlaceTower:FireServer(
        TOWER_IDS[id],pos
    )
end

local function upgradeTower(idx)
    ReplicatedStorage.Remotes.PlayerUpgradeTower:FireServer(idx)
end

-- ====================================
-- INTERFAZ (BASE)
-- ====================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UTDMacroSystemPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainStatusLabel = Instance.new("TextLabel")
MainStatusLabel.Size = UDim2.new(0,600,0,25)
MainStatusLabel.Position = UDim2.new(0.5,-300,0,5)
MainStatusLabel.BackgroundTransparency = 1
MainStatusLabel.Text = "Estado: Listo"
MainStatusLabel.TextColor3 = Color3.fromRGB(200,200,200)
MainStatusLabel.Font = Enum.Font.Gotham
MainStatusLabel.TextSize = 14
MainStatusLabel.Parent = ScreenGui
-- ====================================
-- AUTO FARM
-- ====================================

function playMacroLoop()
    task.spawn(function()
        while CONFIG.isAutoFarmActive do
            CONFIG.placedTowers = {}
            local startTime = tick()

            for i, action in ipairs(CONFIG.recordedActions) do
                if not CONFIG.isAutoFarmActive then break end

                local waitTime = action.Time - (tick() - startTime)
                if waitTime > 0 then task.wait(waitTime) end

                -- COLOCAR TORRE
                if action.TowerPlaced then
                    local coords = {}
                    for c in string.gmatch(action.TowerPosition, "[^,]+") do
                        table.insert(coords, tonumber(c))
                    end
                    local pos = Vector3.new(coords[1], coords[2], coords[3])

                    MainStatusLabel.Text = "▶️ Colocando torre (" .. i .. "/" .. #CONFIG.recordedActions .. ")"
                    placeTower(action.TowerPlaced, pos)

                    table.insert(CONFIG.placedTowers, {
                        position = pos,
                        id = tostring(#CONFIG.placedTowers + 1),
                        towerType = action.TowerPlaced
                    })

                    task.wait(0.2)

                -- MEJORAR TORRE
                elseif action.TowerUpgraded then
                    local cost = action.UpgradeCost or 0

                    if CONFIG.waitForMoney and cost > 0 then
                        while getCurrentMoney() < cost and CONFIG.isAutoFarmActive do
                            MainStatusLabel.Text = "💰 Esperando dinero..."
                            task.wait(0.5)
                        end
                    end

                    local target = CONFIG.placedTowers[action.TowerUpgraded]
                    if target then
                        MainStatusLabel.Text = "⬆️ Mejorando torre (" .. i .. "/" .. #CONFIG.recordedActions .. ")"
                        upgradeTower(target.id)
                    end
                end

                task.wait(0.05)
            end

            MainStatusLabel.Text = "✅ Macro completado - Auto Retry..."
            task.wait(3)

            if CONFIG.isAutoFarmActive then
                teleportToCircle()
                task.wait(2)
            end
        end
    end)
end

function startAutoFarm()
    CONFIG.isAutoFarmActive = true
    MainStatusLabel.Text = "🟢 Auto-Farm activado"
    playMacroLoop()
end

function stopAutoFarm()
    CONFIG.isAutoFarmActive = false
    MainStatusLabel.Text = "⏹️ Auto-Farm detenido"
end

-- ====================================
-- SISTEMA DE GRABACIÓN
-- ====================================

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and CONFIG.isRecording then
        -- COLOCAR TORRE
        if self.Name == "PlayerPlaceTower" then
            local towerGameId = args[1]
            local position = args[2]

            for id, gameId in pairs(TOWER_IDS) do
                if gameId == towerGameId then
                    table.insert(CONFIG.recordedActions, {
                        TowerPlaced = id,
                        TowerPosition = position.X .. "," .. position.Y .. "," .. position.Z,
                        Time = math.floor(tick() - CONFIG.startTime),
                        TotalMoney = getCurrentMoney(),
                        PlaceCost = 0
                    })
                    break
                end
            end

        -- MEJORAR TORRE
        elseif self.Name == "PlayerUpgradeTower" then
            table.insert(CONFIG.recordedActions, {
                TowerUpgraded = #CONFIG.placedTowers,
                Time = math.floor(tick() - CONFIG.startTime),
                TotalMoney = getCurrentMoney(),
                UpgradeCost = 0
            })
        end
    end

    return oldNamecall(self, ...)
end)

function startRecording()
    CONFIG.isRecording = true
    CONFIG.recordedActions = {}
    CONFIG.startTime = tick()
    MainStatusLabel.Text = "🔴 Grabando macro..."
end

function stopRecording()
    CONFIG.isRecording = false
    MainStatusLabel.Text = "⏹️ Grabación detenida (" .. #CONFIG.recordedActions .. " acciones)"
end

-- ====================================
-- CONTROLES RÁPIDOS (TECLAS)
-- ====================================

UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.F6 then
        if CONFIG.isRecording then
            stopRecording()
        else
            startRecording()
        end
    end

    if input.KeyCode == Enum.KeyCode.F7 then
        if CONFIG.isAutoFarmActive then
            stopAutoFarm()
        else
            startAutoFarm()
        end
    end
end)

-- ====================================
-- INICIALIZACIÓN
-- ====================================

loadConfig()

MainStatusLabel.Text = "✅ UTD Pro Macro System cargado"
print("✅ UTD Pro Macro System cargado")
print("📂 Macros guardados:", #listMacros())
print("🎮 Usa F6 para grabar | F7 para Auto-Farm")
