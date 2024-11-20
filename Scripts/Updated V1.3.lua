local teleportService = game:GetService("TeleportService")
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")

-- Variables
local isChecked = false
local lockedPlayer = nil
local currentKey = Enum.KeyCode.Q
local settingKey = false
local isESPEnabled = false
local espLoop
local isMinimized = false
local minimizeKey = Enum.KeyCode.Z
local settingMinimizeKey = false
local shadowsEnabled = true
local antiAFKEnabled = false
local fovValue = 70
local antiAFKConnection
local wallCheckEnabled = false

local function toggleAntiAFK(state)
    if state then
        antiAFKConnection = player.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    elseif antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
end

-- Function to create ESP box
local function createESPBox(targetPlayer, highlightColor)
    if targetPlayer.Character and not targetPlayer.Character:FindFirstChild("ESPBox") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPBox"
        highlight.Parent = targetPlayer.Character
        highlight.FillColor = highlightColor or Color3.fromRGB(30, 144, 255)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.6
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HealthBar"
        billboard.Parent = targetPlayer.Character
        billboard.Adornee = targetPlayer.Character:FindFirstChild("UpperTorso")
        billboard.Size = UDim2.new(0.3, 0, 4, 0)
        billboard.StudsOffset = Vector3.new(-1.5, -0.5, 0)
        billboard.AlwaysOnTop = true

        local bar = Instance.new("Frame")
        bar.Name = "Bar"
        bar.Parent = billboard
        bar.AnchorPoint = Vector2.new(0.5, 1)
        bar.Position = UDim2.new(0.5, 0, 1, 0)
        bar.Size = UDim2.new(0.7, 0, 1, 0)
        bar.BackgroundColor3 = Color3.new(1, 0, 0)

        local healthBar = Instance.new("Frame")
        healthBar.Name = "Health"
        healthBar.Parent = bar
        healthBar.AnchorPoint = Vector2.new(0.5, 1)
        healthBar.Position = UDim2.new(0.5, 0, 1, 0)
        healthBar.Size = UDim2.new(0.7, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.new(0, 1, 0)
    end
end

local function removeESPBox(targetPlayer)
    if targetPlayer.Character then
        local highlight = targetPlayer.Character:FindFirstChild("ESPBox")
        if highlight then
            highlight:Destroy()
        end
    end
end

-- Function to refresh ESP
local function refreshESP()
    for _, targetPlayer in ipairs(game.Players:GetPlayers()) do
        if targetPlayer.Character then
            if targetPlayer == lockedPlayer then
                -- Highlight the locked player in red
                createESPBox(targetPlayer, Color3.new(1, 0, 0))
            elseif isESPEnabled then
                -- Highlight other players in blue if ESP is enabled
                createESPBox(targetPlayer, Color3.fromRGB(30, 144, 255))
            else
                -- Remove ESP for other players if ESP is off
                removeESPBox(targetPlayer)
            end
        end
    end
end



-- Function to update health bars
local function updateHealthBars()
    for _, targetPlayer in ipairs(game.Players:GetPlayers()) do
        if targetPlayer.Character then
            local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            local healthBar = targetPlayer.Character:FindFirstChild("HealthBar") and targetPlayer.Character.HealthBar.Bar.Health
            if humanoid and healthBar then
                healthBar.Size = UDim2.new(0.7, 0, humanoid.Health / humanoid.MaxHealth, 0)
            end
        end
    end
end

-- Toggle ESP
local function toggleESP(state)
    if state then
        espLoop = runService.Heartbeat:Connect(function()
            refreshESP()
            updateHealthBars()
        end)
    elseif espLoop then
        espLoop:Disconnect()
        espLoop = nil
        for _, targetPlayer in ipairs(game.Players:GetPlayers()) do
            if targetPlayer.Character then
                local highlight = targetPlayer.Character:FindFirstChild("ESPBox")
                local healthBar = targetPlayer.Character:FindFirstChild("HealthBar")
                if highlight then highlight:Destroy() end
                if healthBar then healthBar:Destroy() end
            end
        end
    end
end

-- Remove shadows
local function toggleShadows(state)
    lighting.GlobalShadows = state
    lighting.EnvironmentDiffuseScale = state and 1 or 0
    lighting.EnvironmentSpecularScale = state and 1 or 0
end

-- Creating a ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CamlockESPGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame for the UI
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 340)
frame.Position = UDim2.new(0.5, -125, 0.5, -200)
frame.BackgroundColor3 = Color3.new(0, 0, 0) -- Set background to black
frame.Active = true
frame.Draggable = true
frame.Visible = false
frame.Parent = screenGui
screenGui.ResetOnSpawn = false

