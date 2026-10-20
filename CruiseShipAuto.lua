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

local oldGui = playerGui:FindFirstChild("Cruise Line Tycoon AFK Script") or CoreGui:FindFirstChild("Cruise Line Tycoon AFK Script")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Cruise Line Tycoon AFK Script"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

local CONFIG_FILE_NAME = "cruiseline_config.json"
local toggleBtn, nuclearToggleBtn
local fuelBox, stockBox, energyBox, routeBox
local configStatusLabel
local isSmartActive = false
local nuclearActive = true
local cachedShipId = "0lAl"

local function saveConfig()
    local success = pcall(function()
        local data = {
            FuelAmount = fuelBox.Text,
            StockAmount = stockBox.Text,
            EnergyAmount = energyBox.Text,
            RouteID = routeBox.Text,
            AutomationActive = isSmartActive,
            NuclearMode = nuclearActive
        }
        if writefile then
            writefile(CONFIG_FILE_NAME, HttpService:JSONEncode(data))
        end
    end)
    return success
end

local function loadConfig()
    local success = pcall(function()
        if isfile and isfile(CONFIG_FILE_NAME) then
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE_NAME))
            if decoded then
                if fuelBox and decoded.FuelAmount then fuelBox.Text = tostring(decoded.FuelAmount) end
                if stockBox and decoded.StockAmount then stockBox.Text = tostring(decoded.StockAmount) end
                if energyBox and decoded.EnergyAmount then energyBox.Text = tostring(decoded.EnergyAmount) end
                if routeBox and decoded.RouteID then routeBox.Text = tostring(decoded.RouteID) end
                
                if decoded.NuclearMode ~= nil then
                    nuclearActive = decoded.NuclearMode
                    if nuclearToggleBtn then
                        nuclearToggleBtn.Text = nuclearActive and "Nuclear Mode: ON" or "Nuclear Mode: OFF"
                        nuclearToggleBtn.BackgroundColor3 = nuclearActive and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(180, 50, 50)
                    end
                end
                
                if decoded.AutomationActive ~= nil then
                    isSmartActive = decoded.AutomationActive
                    if toggleBtn then
                        toggleBtn.Text = isSmartActive and "Automation: ACTIVE" or "Automation: OFF"
                        toggleBtn.BackgroundColor3 = isSmartActive and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(180, 50, 50)
                    end
                end
            end
        end
    end)
    return success
end

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
mainFrame.Size = UDim2.new(0, 220, 0, 440)
mainFrame.Position = UDim2.new(1, -240, 1, -465)
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
titleLabel.Text = "Cruise Line Tycoon Auto"
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

local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Size = UDim2.new(1, -20, 1, -45)
contentContainer.Position = UDim2.new(0, 10, 0, 38)
contentContainer.BackgroundTransparency = 1
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 480)
contentContainer.ScrollBarThickness = 4
contentContainer.Parent = mainFrame

local layout = Instance.new("UIListLayout", contentContainer)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)

toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 0, 32)
toggleBtn.LayoutOrder = 1
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggleBtn.Text = "Automation: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 13
toggleBtn.Parent = contentContainer
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

nuclearToggleBtn = Instance.new("TextButton")
nuclearToggleBtn.Size = UDim2.new(1, 0, 0, 30)
nuclearToggleBtn.LayoutOrder = 2
nuclearToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
nuclearToggleBtn.Text = "Nuclear Mode: ON"
nuclearToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nuclearToggleBtn.Font = Enum.Font.SourceSansBold
nuclearToggleBtn.TextSize = 13
nuclearToggleBtn.Parent = contentContainer
Instance.new("UICorner", nuclearToggleBtn).CornerRadius = UDim.new(0, 6)

-- Hold-to-View Description Logic
local isHoldingNuclear = false

nuclearToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isHoldingNuclear = true
        nuclearToggleBtn.Text = "Discards fuel automation"
    end
end)

nuclearToggleBtn.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isHoldingNuclear then
        isHoldingNuclear = false
        nuclearToggleBtn.Text = nuclearActive and "Nuclear Mode: ON" or "Nuclear Mode: OFF"
    end
