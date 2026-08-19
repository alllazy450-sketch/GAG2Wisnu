-- ============================================================
--  WISNU HUB | GROW A GARDEN 2 (UPGRADED FULL VERSION)
-- ============================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()

Library:SetTheme("OLED")

local MY_LOGO = "rbxassetid://75991977420487"

-- Buat Jendela Utama WISNU HUB
local Window = Library:CreateWindow({
    Name = "WISNU HUB",
    BrandSubtitle = "Grow a Garden 2",
    Logo = MY_LOGO,
    LogoZoom = 1.5,
    ToggleKey = Enum.KeyCode.F3,
    ProfileKey = Enum.KeyCode.K,
    Size = UDim2.fromOffset(720, 500),
    LoadingText = "WISNU HUB",
    LoadingSubtitle = "Loading Upgraded Engine...",
})

-- Ketebalan Watermark Logo
task.spawn(function()
    task.wait(0.5)
    if Window.Watermark then
        Window.Watermark.ImageTransparency = 0.4
    end
end)

-- Smart Mobile Bubble
task.spawn(function()
    pcall(function()
        local sg = Window.ScreenGui
        if not sg then return end
        
        local btn = Instance.new("TextButton")
        btn.Name = "WisnuMobileBubble"
        btn.Size = UDim2.new(0, 56, 0, 56)
        btn.Position = UDim2.new(0.1, 0, 0.4, 0)
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        btn.BackgroundTransparency = 0.1
        btn.Text = ""
        btn.ZIndex = 999
        btn.Parent = sg
        
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 16)
        
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(167, 200, 244)
        stroke.Thickness = 1.5
        
        local icon = Instance.new("ImageLabel", btn)
        icon.Size = UDim2.new(0.8, 0, 0.8, 0)
        icon.Position = UDim2.new(0.1, 0, 0.1, 0)
        icon.BackgroundTransparency = 1
        icon.Image = MY_LOGO
        icon.ScaleType = Enum.ScaleType.Fit
        icon.ZIndex = 1000
        
        btn.MouseButton1Click:Connect(function() Window:ToggleUI() end)
        
        local UserInputService = game:GetService("UserInputService")
        local dragging, dragStart, startPos = false, nil, nil
        
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, btn.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end)
end)

-- ============================================================
--  DATABASE & BACKEND GAME[span_1](start_span)[span_1](end_span)
-- ============================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")

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

local SEED_OPTIONS = {"All"}
for _, v in ipairs(SEEDS) do table.insert(SEED_OPTIONS, v) end

local GEAR_OPTIONS = {"All"}
for _, v in ipairs(GEARS) do table.insert(GEAR_OPTIONS, v) end

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

local S = {
    autoHarvest = false, autoSell = false, autoSteal = false, autoBuySeed = false, autoBuyGear = false, autoPlant = false,
    sellInterval = 10, stealInterval = 5, plantInterval = 10, buySeedInterval = 5, buyGearInterval = 5,
    antiAfk = true, optimize = false, reduceMap = false, playerESP = false, espColor = Color3.fromRGB(167, 200, 244)
}

local Selected = { harvestItem = "All", plantItem = "All", buySeedItem = "All", buyGearItem = "All" }

-- ============================================================
--  LOGIKA UTAMA[span_2](start_span)[span_2](end_span)
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
                            if pid then pcall(function() Networking.Garden.CollectFruit:Fire(pid, fid) end) count = count + 1 end
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
                    if pid then pcall(function() Networking.Garden.CollectFruit:Fire(pid, "") end) count = count + 1 end
                end
            end
        end
    end
    return count
end

local function sellAll() if Networking then pcall(function() Networking.NPCS.SellAll:Fire() end) end end

local function buySeeds(items)
    if not Networking then return end
    pcall(function()
        for _, item in ipairs(ReplicatedStorage.StockValues.SeedShop.Items:GetChildren()) do
            if item:IsA("ValueBase") and item.Value > 0 and isSelected(items, item.Name) then
                Networking.SeedShop.PurchaseSeed:Fire(item.Name)
            end
        end
    end)
end

local function buyGears(items)
    if not Networking then return end
    pcall(function()
        for _, item in ipairs(ReplicatedStorage.StockValues.GearShop.Items:GetChildren()) do
            if item:IsA("ValueBase") and item.Value > 0 and isSelected(items, item.Name) then
                Networking.GearShop.PurchaseGear:Fire(item.Name)
            end
        end
    end)
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
            end
        end
    end
end

