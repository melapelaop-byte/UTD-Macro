--// ULTIMATE TOWER DEFENSE - MACRO AFK PRO
--// Mobile + Delta Executor
--// UI flotante + Auto record + Auto play

--------------------------------------------------
-- SERVICIOS
--------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--------------------------------------------------
-- NETWORK (CONFIRMADO POR REMOTE SPY)
--------------------------------------------------
local Network =
    ReplicatedStorage
    :WaitForChild("GenericModules")
    :WaitForChild("Service")
    :WaitForChild("Network")

local PLACE_REMOTE   = Network:WaitForChild("PlayerPlaceTower")
local UPGRADE_REMOTE = Network:WaitForChild("PlayerUpgradeTower")
local SELL_REMOTE    = Network:FindFirstChild("PlayerSellTower") -- puede existir o no

local START_REMOTE   = Network:FindFirstChild("PlayerVoteStart")
local RETRY_REMOTE   = Network:FindFirstChild("PlayerRetry")
local SPEED_REMOTE   = Network:FindFirstChild("PlayerSetSpeed")

--------------------------------------------------
-- CONFIG PERSISTENTE
--------------------------------------------------
local FILE = "UTD_MACRO_PRO.json"

local CONFIG = {
    recording = false,
    actions = {},
    autoPlay = true,
    autoStart = true,
    autoRetry = true,
    speed = 1.5
}

local function save()
    if writefile then
        writefile(FILE, HttpService:JSONEncode(CONFIG))
    end
end

local function load()
    if readfile and isfile and isfile(FILE) then
        local data = HttpService:JSONDecode(readfile(FILE))
        for k,v in pairs(data) do
            CONFIG[k] = v
        end
    end
end

load()

--------------------------------------------------
-- UTILIDADES
--------------------------------------------------
local function getMoney()
    local ls = player:FindFirstChild("leaderstats")
    return ls and ls:FindFirstChild("Cash") and ls.Cash.Value or 0
end

local function waitMoney(cost)
    while getMoney() < cost do
        task.wait(0.2)
    end
end

--------------------------------------------------
-- TELEPORT SOLO EN LOBBY
--------------------------------------------------
local lobbyTeleported = false
local LOBBY_CFRAME = CFrame.new(11267.60, 22.89, 50.98)

local function isInLobby()
    return player.PlayerGui:FindFirstChild("LobbyGui") ~= nil
end

task.spawn(function()
    while task.wait(1) do
        if isInLobby() and not lobbyTeleported then
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = LOBBY_CFRAME
            lobbyTeleported = true
        end

        if not isInLobby() then
            lobbyTeleported = false
        end
    end
end)

--------------------------------------------------
-- SISTEMA DE GRABACIÓN AUTOMÁTICA
--------------------------------------------------
local recordStart = 0

local function record(action, data)
    if not CONFIG.recording then return end
    table.insert(CONFIG.actions, {
        t = tick() - recordStart,
        a = action,
        d = data
    })
    save()
end

--------------------------------------------------
-- HOOK DE REMOTES (AUTO RECORD)
--------------------------------------------------
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" then
        if self == PLACE_REMOTE then
            record("Place", {
                towerKey = args[1],
                pos = args[2]
            })

        elseif self == UPGRADE_REMOTE then
            record("Upgrade", {
                id = args[1]
            })

        elseif SELL_REMOTE and self == SELL_REMOTE then
            record("Sell", {
                id = args[1]
            })
        end
    end

    return old(self, ...)
end)

--------------------------------------------------
-- AUTO PLAY MACRO
--------------------------------------------------
task.spawn(function()
    if not CONFIG.autoPlay then return end

    task.wait(4)

    if CONFIG.autoStart and START_REMOTE then
        pcall(function() START_REMOTE:FireServer() end)
    end

    task.wait(3)

    if SPEED_REMOTE then
        pcall(function() SPEED_REMOTE:FireServer(CONFIG.speed) end)
    end

    local start = tick()

    for _,v in ipairs(CONFIG.actions) do
        local delay = v.t - (tick() - start)
        if delay > 0 then task.wait(delay) end

        if v.a == "Place" then
            PLACE_REMOTE:FireServer(v.d.towerKey, v.d.pos)

        elseif v.a == "Upgrade" then
            UPGRADE_REMOTE:FireServer(v.d.id)

        elseif v.a == "Sell" and SELL_REMOTE then
            SELL_REMOTE:FireServer(v.d.id)
        end
    end
end)

--------------------------------------------------
-- AUTO RETRY
--------------------------------------------------
task.spawn(function()
    while task.wait(2) do
        if CONFIG.autoRetry and RETRY_REMOTE then
            local gui = player.PlayerGui:FindFirstChild("EndGameGui")
            if gui and gui.Enabled then
                task.wait(2)
                RETRY_REMOTE:FireServer()
            end
        end
    end
end)

--------------------------------------------------
-- UI FLOTANTE (MÓVIL)
--------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "UTD_Macro_UI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(160, 140)
frame.Position = UDim2.fromScale(0.05, 0.35)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local function button(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.fromOffset(140, 35)
    b.Position = UDim2.fromOffset(10, y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0
    return b
end

local rec = button("🔴 REC", 10)
local stop = button("⏹ STOP", 55)
local hide = button("👁 HIDE", 100)

rec.MouseButton1Click:Connect(function()
    CONFIG.actions = {}
    CONFIG.recording = true
    recordStart = tick()
    save()
end)

stop.MouseButton1Click:Connect(function()
    CONFIG.recording = false
    save()
end)

hide.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

print("✅ UTD MACRO AFK PRO CARGADO")
