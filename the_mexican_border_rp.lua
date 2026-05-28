local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local backpack = player:WaitForChild("Backpack")
local camera = workspace.CurrentCamera

local REGULAR_BUY = Vector3.new(-47, 14, -74)
local REGULAR_SELL = Vector3.new(-236, 14, 683)
local REGULAR_NAME = "Crate"

local ILLEGAL_BUY = Vector3.new(-98, -23, -160)
local ILLEGAL_SELL = Vector3.new(-19, 14, 621)
local ILLEGAL_NAME = "Illegal Crate"

local farmActive = false
local illegalActive = false
local noclip = false
local scriptRunning = true
local customWalkSpeed = 16
local customJumpPower = 50

local boxActive = false
local nameActive = false
local tracerActive = false
local skeletonActive = false
local crosshairActive = false
local maxZoomActive = false
local freecamActive = false

local freecamCFrame = CFrame.new()
local freecamSpeed = 1
local originalCameraType = camera.CameraType
local originalMouseBehavior = userInputService.MouseBehavior

local cameraX = 0
local cameraY = 0
local focusPart = nil 

local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "CrateMaster_V34_Fixed"
sg.ResetOnSpawn = false

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 200, 0, 255)
main.Position = UDim2.new(0, 10, 1, -265)
main.BackgroundColor3 = Color3.new(0, 0, 0)
main.BackgroundTransparency = 0.4
makeDraggable(main)
Instance.new("UICorner", main)

local moveMenu = Instance.new("Frame", sg)
moveMenu.Size = UDim2.new(0, 180, 0, 230)
moveMenu.Position = UDim2.new(0, 220, 1, -240)
moveMenu.BackgroundColor3 = Color3.new(0, 0, 0)
moveMenu.BackgroundTransparency = 0.4
moveMenu.Visible = false
makeDraggable(moveMenu)
Instance.new("UICorner", moveMenu)

local tpFrame = Instance.new("Frame", sg)
tpFrame.Size = UDim2.new(0, 190, 0, 300)
tpFrame.Position = UDim2.new(0, 410, 1, -310)
tpFrame.BackgroundColor3 = Color3.new(0, 0, 0)
tpFrame.BackgroundTransparency = 0.4
tpFrame.Visible = false
makeDraggable(tpFrame)
Instance.new("UICorner", tpFrame)

local espMenu = Instance.new("Frame", sg)
espMenu.Size = UDim2.new(0, 180, 0, 320)
espMenu.Position = UDim2.new(0, 610, 1, -330)
espMenu.BackgroundColor3 = Color3.new(0, 0, 0)
espMenu.BackgroundTransparency = 0.4
espMenu.Visible = false
makeDraggable(espMenu)
Instance.new("UICorner", espMenu)

local playerBox = Instance.new("TextBox", tpFrame)
playerBox.Size = UDim2.new(1, -20, 0, 25)
playerBox.Position = UDim2.new(0, 10, 0, 10)
playerBox.PlaceholderText = "Type Player Name..."
playerBox.Text = ""
playerBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
playerBox.TextColor3 = Color3.new(1, 1, 1)
playerBox.ClearTextOnFocus = false
Instance.new("UICorner", playerBox)

local tpPlayerBtn = Instance.new("TextButton", tpFrame)
tpPlayerBtn.Size = UDim2.new(1, -20, 0, 25)
tpPlayerBtn.Position = UDim2.new(0, 10, 0, 40)
tpPlayerBtn.Text = "TP TO PLAYER"
tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
tpPlayerBtn.TextColor3 = Color3.new(1, 1, 1)
tpPlayerBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", tpPlayerBtn)

local suggestions = Instance.new("ScrollingFrame", tpFrame)
suggestions.Size = UDim2.new(1, -20, 0, 80)
suggestions.Position = UDim2.new(0, 10, 0, 65)
suggestions.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
suggestions.BackgroundTransparency = 0.1
suggestions.ZIndex = 10
suggestions.Visible = false
local listLayout = Instance.new("UIListLayout", suggestions)

local tpScroll = Instance.new("ScrollingFrame", tpFrame)
tpScroll.Size = UDim2.new(1, -10, 1, -80)
tpScroll.Position = UDim2.new(0, 5, 0, 75)
tpScroll.BackgroundTransparency = 1
tpScroll.BorderSizePixel = 0
tpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tpScroll.ScrollBarThickness = 6

