--==================================================
-- BIGBOS FISH IT — ULTIMATE V3 (PRIVATE DEV MODE)
-- Delta Executor | Stable | Modular | Auto-Detect
--==================================================

--==================== SERVICES ====================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

--==================== CONFIG ======================
local CFG = {
    AutoFish = false,
    SuperInstant = true,
    ReelSpeed = 900,
    AutoSell = false,
    AntiAFK = true,
    ZoneOffset = Vector3.new(0,0,-28),
    LoopDelay = 0.8,
}

--==================== REMOTE SCAN =================
local Remotes = {}
for _,v in ipairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        Remotes[v.Name:lower()] = v
    end
end

local function getRemote(key)
    for n,r in pairs(Remotes) do
        if n:find(key) then return r end
    end
end

--==================== GUI CORE ====================
local gui = Instance.new("ScreenGui")
gui.Name = "BIGBOS_V3_GUI"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,460,0,520)
main.Position = UDim2.new(0.5,-230,0.5,-260)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.Active, main.Draggable = true, true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,50)
title.Text = "BIGBOS FISH IT — ULTIMATE V3"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,215,0)
title.BackgroundTransparency = 1

local function makeBtn(text, y)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(1,-40,0,36)
    b.Position = UDim2.new(0,20,0,y)
    b.Text = text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(36,36,36)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    return b
end

--==================== BUTTONS =====================
local y = 60

local btnAutoFish = makeBtn("Main | Auto Fish : OFF", y)
y+=44
btnAutoFish.MouseButton1Click:Connect(function()
    CFG.AutoFish = not CFG.AutoFish
    btnAutoFish.Text = "Main | Auto Fish : "..(CFG.AutoFish and "ON" or "OFF")
end)

local btnInstant = makeBtn("Main | Super Instant Reel : ON", y)
y+=44
btnInstant.MouseButton1Click:Connect(function()
    CFG.SuperInstant = not CFG.SuperInstant
    btnInstant.Text = "Main | Super Instant Reel : "..(CFG.SuperInstant and "ON" or "OFF")
end)

local btnZone = makeBtn("Zone Fishing | Smart Offset TP", y)
y+=44
btnZone.MouseButton1Click:Connect(function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = hrp.CFrame + CFG.ZoneOffset end
end)

local btnSell = makeBtn("Backpack | Auto Sell : OFF", y)
y+=44
btnSell.MouseButton1Click:Connect(function()
    CFG.AutoSell = not CFG.AutoSell
    btnSell.Text = "Backpack | Auto Sell : "..(CFG.AutoSell and "ON" or "OFF")
end)

local btnWeather = makeBtn("Shopping | Buy Weather (Auto)", y)
y+=44
btnWeather.MouseButton1Click:Connect(function()
    local r = getRemote("weather")
    if r then pcall(function() r:FireServer("Rain") end) end
end)

local btnQuest = makeBtn("Quests | Auto Claim", y)
y+=44
btnQuest.MouseButton1Click:Connect(function()
    local r = getRemote("quest")
    if r then pcall(function() r:FireServer() end) end
end)

local btnTPSell = makeBtn("Teleport | Sell NPC", y)
y+=44
btnTPSell.MouseButton1Click:Connect(function()
    for _,m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") and m.Name:lower():find("sell") then
            local p = m:FindFirstChildWhichIsA("BasePart")
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if p and hrp then hrp.CFrame = p.CFrame + Vector3.new(0,3,0) end
        end
    end
end)

local btnAFK = makeBtn("Utilities | Anti AFK : ON", y)
y+=44
btnAFK.MouseButton1Click:Connect(function()
    CFG.AntiAFK = not CFG.AntiAFK
    btnAFK.Text = "Utilities | Anti AFK : "..(CFG.AntiAFK and "ON" or "OFF")
end)

--==================== AUTOMATION ==================
task.spawn(function()
    while task.wait(CFG_LOOP or 0.8) do
        if CFG.AutoFish then
            local r = getRemote("fish")
            if r then pcall(function() r:FireServer() end) end
        end
    end
end)

task.spawn(function()
    while task.wait(3.5) do
        if CFG.AutoSell then
            local r = getRemote("sell")
            if r then pcall(function() r:FireServer() end) end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if CFG.AutoFish and CFG.SuperInstant then
        pcall(function()
            local rod = LP.Character and LP.Character:FindFirstChild("Rod", true)
            if rod and rod:FindFirstChild("ReelSpeed") then
                rod.ReelSpeed.Value = CFG.ReelSpeed
            end
        end)
    end
end)

if CFG.AntiAFK then
    LP.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
    end)
end
