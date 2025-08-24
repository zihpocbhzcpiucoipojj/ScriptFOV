--[[ 
  GUI FOV client-side avec bouton "X" pour fermer/ouvrir
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

-- Frame principale
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 60)
frame.Position = UDim2.new(0.5, -150, 0, 50) -- en haut
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Bouton "X" pour fermer/ouvrir
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(0.5, -150, 0, 50)
closeButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Text = "X"
closeButton.Parent = screenGui -- bouton indépendant pour rester visible

local guiVisible = true
closeButton.MouseButton1Click:Connect(function()
	guiVisible = not guiVisible
	frame.Visible = guiVisible
end)

-- Slider
local sliderBack = Instance.new("Frame")
sliderBack.Size = UDim2.new(1, -20, 0, 20)
sliderBack.Position = UDim2.new(0, 10, 0, 10)
sliderBack.BackgroundColor3 = Color3.fromRGB(80,80,80)
sliderBack.Parent = frame

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 20, 1, 0)
sliderButton.Position = UDim2.new(0.5, -10, 0, 0)
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
	local relativePos = (sliderButton.Position.X.Offset + sliderButton.Size.X.Offset/2) / sliderBack.AbsoluteSize.X
	currentFOV = 70 + relativePos * (150-70)
	camera.FieldOfView = currentFOV
end

RunService.RenderStepped:Connect(function()
	if draggingSlider then
		local mouseX = UserInputService:GetMouseLocation().X
		local sliderX = math.clamp(mouseX - sliderBack.AbsolutePosition.X - sliderButton.Size.X.Offset/2, 0, sliderBack.AbsoluteSize.X - sliderButton.Size.X.Offset)
		sliderButton.Position = UDim2.new(0, sliderX, 0, 0)
		updateFOV()
	end
end)

-- Reset FOV
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0, 80, 0, 20)
resetButton.Position = UDim2.new(0.5, -40, 1, -25)
resetButton.BackgroundColor3 = Color3.fromRGB(100,100,100)
resetButton.TextColor3 = Color3.fromRGB(255,255,255)
resetButton.Text = "Reset FOV"
resetButton.Parent = frame

resetButton.MouseButton1Click:Connect(function()
	camera.FieldOfView = defaultFOV
	currentFOV = defaultFOV
	sliderButton.Position = UDim2.new(0.5, -10, 0, 0)
end)

-- Déplacement du GUI principal
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
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if draggingFrame then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
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