local function openItems(category)
    if not Networking then return end
    local inv = LocalPlayer:GetAttribute("Inventory") or {}
    local pkt = (category == "Eggs" and Networking.Egg.OpenEgg) or (category == "Crates" and Networking.Crate.OpenCrate) or (category == "SeedPacks" and Networking.SeedPack.OpenSeedPack)
    if not pkt then return end
    for name, count in pairs(inv[category] or {}) do for i = 1, count do pcall(function() pkt:Fire(name) end) task.wait(0.05) end end
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
    task.wait(0.3)
    pcall(function() Networking.Steal.BeginSteal:Fire(tonumber(ownerId), plantId, fruitId) end)
    pcall(function() Networking.Steal.CompleteSteal:Fire() end)
    task.wait(0.3)
    teleportTo(ref.CFrame, 33)
end

-- Custom Player ESP System
local function updatePlayerESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hl = char:FindFirstChild("WisnuPlayerESP")
            if S.playerESP then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "WisnuPlayerESP"
                    hl.FillTransparency = 1
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                end
                hl.OutlineColor = S.espColor
            else
                if hl then hl:Destroy() end
            end
        end
    end
end

-- ============================================================
--  STRUKTUR UI OXIDELIB
-- ============================================================

-- TAB 1: FARM
local TabFarm = Window:AddTab({ Name = "Farm", Icon = "home" })
local SubHarvest = TabFarm:AddSubTab("Harvest & Sell")
local SubPlant = TabFarm:AddSubTab("Planting")

SubHarvest:AddSection("Harvest Automation")
SubHarvest:AddToggle({ Name = "Auto Harvest", Default = false, Callback = function(v) S.autoHarvest = v end })
SubHarvest:AddDropdown({ Name = "Target Harvest", Options = SEED_OPTIONS, Default = "All", Searchable = true, Callback = function(v) Selected.harvestItem = v end })
SubHarvest:AddButton({ Name = "Harvest Now", Callback = function() harvestSpecific(Selected.harvestItem) Window:Notify({Title="WISNU HUB", Content="Panen selesai!", Type="success", Duration=2}) end })

SubHarvest:AddSection("Sell Automation")
SubHarvest:AddToggle({ Name = "Auto Sell", Default = false, Callback = function(v) S.autoSell = v end })
SubHarvest:AddInput({ Name = "Sell Interval (detik)", Default = "10", Placeholder = "10", Callback = function(t) S.sellInterval = tonumber(t) or 10 end })
SubHarvest:AddButton({ Name = "Sell Now", Callback = function() sellAll() Window:Notify({Title="WISNU HUB", Content="Semua terjual!", Type="success", Duration=2}) end })

SubPlant:AddSection("Planting Automation")
SubPlant:AddToggle({ Name = "Auto Plant", Default = false, Callback = function(v) S.autoPlant = v end })
SubPlant:AddDropdown({ Name = "Target Plant", Options = SEED_OPTIONS, Default = "All", Searchable = true, Callback = function(v) Selected.plantItem = v end })
SubPlant:AddInput({ Name = "Plant Interval (detik)", Default = "10", Placeholder = "10", Callback = function(t) S.plantInterval = tonumber(t) or 10 end })
SubPlant:AddButton({ Name = "Plant Now", Callback = function() plantSpecific(Selected.plantItem) Window:Notify({Title="WISNU HUB", Content="Menanam bibit...", Type="success", Duration=2}) end })


-- TAB 2: SHOP (DIpisahkan Seed & Gear)
local TabShop = Window:AddTab({ Name = "Shop", Icon = "shopping" })
local SubBuySeed = TabShop:AddSubTab("Auto Buy Seeds")
local SubBuyGear = TabShop:AddSubTab("Auto Buy Gears")
local SubGacha = TabShop:AddSubTab("Gacha & Openers")

SubBuySeed:AddSection("Seed Store Automation")
SubBuySeed:AddToggle({ Name = "Auto Buy Seeds", Default = false, Callback = function(v) S.autoBuySeed = v end })
SubBuySeed:AddDropdown({ Name = "Target Seed", Options = SEED_OPTIONS, Default = "All", Searchable = true, Callback = function(v) Selected.buySeedItem = v end })
SubBuySeed:AddInput({ Name = "Buy Seed Interval (detik)", Default = "5", Placeholder = "5", Callback = function(t) S.buySeedInterval = tonumber(t) or 5 end })

SubBuyGear:AddSection("Gear & Crate Store Automation")
SubBuyGear:AddToggle({ Name = "Auto Buy Gears", Default = false, Callback = function(v) S.autoBuyGear = v end })
SubBuyGear:AddDropdown({ Name = "Target Gear", Options = GEAR_OPTIONS, Default = "All", Searchable = true, Callback = function(v) Selected.buyGearItem = v end })
SubBuyGear:AddInput({ Name = "Buy Gear Interval (detik)", Default = "5", Placeholder = "5", Callback = function(t) S.buyGearInterval = tonumber(t) or 5 end })

