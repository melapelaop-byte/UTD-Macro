--==================================================
-- ANIME LAST STAND / ULTIMATE TD
-- AUTO TP + AUTO START + AUTO SPEED + AUTO REPLAY
-- DELTA MOBILE COMPATIBLE
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--==================== CONFIG ======================
local AUTO_TP_LOBBY = true
local LOBBY_TP_POSITION = Vector3.new(11267.60, 22.89, 50.98)

local AUTO_START = true
local AUTO_REPLAY = true
local AUTO_SPEED = true
local SPEED_VALUE = 1.5
--==================================================

--==================== UTILS ========================
local function clickButton(btn)
    if btn and btn:IsA("TextButton") then
        pcall(function()
            firesignal(btn.MouseButton1Click)
        end)
    end
end
--==================================================

--==================== AUTO TP LOBBY ================
task.spawn(function()
    if not AUTO_TP_LOBBY then return end

    while true do
        task.wait(2)

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hrp then
            -- Solo en lobby (no en partida)
            if not PlayerGui:FindFirstChild("HUD", true) then
                hrp.CFrame = CFrame.new(LOBBY_TP_POSITION)
                print("📍 TP lobby aplicado")
                task.wait(10)
            end
        end
    end
end)
--==================================================

--==================== AUTO START MATCH =============
task.spawn(function()
    if not AUTO_START then return end

    while true do
        task.wait(1)

        local voteGui = PlayerGui:FindFirstChild("VoteToStart", true)
        if voteGui then
            for _,v in pairs(voteGui:GetDescendants()) do
                if v:IsA("TextButton") and string.find(string.lower(v.Text), "start") then
                    clickButton(v)
                    print("🟢 Auto Start Match")
                    return
                end
            end
        end
    end
end)
--==================================================

--==================== AUTO SPEED 1.5x ==============
task.spawn(function()
    if not AUTO_SPEED then return end

    -- Espera a que inicie la partida
    while true do
        task.wait(1)
        if PlayerGui:FindFirstChild("HUD", true) then
            break
        end
    end

    task.wait(2)

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
--==================================================

--==================== AUTO REPLAY ==================
task.spawn(function()
    if not AUTO_REPLAY then return end

    while true do
        task.wait(1)

        local victoryGui = PlayerGui:FindFirstChild("Victory", true)
        if victoryGui then
            for _,v in pairs(victoryGui:GetDescendants()) do
                if v:IsA("TextButton") and string.find(string.lower(v.Text), "replay") then
                    clickButton(v)
                    print("🔁 Auto Replay")
                    return
                end
            end
        end
    end
end)
--==================================================
