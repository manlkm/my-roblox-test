-- File: StarterGui/ForceFieldGUI/ImprovedForceFieldGUIScript.client.lua
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local forceFieldActive = false
local currentForceField = nil
local healthConnection = nil
local originalHealth = 100 -- Default value, will be updated when character spawns
local healthCheckInterval = 0.1 -- How often to check health

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

-- Status text (displays health protection status)
local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(0, 150, 0, 20)
statusText.Position = UDim2.new(0, toggleButton.Position.X.Offset, 0, toggleButton.Position.Y.Offset + 55)
statusText.BackgroundTransparency = 1
statusText.Text = ""
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.TextSize = 12
statusText.Font = Enum.Font.Gotham
statusText.Visible = false
statusText.Parent = screenGui

-- Update text to be right of indicator
toggleButton.TextXAlignment = Enum.TextXAlignment.Center

-- Function to get the player's humanoid
local function getHumanoid()
    if not player.Character then return nil end
    return player.Character:FindFirstChild("Humanoid")
end

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

-- Function to start health protection
local function startHealthProtection()
    local humanoid = getHumanoid()
    if not humanoid then
        print("Humanoid not found - Can't protect health")
        statusText.Text = "Error: Humanoid not found"
        statusText.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red error text
        statusText.Visible = true
        return
    end
    
    -- Store the original health value
    originalHealth = humanoid.Health
    print("Original health recorded: " .. originalHealth)
    
    -- Display the protection status
    statusText.Text = "Health Protected: " .. originalHealth
    statusText.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green status text
    statusText.Visible = true
    
    -- Create a regular check to reset health if it decreases
    if healthConnection then healthConnection:Disconnect() end
    
    healthConnection = RunService.Heartbeat:Connect(function()
        -- Only run checks every interval to reduce overhead
        if tick() % healthCheckInterval <= 0.01 then
            if not humanoid then
                healthConnection:Disconnect()
                healthConnection = nil
                return
            end
            
            -- If health decreased, restore it
            if humanoid.Health < originalHealth then
                print("Health decreased to " .. humanoid.Health .. ", restoring to " .. originalHealth)
                humanoid.Health = originalHealth
                
                -- Add visual feedback for health restore
                local flashEffect = Instance.new("Frame")
                flashEffect.Size = UDim2.new(1, 0, 1, 0)
                flashEffect.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                flashEffect.BackgroundTransparency = 0.7
                flashEffect.BorderSizePixel = 0
                flashEffect.Parent = screenGui
                
                -- Fade out the flash effect
                game:GetService("Debris"):AddItem(flashEffect, 0.3)
                TweenService:Create(
                    flashEffect,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 1}
                ):Play()
            end
            
            -- Update the status text with current health
            statusText.Text = "Health Protected: " .. humanoid.Health
        end
    end)
end

-- Function to stop health protection
local function stopHealthProtection()
    if healthConnection then
        healthConnection:Disconnect()
        healthConnection = nil
        print("Health protection stopped")
    end
    
    statusText.Visible = false
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
        
        -- Start health protection
        startHealthProtection()
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
        
        -- Stop health protection
        stopHealthProtection()
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
    print("Character added - setting up health protection systems")
    
    -- Wait for humanoid to be available
    local humanoid = newCharacter:WaitForChild("Humanoid")
    
    -- Update the original health value when character spawns
    originalHealth = humanoid.Health
    print("New character's original health: " .. originalHealth)
    
    -- If force field was active before respawn, reapply it
    if forceFieldActive then
        -- Wait a moment for character to fully load
        wait(0.5)
        currentForceField = createForceField()
        startHealthProtection()
    end
end)

-- Function to update status text position when toggle button moves
local function updateStatusTextPosition()
    statusText.Position = UDim2.new(
        0, 
        toggleButton.Position.X.Offset, 
        0, 
        toggleButton.Position.Y.Offset + 55
    )
end

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
    
    -- Update the status text position to follow the button
    updateStatusTextPosition()
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

-- Initialize with existing character if available
if player.Character and player.Character:FindFirstChild("Humanoid") then
    originalHealth = player.Character.Humanoid.Health
    print("Initial character's original health: " .. originalHealth)
end

print("Improved Force Field GUI initialized")
