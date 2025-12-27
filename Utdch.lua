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
        task.wait(
