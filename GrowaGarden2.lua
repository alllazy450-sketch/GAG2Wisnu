-- ============================================================
--  W424HUB-GAG2 | V.3.1 (WisnuVIP Style UI)
--  Grow a Garden 2 – All-in-One
-- ============================================================
print("=== LOADING W424HUB-GAG2 V.3.1 ===")

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")

-- ===== LOAD KEZODX LIBRARY (WisnuVIP UI) =====
local repo = "https://raw.githubusercontent.com/kezodxyz/KezodX/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

if not Library then error("Library gagal dimuat") end

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "W424HUB-GAG2 | V.3.1",
    Footer = "Grow a Garden 2",
    Icon = "96848424314690",
    IconSize = UDim2.fromOffset(50, 50),
    NotifySide = "Right",
    EnableSidebarResize = true,
    EnableCompacting = true,
    SidebarCompacted = true,
    Size = UDim2.fromOffset(450, 550),
    CornerRadius = 20,
    AutoShow = true,
})

-- ============================================================
--  ITEM DATABASE
-- ============================================================
local SEEDS = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple",
    "Bamboo", "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean",
    "Banana", "Grape", "Coconut", "Mango", "Dragon Fruit", "Acorn",
    "Cherry", "Sunflower", "Venus Fly Trap", "Pomegranate", "Poison Apple",
    "Venom Spitter", "Moon Bloom", "Hypno Bloom", "Dragon's Breath"
}

local GEARS = {
    "Common Watering Can", "Common Sprinkler", "Sign", "Uncommon Sprinkler",
    "Trowel", "Rare Sprinkler", "Jump Mushroom", "Speed Mushroom",
    "Lantern", "Shrink Mushroom", "Supersize Mushroom", "Gnome",
    "Flashbang", "Basic Pot", "Legendary Sprinkler", "Invisibility Mushroom",
    "Teleporter", "Wheelbarrow", "Super Watering Can", "Super Sprinkler"
}

local CRATES = {
    "Ladder Crate", "Bench Crate", "Light Crate", "Sign Crate",
    "Arch Crate", "Roleplay Crate", "Bridge Crate", "Spring Crate",
    "Seesaw Crate", "Conveyor Crate", "Owner Door Crate", "Bear Trap Crate",
    "Fence Crate", "Teleporter Pad Crate"
}

-- ============================================================
--  MODUL DAN FUNGSI INTI (SAMA SEPERTI SEBELUMNYA)
-- ============================================================
local Networking, SeedData, FruitValueCalc, PlantLifecycleHandler, StealFlags

pcall(function()
    Networking = require(ReplicatedStorage.SharedModules.Networking)
end)
if not Networking then
    warn("⚠️ Networking module gagal dimuat, beberapa fitur mungkin gak jalan")
end

pcall(function()
    SeedData = require(ReplicatedStorage.SharedModules.SeedData)
end)
pcall(function()
    FruitValueCalc = require(ReplicatedStorage.SharedModules.FruitValueCalc)
end)
pcall(function()
    PlantLifecycleHandler = require(LocalPlayer.PlayerScripts.Controllers.PlantLifecycleHandler)
end)
pcall(function()
    StealFlags = require(ReplicatedStorage.SharedModules.Flags.StealFlags)
end)

local Gardens = Workspace:FindFirstChild("Gardens")
local Night = ReplicatedStorage:FindFirstChild("Night")

local function getMyPlot()
    if not Gardens then return nil end
    for _, plot in ipairs(Gardens:GetChildren()) do
        if plot:GetAttribute("Owner") == LocalPlayer.Name then return plot end
    end
    return nil
end

local function isNightTime()
    return Night and Night.Value == true
end

local function getChar() return LocalPlayer.Character end
local function getHRP() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function teleportTo(targetCF, speed)
    speed = speed or 35
    local hrp = getHRP()
    if not hrp or not targetCF then return end
    local start = hrp.CFrame
    local dist = (targetCF.Position - start.Position).Magnitude
    if dist < 2 then return end
    local duration = dist / speed
    local con
    local elapsed = 0
    con = RunService.RenderStepped:Connect(function(dt)
        elapsed = elapsed + dt
        if elapsed >= duration then
            if hrp and hrp.Parent then hrp.CFrame = targetCF end
            if con then con:Disconnect() end
            return
        end
        local alpha = elapsed / duration
        if hrp and hrp.Parent then
            hrp.CFrame = start:Lerp(targetCF, alpha)
        else
            if con then con:Disconnect() end
        end
    end)
    task.wait(duration + 0.5)
    if con and con.Connected then con:Disconnect() end
