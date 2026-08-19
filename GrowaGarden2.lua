-- ============================================================
--  WISNU HUB | V.4.0 (PULSE HUB STYLE UI)
--  Grow a Garden 2 – All-in-One Auto Farm
-- ============================================================
print("=== LOADING WISNU HUB V.4.0 ===")

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

-- ============================================================
--  ITEM DATABASE[span_1](start_span)[span_1](end_span)
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

local ALL_BUY_ITEMS = {"All"}
for _, v in ipairs(SEEDS) do table.insert(ALL_BUY_ITEMS, v) end
for _, v in ipairs(GEARS) do table.insert(ALL_BUY_ITEMS, v) end
for _, v in ipairs(CRATES) do table.insert(ALL_BUY_ITEMS, v) end

local SEED_OPTIONS = {"All"}
for _, v in ipairs(SEEDS) do table.insert(SEED_OPTIONS, v) end

-- ============================================================
--  MODUL DAN FUNGSI INTI (BACKEND TETAP AMAN)[span_2](start_span)[span_2](end_span)
-- ============================================================
local Networking, SeedData, FruitValueCalc, PlantLifecycleHandler, StealFlags

pcall(function() Networking = require(ReplicatedStorage.SharedModules.Networking) end)
pcall(function() SeedData = require(ReplicatedStorage.SharedModules.SeedData) end)
pcall(function() FruitValueCalc = require(ReplicatedStorage.SharedModules.FruitValueCalc) end)
pcall(function() PlantLifecycleHandler = require(LocalPlayer.PlayerScripts.Controllers.PlantLifecycleHandler) end)
pcall(function() StealFlags = require(ReplicatedStorage.SharedModules.Flags.StealFlags) end)

local Gardens = Workspace:FindFirstChild("Gardens")
local Night = ReplicatedStorage:FindFirstChild("Night")

local function getMyPlot()
    if not Gardens then return nil end
    for _, plot in ipairs(Gardens:GetChildren()) do
        if plot:GetAttribute("Owner") == LocalPlayer.Name then return plot end
    end
    return nil
end

local function isNightTime() return Night and Night.Value == true end
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
    local con, elapsed = nil, 0
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
--  STATE[span_3](start_span)[span_3](end_span)
-- ============================================================
local S = {
    autoHarvest = false, autoSell = false, autoSteal = false, autoBuy = false, autoPlant = false,
    sellInterval = 60, stealInterval = 5, plantInterval = 10, buyInterval = 30,
    antiAfk = true, optimize = false,
}

local Selected = { harvestItem = "All", plantItem = "All", buyItem = "All" }

-- ============================================================
--  FUNGSI UTAMA (PANEN, JUAL, BELI, CURI)[span_4](start_span)[span_4](end_span)
-- ============================================================
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
                        local age, maxAge = fruit:GetAttribute("Age") or 0, fruit:GetAttribute("MaxAge") or 0
                        if age >= maxAge then
                            local pid, fid = fruit:GetAttribute("PlantId"), fruit:GetAttribute("FruitId") or ""
                            if pid then pcall(function() Networking.Garden.CollectFruit:Fire(pid, fid) end) count = count + 1 task.wait(0.05) end
                        end
                    end
                end
            end
        else
            local seedName = plant:GetAttribute("SeedName") or plant:GetAttribute("CorePartName")
            if isSelected(items, seedName) then
                local age, maxAge = plant:GetAttribute("Age") or 0, plant:GetAttribute("MaxAge") or 0
                if age >= maxAge then
                    local pid = plant:GetAttribute("PlantId")
                    if pid then pcall(function() Networking.Garden.CollectFruit:Fire(pid, "") end) count = count + 1 task.wait(0.05) end
                end
            end
        end
    end
    return count
end

local function sellAll() if Networking then pcall(function() Networking.NPCS.SellAll:Fire() end) end end

