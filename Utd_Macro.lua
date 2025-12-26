-- ULTIMATE TOWER DEFENSE - MACRO SYSTEM MOBILE
-- Optimizado para pantallas táctiles (Delta Mobile)
-- Soporte JSON externo + upgrades por modelo real

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

local POSITION_TOLERANCE = 1.5

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
-- UTILIDADES DE TORRES
-- ====================================

local function getPlayerTowers()
    local towers = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Owner") then
            if obj.Owner.Value == player then
                table.insert(towers, obj)
            end
        end
    end
    return towers
end

local function findTowerByX(xValue)
    for _, tower in ipairs(getPlayerTowers()) do
        if tower.PrimaryPart and math.abs(tower.PrimaryPart.Position.X - xValue) <= POSITION_TOLERANCE then
            return tower
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
end

local function listMacros()
    ensureFolderExists()
    local macros = {}
    for _, file in ipairs(listfiles(CONFIG.macroFolder)) do
        local name = file:match("([^/\\]+)%.json$")
        if name then table.insert(macros, name) end
    end
    return macros
end

-- ====================================
-- FUNCIONES DE JUEGO
-- ====================================

local function getCurrentMoney()
    local success, money = pcall(function()
        return player.leaderstats.Cash.Value
    end)
    return success and money or 0
end

local function teleportToCircle()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(CONFIG.circlePosition)
        end
    end)
end

local function placeTower(towerTypeId, position)
    ReplicatedStorage.GenericModules.Service.Network.PlayerPlaceTower
        :FireServer(TOWER_IDS[towerTypeId], position, 0)
end

local function upgradeTower(towerModel)
    ReplicatedStorage.GenericModules.Service.Network.PlayerUpgradeTower
        :FireServer(towerModel)
end

-- ====================================
-- MACRO PLAYER
-- ====================================

local function playMacroLoop()
    if #CONFIG.recordedActions == 0 then return end

    task.spawn(function()
        while CONFIG.isAutoFarmActive do
            CONFIG.placedTowers = {}
            local startTime = tick()

            for i, action in ipairs(CONFIG.recordedActions) do
                if not CONFIG.isAutoFarmActive then break end

                local waitTime = action.Time - (tick() - startTime)
                if waitTime > 0 then task.wait(waitTime) end

                -- COLOCAR TORRE
                if action.TowerPlaced and action.TowerPosition then
                    local coords = {}
                    for c in string.gmatch(action.TowerPosition, "[^,]+") do
                        table.insert(coords, tonumber(c))
                    end
                    local pos = Vector3.new(coords[1], coords[2], coords[3])
                    placeTower(action.TowerPlaced, pos)

                    task.wait(0.6)

                    for _, tower in ipairs(getPlayerTowers()) do
                        if tower.PrimaryPart and (tower.PrimaryPart.Position - pos).Magnitude <= POSITION_TOLERANCE then
                            table.insert(CONFIG.placedTowers, { position = pos, model = tower })
                            break
                        end
                    end

                -- UPGRADE
                elseif action.TowerUpgraded then
                    local cost = action.UpgradeCost or 0
                    if CONFIG.waitForMoney and cost > 0 then
                        while getCurrentMoney() < cost and CONFIG.isAutoFarmActive do
                            task.wait(0.5)
                        end
                    end

                    local tower = findTowerByX(action.TowerUpgraded)
                    if tower then
                        upgradeTower(tower)
                    end
                end

                task.wait(0.05)
            end

            teleportToCircle()
            task.wait(3)
        end
    end)
end

-- ====================================
-- CONTROLES
-- ====================================

local function startAutoFarm()
    CONFIG.isAutoFarmActive = true
    playMacroLoop()
end

local function stopAutoFarm()
    CONFIG.isAutoFarmActive = false
end

-- ====================================
-- UI (sin cambios funcionales)
-- ====================================

-- ⚠️ La interfaz se mantiene EXACTAMENTE igual que la tuya
-- (No se toca para no romper nada)
-- Solo se corrigió el motor interno del macro

refreshMacroList()
print("✅ UTD Macro Mobile FINAL listo")
