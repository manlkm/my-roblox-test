-- File: StarterGui/CoordinatesGUI/CoordinatesGUIScript.client.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local MAX_SAVED_COORDS = 5
local COORDS_FORMAT = "%.1f, %.1f, %.1f"
local UPDATE_INTERVAL = 0.1

-- Variables to store coordinates
local currentPosition = Vector3.new(0, 0, 0)
local savedCoordinates = {}

-- Load any previously saved coordinates from attributes
local function loadSavedCoordinates()
    savedCoordinates = {}
    for i = 1, MAX_SAVED_COORDS do
        local coordKey = "SavedCoord_" .. i
        local coord = player:GetAttribute(coordKey)
        if coord then
            -- Convert string back to Vector3
            local x, y, z = string.match(coord, "([^,]+),([^,]+),([^,]+)")
            if x and y and z then
                table.insert(savedCoordinates, Vector3.new(tonumber(x), tonumber(y), tonumber(z)))
            end
        end
    end
end

-- Save coordinates to player attributes
local function saveCoordinatesToAttributes()
    -- Clear old attributes first
    for i = 1, MAX_SAVED_COORDS do
        local coordKey = "SavedCoord_" .. i
        player:SetAttribute(coordKey, nil)
    end
    
    -- Save new coordinates
    for i, coord in ipairs(savedCoordinates) do
        local coordKey = "SavedCoord_" .. i
        local coordString = string.format("%.6f,%.6f,%.6f", coord.X, coord.Y, coord.Z)
        player:SetAttribute(coordKey, coordString)
    end
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoordinatesGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Create main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 300)
mainFrame.Position = UDim2.new(1, -260, 0, 10) -- Top-right
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add corner radius
local cornerRadius = Instance.new("UICorner")
cornerRadius.CornerRadius = UDim.new(0, 8)
cornerRadius.Parent = mainFrame

-- Create title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleLabel.BackgroundTransparency = 0.2
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Coordinates Tracker"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Add corner radius to title
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleLabel

-- Add toggle button to title
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 20, 0, 20)
toggleButton.Position = UDim2.new(1, -25, 0.5, -10)
toggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
toggleButton.BackgroundTransparency = 1
toggleButton.Image = "rbxassetid://6031094664" -- Down arrow icon
toggleButton.Parent = titleLabel

-- Store content frames for easy toggling
local contentFrames = {}

-- Create current coordinates display
local currentCoordsFrame = Instance.new("Frame")
currentCoordsFrame.Name = "CurrentCoordsFrame"
currentCoordsFrame.Size = UDim2.new(1, -20, 0, 60)
currentCoordsFrame.Position = UDim2.new(0, 10, 0, 40)
currentCoordsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
currentCoordsFrame.BackgroundTransparency = 0.5
currentCoordsFrame.BorderSizePixel = 0
currentCoordsFrame.Parent = mainFrame
table.insert(contentFrames, currentCoordsFrame)

-- Add corner radius
local currentCoordsCorner = Instance.new("UICorner")
currentCoordsCorner.CornerRadius = UDim.new(0, 6)
currentCoordsCorner.Parent = currentCoordsFrame

-- Create current position label
local currentPosLabel = Instance.new("TextLabel")
currentPosLabel.Name = "CurrentPosLabel"
currentPosLabel.Size = UDim2.new(1, -10, 0, 20)
currentPosLabel.Position = UDim2.new(0, 5, 0, 5)
currentPosLabel.BackgroundTransparency = 1
currentPosLabel.Text = "Current Position:"
currentPosLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
currentPosLabel.TextSize = 14
currentPosLabel.Font = Enum.Font.GothamSemibold
currentPosLabel.TextXAlignment = Enum.TextXAlignment.Left
currentPosLabel.Parent = currentCoordsFrame