end

local function isSelected(items, name)
    if not items then return false end
    if type(items) == "table" then
        for k, v in pairs(items) do
            if v == "All" or k == "All" then return true end
            if v == name or k == name then return true end
        end
        return false
    elseif type(items) == "string" then
        return items == "All" or items == name
    end
    return false
end

-- ============================================================
--  FUNGSI UTAMA
-- ============================================================
local Selected = {
    harvestItem = {},
    plantItem = {},
    buyItem = {},
}

local function harvestSpecific(items)
    local plot = getMyPlot()
    if not plot or not Networking then return 0 end
    local plants = plot:FindFirstChild("Plants")
    if not plants then return 0 end
    local count = 0
    for _, plant in ipairs(plants:GetChildren()) do
        local fruits = plant:FindFirstChild("Fruits")
        if fruits then
            for _, fruit in ipairs(fruits:GetChildren()) do
                if fruit:IsA("Model") then
                    local seedName = fruit:GetAttribute("SeedName") or fruit:GetAttribute("CorePartName")
                    if isSelected(items, seedName) then
                        local age = fruit:GetAttribute("Age") or 0
                        local maxAge = fruit:GetAttribute("MaxAge") or 0
                        if age >= maxAge then
                            local pid = fruit:GetAttribute("PlantId")
                            local fid = fruit:GetAttribute("FruitId") or ""
                            if pid then
                                pcall(function() Networking.Garden.CollectFruit:Fire(pid, fid) end)
                                count = count + 1
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end
        else
            local seedName = plant:GetAttribute("SeedName") or plant:GetAttribute("CorePartName")
            if isSelected(items, seedName) then
                local age = plant:GetAttribute("Age") or 0
                local maxAge = plant:GetAttribute("MaxAge") or 0
                if age >= maxAge then
                    local pid = plant:GetAttribute("PlantId")
                    if pid then
                        pcall(function() Networking.Garden.CollectFruit:Fire(pid, "") end)
                        count = count + 1
                        task.wait(0.05)
                    end
                end
            end
        end
    end
    return count
end

local function sellAll()
    if Networking then
        pcall(function() Networking.NPCS.SellAll:Fire() end)
    end
end

local function buySpecific(items)
    if not Networking then return end
    if isSelected(items, "All") then
        buyItems()
        return
    end
    pcall(function()
        local seedStock = ReplicatedStorage.StockValues.SeedShop.Items
        for _, item in ipairs(seedStock:GetChildren()) do
            if item:IsA("ValueBase") and item.Value > 0 and isSelected(items, item.Name) then
                Networking.SeedShop.PurchaseSeed:Fire(item.Name)
                task.wait(0.05)
            end
        end
    end)
    pcall(function()
        local gearStock = ReplicatedStorage.StockValues.GearShop.Items
        for _, item in ipairs(gearStock:GetChildren()) do
            if item:IsA("ValueBase") and item.Value > 0 and isSelected(items, item.Name) then
                Networking.GearShop.PurchaseGear:Fire(item.Name)
                task.wait(0.05)
            end
        end
    end)
    pcall(function()
        local crateStock = ReplicatedStorage.StockValues.CrateShop.Items
        for _, item in ipairs(crateStock:GetChildren()) do
            if item:IsA("ValueBase") and item.Value > 0 and isSelected(items, item.Name) then
                Networking.CrateShop.PurchaseCrate:Fire(item.Name)
                task.wait(0.05)
            end
        end
    end)
end