-- Add Border Using UIStroke
local border = Instance.new("UIStroke")
border.Thickness = 5 -- Thickness of the border
border.Color = Color3.fromRGB(91, 0, 255) -- Amethyst purple color
border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
border.Parent = frame

-- Make the UI rounded
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 12) -- Slightly larger radius for the border
borderCorner.Parent = border

-- Checkbox for Shadows
local shadowsCheckbox = Instance.new("TextButton")
shadowsCheckbox.Size = UDim2.new(0, 20, 0, 20)
shadowsCheckbox.Position = UDim2.new(0, 10, 0, 10)
shadowsCheckbox.BackgroundColor3 = Color3.new(0.4, 0.1, 1)
shadowsCheckbox.Text = ""
shadowsCheckbox.Parent = frame

local shadowsLabel = Instance.new("TextLabel")
shadowsLabel.Size = UDim2.new(0, 160, 0, 20)
shadowsLabel.Position = UDim2.new(0, 20, 0, 10)
shadowsLabel.BackgroundTransparency = 1
shadowsLabel.Text = "Shadows"
shadowsLabel.TextColor3 = Color3.new(1, 1, 1)
shadowsLabel.Font = Enum.Font.SourceSans
shadowsLabel.TextSize = 16
shadowsLabel.Parent = frame

local wallCheckCheckbox = Instance.new("TextButton")
wallCheckCheckbox.Size = UDim2.new(0, 20, 0, 20)
wallCheckCheckbox.Position = UDim2.new(0, 10, 0, 250)
wallCheckCheckbox.BackgroundColor3 = Color3.new(1, 1, 1)
wallCheckCheckbox.Text = ""
wallCheckCheckbox.Parent = frame

local wallCheckLabel = Instance.new("TextLabel")
wallCheckLabel.Size = UDim2.new(0, 160, 0, 20)
wallCheckLabel.Position = UDim2.new(0, 20, 0, 250)
wallCheckLabel.BackgroundTransparency = 1
wallCheckLabel.Text = "Wall Check"
wallCheckLabel.TextColor3 = Color3.new(1, 1, 1)
wallCheckLabel.Font = Enum.Font.SourceSans
wallCheckLabel.TextSize = 16
wallCheckLabel.Parent = frame

wallCheckCheckbox.MouseButton1Click:Connect(function()
    wallCheckEnabled = not wallCheckEnabled
    wallCheckCheckbox.BackgroundColor3 = wallCheckEnabled and Color3.fromRGB(91, 0, 255) or Color3.new(1, 1, 1)
end)

-- Anti-AFK Checkbox
local antiAFKCheckbox = Instance.new("TextButton")
antiAFKCheckbox.Size = UDim2.new(0, 20, 0, 20)
antiAFKCheckbox.Position = UDim2.new(0, 10, 0, 100)
antiAFKCheckbox.BackgroundColor3 = Color3.new(1, 1, 1)
antiAFKCheckbox.Text = ""
antiAFKCheckbox.Parent = frame

local antiAFKLabel = Instance.new("TextLabel")
antiAFKLabel.Size = UDim2.new(0, 160, 0, 20)
antiAFKLabel.Position = UDim2.new(0, 20, 0, 100)
antiAFKLabel.BackgroundTransparency = 1
antiAFKLabel.Text = "Anti-AFK"
antiAFKLabel.TextColor3 = Color3.new(1, 1, 1)
antiAFKLabel.Font = Enum.Font.SourceSans
antiAFKLabel.TextSize = 16
antiAFKLabel.Parent = frame

-- Checkbox for Camlock
local camlockCheckbox = Instance.new("TextButton")
camlockCheckbox.Size = UDim2.new(0, 20, 0, 20)
camlockCheckbox.Position = UDim2.new(0, 10, 0, 40)
camlockCheckbox.BackgroundColor3 = Color3.new(1, 1, 1)
camlockCheckbox.Text = ""
camlockCheckbox.Parent = frame

local camlockLabel = Instance.new("TextLabel")
camlockLabel.Size = UDim2.new(0, 160, 0, 20)
camlockLabel.Position = UDim2.new(0, 20, 0, 40)
camlockLabel.BackgroundTransparency = 1
camlockLabel.Text = "Camlock"
camlockLabel.TextColor3 = Color3.new(1, 1, 1)
camlockLabel.Font = Enum.Font.SourceSans
camlockLabel.TextSize = 16
camlockLabel.Parent = frame

-- ESP Checkbox
local espCheckbox = Instance.new("TextButton")
espCheckbox.Size = UDim2.new(0, 20, 0, 20)
espCheckbox.Position = UDim2.new(0, 10, 0, 70)
espCheckbox.BackgroundColor3 = Color3.new(1, 1, 1)
espCheckbox.Text = ""
espCheckbox.Parent = frame