-- Create coordinates text
local coordsText = Instance.new("TextLabel")
coordsText.Name = "CoordsText"
coordsText.Size = UDim2.new(1, -10, 0, 20)
coordsText.Position = UDim2.new(0, 5, 0, 30)
coordsText.BackgroundTransparency = 1
coordsText.Text = "X: 0, Y: 0, Z: 0"
coordsText.TextColor3 = Color3.fromRGB(255, 255, 255)
coordsText.TextSize = 14
coordsText.Font = Enum.Font.Gotham
coordsText.TextXAlignment = Enum.TextXAlignment.Left
coordsText.Parent = currentCoordsFrame

-- Create save button
local saveButton = Instance.new("TextButton")
saveButton.Name = "SaveButton"
saveButton.Size = UDim2.new(1, -20, 0, 30)
saveButton.Position = UDim2.new(0, 10, 0, 110)
saveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
saveButton.BorderSizePixel = 0
saveButton.Text = "Save Current Position"
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.TextSize = 14
saveButton.Font = Enum.Font.GothamSemibold
saveButton.Parent = mainFrame
table.insert(contentFrames, saveButton)

-- Add corner radius to button
local saveButtonCorner = Instance.new("UICorner")
saveButtonCorner.CornerRadius = UDim.new(0, 6)
saveButtonCorner.Parent = saveButton

-- Create saved coordinates title
local savedCoordsTitle = Instance.new("TextLabel")
savedCoordsTitle.Name = "SavedCoordsTitle"
savedCoordsTitle.Size = UDim2.new(1, -20, 0, 25)
savedCoordsTitle.Position = UDim2.new(0, 10, 0, 150)
savedCoordsTitle.BackgroundTransparency = 1
savedCoordsTitle.Text = "Saved Positions:"
savedCoordsTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
savedCoordsTitle.TextSize = 14
savedCoordsTitle.Font = Enum.Font.GothamSemibold
savedCoordsTitle.TextXAlignment = Enum.TextXAlignment.Left
savedCoordsTitle.Parent = mainFrame
table.insert(contentFrames, savedCoordsTitle)

-- Create saved coordinates list frame
local savedCoordsFrame = Instance.new("Frame")
savedCoordsFrame.Name = "SavedCoordsFrame"
savedCoordsFrame.Size = UDim2.new(1, -20, 0, 115)
savedCoordsFrame.Position = UDim2.new(0, 10, 0, 175)
savedCoordsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
savedCoordsFrame.BackgroundTransparency = 0.5
savedCoordsFrame.BorderSizePixel = 0
savedCoordsFrame.Parent = mainFrame
table.insert(contentFrames, savedCoordsFrame)

-- Add corner radius
local savedCoordsCorner = Instance.new("UICorner")
savedCoordsCorner.CornerRadius = UDim.new(0, 6)
savedCoordsCorner.Parent = savedCoordsFrame

-- Function to update current coordinates display
local function updateCoordinates()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        currentPosition = character.HumanoidRootPart.Position
        coordsText.Text = string.format(
            "X: %.1f, Y: %.1f, Z: %.1f", 
            currentPosition.X, currentPosition.Y, currentPosition.Z
        )
    end
end

