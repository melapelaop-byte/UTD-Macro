--========================================
-- ULTIMATE / ANIME LAST STAND
-- AUTO START + AUTO SPEED 1.5x + AUTO REPLAY
-- Compatible con DELTA MOBILE
--========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--========================================
-- CONFIG
--========================================
local AUTO_START = true
local AUTO_REPLAY = true
local AUTO_SPEED = true
local SPEED_VALUE = 1.5

--========================================
-- UTILS
--========================================
local function safeActivate(btn)
    pcall(function()
        if btn and btn.Visible then
            btn:Activate()
        end
    end)
end

--========================================
-- AUTO START MATCH
--========================================
task.spawn(function()
    if not AUTO_START then return end

    while true do
        task.wait(1)

        local voteGui = PlayerGui:FindFirstChild("VoteToStart", true)
        if voteGui then
            local startBtn = voteGui:FindFirstChild("StartMatch", true)
            if startBtn and startBtn:IsA("TextButton") then
                safeActivate(startBtn)
                print("🟢 Auto Start Match")
                break
            end
        end
    end
end)

--========================================
-- AUTO SPEED 1.5x
--========================================
task.spawn(function()
    if not AUTO_SPEED then return end

    -- Espera a que el HUD de la partida exista
    while true do
        task.wait(1)
        if PlayerGui:FindFirstChild("HUD", true) then
            break
        end
    end

    task.wait(2)

    -- Intenta encontrar el remote de speed
    for _,v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and string.lower(v.Name):find("speed") then
            pcall(function()
                v:FireServer(SPEED_VALUE)
                print("⚡ Speed cambiado a 1.5x")
            end)
            break
        end
    end
end)

--========================================
-- AUTO REPLAY
--========================================
task.spawn(function()
    if not AUTO_REPLAY then return end

    while true do
        task.wait(1)

        local victoryGui = PlayerGui:FindFirstChild("Victory", true)
        if victoryGui then
            local replayBtn = victoryGui:FindFirstChild("Replay", true)
            if replayBtn and replayBtn:IsA("TextButton") then
                safeActivate(replayBtn)
                print("🔁 Auto Replay")
                break
            end
        end
    end
end)
