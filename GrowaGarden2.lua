-- ============================================================
--  WISNU HUB - GROW A GARDEN 2 (Wisnu UI)
--  All-in-One Auto Farm
-- ============================================================
print("=== LOADING WISNU HUB - GAG2 ===")

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

-- ===== LOAD PULSELYB LIBRARY (Wisnu UI) =====
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nootmaus/pulselyb/refs/heads/main/.lua"))()
if not Library then error("Library gagal dimuat") end

local IMAGE_ID = "75991977420487"

-- === WINDOW ===
local Window = Library:Window({
    Name = "WISNU HUB",
    SubName = "Grow a Garden 2 Auto Farm",
    Logo = IMAGE_ID
})

Window:SetOpen(true)

-- === PERBAIKI LOGO & TEKS ===
pcall(function()
    local logo = Window.Items.Logo
    if logo then
        logo.Instance.Size = UDim2.new(0, 50, 0, 50)
        logo.Instance.Position = UDim2.new(0, 15, 0, 12)
        logo.Instance.ImageTransparency = 0
        logo.Instance.ImageColor3 = Color3.new(1, 1, 1)
    end
    local title = Window.Items.Title
    if title then
        title.Instance.Position = UDim2.new(0, 75, 0, 13)
        title.Instance.TextSize = 18
    end
    local sub = Window.Items.SubTitle
    if sub then
        sub.Instance.Position = UDim2.new(0, 75, 0, 33)
        sub.Instance.TextSize = 15
    end
end)

-- === PERBAIKI ICON TAB ===
pcall(function()
    for _, page in pairs(Window.Pages) do
        if page.Items and page.Items.Icon then
            page.Items.Icon.Instance.ImageTransparency = 0
            page.Items.Icon.Instance.ImageColor3 = Color3.new(1, 1, 1)
            page.Items.Icon.Instance.Size = UDim2.new(0, 24, 0, 24)
        end
    end
end)

-- === HAPUS BUBBLE BAWAAN ===
pcall(function()
    if Window.Items and Window.Items.FloatingButton then
        Window.Items.FloatingButton.Instance:Destroy()
    end
end)

-- === BUBBLE CERDAS ===
local function createBubble()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 75, 0, 75)
    btn.Position = UDim2.new(0.5, -37, 0.5, -37)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    btn.BackgroundTransparency = 0
    btn.Text = ""
    btn.Parent = Library.Holder.Instance
    btn.ZIndex = 10

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 110)
    stroke.Thickness = 1.5
    stroke.Parent = btn

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0.8, 0, 0.8, 0)
    icon.Position = UDim2.new(0.1, 0, 0.1, 0)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. IMAGE_ID
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ImageTransparency = 0
    icon.ImageColor3 = Color3.new(1, 1, 1)
    icon.ZIndex = 20
    icon.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Window:SetOpen(not Window.IsOpen)
    end)

    local dragging = false
    local dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return btn
end

createBubble()

-- === PERBESAR UI ===
pcall(function()
    local mainFrame = Window.Items["MainFrame"].Instance
    local scale = Instance.new("UIScale")
    scale.Scale = 1.3
    scale.Parent = mainFrame
end)

-- ============================================================
--  ITEM DATABASE (LENGKAP 33 SEED)
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
--  MODUL DAN FUNGSI INTI (DARI GAG2)
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
        local owner = plot:GetAttribute("OwnerId") or plot:GetAttribute("Owner")
        if owner then
            if type(owner) == "number" and owner == LocalPlayer.UserId then
                return plot
            elseif type(owner) == "string" and owner == LocalPlayer.Name then
                return plot
            end
        end
    end
    return nil
end

local function isNightTime()
    return Night and Night.Value == true
end

local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

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
--  FUNGSI UTAMA (DARI GAG2)
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
--  UI – WISNU UI STYLE (PULSELYB)
-- ============================================================

local TabUtama = Window:Page({
    Name = "Auto Farm",
    Icon = "",
    Columns = 2
})

pcall(function()
    if TabUtama and TabUtama.Items then
        if TabUtama.Items.Icon then
            TabUtama.Items.Icon.Instance:Destroy()
        end
        if TabUtama.Items.Text then
            TabUtama.Items.Text.Instance.Position = UDim2.new(0, 16, 0.5, 0)
        end
    end
end)

-- ===== SECTION KIRI (Fitur Utama) =====
local SectionKiri = TabUtama:Section({
    Name = "Fitur Utama",
    Description = "Pengaturan Auto Farm",
    Side = 1
})