-- Function to create a saved coordinate button
local function createCoordButton(index, pos)
    local button = Instance.new("TextButton")
    button.Name = "Coord" .. index
    button.Size = UDim2.new(1, -10, 0, 20)
    button.Position = UDim2.new(0, 5, 0, (index - 1) * 23 + 5)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.BackgroundTransparency = 0.5
    button.BorderSizePixel = 0
    button.Text = string.format(
        "%d. %s", 
        index, 
        string.format(COORDS_FORMAT, pos.X, pos.Y, pos.Z)
    )
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = savedCoordsFrame
    
    -- Add corner radius
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    -- Add teleport icon
    local teleportIcon = Instance.new("ImageLabel")
    teleportIcon.Name = "TeleportIcon"
    teleportIcon.Size = UDim2.new(0, 16, 0, 16)
    teleportIcon.Position = UDim2.new(1, -20, 0, 2)
    teleportIcon.BackgroundTransparency = 1
    teleportIcon.Image = "rbxassetid://6031233233" -- Teleport icon
    teleportIcon.Parent = button
    
    -- Add hover effect
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)
    
    -- Add click functionality with teleport/copy choice
    button.MouseButton1Click:Connect(function()
        -- Store reference to the coordinate button for feedback
        local coordButton = button
        
        -- Create popup GUI
        local popupGui = Instance.new("ScreenGui")
        popupGui.Name = "CoordinateActionPopup"
        popupGui.ResetOnSpawn = false
        popupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        popupGui.Parent = playerGui
        
        -- Create background frame
        local popupFrame = Instance.new("Frame")
        popupFrame.Name = "PopupFrame"
        popupFrame.Size = UDim2.new(0, 300, 0, 150)
        popupFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
        popupFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        popupFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        popupFrame.BackgroundTransparency = 0.1
        popupFrame.BorderSizePixel = 0
        popupFrame.Parent = popupGui
        
        -- Add corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = popupFrame
        
        -- Add title
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 30)
        title.Position = UDim2.new(0, 0, 0, 10)
        title.BackgroundTransparency = 1
        title.Text = "Coordinate Action"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.Parent = popupFrame
        
        -- Add message
        local message = Instance.new("TextLabel")
        message.Name = "Message"
        message.Size = UDim2.new(1, -20, 0, 40)
        message.Position = UDim2.new(0, 10, 0, 40)
        message.BackgroundTransparency = 1
        message.Text = "Choose an action for these coordinates:"
        message.TextColor3 = Color3.fromRGB(200, 200, 200)
        message.TextSize = 14
        message.Font = Enum.Font.Gotham
        message.TextWrapped = true
        message.Parent = popupFrame
        
        -- Create teleport button
        local teleportBtn = Instance.new("TextButton")
        teleportBtn.Name = "TeleportBtn"
        teleportBtn.Size = UDim2.new(0.4, 0, 0, 30)
        teleportBtn.Position = UDim2.new(0.1, 0, 0, 90)
        teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        teleportBtn.Text = "Teleport"
        teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        teleportBtn.TextSize = 14
        teleportBtn.Font = Enum.Font.GothamSemibold
        teleportBtn.Parent = popupFrame
        
        -- Add corner to button
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = teleportBtn
        
        -- Create copy button
        local copyBtn = Instance.new("TextButton")
        copyBtn.Name = "CopyBtn"
        copyBtn.Size = UDim2.new(0.4, 0, 0, 30)
        copyBtn.Position = UDim2.new(0.5, 0, 0, 90)
        copyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        copyBtn.Text = "Copy"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.TextSize = 14
        copyBtn.Font = Enum.Font.GothamSemibold
        copyBtn.Parent = popupFrame
        
        -- Add corner to button
        btnCorner:Clone().Parent = copyBtn
        
        -- Teleport button click handler
        teleportBtn.MouseButton1Click:Connect(function()
            popupGui:Destroy()
            
            -- Visual feedback
            local originalText = coordButton.Text
            coordButton.Text = "Teleporting..."
            
            -- Teleport to saved position
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character:SetPrimaryPartCFrame(CFrame.new(pos))
            end
            
            -- Reset text after delay
            task.delay(1, function()
                coordButton.Text = originalText
            end)
        end)
        
        -- Copy button click handler
        copyBtn.MouseButton1Click:Connect(function()
            popupGui:Destroy()
            
            -- Copy coordinates to clipboard
            local coordsText = string.format("x=%.1f, y=%.1f, z=%.1f", pos.X, pos.Y, pos.Z)
            game:GetService("GuiService"):SetClipboard(coordsText)
            
            -- Visual feedback
            local originalText = coordButton.Text
            coordButton.Text = "Copied!"
            task.delay(1, function()
                coordButton.Text = originalText
            end)
        end)
    end)
    
    return button
end