local function buySpecific(items)
    if not Networking then return end
    if isSelected(items, "All") then
        pcall(function() for _, item in ipairs(ReplicatedStorage.StockValues.SeedShop.Items:GetChildren()) do if item:IsA("ValueBase") and item.Value > 0 then Networking.SeedShop.PurchaseSeed:Fire(item.Name) task.wait(0.05) end end end)
        pcall(function() for _, item in ipairs(ReplicatedStorage.StockValues.GearShop.Items:GetChildren()) do if item:IsA("ValueBase") and item.Value > 0 then Networking.GearShop.PurchaseGear:Fire(item.Name) task.wait(0.05) end end end)
        pcall(function() for _, item in ipairs(ReplicatedStorage.StockValues.CrateShop.Items:GetChildren()) do if item:IsA("ValueBase") and item.Value > 0 then Networking.CrateShop.PurchaseCrate:Fire(item.Name) task.wait(0.05) end end end)
        return
    end
    pcall(function() for _, item in ipairs(ReplicatedStorage.StockValues.SeedShop.Items:GetChildren()) do if item:IsA("ValueBase") and item.Value > 0 and isSelected(items, item.Name) then Networking.SeedShop.PurchaseSeed:Fire(item.Name) task.wait(0.05) end end end)
    pcall(function() for _, item in ipairs(ReplicatedStorage.StockValues.GearShop.Items:GetChildren()) do if item:IsA("ValueBase") and item.Value > 0 and isSelected(items, item.Name) then Networking.GearShop.PurchaseGear:Fire(item.Name) task.wait(0.05) end end end)
    pcall(function() for _, item in ipairs(ReplicatedStorage.StockValues.CrateShop.Items:GetChildren()) do if item:IsA("ValueBase") and item.Value > 0 and isSelected(items, item.Name) then Networking.CrateShop.PurchaseCrate:Fire(item.Name) task.wait(0.05) end end end)
end

local function plantSpecific(items)
    local plot = getMyPlot()
    if not plot or not Networking then return end
    local inv = LocalPlayer:GetAttribute("Inventory")
    if not inv or not inv.Seeds then return end
    local seeds, freeSpots = inv.Seeds, {}
    local function addSpotsFromArea(area)
        for x = -area.Size.X/2 + 3, area.Size.X/2 - 3, 6 do
            for z = -area.Size.Z/2 + 3, area.Size.Z/2 - 3, 6 do table.insert(freeSpots, (area.CFrame * CFrame.new(x, 0.5, z)).Position) end
        end
    end
    for _, area in ipairs(plot:GetDescendants()) do if area:IsA("BasePart") and (area.Name == "PlantArea" or area.Name == "Soil") then addSpotsFromArea(area) end end
    for _, area in ipairs(CollectionService:GetTagged("PlantArea")) do if area:IsDescendantOf(plot) then addSpotsFromArea(area) end end
    if #freeSpots == 0 then return end
    local planted = 0
    for seed, count in pairs(seeds) do
        if count > 0 and planted < 40 and isSelected(items, seed) then
            for i = 1, math.min(count, 5) do
                if planted >= #freeSpots then break end
                pcall(function() Networking.Plant.PlantSeed:Fire(freeSpots[planted + 1], seed, plot) end)
                planted = planted + 1
                task.wait(0.1)
            end
        end
    end
end

local function openItems(category)
    if not Networking then return end
    local inv = LocalPlayer:GetAttribute("Inventory") or {}
    local pkt = (category == "Eggs" and Networking.Egg.OpenEgg) or (category == "Crates" and Networking.Crate.OpenCrate) or (category == "SeedPacks" and Networking.SeedPack.OpenSeedPack)
    if not pkt then return end
    for name, count in pairs(inv[category] or {}) do for i = 1, count do pcall(function() pkt:Fire(name) end) task.wait(0.1) end end
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
                                    if owner and owner ~= LocalPlayer and not owner:GetAttribute("IsInOwnGarden") then target = fruit break end
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
    local ownerId, plantId, fruitId = target:GetAttribute("UserId"), target:GetAttribute("PlantId"), target:GetAttribute("FruitId") or ""
    if not (ownerId and plantId) then return end
    local plot = getMyPlot()
    if not plot then return end
    local ref = plot:FindFirstChild("PlotSizeReference")
    if not ref then return end
    local bp = target:FindFirstChildWhichIsA("BasePart")
    if not bp then return end
    teleportTo(bp.CFrame + Vector3.new(0, 3, 0), 33)
    task.wait(0.5)
    pcall(function() Networking.Steal.BeginSteal:Fire(tonumber(ownerId), plantId, fruitId) end)
    task.wait(0.1)
    pcall(function() Networking.Steal.CompleteSteal:Fire() end)
    task.wait(0.5)
    teleportTo(ref.CFrame, 33)