end)

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
    
    box.FocusLost:Connect(function()
        saveConfig()
    end)
    
    return box
end

fuelBox = createInputBox("Fuel Amount:", 0, 4)
stockBox = createInputBox("Stock Amount:", 551000, 5)
energyBox = createInputBox("Energy Amt:", 0, 6)
routeBox = createInputBox("Route ID:", 3, 7)

local saveConfigBtn = Instance.new("TextButton")
saveConfigBtn.Size = UDim2.new(1, 0, 0, 32)
saveConfigBtn.LayoutOrder = 8
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
saveConfigBtn.Text = "Save Config"
saveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveConfigBtn.Font = Enum.Font.SourceSansBold
saveConfigBtn.TextSize = 13
saveConfigBtn.Parent = contentContainer
Instance.new("UICorner", saveConfigBtn).CornerRadius = UDim.new(0, 6)

local loadConfigBtn = Instance.new("TextButton")
loadConfigBtn.Size = UDim2.new(1, 0, 0, 32)
loadConfigBtn.LayoutOrder = 9
loadConfigBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
loadConfigBtn.Text = "Load Config"
loadConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadConfigBtn.Font = Enum.Font.SourceSansBold
loadConfigBtn.TextSize = 13
loadConfigBtn.Parent = contentContainer
Instance.new("UICorner", loadConfigBtn).CornerRadius = UDim.new(0, 6)

configStatusLabel = Instance.new("TextLabel")
configStatusLabel.Size = UDim2.new(1, 0, 0, 40)
configStatusLabel.LayoutOrder = 10
configStatusLabel.BackgroundTransparency = 1
configStatusLabel.Text = "Config system active."
configStatusLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
configStatusLabel.Font = Enum.Font.SourceSans
configStatusLabel.TextSize = 11
configStatusLabel.TextWrapped = true
configStatusLabel.Parent = contentContainer