local tpListLayout = Instance.new("UIListLayout", tpScroll)
tpListLayout.Padding = UDim.new(0, 5)
tpListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

playerBox:GetPropertyChangedSignal("Text"):Connect(function()
    for _, v in pairs(suggestions:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local text = playerBox.Text:lower()
    if text == "" then suggestions.Visible = false return end
    local found = false
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player and (p.Name:lower():find(text) or p.DisplayName:lower():find(text)) then
            found = true
            local b = Instance.new("TextButton", suggestions)
            b.Size = UDim2.new(1, 0, 0, 20)
            b.Text = p.Name
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            b.TextColor3 = Color3.new(1, 1, 1)
            b.ZIndex = 11
            b.MouseButton1Click:Connect(function()
                playerBox.Text = p.Name
                suggestions.Visible = false
            end)
        end
    end
    suggestions.Visible = found
    suggestions.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y)
end)

tpPlayerBtn.MouseButton1Click:Connect(function()
    local target = players:FindFirstChild(playerBox.Text)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        farmActive = false; illegalActive = false
        player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end)

local function createBtn(text, pos, parent, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Position = pos
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    return btn
end

local function getFaction(plr)
    if not plr.Team then return "Neutral" end
    local name = plr.Team.Name:lower()
    if name:find("guard") or name:find("police") or name:find("mil") then return "Guard"
    elseif name:find("citizen") or name:find("foreigner") or name:find("civ") then return "Civilian" end
    return "Neutral"
end

local function getESPColor(targetPlr)
    local myFaction = getFaction(player)
    local targetFaction = getFaction(targetPlr)
    if targetFaction == "Neutral" or myFaction == "Neutral" then return Color3.fromRGB(200, 200, 200)
    elseif myFaction == targetFaction then return Color3.fromRGB(0, 255, 0)
    else return Color3.fromRGB(255, 0, 0) end
end

local function createESP(plr)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = nil
    box.Transparency = 0.6
    box.Size = Vector3.new(4, 5.5, 1)
    box.Color3 = Color3.new(1, 1, 1)
    box.Parent = sg

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_UI"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    billboard.Enabled = false

    local healthBG = Instance.new("Frame", billboard)
    healthBG.Size = UDim2.new(0, 5, 0, 30)
    healthBG.Position = UDim2.new(0, -10, 0, 5)
    healthBG.BackgroundColor3 = Color3.new(0, 0, 0)

    local healthBar = Instance.new("Frame", healthBG)
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.new(0, 1, 0)
    healthBar.BorderSizePixel = 0

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0, 15)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 12

    local healthLabel = Instance.new("TextLabel", billboard)
    healthLabel.Size = UDim2.new(1, 0, 0, 15)
    healthLabel.Position = UDim2.new(0, 0, 0, 15)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.new(0, 1, 0)
    healthLabel.TextStrokeTransparency = 0
    healthLabel.Font = Enum.Font.SourceSansBold
    healthLabel.TextSize = 11

    local tracerLine = Drawing.new("Line")
    tracerLine.Thickness = 1.5
    tracerLine.Transparency = 0.8

    local skeletonLines = {}
    for i = 1, 6 do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Transparency = 0.8
        line.Visible = false
        table.insert(skeletonLines, line)
    end

    local function hideSkeleton()
        for _, line in pairs(skeletonLines) do line.Visible = false end
    end

    local connection
    connection = runService.RenderStepped:Connect(function()
        if not scriptRunning then 
            box:Destroy(); billboard:Destroy(); tracerLine:Destroy()
            for _, line in pairs(skeletonLines) do line:Destroy() end
            connection:Disconnect()
            return 
        end

        local char = plr.Character
        if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
            local hum = char.Humanoid
            local root = char.HumanoidRootPart
            local dynamicColor = getESPColor(plr)
            
            if boxActive then
                box.Adornee = root; box.Color3 = dynamicColor; box.Visible = true
            else
                box.Visible = false
            end

            if nameActive then
                billboard.Adornee = root
                nameLabel.TextColor3 = dynamicColor
                nameLabel.Text = plr.Name
                local roundedHealth = math.floor(hum.Health)
                healthLabel.Text = "HP: " .. roundedHealth .. "%"
                healthLabel.TextColor3 = dynamicColor
                local healthRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                healthBar.Size = UDim2.new(1, 0, healthRatio, 0)
                healthBar.Position = UDim2.new(0, 0, 1 - healthRatio, 0)
                healthBar.BackgroundColor3 = Color3.fromHSV(healthRatio * 0.3, 1, 1)
                billboard.Enabled = true
            else
                billboard.Enabled = false
            end

            if tracerActive then
                local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    tracerLine.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    tracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
                    tracerLine.Color = dynamicColor
                    tracerLine.Visible = true
                else tracerLine.Visible = false end
            else tracerLine.Visible = false end

            if skeletonActive then
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                local leftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand")
                local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
                local leftLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot")
                local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot")

                if head and torso and leftArm and rightArm and leftLeg and rightLeg then
                    local headP, headO = camera:WorldToViewportPoint(head.Position)
                    local torsoP, torsoO = camera:WorldToViewportPoint(torso.Position)
                    local leftArmP, leftArmO = camera:WorldToViewportPoint(leftArm.Position)
                    local rightArmP, rightArmO = camera:WorldToViewportPoint(rightArm.Position)
                    local leftLegP, leftLegO = camera:WorldToViewportPoint(leftLeg.Position)
                    local rightLegP, rightLegO = camera:WorldToViewportPoint(rightLeg.Position)

                    if torsoO then
                        skeletonLines[1].From = Vector2.new(headP.X, headP.Y); skeletonLines[1].To = Vector2.new(torsoP.X, torsoP.Y)
                        skeletonLines[2].From = Vector2.new(torsoP.X, torsoP.Y); skeletonLines[2].To = Vector2.new(leftArmP.X, leftArmP.Y)
                        skeletonLines[3].From = Vector2.new(torsoP.X, torsoP.Y); skeletonLines[3].To = Vector2.new(rightArmP.X, rightArmP.Y)
                        skeletonLines[4].From = Vector2.new(torsoP.X, torsoP.Y); skeletonLines[4].To = Vector2.new(leftLegP.X, leftLegP.Y)
                        skeletonLines[5].From = Vector2.new(torsoP.X, torsoP.Y); skeletonLines[5].To = Vector2.new(rightLegP.X, rightLegP.Y)
                        skeletonLines[6].From = Vector2.new(leftArmP.X, leftArmP.Y); skeletonLines[6].To = Vector2.new(rightArmP.X, rightArmP.Y)
                        for _, line in pairs(skeletonLines) do line.Color = dynamicColor; line.Visible = true end
                    else hideSkeleton() end
                else hideSkeleton() end
            else hideSkeleton() end
        else
            box.Visible = false; billboard.Enabled = false; tracerLine.Visible = false; hideSkeleton()
        end
    end)
    billboard.Parent = sg
