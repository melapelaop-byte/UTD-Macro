-- ULTIMATE TOWER DEFENSE - MACRO PLAYER (DELTA MOBILE)
-- Reproduce macros grabados reales (JSON)
-- Compatible con PlayerPlaceTower / PlayerUpgradeTower

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- === REMOTES ===
local Network = ReplicatedStorage
    :WaitForChild("GenericModules")
    :WaitForChild("Service")
    :WaitForChild("Network")

local PlaceRemote = Network:WaitForChild("PlayerPlaceTower")
local UpgradeRemote = Network:WaitForChild("PlayerUpgradeTower")

-- === DINERO ===
local function getMoney()
    local stats = player:FindFirstChild("Stats") or player:FindFirstChild("leaderstats")
    if not stats then return 0 end
    local money = stats:FindFirstChild("Money") or stats:FindFirstChild("Cash")
    return money and money.Value or 0
end

-- === ESPERAR DINERO ===
local function waitForMoney(amount)
    while getMoney() < amount do
        task.wait(0.3)
    end
end

-- === PARSE VECTOR ===
local function parseVector(str)
    local x,y,z = str:match("([^,]+),%s*([^,]+),%s*([^,]+)")
    return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
end

-- === TU MACRO ===
local MACRO = loadstring("return " .. [[
[{"TowerPlaced":"3","Time":6,"TotalMoney":3500,"PlaceCost":1500,"TowerPosition":"-43.53178405761719, -88.67243957519531, -142.30076599121094"},{"TowerPlaced":"4","Time":9,"TotalMoney":2000,"PlaceCost":300,"TowerPosition":"-51.108673095703125, -88.50997924804688, -142.85684204101562"},{"TotalMoney":1700,"Time":12,"UpgradeCost":600,"TowerUpgraded":-51.108673095703128},{"TowerPlaced":"2","Time":42,"TotalMoney":5578,"PlaceCost":5000,"TowerPosition":"-42.511043548583984, -89.4057846069336, -149.3387908935547"},{"TotalMoney":20050,"Time":46,"UpgradeCost":3100,"TowerUpgraded":-43.53178024291992},{"TotalMoney":19891,"Time":48,"UpgradeCost":6000,"TowerUpgraded":-43.53178024291992},{"TotalMoney":13891,"Time":48,"UpgradeCost":9500,"TowerUpgraded":-43.53178024291992},{"TotalMoney":19605,"Time":49,"UpgradeCost":3100,"TowerUpgraded":-43.991024017333987},{"TotalMoney":18105,"Time":50,"UpgradeCost":6000,"TowerUpgraded":-43.991024017333987},{"TotalMoney":25860,"Time":53,"UpgradeCost":23340,"TowerUpgraded":-43.53178024291992},{"TowerPlaced":"6","Time":54,"TotalMoney":25385,"PlaceCost":17500,"TowerPosition":"-50.01185989379883, -85.55986022949219, -144.6118927001953"},{"TotalMoney":40929,"Time":55,"UpgradeCost":34000,"TowerUpgraded":-43.53178024291992},{"TotalMoney":36195,"Time":58,"UpgradeCost":9500,"TowerUpgraded":-43.991024017333987},{"TotalMoney":77535,"Time":60,"UpgradeCost":23340,"TowerUpgraded":-43.991024017333987},{"TotalMoney":184887,"Time":68,"UpgradeCost":34000,"TowerUpgraded":-43.991024017333987},{"TowerPlaced":"6","Time":69,"TotalMoney":52387,"PlaceCost":17500,"TowerPosition":"-47.37234878540039, -85.613037109375, -142.14886474609375"},{"TowerPlaced":"5","Time":72,"TotalMoney":104523,"PlaceCost":840,"TowerPosition":"-50.95258331298828, -89.0542984008789, -147.15003967285156"},{"TotalMoney":103683,"Time":73,"UpgradeCost":2450,"TowerUpgraded":-50.952579498291019},{"TotalMoney":101233,"Time":74,"UpgradeCost":1200,"TowerUpgraded":-51.108673095703128},{"TotalMoney":100033,"Time":75,"UpgradeCost":2400,"TowerUpgraded":-51.108673095703128},{"TotalMoney":97760,"Time":75,"UpgradeCost":4800,"TowerUpgraded":-51.108673095703128},{"TotalMoney":92960,"Time":76,"UpgradeCost":4059.9999999999997,"TowerUpgraded":-50.952579498291019},{"TotalMoney":88900,"Time":77,"UpgradeCost":5600,"TowerUpgraded":-50.952579498291019},{"TotalMoney":83300,"Time":77,"UpgradeCost":8750,"TowerUpgraded":-50.952579498291019},{"TowerPlaced":"5","Time":79,"TotalMoney":189474,"PlaceCost":840,"TowerPosition":"-45.665096282958984, -89.21881866455078, -135.86407470703125"},{"TotalMoney":188634,"Time":81,"UpgradeCost":2450,"TowerUpgraded":-45.66509246826172},{"TotalMoney":186184,"Time":81,"UpgradeCost":4059.9999999999997,"TowerUpgraded":-45.66509246826172},{"TotalMoney":182124,"Time":82,"UpgradeCost":5600,"TowerUpgraded":-45.66509246826172},{"TotalMoney":176524,"Time":82,"UpgradeCost":8750,"TowerUpgraded":-45.66509246826172},{"TowerPlaced":"6","Time":84,"TotalMoney":262363,"PlaceCost":17500,"TowerPosition":"-47.37234878540039, -85.613037109375, -142.14886474609375"},{"TowerPlaced":"1","Time":89,"TotalMoney":244863,"PlaceCost":15150,"TowerPosition":"-38.76160430908203, -89.16875457763672, -137.0958709716797"},{"TotalMoney":229847,"Time":90,"UpgradeCost":25250,"TowerUpgraded":-38.76160430908203},{"TotalMoney":222132,"Time":91,"UpgradeCost":50500,"TowerUpgraded":-38.76160430908203},{"TotalMoney":171632,"Time":91,"UpgradeCost":75750,"TowerUpgraded":-38.76160430908203},{"TotalMoney":318243,"Time":98,"UpgradeCost":217150,"TowerUpgraded":-38.76160430908203},{"TowerPlaced":"6","Time":99,"TotalMoney":101093,"PlaceCost":17500,"TowerPosition":"-47.37234878540039, -85.613037109375, -142.14886474609375"},{"TowerPlaced":"6","Time":114,"TotalMoney":488119,"PlaceCost":17500,"TowerPosition":"-47.37234878540039, -85.613037109375, -142.14886474609375"},{"TowerPlaced":"6","Time":129,"TotalMoney":743958,"PlaceCost":17500,"TowerPosition":"-52.7375602722168, -86.92277526855469, -134.46139526367188"},{"TotalMoney":797044,"Time":134,"UpgradeCost":757500,"TowerUpgraded":-38.76160430908203},{"TowerPlaced":"6","Time":145,"TotalMoney":389958,"PlaceCost":17500,"TowerPosition":"-47.509185791015625, -86.02413940429688, -137.74215698242188"},{"TowerPlaced":"6","Time":160,"TotalMoney":553000,"PlaceCost":17500,"TowerPosition":"-47.509185791015625, -86.02413940429688, -137.74215698242188"},{"TowerPlaced":"6","Time":175,"TotalMoney":939599,"PlaceCost":17500,"TowerPosition":"-99.03961181640625, -86.82777404785156, -96.73726654052734"},{"TowerPlaced":"6","Time":190,"TotalMoney":1336740,"PlaceCost":17500,"TowerPosition":"-149.70095825195312, -86.501220703125, -260.3809509277344"},{"TowerPlaced":"6","Time":205,"TotalMoney":1860177,"PlaceCost":17500,"TowerPosition":"-111.2096176147461, -77.56758117675781, -153.416015625"},{"TowerPlaced":"6","Time":220,"TotalMoney":2369164,"PlaceCost":17500,"TowerPosition":"-86.88648223876953, -86.50109100341797, -149.96559143066406"},{"TowerPlaced":"6","Time":236,"TotalMoney":2972289,"PlaceCost":17500,"TowerPosition":"-145.07809448242188, -75.5888442993164, -227.58816528320312"},{"TowerPlaced":"6","Time":251,"TotalMoney":3403391,"PlaceCost":17500,"TowerPosition":"-106.066162109375, -86.503662109375, -221.4168243408203"},{"TowerPlaced":"6","Time":266,"TotalMoney":3735185,"PlaceCost":17500,"TowerPosition":"-39.472023010253906, -85.90607452392578, -139.77935791015625"},{"TowerPlaced":"6","Time":281,"TotalMoney":3855686,"PlaceCost":17500,"TowerPosition":"-78.20619201660156, -86.92277526855469, -110.57869720458984"},{"TowerPlaced":"6","Time":296,"TotalMoney":4190285,"PlaceCost":17500,"TowerPosition":"-86.70272827148438, -86.50120544433594, -209.13015747070312"},{"TowerPlaced":"6","Time":312,"TotalMoney":4506214,"PlaceCost":17500,"TowerPosition":"-45.74924850463867, -85.63729858398438, -142.177978515625"},{"TowerPlaced":"6","Time":327,"TotalMoney":5021976,"PlaceCost":17500,"TowerPosition":"-44.50223159790039, -85.56562042236328, -143.8746795654297"},{"TowerPlaced":"6","Time":342,"TotalMoney":5541869,"PlaceCost":17500,"TowerPosition":"-44.50223159790039, -85.56562042236328, -143.8746795654297"},{"TowerPlaced":"6","Time":357,"TotalMoney":7748203,"PlaceCost":17500,"TowerPosition":"-44.50223159790039, -85.56562042236328, -143.8746795654297"},{"TowerPlaced":"6","Time":372,"TotalMoney":7967458,"PlaceCost":17500,"TowerPosition":"-44.50223159790039, -85.56562042236328, -143.8746795654297"},{"TowerPlaced":"6","Time":388,"TotalMoney":9518596,"PlaceCost":17500,"TowerPosition":"-44.50223159790039, -85.56562042236328, -143.8746795654297"},{"TowerPlaced":"6","Time":403,"TotalMoney":9808019,"PlaceCost":17500,"TowerPosition":"-44.50223159790039, -85.56562042236328, -143.8746795654297"},{"TowerPlaced":"6","Time":418,"TotalMoney":10030643,"PlaceCost":17500,"TowerPosition":"-44.50223159790039, -85.56562042236328, -143.8746795654297"}]
]])()

-- ⬆️ PUEDES PEGAR TODO TU JSON AHÍ DENTRO SIN CAMBIAR NADA

-- === EJECUCIÓN ===
task.spawn(function()
    local startTime = os.clock()

    for _, action in ipairs(MACRO) do
        -- Esperar tiempo exacto
        while os.clock() - startTime < action.Time do
            task.wait()
        end

        -- COLOCAR TORRE
        if action.TowerPlaced then
            waitForMoney(action.PlaceCost)

            PlaceRemote:FireServer(
                tostring(action.TowerPlaced),
                parseVector(action.TowerPosition)
            )
        end

        -- MEJORAR TORRE
        if action.TowerUpgraded then
            waitForMoney(action.UpgradeCost)

            UpgradeRemote:FireServer(
                tostring(action.TowerUpgraded)
            )
        end
    end
end)

print("✅ Macro ejecutándose")
