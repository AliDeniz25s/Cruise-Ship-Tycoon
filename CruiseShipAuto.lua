local execName = ""
pcall(function()
    execName = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Unknown"
end)

if string.find(string.lower(execName), "xeno") then
    return
end

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
while not localPlayer do
    Players.PlayerAdded:Wait()
    localPlayer = Players.LocalPlayer
end

local playerGui = localPlayer:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("ShipAutoRestockGui") or CoreGui:FindFirstChild("ShipAutoRestockGui")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShipAutoRestockGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

local function triggerAntiAfk()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end

localPlayer.Idled:Connect(function()
    triggerAntiAfk()
end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(120)
        triggerAntiAfk()
    end
end)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 340)
mainFrame.Position = UDim2.new(1, -240, 1, -365)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = ScreenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Ship Auto"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 20)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 12
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -45)
contentContainer.Position = UDim2.new(0, 10, 0, 38)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local layout = Instance.new("UIListLayout", contentContainer)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 0, 32)
toggleBtn.LayoutOrder = 1
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggleBtn.Text = "Automation: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 13
toggleBtn.Parent = contentContainer
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local nuclearActive = true
local nuclearToggleBtn = Instance.new("TextButton")
nuclearToggleBtn.Size = UDim2.new(1, 0, 0, 30)
nuclearToggleBtn.LayoutOrder = 2
nuclearToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
nuclearToggleBtn.Text = "Nuclear Reactor Mode: ON"
nuclearToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nuclearToggleBtn.Font = Enum.Font.SourceSansBold
nuclearToggleBtn.TextSize = 13
nuclearToggleBtn.Parent = contentContainer
Instance.new("UICorner", nuclearToggleBtn).CornerRadius = UDim.new(0, 6)

local testBtn = Instance.new("TextButton")
testBtn.Size = UDim2.new(1, 0, 0, 30)
testBtn.LayoutOrder = 3
testBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
testBtn.Text = "Run Sequence"
testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
testBtn.Font = Enum.Font.SourceSansBold
testBtn.TextSize = 13
testBtn.Parent = contentContainer
Instance.new("UICorner", testBtn).CornerRadius = UDim.new(0, 6)

local function createInputBox(labelText, defaultVal, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 28)
    container.LayoutOrder = order
    container.BackgroundTransparency = 1
    container.Parent = contentContainer
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.6, 0, 1, 0)
    box.Position = UDim2.new(0.4, 0, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.Parent = container
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    
    return box
end

local fuelBox = createInputBox("Fuel Amount:", 96000, 4)
local stockBox = createInputBox("Stock Amount:", 100000, 5)
local energyBox = createInputBox("Energy Amt:", 7925.2, 6)
local routeBox = createInputBox("Route ID:", 1, 7)

local CONFIG_FILE = "ShipAutoConfig.json"
local canSaveFiles = (writefile and readfile and isfile) or false

local function saveConfig()
    if not canSaveFiles then return end
    pcall(function()
        local configData = {
            fuel = fuelBox.Text,
            stock = stockBox.Text,
            energy = energyBox.Text,
            route = routeBox.Text,
            nuclear = nuclearActive
        }
        writefile(CONFIG_FILE, HttpService:JSONEncode(configData))
    end)
end

local function loadConfig()
    if not canSaveFiles then return end
    pcall(function()
        if isfile(CONFIG_FILE) then
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if decoded.fuel then fuelBox.Text = tostring(decoded.fuel) end
            if decoded.stock then stockBox.Text = tostring(decoded.stock) end
            if decoded.energy then energyBox.Text = tostring(decoded.energy) end
            if decoded.route then routeBox.Text = tostring(decoded.route) end
            if decoded.nuclear ~= nil then
                nuclearActive = decoded.nuclear
                if nuclearActive then
                    nuclearToggleBtn.Text = "Nuclear Reactor Mode: ON"
                    nuclearToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
                else
                    nuclearToggleBtn.Text = "Nuclear Reactor Mode: OFF"
                    nuclearToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
                end
            end
        end
    end)
end

fuelBox.FocusLost:Connect(saveConfig)
stockBox.FocusLost:Connect(saveConfig)
energyBox.FocusLost:Connect(saveConfig)
routeBox.FocusLost:Connect(saveConfig)
loadConfig()

local isSmartActive = false
local cachedShipId = "0lAl"

toggleBtn.MouseButton1Click:Connect(function()
    isSmartActive = not isSmartActive
    if isSmartActive then
        toggleBtn.Text = "Automation: ACTIVE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
    else
        toggleBtn.Text = "Automation: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

nuclearToggleBtn.MouseButton1Click:Connect(function()
    nuclearActive = not nuclearActive
    if nuclearActive then
        nuclearToggleBtn.Text = "Nuclear Reactor Mode: ON"
        nuclearToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
    else
        nuclearToggleBtn.Text = "Nuclear Reactor Mode: OFF"
        nuclearToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
    saveConfig()
end)

closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
local shipEvent = remoteFolder and remoteFolder:WaitForChild("ShipEvent", 5)
local passengerEvent = remoteFolder and remoteFolder:WaitForChild("PassengerEvent", 5)

local function runPortSequence(shipId)
    if not shipEvent or not passengerEvent then return end
    task.spawn(function()