end

local d1 = Drawing.new("Line")
d1.Thickness = 2; d1.Transparency = 1; d1.Color = Color3.fromRGB(255, 0, 0)
local d2 = Drawing.new("Line")
d2.Thickness = 2; d2.Transparency = 1; d2.Color = Color3.fromRGB(255, 0, 0)
local d3 = Drawing.new("Line")
d3.Thickness = 2; d3.Transparency = 1; d3.Color = Color3.fromRGB(255, 0, 0)
local d4 = Drawing.new("Line")
d4.Thickness = 2; d4.Transparency = 1; d4.Color = Color3.fromRGB(255, 0, 0)
local centerDot = Drawing.new("Circle")
centerDot.Filled = true; centerDot.Radius = 3.5; centerDot.Transparency = 1; centerDot.Color = Color3.fromRGB(255, 0, 0)
local crossV = Drawing.new("Line")
crossV.Thickness = 2; crossV.Transparency = 1; crossV.Color = Color3.fromRGB(255, 0, 0)
local crossH = Drawing.new("Line")
crossH.Thickness = 2; crossH.Transparency = 1; crossH.Color = Color3.fromRGB(255, 0, 0)

for _, p in pairs(players:GetPlayers()) do if p ~= player then createESP(p) end end
players.PlayerAdded:Connect(function(p) if p ~= player then createESP(p) end end)

