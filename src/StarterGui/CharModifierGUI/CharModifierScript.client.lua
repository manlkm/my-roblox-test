local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer

-- Create main GUI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModifierGUI"
screenGui.ResetOnSpawn = false
screenGui.Enabled = true

if game:GetService("RunService"):IsStudio() then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
else
    screenGui.Parent = game:GetService("CoreGui")
end

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 180)
mainFrame.Position = UDim2.new(0.8, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 1, 0)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 45, 0, 0)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Character Modifier"
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Expand Button
local expandButton = Instance.new("TextButton")
expandButton.Size = UDim2.new(0, 45, 1, 0)
expandButton.Position = UDim2.new(0, 0, 0, 0)
expandButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
expandButton.TextColor3 = Color3.fromRGB(255, 255, 255)
expandButton.Text = "-"
expandButton.TextSize = 20
expandButton.Font = Enum.Font.GothamBold
expandButton.BorderSizePixel = 0
expandButton.Parent = titleBar

-- Hitbox Button
local hitboxButton = Instance.new("TextButton")
hitboxButton.Size = UDim2.new(1, -20, 0, 35)
hitboxButton.Position = UDim2.new(0, 10, 0, 40)
hitboxButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
hitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hitboxButton.Text = "Tiny Hitbox: OFF"
hitboxButton.TextSize = 14
hitboxButton.Font = Enum.Font.GothamSemibold
hitboxButton.Parent = mainFrame

-- Invisible Button
local invisibleButton = Instance.new("TextButton")
invisibleButton.Size = UDim2.new(1, -20, 0, 35)
invisibleButton.Position = UDim2.new(0, 10, 0, 85)
invisibleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
invisibleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
invisibleButton.Text = "Invisible: OFF"
invisibleButton.TextSize = 14
invisibleButton.Font = Enum.Font.GothamSemibold
invisibleButton.Parent = mainFrame

-- Team Button
local teamButton = Instance.new("TextButton")
teamButton.Size = UDim2.new(1, -20, 0, 35)
teamButton.Position = UDim2.new(0, 10, 0, 130)
teamButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
teamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teamButton.Text = "Change Team"
teamButton.TextSize = 14
teamButton.Font = Enum.Font.GothamSemibold
teamButton.Parent = mainFrame

-- Team Popup Menu
local popupFrame = Instance.new("Frame")
popupFrame.Size = UDim2.new(0, 220, 0, 220)
popupFrame.Position = UDim2.new(0.5, -110, 0.5, -110)
popupFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
popupFrame.BorderSizePixel = 0
popupFrame.Visible = false
popupFrame.ZIndex = 20
popupFrame.Parent = screenGui

local popupTitle = Instance.new("TextLabel")
popupTitle.Size = UDim2.new(1, 0, 0, 36)
popupTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
popupTitle.Text = "Choose a Team"
popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popupTitle.Font = Enum.Font.GothamBold
popupTitle.TextSize = 18
popupTitle.ZIndex = 21
popupTitle.Parent = popupFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.ZIndex = 21
closeBtn.Parent = popupFrame

local teamListFrame = Instance.new("ScrollingFrame")
teamListFrame.Size = UDim2.new(1, -8, 1, -44)
teamListFrame.Position = UDim2.new(0, 4, 0, 40)
teamListFrame.BackgroundTransparency = 1
teamListFrame.BorderSizePixel = 0
teamListFrame.ScrollBarThickness = 6
teamListFrame.ZIndex = 20
teamListFrame.Parent = popupFrame

local teamListLayout = Instance.new("UIListLayout")
teamListLayout.Padding = UDim.new(0, 4)
teamListLayout.Parent = teamListFrame

-- Variables
local isExpanded = true
local hitboxEnabled = false
local invisibleEnabled = false
local originalSizes = {}
local connections = {}

-- Populate Team Popup
local function populateTeamPopup()
    for _, v in ipairs(teamListFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    
    for _, team in ipairs(Teams:GetTeams()) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = team.TeamColor.Color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 15
        btn.Text = team.Name
        btn.ZIndex = 21
        btn.Parent = teamListFrame
        
        btn.MouseButton1Click:Connect(function()
            LocalPlayer.Team = team
            popupFrame.Visible = false
        end)
    end
    
    teamListFrame.CanvasSize = UDim2.new(0, 0, 0, teamListLayout.AbsoluteContentSize.Y)
end

-- Toggle GUI
local function toggleGUI()
    isExpanded = not isExpanded
    local targetSize = isExpanded and UDim2.new(0, 200, 0, 180) or UDim2.new(0, 200, 0, 45)
    expandButton.Text = isExpanded and "-" or "+"
    
    local tween = TweenService:Create(mainFrame, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = targetSize}
    )
    tween:Play()
end

-- Toggle Tiny Hitbox
local function toggleTinyHitbox()
    hitboxEnabled = not hitboxEnabled
    
    if hitboxEnabled then
        hitboxButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        hitboxButton.Text = "Tiny Hitbox: ON"
        
        connections.hitbox = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "Right Leg" then
                        if not originalSizes[part] then
                            originalSizes[part] = part.Size
                        end
                        part.Size = Vector3.new(0.1, 0.1, 0.1)
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        hitboxButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        hitboxButton.Text = "Tiny Hitbox: OFF"
        
        if connections.hitbox then
            connections.hitbox:Disconnect()
        end
        
        for part, size in pairs(originalSizes) do
            if part and part.Parent then
                part.Size = size
                part.CanCollide = true
            end
        end
        originalSizes = {}
    end
end

-- Toggle Invisible
local function toggleInvisible()
    invisibleEnabled = not invisibleEnabled
    
    if invisibleEnabled then
        invisibleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        invisibleButton.Text = "Invisible: ON"
        
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("MeshPart") then
                    part.Transparency = 1
                end
                if part:IsA("Accessory") then
                    part.Handle.Transparency = 1
                end
            end
        end
        
        connections.invisible = LocalPlayer.CharacterAdded:Connect(function(char)
            wait(0.5)
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("MeshPart") then
                    part.Transparency = 1
                end
                if part:IsA("Accessory") then
                    part.Handle.Transparency = 1
                end
            end
        end)
    else
        invisibleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        invisibleButton.Text = "Invisible: OFF"
        
        if connections.invisible then
            connections.invisible:Disconnect()
        end
        
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("MeshPart") then
                    part.Transparency = 0
                end
                if part:IsA("Accessory") then
                    part.Handle.Transparency = 0
                end
            end
        end
    end
end

-- Connect Buttons
expandButton.MouseButton1Click:Connect(toggleGUI)
hitboxButton.MouseButton1Click:Connect(toggleTinyHitbox)
invisibleButton.MouseButton1Click:Connect(toggleInvisible)
teamButton.MouseButton1Click:Connect(function()
    populateTeamPopup()
    popupFrame.Visible = true
end)
closeBtn.MouseButton1Click:Connect(function()
    popupFrame.Visible = false
end)

-- Make GUI Draggable
local isDragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Handle character respawning
LocalPlayer.CharacterAdded:Connect(function()
    originalSizes = {}
    if hitboxEnabled then
        task.wait(0.1)
        toggleTinyHitbox()
    end
    if invisibleEnabled then
        task.wait(0.1)
        toggleInvisible()
    end
end)

-- Update team list when teams change
Teams.ChildAdded:Connect(populateTeamPopup)
Teams.ChildRemoved:Connect(populateTeamPopup)