local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(0, 160, 0, 20)
espLabel.Position = UDim2.new(0, 20, 0, 70)
espLabel.BackgroundTransparency = 1
espLabel.Text = "ESP"
espLabel.TextColor3 = Color3.new(1, 1, 1)
espLabel.Font = Enum.Font.SourceSans
espLabel.TextSize = 16
espLabel.Parent = frame

-- Rejoin Button
local rejoinButton = Instance.new("TextButton")
rejoinButton.Size = UDim2.new(0, 180, 0, 30)
rejoinButton.Position = UDim2.new(0, 10, 0, 130)
rejoinButton.BackgroundColor3 = Color3.new(0, 0, 0)
rejoinButton.Text = "Rejoin Game"
rejoinButton.TextColor3 = Color3.new(1, 1, 1)
rejoinButton.Font = Enum.Font.SourceSans
rejoinButton.TextSize = 18
rejoinButton.Parent = frame
rejoinButton.MouseButton1Click:Connect(function()
    teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)

-- Set Camlock Key Button
local setKeyButton = Instance.new("TextButton")
setKeyButton.Size = UDim2.new(0, 180, 0, 30)
setKeyButton.Position = UDim2.new(0, 10, 0, 170)
setKeyButton.BackgroundColor3 = Color3.new(0, 0, 0)
setKeyButton.Text = "Set Camlock Key (Current: Q)"
setKeyButton.TextColor3 = Color3.new(1, 1, 1)
setKeyButton.Font = Enum.Font.SourceSans
setKeyButton.TextSize = 18
setKeyButton.Parent = frame
setKeyButton.MouseButton1Click:Connect(function()
    settingKey = true
    setKeyButton.Text = "Press a Key to Set"
end)

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if settingKey then
        currentKey = input.KeyCode
        setKeyButton.Text = "Set Camlock Key (Current: " .. tostring(currentKey.Name) .. ")"
        settingKey = false
    end
end)

-- Set Minimize Key Button
local setMinimizeKeyButton = Instance.new("TextButton")
setMinimizeKeyButton.Size = UDim2.new(0, 180, 0, 30)
setMinimizeKeyButton.Position = UDim2.new(0, 10, 0, 210)
setMinimizeKeyButton.BackgroundColor3 = Color3.new(0, 0, 0)
setMinimizeKeyButton.Text = "Set Minimize Key (Current: Z)"
setMinimizeKeyButton.TextColor3 = Color3.new(1, 1, 1)
setMinimizeKeyButton.Font = Enum.Font.SourceSans
setMinimizeKeyButton.TextSize = 18
setMinimizeKeyButton.Parent = frame
setMinimizeKeyButton.MouseButton1Click:Connect(function()
    settingMinimizeKey = true
    setMinimizeKeyButton.Text = "Press a Key to Set"
end)

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if settingMinimizeKey then
        minimizeKey = input.KeyCode
        setMinimizeKeyButton.Text = "Set Minimize Key (Current: " .. tostring(minimizeKey.Name) .. ")"
        settingMinimizeKey = false
    end
end)

-- Minimize Functionality
local function toggleMinimize()
    isMinimized = not isMinimized
    frame.Visible = not isMinimized
end

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == minimizeKey then
        toggleMinimize()
    end
end)

-- FOV Slider
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0, 100, 0, 20)
fovLabel.Position = UDim2.new(0, 50, 0, 276)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: " .. tostring(fovValue)
fovLabel.TextColor3 = Color3.new(1, 1, 1)
fovLabel.Font = Enum.Font.SourceSans
fovLabel.TextSize = 16
fovLabel.Parent = frame

local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0, 150, 0, 20)
sliderFrame.Position = UDim2.new(0, 25, 0, 296)
sliderFrame.BackgroundColor3 = Color3.new(0, 0, 0)
sliderFrame.Parent = frame

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 10, 0, 20)
sliderButton.Position = UDim2.new((fovValue - 70) / 50, 0, 0, 0)
sliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
sliderButton.Text = ""
sliderButton.Parent = sliderFrame

sliderButton.MouseButton1Down:Connect(function()
    local inputChanged
    inputChanged = userInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local sliderPosition = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            fovValue = math.floor(70 + sliderPosition * 50)
            sliderButton.Position = UDim2.new(sliderPosition, 0, 0, 0)
            fovLabel.Text = "FOV: " .. tostring(fovValue)
            workspace.CurrentCamera.FieldOfView = fovValue
        end
    end)
    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            inputChanged:Disconnect()
        end
    end)
