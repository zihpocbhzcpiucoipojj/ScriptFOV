--[[ 
  GUI FOV client-side vertical stable (droite de l'écran)
--]]

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local defaultFOV = camera.FieldOfView
local currentFOV = defaultFOV

-- Création ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame parent pour tout (UI + bouton X)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 150, 0, 220)
mainFrame.Position = UDim2.new(1, -160, 0.3, 0) -- droite
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

-- Frame principale (panel)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 120, 0, 200)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = mainFrame

-- Bouton X (toujours visible)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Text = "X"
closeButton.Parent = mainFrame

local guiVisible = true
closeButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    frame.Visible = guiVisible -- seulement le panel
end)

-- Label FOV
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0, 20)
label.Position = UDim2.new(0, 0, 0, 10)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255,255,255)
label.Text = "FOV"
label.Parent = frame

-- Slider vertical
local sliderBack = Instance.new("Frame")
sliderBack.Size = UDim2.new(0, 20, 0.7, 0)
sliderBack.Position = UDim2.new(0.5, -10, 0, 40)
sliderBack.BackgroundColor3 = Color3.fromRGB(80,80,80)
sliderBack.Parent = frame

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(1, 0, 0, 20)
sliderButton.Position = UDim2.new(0, 0, 0.5, -10)
sliderButton.BackgroundColor3 = Color3.fromRGB(200,200,200)
sliderButton.Text = ""
sliderButton.Parent = sliderBack

local draggingSlider = false
sliderButton.MouseButton1Down:Connect(function() draggingSlider = true end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

local function updateFOV()
    local relativePos = (sliderButton.Position.Y.Offset + sliderButton.Size.Y.Offset/2) / sliderBack.AbsoluteSize.Y
    currentFOV = 70 + (1 - relativePos) * (150-70) -- inversé : haut = rapproché, bas = élargi
    camera.FieldOfView = currentFOV
end

RunService.RenderStepped:Connect(function()
    if draggingSlider then
        local mouseY = UserInputService:GetMouseLocation().Y
        local sliderY = math.clamp(mouseY - sliderBack.AbsolutePosition.Y - sliderButton.Size.Y.Offset/2, 0, sliderBack.AbsoluteSize.Y - sliderButton.Size.Y.Offset)
        sliderButton.Position = UDim2.new(0, 0, 0, sliderY)
        updateFOV()
    end
end)

-- Reset FOV
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0.8, 0, 0, 25)
resetButton.Position = UDim2.new(0.1, 0, 1, -35)
resetButton.BackgroundColor3 = Color3.fromRGB(100,100,100)
resetButton.TextColor3 = Color3.fromRGB(255,255,255)
resetButton.Text = "Reset FOV"
resetButton.Parent = frame

resetButton.MouseButton1Click:Connect(function()
    camera.FieldOfView = defaultFOV
    currentFOV = defaultFOV
    sliderButton.Position = UDim2.new(0, 0, 0.5, -10)
end)

-- Déplacement du frame principal
local draggingFrame = false
local dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not draggingSlider then
        draggingFrame = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingFrame = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and draggingFrame then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Déplacement du bouton X
local draggingClose = false
local closeStart, closePos
closeButton.MouseButton1Down:Connect(function()
    draggingClose = true
    closeStart = UserInputService:GetMouseLocation()
    closePos = closeButton.Position
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and draggingClose then
        local delta = input.Position - closeStart
        closeButton.Position = UDim2.new(closePos.X.Scale, closePos.X.Offset + delta.X, closePos.Y.Scale, closePos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingClose = false
    end
end)