-- Auto Harvest
SectionKiri:Toggle({
    Name = "Auto Harvest",
    Default = false,
    Callback = function(v)
        S.autoHarvest = v
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Auto Harvest: " .. (v and "ON" or "OFF"),
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

-- Auto Sell
SectionKiri:Toggle({
    Name = "Auto Sell",
    Default = false,
    Callback = function(v)
        S.autoSell = v
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Auto Sell: " .. (v and "ON" or "OFF"),
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

-- Auto Plant
SectionKiri:Toggle({
    Name = "Auto Plant",
    Default = false,
    Callback = function(v)
        S.autoPlant = v
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Auto Plant: " .. (v and "ON" or "OFF"),
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

-- Auto Buy
SectionKiri:Toggle({
    Name = "Auto Buy",
    Default = false,
    Callback = function(v)
        S.autoBuy = v
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Auto Buy: " .. (v and "ON" or "OFF"),
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

-- Slider Harvest Interval
SectionKiri:Slider({
    Name = "Harvest Interval (s)",
    Min = 1,
    Max = 30,
    Default = 5,
    Suffix = "s",
    Decimals = 0,
    Callback = function(v)
        S.harvestInterval = v
    end
})

-- Slider Plant Interval
SectionKiri:Slider({
    Name = "Plant Interval (s)",
    Min = 5,
    Max = 60,
    Default = 15,
    Suffix = "s",
    Decimals = 0,
    Callback = function(v)
        S.plantInterval = v
    end
})

-- Slider Sell Interval
SectionKiri:Slider({
    Name = "Sell Interval (s)",
    Min = 10,
    Max = 120,
    Default = 60,
    Suffix = "s",
    Decimals = 0,
    Callback = function(v)
        S.sellInterval = v
    end
})

-- Slider Buy Interval
SectionKiri:Slider({
    Name = "Buy Interval (s)",
    Min = 10,
    Max = 120,
    Default = 30,
    Suffix = "s",
    Decimals = 0,
    Callback = function(v)
        S.buyInterval = v
    end
})

-- Dropdown Harvest Item (Multi Select)
local harvestOptions = {"All"}
for _, seed in ipairs(SEEDS) do table.insert(harvestOptions, seed) end

if SectionKiri.Dropdown then
    SectionKiri:Dropdown({
        Name = "Harvest Item",
        Options = harvestOptions,
        Default = "All",
        Multi = true,
        Callback = function(v)
            Selected.harvestItem = v
            Library:Notification({
                Title = "WISNU HUB",
                Description = "Harvest item diupdate",
                Duration = 2,
                Icon = IMAGE_ID
            })
        end
    })
else
    SectionKiri:Button({
        Name = "Harvest Item: All (click to cycle)",
        Callback = function()
            local idx = table.find(harvestOptions, Selected.harvestItem) or 1
            idx = idx % #harvestOptions + 1
            Selected.harvestItem = harvestOptions[idx]
            Library:Notification({
                Title = "WISNU HUB",
                Description = "Harvest item: " .. Selected.harvestItem,
                Duration = 2,
                Icon = IMAGE_ID
            })
        end
    })
end

-- Dropdown Plant Item (Multi Select)
local plantOptions = {"All"}
for _, seed in ipairs(SEEDS) do table.insert(plantOptions, seed) end

if SectionKiri.Dropdown then
    SectionKiri:Dropdown({
        Name = "Plant Item",
        Options = plantOptions,
        Default = "All",
        Multi = true,
        Callback = function(v)
            Selected.plantItem = v
            Library:Notification({
                Title = "WISNU HUB",
                Description = "Plant item diupdate",
                Duration = 2,
                Icon = IMAGE_ID
            })
        end
    })
else
    SectionKiri:Button({
        Name = "Plant Item: All (click to cycle)",
        Callback = function()
            local idx = table.find(plantOptions, Selected.plantItem) or 1
            idx = idx % #plantOptions + 1
            Selected.plantItem = plantOptions[idx]
            Library:Notification({
                Title = "WISNU HUB",
                Description = "Plant item: " .. Selected.plantItem,
                Duration = 2,
                Icon = IMAGE_ID
            })
        end
    })
end

-- Dropdown Buy Item (Multi Select)
local buyOptions = {"All"}
for _, seed in ipairs(SEEDS) do table.insert(buyOptions, seed) end
for _, gear in ipairs(GEARS) do table.insert(buyOptions, gear) end
for _, crate in ipairs(CRATES) do table.insert(buyOptions, crate) end

if SectionKiri.Dropdown then
    SectionKiri:Dropdown({
        Name = "Buy Item",
        Options = buyOptions,
        Default = "All",
        Multi = true,
        Callback = function(v)
            Selected.buyItem = v
            Library:Notification({
                Title = "WISNU HUB",
                Description = "Buy item diupdate",
                Duration = 2,
                Icon = IMAGE_ID
            })
        end
    })
else
    SectionKiri:Button({
        Name = "Buy Item: All (click to cycle)",
        Callback = function()
            local idx = table.find(buyOptions, Selected.buyItem) or 1
            idx = idx % #buyOptions + 1
            Selected.buyItem = buyOptions[idx]
            Library:Notification({
                Title = "WISNU HUB",
                Description = "Buy item: " .. Selected.buyItem,
                Duration = 2,
                Icon = IMAGE_ID
            })
        end
    })
end

-- Tombol Aksi
SectionKiri:Button({
    Name = "Harvest Now",
    Callback = function()
        local count = harvestSpecific(Selected.harvestItem)
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Panen " .. count .. " tanaman",
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

SectionKiri:Button({
    Name = "Sell Now",
    Callback = function()
        sellAll()
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Semua terjual!",
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

SectionKiri:Button({
    Name = "Plant Now",
    Callback = function()
        plantSpecific(Selected.plantItem)
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Menanam bibit terpilih",
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

SectionKiri:Button({
    Name = "Buy Now",
    Callback = function()
        buySpecific(Selected.buyItem)
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Membeli item terpilih",
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

SectionKiri:Button({
    Name = "Open All Eggs",
    Callback = function()
        openItems("Eggs")
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Semua telur dibuka!",
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

SectionKiri:Button({
    Name = "Open All Crates",
    Callback = function()
        openItems("Crates")
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Semua crate dibuka!",
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

SectionKiri:Button({
    Name = "Open All Seed Packs",
    Callback = function()
        openItems("SeedPacks")
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Semua seed pack dibuka!",
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

-- ===== SECTION KANAN (Player Set) =====
local SectionKanan = TabUtama:Section({
    Name = "Player Set",
    Description = "Kecepatan & Lompat",
    Side = 2
})

SectionKanan:Slider({
    Name = "Walkspeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Suffix = " WS",
    Decimals = 1,
    Callback = function(Value)
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Value
            end
        end)
    end
})

local infiniteJumpEnabled = false
SectionKanan:Toggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v)
        infiniteJumpEnabled = v
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Infinite Jump: " .. (v and "ON" or "OFF"),
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ===== SECTION STEAL (Tambahan) =====
local TabSteal = Window:Page({
    Name = "Steal",
    Icon = "",
    Columns = 1
})

local StealSection = TabSteal:Section({
    Name = "Auto Steal",
    Description = "Curi buah saat malam",
    Side = 1
})

StealSection:Toggle({
    Name = "Auto Steal",
    Default = false,
    Callback = function(v)
        S.autoSteal = v
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Auto Steal: " .. (v and "ON" or "OFF"),
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

StealSection:Slider({
    Name = "Steal Interval (s)",
    Min = 3,
    Max = 30,
    Default = 5,
    Suffix = "s",
    Decimals = 0,
    Callback = function(v)
        S.stealInterval = v
    end
})

StealSection:Button({
    Name = "Steal Now",
    Callback = function()
        performSteal()
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Mencoba mencuri...",
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

-- ===== SECTION MISC =====
local TabMisc = Window:Page({
    Name = "Misc",
    Icon = "",
    Columns = 1
})

local MiscSection = TabMisc:Section({
    Name = "Lainnya",
    Description = "Fitur tambahan",
    Side = 1
})

MiscSection:Toggle({
    Name = "Anti-AFK",
    Default = true,
    Callback = function(v)
        S.antiAfk = v
        Library:Notification({
            Title = "WISNU HUB",
            Description = "Anti-AFK: " .. (v and "ON" or "OFF"),
            Duration = 2,
            Icon = IMAGE_ID
        })
    end
})

MiscSection:Toggle({
    Name = "Optimize (FPS)",
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

MiscSection:Button({
    Name = "Unload Script",
    Callback = function()
        Window:Destroy()
        print("WISNU HUB Unloaded")
    end
})

-- ============================================================
--  MAIN LOOPS
-- ============================================================

task.spawn(function()
    while true do
        task.wait(S.harvestInterval or 5)
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
        task.wait(S.plantInterval or 15)
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
Library:Notification({
    Title = "WISNU HUB",
    Description = "Grow a Garden 2 Loaded!",
    Duration = 5,
    Icon = IMAGE_ID
})

print("✅ WISNU HUB - GROW A GARDEN 2 LOADED")
