--[[ 
UTD MOBILE MACRO (ALS-STYLE)
Compatible con Delta Mobile
No hooks / No input recorder
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- =========================
-- FILE SYSTEM (DELTA)
-- =========================
local SAVE_FILE = "UTD_Macro.json"

local function save(data)
    if writefile then
        writefile(SAVE_FILE, HttpService:JSONEncode(data))
    end
end

local function load()
    if readfile and isfile and isfile(SAVE_FILE) then
        return HttpService:JSONDecode(readfile(SAVE_FILE))
    end
    return nil
end

-- =========================
-- STATE
-- =========================
local DATA = load() or {
    Macro = {},
    AutoPlay = false
}

local RECORDING = false
local PLAYING = false

-- =========================
-- REMOTES
-- =========================
local Network = ReplicatedStorage:WaitForChild("GenericModules")
    :WaitForChild("Service")
    :WaitForChild("Network")

local PlaceRemote = Network:WaitForChild("PlayerPlaceTower")
local UpgradeRemote = Network:WaitForChild("PlayerUpgradeTower")

-- =========================
-- HELPERS
-- =========================
local function getMoney()
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Cash") then
        return stats.Cash.Value
    end
    return 0
end

local function waitForMoney(amount)
    while getMoney() < amount do
        task.wait(0.25)
    end
end

-- =========================
-- RECORD FUNCTIONS
-- =========================
_G.StartRecording = function()
    RECORDING = true
    DATA.Macro = {}
    save(DATA)
end

_G.StopRecording = function()
    RECORDING = false
    save(DATA)
end

-- =========================
-- SAFE OBSERVER (NO HOOK)
-- =========================
player.CharacterAdded:Connect(function()
    -- reset session state
end)

-- =========================
-- PLAY MACRO
-- =========================
local function playMacro()
    if PLAYING then return end
    PLAYING = true

    for _, action in ipairs(DATA.Macro) do
        if not PLAYING then break end

        waitForMoney(action.cost)

        if action.type == "Place" then
            PlaceRemote:FireServer(action.unit, action.pos)
        elseif action.type == "Upgrade" then
            UpgradeRemote:FireServer(action.index)
        end

        task.wait(0.3)
    end

    PLAYING = false
end

_G.PlayMacro = playMacro
_G.StopMacro = function()
    PLAYING = false
end

-- =========================
-- GUI (FLOATING)
-- =========================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "UTDMacroGUI"
gui.ResetOnSpawn = false

local function makeButton(text, pos, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 120, 0, 40)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Parent = gui
    b.MouseButton1Click:Connect(callback)
end

makeButton("RECORD", UDim2.new(0,20,0,200), _G.StartRecording)
makeButton("STOP", UDim2.new(0,20,0,250), _G.StopRecording)
makeButton("PLAY", UDim2.new(0,20,0,300), _G.PlayMacro)

-- =========================
-- AUTO PLAY
-- =========================
if DATA.AutoPlay then
    task.delay(3, playMacro)
end

print("UTD Mobile Macro Loaded")
