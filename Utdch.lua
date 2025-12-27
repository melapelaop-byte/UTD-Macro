-- UTD AUTO MACRO - DELTA MOBILE
-- Grabar / Reproducir / Auto Start / Auto Retry / Persistente
-- UI flotante | CoreGui | Mobile Friendly

-- ===============================
-- SERVICIOS
-- ===============================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ===============================
-- REMOTES
-- ===============================
local Network = ReplicatedStorage
    :WaitForChild("GenericModules")
    :WaitForChild("Service")
    :WaitForChild("Network")

local PlaceRemote   = Network:WaitForChild("PlayerPlaceTower")
local UpgradeRemote = Network:WaitForChild("PlayerUpgradeTower")
local SellRemote    = Network:FindFirstChild("PlayerSellTower") 
                    or Network:FindFirstChild("PlayerRemoveTower")

-- ===============================
-- CONFIG PERSISTENTE
-- ===============================
local SAVE_KEY = "UTD_MACRO_CONFIG_V1"

local CONFIG = {
    recorded = {},
    autoStart = true,
    autoRetry = true,
    speed = 1.5
}

-- Cargar
pcall(function()
    if isfile(SAVE_KEY) then
        CONFIG = HttpService:JSONDecode(readfile(SAVE_KEY))
    end
end)

local function save()
    writefile(SAVE_KEY, HttpService:JSONEncode(CONFIG))
end

-- ===============================
-- ESTADO
-- ===============================
local recording = false
local playing = false
local startTick = 0

-- ===============================
-- UTILIDADES
-- ===============================
local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function getCash()
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Cash") then
        return stats.Cash.Value
    end
    return 0
end

local function waitForCash(amount)
    while getCash() < amount do
        task.wait(0.2)
    end
end

-- ===============================
-- TELEPORT SOLO EN LOBBY
-- ===============================
task.spawn(function()
    task.wait(2)
    if isInLobby() then
        local hrp = player.Character and player.Character:WaitForChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(11267.60, 22.89, 50.98)
        end
    end
end)

-- ===============================
-- HOOK DE REMOTES (GRABAR)
-- ===============================
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if recording and method == "FireServer" then
        if self == PlaceRemote then
            table.insert(CONFIG.recorded, {
                type = "place",
                towerKey = args[1],
                pos = args[2],
                time = tick() - startTick
            })
            save()
        elseif self == UpgradeRemote then
            table.insert(CONFIG.recorded, {
                type = "upgrade",
                id = args[1],
                time = tick() - startTick
            })
            save()
        elseif SellRemote and self == SellRemote then
            table.insert(CONFIG.recorded, {
                type = "sell",
                id = args[1],
                time = tick() - startTick
            })
            save()
        end
    end

    return old(self, ...)
end)

-- ===============================
-- REPRODUCIR MACRO
-- ===============================
local function playMacro()
    if playing or #CONFIG.recorded == 0 then return end
    playing = true
    local base = tick()

    for _, action in ipairs(CONFIG.recorded) do
        if not playing then break end

        local waitTime = action.time - (tick() - base)
        if waitTime > 0 then task.wait(waitTime) end

        if action.type == "place" then
            waitForCash(0)
            PlaceRemote:FireServer(action.towerKey, action.pos)

        elseif action.type == "upgrade" then
            UpgradeRemote:FireServer(action.id)

        elseif action.type == "sell" and SellRemote then
            SellRemote:FireServer(action.id)
        end
    end

    playing = false
end

-- ===============================
-- AUTO START / RETRY / SPEED
-- ===============================
task.spawn(function()
    task.wait(5)

    if CONFIG.autoStart then
        pcall(function()
            Network:FindFirstChild("PlayerVoteStart"):FireServer()
        end)
    end

    pcall(function()
        Network:FindFirstChild("SetGameSpeed"):FireServer(CONFIG.speed)
    end)

    if CONFIG.autoStart then
        task.wait(3)
        playMacro()
    end
end)

-- Auto Retry
task.spawn(function()
    while true do
        task.wait(5)
        if CONFIG.autoRetry then
            local endGui = player.PlayerGui:FindFirstChild("EndScreen", true)
            if endGui then
                TeleportService:Teleport(game.PlaceId, player)
            end
        end
    end
end)

-- ===============================
-- UI FLOTRANTE (MOBILE)
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "UTD_Macro"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(180, 200)
frame.Position = UDim2.fromOffset(20, 200)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local function makeBtn(text, y, cb)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.fromOffset(160, 40)
    b.Position = UDim2.fromOffset(10, y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(cb)
end

makeBtn("🔴 REC", 10, function()
    CONFIG.recorded = {}
    recording = true
    startTick = tick()
    save()
end)

makeBtn("⏹ STOP", 60, function()
    recording = false
    save()
end)

makeBtn("▶ PLAY", 110, function()
    playMacro()
end)

makeBtn("❌ HIDE", 160, function()
    gui.Enabled = false
end)