end)

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -30, 0, 8)
closeButton.BackgroundColor3 = Color3.new(0, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSans
closeButton.TextSize = 16
closeButton.Parent = frame

-- Cleanup on close
local function cleanup()
    toggleESP(false)
    toggleShadows(false)
    toggleAntiAFK(false)
    runService:UnbindFromRenderStep("Camlock")
    screenGui:Destroy()
end

closeButton.MouseButton1Click:Connect(cleanup)

-- Checkbox Functionality
camlockCheckbox.MouseButton1Click:Connect(function()
    isChecked = not isChecked
camlockCheckbox.BackgroundColor3 = isChecked and Color3.fromRGB(91, 0, 255) or Color3.new(1, 1, 1)
    if not isChecked then
        runService:UnbindFromRenderStep("Camlock")
        lockedPlayer = nil
    end
end)

espCheckbox.MouseButton1Click:Connect(function()
    isESPEnabled = not isESPEnabled
espCheckbox.BackgroundColor3 = isESPEnabled and Color3.fromRGB(91, 0, 255) or Color3.new(1, 1, 1)
    toggleESP(isESPEnabled)
end)

shadowsCheckbox.MouseButton1Click:Connect(function()
    shadowsEnabled = not shadowsEnabled
    shadowsCheckbox.BackgroundColor3 = shadowsEnabled and Color3.fromRGB(91, 0, 255) or Color3.new(1, 1, 1)
    toggleShadows(shadowsEnabled)
end)

antiAFKCheckbox.MouseButton1Click:Connect(function()
    antiAFKEnabled = not antiAFKEnabled
    antiAFKCheckbox.BackgroundColor3 = antiAFKEnabled and Color3.fromRGB(91, 0, 255) or Color3.new(1, 1, 1)
    toggleAntiAFK(antiAFKEnabled)
end)

-- Locked Player Highlight Persistence
local function ensureLockedPlayerESP()
    if lockedPlayer and lockedPlayer.Character then
        createESPBox(lockedPlayer, Color3.new(1, 0, 0))
    end
end

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == currentKey and isChecked then
        if lockedPlayer then
            -- Unlock the currently locked player
            if isESPEnabled then
                -- Change the locked player's highlight back to blue
                createESPBox(lockedPlayer, Color3.fromRGB(30, 144, 255))
            else
                -- Remove the highlight if ESP is disabled
                removeESPBox(lockedPlayer)
            end

            -- Remove the health bar
            local healthBar = lockedPlayer.Character:FindFirstChild("HealthBar")
            if healthBar then
                healthBar:Destroy()
            end

            -- Stop Camlock updates
            runService:UnbindFromRenderStep("Camlock")
            lockedPlayer = nil
            refreshESP() -- Update all highlights
        else
            -- Find the closest player to lock onto
            local camera = workspace.CurrentCamera
            local closestPlayer
            local closestDistance = math.huge

            for _, targetPlayer in ipairs(game.Players:GetPlayers()) do
                if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("UpperTorso") then
                    local targetPosition = targetPlayer.Character.UpperTorso.Position
                    local screenPoint, onScreen = camera:WorldToViewportPoint(targetPosition)
                    if onScreen then
                        if wallCheckEnabled then
                            -- Perform a raycast to check if the player is visible
                            local origin = camera.CFrame.Position
                            local direction = (targetPosition - origin).Unit * 500
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterDescendantsInstances = {player.Character, camera}
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

                            local raycastResult = workspace:Raycast(origin, direction, raycastParams)
                            if raycastResult and raycastResult.Instance:IsDescendantOf(targetPlayer.Character) then
                                local mouse = player:GetMouse()
                                local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestPlayer = targetPlayer
                                end
                            end
                        else
                            -- Skip the wall check
                            local mouse = player:GetMouse()
                            local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = targetPlayer
                            end
                        end
                    end
                end
            end

            if closestPlayer then
                lockedPlayer = closestPlayer
                -- Highlight the locked player in red
                createESPBox(lockedPlayer, Color3.new(1, 0, 0))

                -- Start Camlock updates
                runService:BindToRenderStep("Camlock", Enum.RenderPriority.Camera.Value + 1, function()
                    if lockedPlayer and lockedPlayer.Character and lockedPlayer.Character:FindFirstChild("UpperTorso") then
                        workspace.CurrentCamera.CFrame = CFrame.new(
                            workspace.CurrentCamera.CFrame.Position, 
                            lockedPlayer.Character.UpperTorso.Position
                        )
                    else
                        -- Stop Camlock if the locked player is no longer valid
                        runService:UnbindFromRenderStep("Camlock")
                        lockedPlayer = nil
                        refreshESP()
                    end
                end)
                refreshESP() -- Update all players' highlights
            end
        end
    end
end)


-- Fade-in effect
local function fadeIn()
    screenGui.Enabled = true
    for i = 0, 1, 0.1 do
        frame.BackgroundTransparency = 1 - i
        wait(0.05)
    end
    frame.Visible = true
end

-- Initialize settings
fadeIn()
toggleShadows(true)