local function buyItems()
    if not Networking then return end
    pcall(function()
        local seedStock = ReplicatedStorage.StockValues.SeedShop.Items
        for _, item in ipairs(seedStock:GetChildren()) do
            if item:IsA("ValueBase") and item.Value > 0 then
                Networking.SeedShop.PurchaseSeed:Fire(item.Name)
                task.wait(0.05)
            end
        end
    end)
    pcall(function()
        local gearStock = ReplicatedStorage.StockValues.GearShop.Items
        for _, item in ipairs(gearStock:GetChildren()) do
            if item:IsA("ValueBase") and item.Value > 0 then
                Networking.GearShop.PurchaseGear:Fire(item.Name)
                task.wait(0.05)
            end
        end
    end)
    pcall(function()
        local crateStock = ReplicatedStorage.StockValues.CrateShop.Items
        for _, item in ipairs(crateStock:GetChildren()) do
            if item:IsA("ValueBase") and item.Value > 0 then
                Networking.CrateShop.PurchaseCrate:Fire(item.Name)
                task.wait(0.05)
            end
        end
    end)
end

local function plantSpecific(items)
    local plot = getMyPlot()
    if not plot or not Networking then return end
    local inv = LocalPlayer:GetAttribute("Inventory")
    if not inv or not inv.Seeds then return end
    local seeds = inv.Seeds
    local freeSpots = {}
    local function addSpotsFromArea(area)
        local size = area.Size
        local step = 6
        for x = -size.X/2 + 3, size.X/2 - 3, step do
            for z = -size.Z/2 + 3, size.Z/2 - 3, step do
                local pos = area.CFrame * CFrame.new(x, 0.5, z)
                table.insert(freeSpots, pos.Position)
            end
        end
    end
    for _, area in ipairs(plot:GetDescendants()) do
        if area:IsA("BasePart") and (area.Name == "PlantArea" or area.Name == "Soil") then
            addSpotsFromArea(area)
        end
    end
    for _, area in ipairs(CollectionService:GetTagged("PlantArea")) do
        if area:IsDescendantOf(plot) then
            addSpotsFromArea(area)
        end
    end
    if #freeSpots == 0 then return end
    local planted = 0
    for seed, count in pairs(seeds) do
        if count > 0 and planted < 40 then
            if isSelected(items, seed) then
                for i = 1, math.min(count, 5) do
                    if planted >= #freeSpots then break end
                    local pos = freeSpots[planted + 1]
                    pcall(function()
                        Networking.Plant.PlantSeed:Fire(pos, seed, plot)
                    end)
                    planted = planted + 1
                    task.wait(0.1)
                end
            end
        end
    end
end

local function openItems(category)
    if not Networking then return end
    local inv = LocalPlayer:GetAttribute("Inventory") or {}
    local pkt
    if category == "Eggs" then pkt = Networking.Egg.OpenEgg
    elseif category == "Crates" then pkt = Networking.Crate.OpenCrate
    elseif category == "SeedPacks" then pkt = Networking.SeedPack.OpenSeedPack
    else return end
    for name, count in pairs(inv[category] or {}) do
        for i = 1, count do
            pcall(function() pkt:Fire(name) end)
            task.wait(0.1)
        end
    end
end

local function performSteal()
    if not isNightTime() or not Networking then return end
    local target = nil
    for _, plot in ipairs(Gardens:GetChildren()) do
        local plants = plot:FindFirstChild("Plants")
        if plants then
            for _, plant in ipairs(plants:GetChildren()) do
                local fruits = plant:FindFirstChild("Fruits")
                if fruits then
                    for _, fruit in ipairs(fruits:GetChildren()) do
                        if fruit:IsA("Model") then
                            local seedName = fruit:GetAttribute("SeedName") or fruit:GetAttribute("CorePartName")
                            if seedName and StealFlags and StealFlags.IsPlantStealable and StealFlags.IsPlantStealable(seedName) then
                                local ownerId = fruit:GetAttribute("UserId")
                                if ownerId then
                                    local owner = Players:GetPlayerByUserId(tonumber(ownerId))
                                    if owner and owner ~= LocalPlayer and not owner:GetAttribute("IsInOwnGarden") then
                                        target = fruit
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                if target then break end
            end
        end
        if target then break end
    end
    if not target then return end
    local ownerId = target:GetAttribute("UserId")
    local plantId = target:GetAttribute("PlantId")
    local fruitId = target:GetAttribute("FruitId") or ""
    if not (ownerId and plantId) then return end
    local plot = getMyPlot()
    if not plot then return end
    local ref = plot:FindFirstChild("PlotSizeReference")
    if not ref then return end
    local home = ref.CFrame
    local bp = target:FindFirstChildWhichIsA("BasePart")
    if not bp then return end
    local targetCF = bp.CFrame + Vector3.new(0, 3, 0)
    teleportTo(targetCF, 33)
    task.wait(0.5)
    pcall(function()
        Networking.Steal.BeginSteal:Fire(tonumber(ownerId), plantId, fruitId)
    end)
    task.wait(0.1)
    pcall(function()
        Networking.Steal.CompleteSteal:Fire()
    end)
    task.wait(0.5)
    teleportTo(home, 33)
