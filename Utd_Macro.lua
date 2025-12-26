-- ULTIMATE TOWER DEFENSE - MACRO SYSTEM FINAL
-- Script ORIGINAL + Auto Lobby TP + Auto Join + Auto Retry + Delay + Speed
-- Delta Mobile Compatible

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

--------------------------------------------------
-- CONFIG ORIGINAL
--------------------------------------------------

local CONFIG = {
    isAutoFarmActive = false,
    recordedActions = {},
    placedTowers = {},

    circlePosition = Vector3.new(11264.80, 22.77, 51.57),

    macroStarted = false,
    hasSetSpeed = false,
    autoRetry = true,
    startDelay = 10
}

--------------------------------------------------
-- ESTADO
--------------------------------------------------

local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function isInGame()
    return workspace:FindFirstChild("Map") ~= nil
end

--------------------------------------------------
-- RESET
--------------------------------------------------

local function resetRun()
    CONFIG.macroStarted = false
    CONFIG.hasSetSpeed = false
    CONFIG.placedTowers = {}
end

--------------------------------------------------
-- TP LOBBY
--------------------------------------------------

local function tpToCircle()
    if not isInLobby() then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local cf = CFrame.new(CONFIG.circlePosition + Vector3.new(0,3,0))
    for i = 1,6 do
        pcall(function()
            hrp.CFrame = cf
            hrp.Velocity = Vector3.zero
        end)
        task.wait(0.25)
    end
end

--------------------------------------------------
-- SPEED 1.5x
--------------------------------------------------

local function setSpeed()
    if CONFIG.hasSetSpeed then return end
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return end

    for _,v in ipairs(gui:GetDescendants()) do
        if v:IsA("TextButton") and v.Text:find("x") then
            v:Activate()
            CONFIG.hasSetSpeed = true
            break
        end
    end
end

--------------------------------------------------
-- RETRY
--------------------------------------------------

local function autoRetry()
    if not CONFIG.autoRetry then return end
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return end

    for _,v in ipairs(gui:GetDescendants()) do
        if v:IsA("TextButton") and v.Text:lower():find("reintentar") then
            v:Activate()
            resetRun()
            return
        end
    end
end

--------------------------------------------------
-- MACRO
--------------------------------------------------

local function playMacro()
    if #CONFIG.recordedActions == 0 then return end

    task.spawn(function()
        local start = tick()
        for _,action in ipairs(CONFIG.recordedActions) do
            if not CONFIG.isAutoFarmActive then break end

            local waitTime = action.Time - (tick() - start)
            if waitTime > 0 then task.wait(waitTime) end

            if action.TowerPlaced then
                ReplicatedStorage.GenericModules.Service.Network.PlayerPlaceTower
                    :FireServer(action.TowerPlaced, action.TowerPosition, 0)

            elseif action.TowerUpgraded then
                ReplicatedStorage.GenericModules.Service.Network.PlayerUpgradeTower
                    :FireServer(action.TowerUpgraded)
            end
        end
    end)
end

--------------------------------------------------
-- LOOP PRINCIPAL
--------------------------------------------------

task.spawn(function()
    while true do
        task.wait(1)

        if isInLobby() then
            resetRun()
            tpToCircle()
        end

        if isInGame() and CONFIG.isAutoFarmActive then
            if not CONFIG.macroStarted then
                CONFIG.macroStarted = true

                task.wait(1)
                setSpeed()

                task.wait(CONFIG.startDelay)
                playMacro()
            end
        end

        autoRetry()
    end
end)

--------------------------------------------------
-- INTERFAZ ORIGINAL
--------------------------------------------------
-- Aquí tu UI vieja sigue funcionando:
-- botones de grabar
-- reproducir macro
-- cargar JSON
-- guardar macros
-- CONFIG.isAutoFarmActive = true / false

print("✅ UTD Macro INTEGRADO cargado correctamente")