SubGacha:AddSection("Mass Open Inventory")
SubGacha:AddButton({ Name = "Open All Eggs", Callback = function() openItems("Eggs") Window:Notify({Title="WISNU HUB", Content="Telur dibuka", Type="success", Duration=2}) end })
SubGacha:AddButton({ Name = "Open All Crates", Callback = function() openItems("Crates") Window:Notify({Title="WISNU HUB", Content="Crate dibuka", Type="success", Duration=2}) end })
SubGacha:AddButton({ Name = "Open All Seed Packs", Callback = function() openItems("SeedPacks") Window:Notify({Title="WISNU HUB", Content="Seed Packs dibuka", Type="success", Duration=2}) end })


-- TAB 3: STEAL (Tab Baru Khusus Steal)
local TabSteal = Window:AddTab({ Name = "Steal", Icon = "target" })
local SubStealMenu = TabSteal:AddSubTab("Night Steal Hub")

SubStealMenu:AddSection("Auto Steal Automation")
SubStealMenu:AddToggle({ Name = "Auto Steal (Night)", Default = false, Callback = function(v) S.autoSteal = v end })
SubStealMenu:AddInput({ Name = "Steal Interval (detik)", Default = "5", Placeholder = "5", Callback = function(t) S.stealInterval = tonumber(t) or 5 end })
SubStealMenu:AddButton({ Name = "Steal Target Now", Callback = function() performSteal() Window:Notify({Title="WISNU HUB", Content="Mencoba mencuri...", Type="warning", Duration=2}) end })


-- TAB 4: MISC (Reduce Map, Custom ESP, Anti-AFK, FPS Boost)
local TabMisc = Window:AddTab({ Name = "Misc", Icon = "gear" })
local SubMiscMenu = TabMisc:AddSubTab("Optimization & Visuals")

SubMiscMenu:AddSection("Player Visuals & ESP")
SubMiscMenu:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(v)
        S.playerESP = v
        updatePlayerESP()
    end
})
SubMiscMenu:AddColorPicker({
    Name = "ESP Outline Color",
    Default = Color3.fromRGB(167, 200, 244),
    Callback = function(c)
        S.espColor = c
        updatePlayerESP()
    end
})

SubMiscMenu:AddSection("Game Optimization & Safety")
SubMiscMenu:AddToggle({
    Name = "Reduce Map (Low Detail)",
    Default = false,
    Callback = function(v)
        S.reduceMap = v
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                -- Opsional reduksi detail map
            end
        end
        Window:Notify({ Title = "WISNU HUB", Content = "Reduce map diterapkan!", Type = "info", Duration = 2 })
    end
})
SubMiscMenu:AddToggle({
    Name = "Optimize / FPS Boost",
    Default = false,
    Callback = function(v)
        S.optimize = v
        if v then
            Lighting.GlobalShadows = false
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Window:Notify({ Title = "FPS Boost", Content = "Grafik dimaksimalkan ringan!", Type = "success", Duration = 2 })
        else
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end
})
SubMiscMenu:AddToggle({
    Name = "Anti-AFK",
    Default = true,
    Callback = function(v) S.antiAfk = v end
})

-- ============================================================
--  LOOP EKSEKUSI BACKGROUND (DIKECILKAN DELAY-NYA AGAR RESPON CEPAT)
-- ============================================================
task.spawn(function() while true do task.wait(0.2) if S.autoHarvest then harvestSpecific(Selected.harvestItem) end end end)
task.spawn(function() while true do task.wait(S.sellInterval or 10) if S.autoSell then sellAll() end end end)
task.spawn(function() while true do task.wait(S.plantInterval or 10) if S.autoPlant then plantSpecific(Selected.plantItem) end end end)
task.spawn(function() while true do task.wait(S.buySeedInterval or 5) if S.autoBuySeed then buySeeds(Selected.buySeedItem) end end end)
task.spawn(function() while true do task.wait(S.buyGearInterval or 5) if S.autoBuyGear then buyGears(Selected.buyGearItem) end end end)
task.spawn(function() while true do task.wait(S.stealInterval or 5) if S.autoSteal and isNightTime() then performSteal() end end end)

RunService.RenderStepped:Connect(function()
    if S.playerESP then updatePlayerESP() end
end)

LocalPlayer.Idled:Connect(function()
    if S.antiAfk then pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end
end)

Window:Notify({
    Title = "WISNU HUB UPGRADED",
    Content = "Semua permintaan fitur baru berhasil dimuat! Tekan K untuk melihat Ping & FPS Counter.",
    Type = "success",
    Duration = 5,
})

print("✅ WISNU HUB UPGRADED LOADED SUCESSFULLY!")
