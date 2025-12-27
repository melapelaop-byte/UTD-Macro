-- ===============================
-- UTD AUTO MACRO FINAL - DELTA MOBILE
-- ===============================

-- ===== Servicios =====
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ===== Remotes =====
local Network = ReplicatedStorage
    :WaitForChild("GenericModules")
    :WaitForChild("Service")
    :WaitForChild("Network")

local PlaceRemote   = Network:WaitForChild("PlayerPlaceTower")
local UpgradeRemote = Network:WaitForChild("PlayerUpgradeTower")
local SellRemote    = Network:FindFirstChild("PlayerSellTower")
                   or Network:FindFirstChild("PlayerRemoveTower")

-- ===== Guardado =====
local SAVE_KEY = "UTD_MACRO_CONFIG_FINAL"

local CONFIG = {
    recorded = {},
    autoPlay = false,
    autoStart = true,
    autoRetry = true,
    speed = 1.5
}

pcall(function()
    if isfile(SAVE_KEY) then
        CONFIG = HttpService:JSONDecode(readfile(SAVE_KEY))
    end
end)

local function save()
    writefile(SAVE_KEY, HttpService:JSONEncode(CONFIG))
end

-- ===== Estado =====
local recording = false
local playing = false
local recordStart = 0

-- ===== Utilidades =====
local function inLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function getCash()
    local ls = player:FindFirstChild("leaderstats")
    return (ls and ls:FindFirstChild("Cash") and ls.Cash.Value) or 0
end

local function waitForCash(amount)
    while getCash() < amount do
        task.wait(0.25)
    end
end

-- ===== Teleport robusto en lobby =====
local function teleportLobby()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end

    for _ = 1, 30 do
        if inLobby() then
            hrp.CFrame = CFrame.new(11267.60, 22.89, 50.98)
            break
        end
        task.wait(1)
    end
end

task.spawn(function()
    if inLobby() then
        teleportLobby()
    end
end)

-- ===== Hook seguro (NO bloquea FireServer) =====
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
                time = tick() - recordStart
            })
            save()

        elseif self == UpgradeRemote then
            table.insert(CONFIG.recorded, {
                type = "upgrade",
                id = args[1],
                time = tick() - recordStart
            })
            save()

        elseif SellRemote and self == SellRemote then
            table.insert(CONFIG.recorded, {
                type = "sell",
                id = args[1],
                time = tick() - recordStart
            })
            save()
        end
    end

    local result
    pcall(function()
        result = old(self, unpack(args))
    end)
    return result
end)

-- ===== Reproducir macro =====
local function playMacro()
    if playing or #CONFIG.recorded == 0 then return end
    playing = true

    local base = tick()
    for _, a in ipairs(CONFIG.recorded) do
        if not playing then break end

        local waitTime = a.time - (tick() - base)
        if waitTime > 0 then task.wait(waitTime) end

        if a.type == "place" then
            waitForCash(0)
            PlaceRemote:FireServer(a.towerKey, a.pos)

        elseif a.type == "upgrade" then
            UpgradeRemote:FireServer(a.id)

        elseif a.type == "sell" and SellRemote then
            SellRemote:FireServer(a.id)
        end
    end

    playing = false
end

-- ===== Auto start / speed / autoplay =====
task.spawn(function()
    task.wait(6)

    pcall(function()
        if CONFIG.autoStart then
            Network:FindFirstChild("PlayerVoteStart"):FireServer()
        end
    end)

    pcall(function()
        Network:FindFirstChild("SetGameSpeed"):FireServer(CONFIG.speed)
    end)

    task.wait(3)
    if CONFIG.autoPlay then
        playMacro()
    end
end)

-- ===== Auto retry =====
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

-- ===== UI móvil =====
local gui = Instance.new("ScreenGui")
gui.Name = "UTD_Macro"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(180, 210)
frame.Position = UDim2.fromOffset(20, 220)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local function btn(txt, y, cb)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.fromOffset(160, 40)
    b.Position = UDim2.fromOffset(10, y)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(cb)
end

btn("🔴 REC", 10, function()
    CONFIG.recorded = {}
    recording = true
    recordStart = tick()
    save()
end)

btn("⏹ STOP", 60, function()
    recording = false
    save()
end)

btn("▶ PLAY (AUTO)", 110, function()
    CONFIG.autoPlay = true
    save()
    playMacro()
end)

btn("❌ HIDE", 160, function()
    gui.Enabled = false
end)