local farmBtn = createBtn("AUTOFARM: OFF [F1]", UDim2.new(0, 10, 0, 10), main, Color3.fromRGB(120, 40, 40))
local illegalBtn = createBtn("ILLEGAL FARM: OFF [F2]", UDim2.new(0, 10, 0, 50), main, Color3.fromRGB(120, 40, 40))
local toggleMoveBtn = createBtn("MOVEMENT MENU [F3]", UDim2.new(0, 10, 0, 90), main, Color3.fromRGB(80, 80, 40))
local toggleTpBtn = createBtn("TP MENU [F4]", UDim2.new(0, 10, 0, 130), main, Color3.fromRGB(0, 80, 120))
local toggleEspMenuBtn = createBtn("ESP MENU [F5]", UDim2.new(0, 10, 0, 170), main, Color3.fromRGB(0, 120, 80))
local removeBtn = createBtn("REMOVE SCRIPT", UDim2.new(0, 10, 0, 210), main, Color3.fromRGB(150, 0, 0))

local toggleBoxBtn = createBtn("BOX ESP: OFF", UDim2.new(0, 10, 0, 10), espMenu)
local toggleNameBtn = createBtn("NAME ESP: OFF", UDim2.new(0, 10, 0, 50), espMenu)
local toggleTracerBtn = createBtn("TRACERS: OFF", UDim2.new(0, 10, 0, 90), espMenu)
local toggleSkeletonBtn = createBtn("SKELETON ESP: OFF", UDim2.new(0, 10, 0, 130), espMenu)
local toggleCrossBtn = createBtn("CROSSHAIR: OFF", UDim2.new(0, 10, 0, 170), espMenu)
local maxZoomBtn = createBtn("MAX ZOOM: OFF", UDim2.new(0, 10, 0, 210), espMenu, Color3.fromRGB(80, 40, 120))
local freecamBtn = createBtn("FREE CAM: OFF", UDim2.new(0, 10, 0, 250), espMenu, Color3.fromRGB(40, 80, 120))

local noclipBtn = createBtn("NOCLIP: OFF", UDim2.new(0, 10, 0, 10), moveMenu)
local speedBox = Instance.new("TextBox", moveMenu)
speedBox.Size = UDim2.new(1, -20, 0, 25)
speedBox.Position = UDim2.new(0, 10, 0, 50)
speedBox.PlaceholderText = "WalkSpeed..."
speedBox.Text = "16"
speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", speedBox)
local applySpeedBtn = createBtn("SET WALKSPEED", UDim2.new(0, 10, 0, 85), moveMenu, Color3.fromRGB(0, 120, 150))
local jumpBox = Instance.new("TextBox", moveMenu)
jumpBox.Size = UDim2.new(1, -20, 0, 25)
jumpBox.Position = UDim2.new(0, 10, 0, 125)
jumpBox.PlaceholderText = "JumpPower..."
jumpBox.Text = "50"
jumpBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
jumpBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", jumpBox)
local applyJumpBtn = createBtn("SET JUMP HEIGHT", UDim2.new(0, 10, 0, 160), moveMenu, Color3.fromRGB(150, 100, 0))

toggleBoxBtn.MouseButton1Click:Connect(function() boxActive = not boxActive; toggleBoxBtn.Text = boxActive and "BOX ESP: ON" or "BOX ESP: OFF" end)
toggleNameBtn.MouseButton1Click:Connect(function() nameActive = not nameActive; toggleNameBtn.Text = nameActive and "NAME/HP ESP: ON" or "NAME ESP: OFF" end)
toggleTracerBtn.MouseButton1Click:Connect(function() tracerActive = not tracerActive; toggleTracerBtn.Text = tracerActive and "TRACERS: ON" or "TRACERS: OFF" end)
toggleSkeletonBtn.MouseButton1Click:Connect(function() skeletonActive = not skeletonActive; toggleSkeletonBtn.Text = skeletonActive and "SKELETON ESP: ON" or "SKELETON ESP: OFF" end)
toggleCrossBtn.MouseButton1Click:Connect(function() crosshairActive = not crosshairActive; toggleCrossBtn.Text = crosshairActive and "CROSSHAIR: ON" or "CROSSHAIR: OFF" end)
maxZoomBtn.MouseButton1Click:Connect(function() maxZoomActive = not maxZoomActive; player.CameraMaxZoomDistance = maxZoomActive and 1000 or 400; maxZoomBtn.Text = maxZoomActive and "MAX ZOOM: ON" or "MAX ZOOM: OFF" end)

