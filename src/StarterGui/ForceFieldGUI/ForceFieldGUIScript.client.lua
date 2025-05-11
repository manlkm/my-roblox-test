-- File: StarterGui/ForceFieldGUI/ForceFieldGUIScript.client.lua
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local forceFieldActive = false
local currentForceField = nil

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ForceFieldGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Create toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 150, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0.5, -25) -- Left side, middle
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.BackgroundTransparency = 0.2
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Force Field: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.GothamBold
toggleButton.AutoButtonColor = false
toggleButton.Parent = screenGui

-- Add corner radius to button
local cornerRadius = Instance.new("UICorner")
cornerRadius.CornerRadius = UDim.new(0, 10)
cornerRadius.Parent = toggleButton

-- Add indicator light
local indicatorLight = Instance.new("Frame")
indicatorLight.Name = "IndicatorLight"
indicatorLight.Size = UDim2.new(0, 16, 0, 16)
indicatorLight.Position = UDim2.new(0, 10, 0.5, -8)
indicatorLight.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red = OFF
indicatorLight.BorderSizePixel = 0
indicatorLight.Parent = toggleButton

-- Add corner radius to indicator
local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(1, 0) -- Make it circular
indicatorCorner.Parent = indicatorLight

-- Update text to be right of indicator
toggleButton.TextXAlignment = Enum.TextXAlignment.Center

-- Function to create force field
local function createForceField()
    if not player.Character then
        print("Character not found - Can't create force field")
        return nil
    end
    
    local forceField = Instance.new("ForceField")
    forceField.Name = "PlayerForceField"
    forceField.Visible = true
    forceField.Parent = player.Character
    
    print("Force field created")
    return forceField
end

-- Function to remove force field
local function removeForceField()
    if not player.Character then return end
    
    -- Remove any existing force fields
    for _, child in pairs(player.Character:GetChildren()) do
        if child:IsA("ForceField") then
            child:Destroy()
            print("Force field removed")
        end
    end
end

-- Function to toggle force field
local function toggleForceField()
    forceFieldActive = not forceFieldActive
    
    -- Update UI
    if forceFieldActive then
        -- Visual tweening for turning ON
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- Change colors to green
        local buttonColorTween = TweenService:Create(
            toggleButton, 
            tweenInfo, 
            {BackgroundColor3 = Color3.fromRGB(40, 100, 40)}
        )
        
        local indicatorColorTween = TweenService:Create(
            indicatorLight, 
            tweenInfo, 
            {BackgroundColor3 = Color3.fromRGB(0, 255, 0)} -- Green = ON
        )
        
        buttonColorTween:Play()
        indicatorColorTween:Play()
        
        toggleButton.Text = "Force Field: ON"
        
        -- Create force field
        currentForceField = createForceField()
    else
        -- Visual tweening for turning OFF
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- Change colors back to default/red
        local buttonColorTween = TweenService:Create(
            toggleButton, 
            tweenInfo, 
            {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}
        )
        
        local indicatorColorTween = TweenService:Create(
            indicatorLight, 
            tweenInfo, 
            {BackgroundColor3 = Color3.fromRGB(255, 0, 0)} -- Red = OFF
        )
        
        buttonColorTween:Play()
        indicatorColorTween:Play()
        
        toggleButton.Text = "Force Field: OFF"
        
        -- Remove force field
        removeForceField()
        currentForceField = nil
    end
end

-- Add hover effect
toggleButton.MouseEnter:Connect(function()
    local baseColor = forceFieldActive 
        and Color3.fromRGB(40, 100, 40) 
        or Color3.fromRGB(40, 40, 40)
    
    -- Lighten the base color slightly
    local hoverColor = Color3.new(
        math.min(baseColor.R + 0.1, 1),
        math.min(baseColor.G + 0.1, 1),
        math.min(baseColor.B + 0.1, 1)
    )
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local colorTween = TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = hoverColor})
    colorTween:Play()
end)

toggleButton.MouseLeave:Connect(function()
    local baseColor = forceFieldActive 
        and Color3.fromRGB(40, 100, 40) 
        or Color3.fromRGB(40, 40, 40)
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local colorTween = TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = baseColor})
    colorTween:Play()
end)

-- Set up button click
toggleButton.MouseButton1Click:Connect(function()
    -- Play click animation
    local originalSize = toggleButton.Size
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- Shrink slightly
    local shrinkTween = TweenService:Create(
        toggleButton, 
        tweenInfo, 
        {Size = UDim2.new(0, originalSize.X.Offset * 0.95, 0, originalSize.Y.Offset * 0.95)}
    )
    
    -- Return to original size
    local expandTween = TweenService:Create(
        toggleButton, 
        tweenInfo, 
        {Size = originalSize}
    )
    
    shrinkTween:Play()
    shrinkTween.Completed:Connect(function()
        expandTween:Play()
        toggleForceField()
    end)
end)

-- Handle character respawning
player.CharacterAdded:Connect(function(newCharacter)
    -- If force field was active before respawn, reapply it
    if forceFieldActive then
        -- Wait a moment for character to fully load
        wait(0.5)
        currentForceField = createForceField()
    end
end)

-- Make button draggable
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

-- Helper functions for drag behavior
local function updateDrag(input)
    local delta = input.Position - dragStart
    toggleButton.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

print("Force Field GUI initialized")