saveConfigBtn.MouseButton1Click:Connect(function()
    if saveConfig() then
        configStatusLabel.Text = "Status: Config saved successfully!"
        configStatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        configStatusLabel.Text = "Status: Save failed!"
        configStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

loadConfigBtn.MouseButton1Click:Connect(function()
    if loadConfig() then
        configStatusLabel.Text = "Status: Config loaded successfully!"
        configStatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        configStatusLabel.Text = "Status: No config found or failed!"
        configStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    isSmartActive = not isSmartActive
    toggleBtn.Text = isSmartActive and "Automation: ACTIVE" or "Automation: OFF"
    toggleBtn.BackgroundColor3 = isSmartActive and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(180, 50, 50)
    saveConfig()
end)

nuclearToggleBtn.MouseButton1Click:Connect(function()
    nuclearActive = not nuclearActive
    nuclearToggleBtn.Text = nuclearActive and "Nuclear Mode: ON" or "Nuclear Mode: OFF"
    nuclearToggleBtn.BackgroundColor3 = nuclearActive and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(180, 50, 50)
    saveConfig()
end)

closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

loadConfig()

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
local shipEvent = remoteFolder and remoteFolder:WaitForChild("ShipEvent", 5)
local passengerEvent = remoteFolder and remoteFolder:WaitForChild("PassengerEvent", 5)

local function runPortSequence(shipId)
    if not shipEvent or not passengerEvent then return end
    task.spawn(function()
        pcall(function()
            local targetId = shipId or cachedShipId or "0lAl"
            local targetRoute = tonumber(routeBox.Text) or 1
            
            shipEvent:FireServer("DeactivateRoute", targetId)
            task.wait(0.1)
            
            shipEvent:FireServer("RequestTug")
            task.wait(0.1)
            
            passengerEvent:FireServer(targetId, "UnloadPassengersOfShip")
            task.wait(0.08)
            passengerEvent:FireServer(targetId, "LoadPassengersOfShip")
            task.wait(0.08)
            
            local energyAmount = tonumber(energyBox.Text) or 7925.2
            shipEvent:FireServer("BuyEnergy", energyAmount)
            task.wait(0.05)
            
            local stockAmount = tonumber(stockBox.Text) or 100000
            
            if not nuclearActive then
                local fuelAmount = tonumber(fuelBox.Text) or 96000
                shipEvent:FireServer("BuyFuel", fuelAmount)
                task.wait(0.05)
            end
            
            shipEvent:FireServer("BuyStock", stockAmount)
            task.wait(2.5)
            
            shipEvent:FireServer("ActivateRoute", targetId, targetRoute)
        end)
    end)
end

testBtn.MouseButton1Click:Connect(function()
    runPortSequence(cachedShipId)
end)

local targetPopups = {"ArrivalFare", "DailyFare"}
local OFFSET_Y = -40

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.4)
        if isSmartActive then
            pcall(function()
                for _, popupName in ipairs(targetPopups) do
                    local popupGui = playerGui:FindFirstChild(popupName)
                    
                    if popupGui and popupGui:IsA("ScreenGui") and popupGui.Enabled then
                        local windowFrame = popupGui:FindFirstChild("MainFrame", true)
                        
                        if windowFrame and windowFrame:IsA("GuiObject") and windowFrame.Visible then
                            local fPos = windowFrame.AbsolutePosition
                            local fSize = windowFrame.AbsoluteSize
                            
                            if fSize.X > 50 and fSize.Y > 50 and fPos.X > 0 and fPos.Y > 0 then
                                local clickX = fPos.X + (fSize.X / 2)
                                local clickY = fPos.Y + fSize.Y - OFFSET_Y
                                
                                task.wait(0.05)
                                
                                pcall(function()
                                    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                                    task.wait(0.05)
                                    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                                end)
                                
                                task.wait(1.0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

local LOW_THRESHOLD = 2000 
local isRestocking = false
local lastRestockTime = 0
local RESTOCK_COOLDOWN = 1800
local lastInstantPassengerAction = 0

if shipEvent and passengerEvent then
    shipEvent.OnClientEvent:Connect(function(...)
        if not ScreenGui.Parent then return end
        
        local val_args = {...}
        local actionType = val_args[1] 
        local shipId     = val_args[2] 
        local currentVal = val_args[4] 
        
        if type(shipId) == "string" and #shipId > 0 then
            cachedShipId = shipId
        end
        
        if type(actionType) == "string" then
            local actionStr = string.lower(actionType)
            local isArrival = string.find(actionStr, "dock") or string.find(actionStr, "arrive") or string.find(actionStr, "port")
            local isDeparture = string.find(actionStr, "leave") or string.find(actionStr, "depart") or string.find(actionStr, "exit")
            
            if isArrival and not isDeparture then
                if (tick() - lastInstantPassengerAction > 5) then
                    lastInstantPassengerAction = tick()
                    task.spawn(function()
                        pcall(function()
                            local targetId = shipId or cachedShipId
                            passengerEvent:FireServer(targetId, "UnloadPassengersOfShip")
                            task.wait(0.08)
                            passengerEvent:FireServer(targetId, "LoadPassengersOfShip")
                            
                            if isSmartActive then
                                task.wait(0.08)
                                local energyAmount = tonumber(energyBox.Text) or 7925.2
                                shipEvent:FireServer("BuyEnergy", energyAmount)
                            end
                        end)
                    end)
                end
            end
        end
        
        if not isSmartActive or isRestocking then return end
        
        if (tick() - lastRestockTime) < RESTOCK_COOLDOWN then
            return
        end
        
        loadConfig()
        local shouldTriggerRestock = false
        if nuclearActive then
            if actionType == "Stock" and type(currentVal) == "number" and currentVal <= LOW_THRESHOLD then
                shouldTriggerRestock = true
            end
        else
            if (actionType == "Fuel" or actionType == "Stock") and type(currentVal) == "number" and currentVal <= LOW_THRESHOLD then
                shouldTriggerRestock = true
            end
        end
        
        if shouldTriggerRestock then
            isRestocking = true
            lastRestockTime = tick()
            runPortSequence(shipId)
            
            task.spawn(function()
                task.wait(15)
                isRestocking = false
            end)
        end
    end)
end

print("Cruise Line Tycoon AFK Script loaded successfully!")