-- Function to update saved coordinates display
local function updateSavedCoordinates()
    -- Clear existing buttons
    for _, child in pairs(savedCoordsFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Create new buttons for each saved coordinate
    for i, pos in ipairs(savedCoordinates) do
        createCoordButton(i, pos)
    end
end

-- Handle save button click
saveButton.MouseButton1Click:Connect(function()
    -- Visual feedback
    local originalColor = saveButton.BackgroundColor3
    saveButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    saveButton.Text = "Saving..."
    
    -- Save current position
    table.insert(savedCoordinates, 1, currentPosition)
    
    -- Keep only the most recent MAX_SAVED_COORDS
    while #savedCoordinates > MAX_SAVED_COORDS do
        table.remove(savedCoordinates)
    end
    
    -- Update display
    updateSavedCoordinates()
    
    -- Save to player attributes
    saveCoordinatesToAttributes()
    
    -- Reset button after delay
    task.delay(0.5, function()
        saveButton.Text = "Position Saved!"
        task.delay(1, function()
            saveButton.Text = "Save Current Position"
            saveButton.BackgroundColor3 = originalColor
        end)
    end)
end)

-- Create a folder to persist during the session
local function createSessionStorage()
    -- Check if session storage already exists in ReplicatedStorage
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local sessionStorage = replicatedStorage:FindFirstChild("CoordinatesSessionStorage")
    
    if not sessionStorage then
        sessionStorage = Instance.new("Folder")
        sessionStorage.Name = "CoordinatesSessionStorage"
        sessionStorage.Parent = replicatedStorage
    end
    
    -- Create player's personal storage if it doesn't exist
    local playerStorage = sessionStorage:FindFirstChild("Player_" .. player.UserId)
    if not playerStorage then
        playerStorage = Instance.new("Folder")
        playerStorage.Name = "Player_" .. player.UserId
        playerStorage.Parent = sessionStorage
    end
    
    return playerStorage
end

-- Load saved coordinates from session storage
local function loadFromSessionStorage()
    local playerStorage = createSessionStorage()
    savedCoordinates = {}
    
    -- Load each coordinate
    for i = 1, MAX_SAVED_COORDS do
        local valueObj = playerStorage:FindFirstChild("Coord_" .. i)
        if valueObj and valueObj:IsA("Vector3Value") then
            table.insert(savedCoordinates, valueObj.Value)
        end
    end
    
    updateSavedCoordinates()
end

-- Save coordinates to session storage
local function saveToSessionStorage()
    local playerStorage = createSessionStorage()
    
    -- Clear old values
    for _, child in pairs(playerStorage:GetChildren()) do
        child:Destroy()
    end
    
    -- Save new values
    for i, coord in ipairs(savedCoordinates) do
        local valueObj = Instance.new("Vector3Value")
        valueObj.Name = "Coord_" .. i
        valueObj.Value = coord
        valueObj.Parent = playerStorage
    end
end

-- Toggle GUI visibility
local function toggleGUI(isCollapsed)
    if isCollapsed == nil then
        isCollapsed = not player:GetAttribute("CoordinatesGUICollapsed")
    end
    
    player:SetAttribute("CoordinatesGUICollapsed", isCollapsed)
    
    if isCollapsed then
        -- Collapse the GUI
        mainFrame.Size = UDim2.new(0, 250, 0, 30)
        toggleButton.Image = "rbxassetid://6031094677" -- Right arrow icon
        
        -- Hide all content frames
        for _, frame in pairs(contentFrames) do
            frame.Visible = false
        end
    else
        -- Expand the GUI
        mainFrame.Size = UDim2.new(0, 250, 0, 300)
        toggleButton.Image = "rbxassetid://6031094664" -- Down arrow icon
        
        -- Show all content frames
        for _, frame in pairs(contentFrames) do
            frame.Visible = true
        end
    end
end

-- Connect toggle button
toggleButton.MouseButton1Click:Connect(function()
    toggleGUI()
end)

-- Try to load saved coordinates when the script starts
loadFromSessionStorage()

-- Load collapsed state
local isCollapsed = player:GetAttribute("CoordinatesGUICollapsed")
if isCollapsed then
    toggleGUI(true)
end

-- Update coordinates periodically
while true do
    updateCoordinates()
    wait(UPDATE_INTERVAL)
end