end

-- ============================================================
--  UI BARU (PULSE HUB STYLE)
-- ============================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nootmaus/pulselyb/refs/heads/main/.lua"))()
local IMAGE_ID = "75991977420487"

-- DI SINI PENAMBAHAN KEYBIND F3-NYA!
local Window = Library:Window({
    Name = "WISNU HUB",
    SubName = "Grow a Garden 2",
    Logo = IMAGE_ID,
    KeyBind = Enum.KeyCode.F3
})
Window:SetOpen(true)

-- Cleanup & Smart Bubble (Fitur dari Script sebelumnya)
pcall(function() if Window.Items and Window.Items.FloatingButton then Window.Items.FloatingButton.Instance:Destroy() end end)
local function createBubble()
    local btn = Instance.new("TextButton")
    btn.Size, btn.Position = UDim2.new(0, 60, 0, 60), UDim2.new(0.5, -30, 0.5, -30)
    btn.BackgroundColor3, btn.BackgroundTransparency, btn.Text, btn.ZIndex = Color3.fromRGB(15, 15, 20), 0, "", 10
    btn.Parent = Library.Holder.Instance
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 18)
    local stroke = Instance.new("UIStroke", btn) stroke.Color, stroke.Thickness = Color3.fromRGB(100, 100, 110), 1.5
    local icon = Instance.new("ImageLabel", btn)
    icon.Size, icon.Position = UDim2.new(0.8, 0, 0.8, 0), UDim2.new(0.1, 0, 0.1, 0)
    icon.BackgroundTransparency, icon.Image, icon.ScaleType, icon.ZIndex = 1, "rbxassetid://" .. IMAGE_ID, Enum.ScaleType.Fit, 20
    btn.MouseButton1Click:Connect(function() Window:SetOpen(not Window.IsOpen) end)
    local dragging, dragStart, startPos = false, nil, nil
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, btn.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
createBubble()

-- ============================================
-- TAB 1: FARM (🌱 Farming Automation)
-- ============================================
local TabFarm = Window:Page({ Name = "Farm", Columns = 2 })

-- KIRI: Harvest & Sell
local SectionHarvestSell = TabFarm:Section({ Name = "Harvest & Sell", Side = 1 })
SectionHarvestSell:Toggle({ Name = "Auto Harvest", Default = false, Callback = function(v) S.autoHarvest = v end })
SectionHarvestSell:Dropdown({ Name = "Target Harvest", Options = SEED_OPTIONS, Default = "All", Callback = function(v) Selected.harvestItem = v end })
SectionHarvestSell:Button({ Name = "Harvest Now", Callback = function() local count = harvestSpecific(Selected.harvestItem) Library:Notification({Title="WISNU HUB", Description="Panen "..count.." tanaman", Duration=2}) end })
SectionHarvestSell:Toggle({ Name = "Auto Sell", Default = false, Callback = function(v) S.autoSell = v end })
SectionHarvestSell:Slider({ Name = "Sell Interval", Min = 5, Max = 300, Default = 60, Suffix = " s", Callback = function(v) S.sellInterval = v end })
SectionHarvestSell:Button({ Name = "Sell Now", Callback = function() sellAll() Library:Notification({Title="WISNU HUB", Description="Semua terjual!", Duration=2}) end })

-- KANAN: Planting
local SectionPlant = TabFarm:Section({ Name = "Planting", Side = 2 })
SectionPlant:Toggle({ Name = "Auto Plant", Default = false, Callback = function(v) S.autoPlant = v end })
SectionPlant:Dropdown({ Name = "Target Plant", Options = SEED_OPTIONS, Default = "All", Callback = function(v) Selected.plantItem = v end })
SectionPlant:Slider({ Name = "Plant Interval", Min = 5, Max = 120, Default = 10, Suffix = " s", Callback = function(v) S.plantInterval = v end })
SectionPlant:Button({ Name = "Plant Now", Callback = function() plantSpecific(Selected.plantItem) Library:Notification({Title="WISNU HUB", Description="Menanam bibit", Duration=2}) end })