freecamBtn.MouseButton1Click:Connect(function()
    freecamActive = not freecamActive; freecamBtn.Text = freecamActive and "FREE CAM: ON" or "FREE CAM: OFF"
    if freecamActive then
        originalCameraType = camera.CameraType; freecamCFrame = camera.CFrame; camera.CameraType = Enum.CameraType.Scriptable
        focusPart = Instance.new("Part"); focusPart.Anchored = true; focusPart.Transparency = 1; focusPart.Parent = workspace
    else
        camera.CameraType = originalCameraType; player.ReplicationFocus = nil
        if focusPart then focusPart:Destroy() end
    end
end)

local function updateButtonVisuals()
    farmBtn.Text = farmActive and "AUTOFARM: ACTIVE [F1]" or "AUTOFARM: OFF [F1]"
    illegalBtn.Text = illegalActive and "ILLEGAL FARM: ACTIVE [F2]" or "ILLEGAL FARM: OFF [F2]"
end

local function toggleFarm() farmActive = not farmActive; illegalActive = false; updateButtonVisuals() end
local function toggleIllegal() illegalActive = not illegalActive; farmActive = false; updateButtonVisuals() end
local function toggleNoclip() noclip = not noclip; noclipBtn.Text = noclip and "NOCLIP: ACTIVE" or "NOCLIP: OFF" end

farmBtn.MouseButton1Click:Connect(toggleFarm)
illegalBtn.MouseButton1Click:Connect(toggleIllegal)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
toggleMoveBtn.MouseButton1Click:Connect(function() moveMenu.Visible = not moveMenu.Visible end)
toggleTpBtn.MouseButton1Click:Connect(function() tpFrame.Visible = not tpFrame.Visible end)
toggleEspMenuBtn.MouseButton1Click:Connect(function() espMenu.Visible = not espMenu.Visible end)

runService.Stepped:Connect(function()
    if not scriptRunning or not player.Character then return end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if crosshairActive and player.Character:FindFirstChildOfClass("Tool") then
        local center = camera.ViewportSize / 2; local adjustedY = center.Y - 55
        local ray = workspace:Raycast(camera.ViewportPointToRay(center.X, adjustedY).Origin, camera.ViewportPointToRay(center.X, adjustedY).Direction * 1000)
        local hitPlr = ray and ray.Instance:FindFirstAncestorOfClass("Model") and players:GetPlayerFromCharacter(ray.Instance:FindFirstAncestorOfClass("Model"))
        local innerGap = 13; local lineLength = 11
        d1.From = Vector2.new(center.X - innerGap - lineLength, adjustedY - innerGap - lineLength); d1.To = Vector2.new(center.X - innerGap, adjustedY - innerGap)
        d2.From = Vector2.new(center.X + innerGap, adjustedY - innerGap); d2.To = Vector2.new(center.X + innerGap + lineLength, adjustedY - innerGap - lineLength)
        d3.From = Vector2.new(center.X - innerGap - lineLength, adjustedY + innerGap + lineLength); d3.To = Vector2.new(center.X - innerGap, adjustedY + innerGap)
        d4.From = Vector2.new(center.X + innerGap, adjustedY + innerGap); d4.To = Vector2.new(center.X + innerGap + lineLength, adjustedY + innerGap + lineLength)
        centerDot.Position = Vector2.new(center.X, adjustedY)
        d1.Visible = true; d2.Visible = true; d3.Visible = true; d4.Visible = true; centerDot.Visible = true
        crossV.Visible = hitPlr and true or false; crossH.Visible = hitPlr and true or false
    else
        d1.Visible = false; d2.Visible = false; d3.Visible = false; d4.Visible = false; centerDot.Visible = false; crossV.Visible = false; crossH.Visible = false
    end
    if noclip then for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if hum then hum.WalkSpeed = customWalkSpeed; hum.JumpPower = customJumpPower end
end)

task.spawn(function()
    while scriptRunning do
        task.wait(0.2)
        if (farmActive or illegalActive) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local target = farmActive and REGULAR_BUY or ILLEGAL_BUY
            local sell = farmActive and REGULAR_SELL or ILLEGAL_SELL
            local name = farmActive and REGULAR_NAME or ILLEGAL_NAME
            if not backpack:FindFirstChild(name) and not player.Character:FindFirstChild(name) then
                root.CFrame = CFrame.new(target)
                task.wait(0.5)
            else
                root.CFrame = CFrame.new(sell)
                task.wait(0.5)
            end
        end
    end
end)