end

-- ============================================================
--  STATE
-- ============================================================
local S = {
    autoHarvest = false,
    autoSell = false,
    autoSteal = false,
    autoBuy = false,
    autoPlant = false,
    sellInterval = 60,
    stealInterval = 5,
    plantInterval = 10,
    buyInterval = 30,
    antiAfk = true,
    optimize = false,
}

-- ============================================================
--  UI – WisnuVIP Style (KezodX Library)
-- ============================================================

-- Tabs
local Tabs = {
    Farm = Window:AddTab("Farm", "garden", "Panen & Tanam"),
    Shop = Window:AddTab("Shop", "shopping-bag", "Beli & Buka item"),
    Steal = Window:AddTab("Steal", "skull", "Curi buah"),
    Misc = Window:AddTab("Misc", "sliders-horizontal", "Lainnya"),
    Config = Window:AddTab("Config", "settings-2", "UI Settings"),
}

-- ===== FARM TAB =====
local FarmLeft = Tabs.Farm:AddLeftGroupbox("Auto Farm", "bot")
local FarmRight = Tabs.Farm:AddRightGroupbox("Manually", "play")

FarmLeft:AddToggle("AutoHarvest", {
    Text = "Auto Harvest",
    Default = false,
    Callback = function(v) S.autoHarvest = v end
})
FarmLeft:AddToggle("AutoSell", {
    Text = "Auto Sell",
    Default = false,
    Callback = function(v) S.autoSell = v end
})
FarmLeft:AddSlider("SellInterval", {
    Text = "Sell Interval (s)",
    Default = 60,
    Min = 5,
    Max = 300,
    Rounding = 0,
    Callback = function(v) S.sellInterval = v end
})
FarmLeft:AddToggle("AutoPlant", {
    Text = "Auto Plant",
    Default = false,
    Callback = function(v) S.autoPlant = v end
})
FarmLeft:AddSlider("PlantInterval", {
    Text = "Plant Interval (s)",
    Default = 10,
    Min = 5,
    Max = 120,
    Rounding = 0,
    Callback = function(v) S.plantInterval = v end
})
FarmLeft:AddDivider()
FarmLeft:AddDropdown("HarvestItem", {
    Text = "Harvest Item",
    Values = {"All", unpack(SEEDS)},
    Default = "All",
    Multi = true,
    Callback = function(v) Selected.harvestItem = v end
})
FarmLeft:AddDropdown("PlantItem", {
    Text = "Plant Item",
    Values = {"All", unpack(SEEDS)},
    Default = "All",
    Multi = true,
    Callback = function(v) Selected.plantItem = v end
})

FarmRight:AddButton("Harvest Now", function()
    local count = harvestSpecific(Selected.harvestItem)
    Library:Notify({Title = "Harvest", Description = "Panen " .. count .. " tanaman", Duration = 2})
end)
FarmRight:AddButton("Sell Now", function()
    sellAll()
    Library:Notify({Title = "Sell", Description = "Semua terjual!", Duration = 2})
end)
FarmRight:AddButton("Plant Now", function()
    plantSpecific(Selected.plantItem)
    Library:Notify({Title = "Plant", Description = "Menanam bibit terpilih", Duration = 2})
end)

-- ===== SHOP TAB =====
local ShopLeft = Tabs.Shop:AddLeftGroupbox("Auto Buy", "shopping-cart")
local ShopRight = Tabs.Shop:AddRightGroupbox("Open", "box")