-- ============================================
-- TAB 2: SHOP (🛒 Store & Items)
-- ============================================
local TabShop = Window:Page({ Name = "Shop", Columns = 2 })

-- KIRI: Auto Buy
local SectionBuy = TabShop:Section({ Name = "Auto Buy", Side = 1 })
SectionBuy:Toggle({ Name = "Auto Buy", Default = false, Callback = function(v) S.autoBuy = v end })
SectionBuy:Dropdown({ Name = "Target Buy", Options = ALL_BUY_ITEMS, Default = "All", Callback = function(v) Selected.buyItem = v end })
SectionBuy:Slider({ Name = "Buy Interval", Min = 5, Max = 300, Default = 30, Suffix = " s", Callback = function(v) S.buyInterval = v end })
SectionBuy:Button({ Name = "Buy Now", Callback = function() buySpecific(Selected.buyItem) Library:Notification({Title="WISNU HUB", Description="Membeli item terpilih", Duration=2}) end })

-- KANAN: Inventory & Gacha
local SectionGacha = TabShop:Section({ Name = "Inventory & Gacha", Side = 2 })
SectionGacha:Button({ Name = "Open All Eggs", Callback = function() openItems("Eggs") Library:Notification({Title="WISNU HUB", Description="Semua telur dibuka", Duration=2}) end })
SectionGacha:Button({ Name = "Open All Crates", Callback = function() openItems("Crates") Library:Notification({Title="WISNU HUB", Description="Semua crate dibuka", Duration=2}) end })
SectionGacha:Button({ Name = "Open All Seed Packs", Callback = function() openItems("SeedPacks") Library:Notification({Title="WISNU HUB", Description="Semua Seed Packs dibuka", Duration=2}) end })

-- ============================================
-- TAB 3: STEAL & MISC (🌙 Extra)
-- ============================================
local TabMisc = Window:Page({ Name = "Steal & Misc", Columns = 2 })

-- KIRI: Night Steal
local SectionSteal = TabMisc:Section({ Name = "Night Steal", Side = 1 })
SectionSteal:Toggle({ Name = "Auto Steal (Night)", Default = false, Callback = function(v) S.autoSteal = v end })
SectionSteal:Slider({ Name = "Steal Interval", Min = 3, Max = 30, Default = 5, Suffix = " s", Callback = function(v) S.stealInterval = v end })
SectionSteal:Button({ Name = "Steal Now", Callback = function() performSteal() Library:Notification({Title="WISNU HUB", Description="Mencoba mencuri...", Duration=2}) end })

-- KANAN: Settings
local SectionSettings = TabMisc:Section({ Name = "Settings", Side = 2 })
SectionSettings:Toggle({ Name = "Anti-AFK", Default = true, Callback = function(v) S.antiAfk = v end })
SectionSettings:Toggle({
    Name = "Optimize / FPS Boost",
    Default = false,
    Callback = function(v)
        S.optimize = v
        if v then
            Lighting.GlobalShadows = false
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, e in ipairs(Lighting:GetDescendants()) do if e:IsA("PostEffect") or e:IsA("Atmosphere") then pcall(function() e.Enabled = false end) end end
        else
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end
})

-- ============================================================
--  MAIN LOOPS[span_5](start_span)[span_5](end_span)
-- ============================================================
task.spawn(function() while true do task.wait(1) if S.autoHarvest then harvestSpecific(Selected.harvestItem) end end end)
task.spawn(function() while true do task.wait(S.sellInterval or 60) if S.autoSell then sellAll() end end end)
task.spawn(function() while true do task.wait(S.plantInterval or 10) if S.autoPlant then plantSpecific(Selected.plantItem) end end end)
task.spawn(function() while true do task.wait(S.buyInterval or 30) if S.autoBuy then buySpecific(Selected.buyItem) end end end)
task.spawn(function() while true do task.wait(S.stealInterval or 5) if S.autoSteal and isNightTime() then performSteal() end end end)

LocalPlayer.Idled:Connect(function()
    if S.antiAfk then pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end
end)

Library:Notification({ Title = "WISNU HUB", Description = "Grow a Garden 2 Script Loaded!", Duration = 3, Icon = IMAGE_ID })
print("✅ WISNU HUB  loaded!")