ShopLeft:AddToggle("AutoBuy", {
    Text = "Auto Buy",
    Default = false,
    Callback = function(v) S.autoBuy = v end
})
ShopLeft:AddSlider("BuyInterval", {
    Text = "Buy Interval (s)",
    Default = 30,
    Min = 5,
    Max = 300,
    Rounding = 0,
    Callback = function(v) S.buyInterval = v end
})
ShopLeft:AddDivider()
ShopLeft:AddDropdown("BuyItem", {
    Text = "Buy Item",
    Values = {"All", unpack(SEEDS), unpack(GEARS), unpack(CRATES)},
    Default = "All",
    Multi = true,
    Callback = function(v) Selected.buyItem = v end
})
ShopLeft:AddButton("Buy Now", function()
    buySpecific(Selected.buyItem)
    Library:Notify({Title = "Buy", Description = "Membeli item terpilih", Duration = 2})
end)

ShopRight:AddButton("Open All Eggs", function()
    openItems("Eggs")
    Library:Notify({Title = "Open", Description = "Semua telur dibuka!", Duration = 2})
end)
ShopRight:AddButton("Open All Crates", function()
    openItems("Crates")
    Library:Notify({Title = "Open", Description = "Semua crate dibuka!", Duration = 2})
end)
ShopRight:AddButton("Open All Seed Packs", function()
    openItems("SeedPacks")
    Library:Notify({Title = "Open", Description = "Semua seed pack dibuka!", Duration = 2})
end)

-- ===== STEAL TAB =====
local StealLeft = Tabs.Steal:AddLeftGroupbox("Auto Steal", "moon")
StealLeft:AddToggle("AutoSteal", {
    Text = "Auto Steal (Night only)",
    Default = false,
    Callback = function(v) S.autoSteal = v end
})
StealLeft:AddSlider("StealInterval", {
    Text = "Steal Interval (s)",
    Default = 5,
    Min = 3,
    Max = 30,
    Rounding = 0,
    Callback = function(v) S.stealInterval = v end
})
StealLeft:AddButton("Steal Now", function()
    performSteal()
    Library:Notify({Title = "Steal", Description = "Mencoba mencuri...", Duration = 2})
end)

-- ===== MISC TAB =====
local MiscLeft = Tabs.Misc:AddLeftGroupbox("Misc", "sliders-horizontal")
MiscLeft:AddToggle("AntiAfk", {
    Text = "Anti-AFK",
    Default = true,
    Callback = function(v) S.antiAfk = v end
})
MiscLeft:AddToggle("Optimize", {
    Text = "Optimize (FPS)",
    Default = false,
    Callback = function(v)
        S.optimize = v
        if v then
            Lighting.GlobalShadows = false
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, e in ipairs(Lighting:GetDescendants()) do
                if e:IsA("PostEffect") or e:IsA("Atmosphere") then
                    pcall(function() e.Enabled = false end)
                end
            end
        else
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end
})
MiscLeft:AddButton("Unload Script", function()
    Window:Destroy()
end)

-- ===== CONFIG TAB (UI Settings) =====
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("W424GAG2")
SaveManager:SetFolder("W424GAG2/configs")
SaveManager:BuildConfigSection(Tabs.Config)
ThemeManager:ApplyToTab(Tabs.Config)
SaveManager:LoadAutoloadConfig()

-- ============================================================
--  MAIN LOOPS
-- ============================================================

task.spawn(function()
    while true do
        task.wait(1)
        if S.autoHarvest then
            harvestSpecific(Selected.harvestItem)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(S.sellInterval or 60)
        if S.autoSell then sellAll() end
    end
end)

task.spawn(function()
    while true do
        task.wait(S.plantInterval or 10)
        if S.autoPlant then plantSpecific(Selected.plantItem) end
    end
end)

task.spawn(function()
    while true do
        task.wait(S.buyInterval or 30)
        if S.autoBuy then buySpecific(Selected.buyItem) end
    end
end)

task.spawn(function()
    while true do
        task.wait(S.stealInterval or 5)
        if S.autoSteal and isNightTime() then performSteal() end
    end
end)

LocalPlayer.Idled:Connect(function()
    if S.antiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- ============================================================
--  NOTIFIKASI AWAL
-- ============================================================
Library:Notify({
    Title = "W424HUB-GAG2",
    Description = "V.3.1 – WisnuVIP UI Style",
    Duration = 5
})

print("✅ W424HUB-GAG2 V.3.1 (WisnuVIP UI) loaded!")