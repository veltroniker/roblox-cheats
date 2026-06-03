local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")
local textChatService = game:GetService("TextChatService")
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
local antiAfkActive = false
local flyActive = false

local boxActive = false
local nameActive = false
local tracerActive = false
local skeletonActive = false
local maxZoomActive = false
local freecamActive = false
local noFogActive = false
local chatLogActive = true

local freecamCFrame = CFrame.new()
local freecamSpeed = 4 
local originalCameraType = camera.CameraType
local originalMouseBehavior = userInputService.MouseBehavior

local cameraX = 0
local cameraY = 0
local focusPart = nil 

local virtualUser = game:GetService("VirtualUser")
local afkConnection

afkConnection = player.Idled:Connect(function()
    if scriptRunning then
        if antiAfkActive then
            virtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
            task.wait(1)
            virtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
        end
    else
        if afkConnection then afkConnection:Disconnect() end
    end
end)

local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "CrateMaster_V40_Clean"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999999

local drawOverlay = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
drawOverlay.Name = "CrateMaster_DrawOverlay"
drawOverlay.ResetOnSpawn = false
drawOverlay.DisplayOrder = 999998

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
moveMenu.Size = UDim2.new(0, 180, 0, 300)
moveMenu.Position = UDim2.new(0, 220, 1, -310)
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
espMenu.Size = UDim2.new(0, 220, 0, 395)
espMenu.Position = UDim2.new(0, 610, 1, -405)
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

local function setGuiLine(lineFrame, from, to)
    local distance = (to - from).Magnitude
    lineFrame.Size = UDim2.new(0, distance, 0, 2)
    lineFrame.Position = UDim2.new(0, (from.X + to.X) / 2, 0, (from.Y + to.Y) / 2)
    lineFrame.Rotation = math.deg(math.atan2(to.Y - from.Y, to.X - from.X))
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

    local tracerLine = Instance.new("Frame", drawOverlay)
    tracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
    tracerLine.BorderSizePixel = 0
    tracerLine.Visible = false

    local skeletonLines = {}
    for i = 1, 6 do
        local line = Instance.new("Frame", drawOverlay)
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BorderSizePixel = 0
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
                    local from = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    local to = Vector2.new(screenPos.X, screenPos.Y)
                    tracerLine.BackgroundColor3 = dynamicColor
                    setGuiLine(tracerLine, from, to)
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
                        for _, line in pairs(skeletonLines) do line.BackgroundColor3 = dynamicColor; line.Visible = true end
                        setGuiLine(skeletonLines[1], Vector2.new(headP.X, headP.Y), Vector2.new(torsoP.X, torsoP.Y))
                        setGuiLine(skeletonLines[2], Vector2.new(torsoP.X, torsoP.Y), Vector2.new(leftArmP.X, leftArmP.Y))
                        setGuiLine(skeletonLines[3], Vector2.new(torsoP.X, torsoP.Y), Vector2.new(rightArmP.X, rightArmP.Y))
                        setGuiLine(skeletonLines[4], Vector2.new(torsoP.X, torsoP.Y), Vector2.new(leftLegP.X, leftLegP.Y))
                        setGuiLine(skeletonLines[5], Vector2.new(torsoP.X, torsoP.Y), Vector2.new(rightLegP.X, rightLegP.Y))
                        setGuiLine(skeletonLines[6], Vector2.new(leftArmP.X, leftArmP.Y), Vector2.new(rightArmP.X, rightArmP.Y))
                    else hideSkeleton() end
                else hideSkeleton() end
            else hideSkeleton() end
        else
            box.Visible = false; billboard.Enabled = false; tracerLine.Visible = false; hideSkeleton()
        end
    end)
    billboard.Parent = sg
end

for _, p in pairs(players:GetPlayers()) do if p ~= player then createESP(p) end end
players.PlayerAdded:Connect(function(p) if p ~= player then createESP(p) end end)

local mainFrame = main
local farmBtn = createBtn("AUTOFARM: OFF [F1]", UDim2.new(0, 10, 0, 10), mainFrame, Color3.fromRGB(120, 40, 40))
local illegalBtn = createBtn("ILLEGAL FARM: OFF [F2]", UDim2.new(0, 10, 0, 50), mainFrame, Color3.fromRGB(120, 40, 40))
local toggleMoveBtn = createBtn("MOVEMENT MENU [F3]", UDim2.new(0, 10, 0, 90), mainFrame, Color3.fromRGB(80, 80, 40))
local toggleTpBtn = createBtn("TP MENU [F4]", UDim2.new(0, 10, 0, 130), mainFrame, Color3.fromRGB(0, 80, 120))
local toggleEspMenuBtn = createBtn("ESP MENU [F5]", UDim2.new(0, 10, 0, 170), mainFrame, Color3.fromRGB(0, 120, 80))
local removeBtn = createBtn("REMOVE SCRIPT", UDim2.new(0, 10, 0, 210), mainFrame, Color3.fromRGB(150, 0, 0))

local toggleBoxBtn = createBtn("BOX ESP: OFF", UDim2.new(0, 10, 0, 10), espMenu)
local toggleNameBtn = createBtn("NAME ESP: OFF", UDim2.new(0, 10, 0, 45), espMenu)
local toggleTracerBtn = createBtn("TRACERS: OFF", UDim2.new(0, 10, 0, 80), espMenu)
local toggleSkeletonBtn = createBtn("SKELETON ESP: OFF", UDim2.new(0, 10, 0, 115), espMenu)
local maxZoomBtn = createBtn("MAX ZOOM: OFF", UDim2.new(0, 10, 0, 150), espMenu, Color3.fromRGB(80, 40, 120))
local toggleFogBtn = createBtn("NO FOG: OFF", UDim2.new(0, 10, 0, 185), espMenu, Color3.fromRGB(120, 60, 0))
local chatLogToggleBtn = createBtn("CHAT LOG: ON", UDim2.new(0, 10, 0, 220), espMenu, Color3.fromRGB(0, 100, 150))
chatLogToggleBtn.TextColor3 = Color3.new(0, 1, 0)

local chatContainer = Instance.new("Frame", espMenu)
chatContainer.Size = UDim2.new(1, -20, 0, 120)
chatContainer.Position = UDim2.new(0, 10, 0, 260)
chatContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
chatContainer.BackgroundTransparency = 0.3
Instance.new("UICorner", chatContainer)

local chatScroll = Instance.new("ScrollingFrame", chatContainer)
chatScroll.Size = UDim2.new(1, -10, 1, -10)
chatScroll.Position = UDim2.new(0, 5, 0, 5)
chatScroll.BackgroundTransparency = 1
chatScroll.BorderSizePixel = 0
chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
chatScroll.ScrollBarThickness = 4

local chatListLayout = Instance.new("UIListLayout", chatScroll)
chatListLayout.Padding = UDim.new(0, 3)
chatListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function appendToChatLog(sender, message, isWarning)
    if not scriptRunning then return end
    if not chatLogActive and not isWarning then return end
    
    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, -5, 0, 0)
    logLabel.AutomaticSize = Enum.AutomaticSize.Y
    logLabel.BackgroundTransparency = 1
    logLabel.Font = Enum.Font.SourceSansBold
    logLabel.TextSize = 13
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextYAlignment = Enum.TextYAlignment.Top
    logLabel.TextWrapped = true
    
    if isWarning then
        logLabel.Text = string.format('<font color="#FF0000"><b>[COMMAND DETECTED] %s</b></font>', message)
    else
        local pObj = players:FindFirstChild(sender)
        local colHex = "FFFFFF"
        if pObj then
            local c = getESPColor(pObj)
            colHex = string.format("%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
        end
        logLabel.Text = string.format('<font color="#%s">[%s]</font>: <font color="#FFFFFF">%s</font>', colHex, sender, message)
    end
    
    logLabel.RichText = true
    logLabel.Parent = chatScroll
    
    task.wait(0.01)
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatListLayout.AbsoluteContentSize.Y + 10)
    chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
end

local chatConnections = {}

local function disconnectChat()
    for _, conn in pairs(chatConnections) do
        if conn then conn:Disconnect() end
    end
    chatConnections = {}
end

local function handleIncomingText(senderName, rawMessage)
    if not scriptRunning or senderName == "" or rawMessage == "" then return end
    
    local isCmd = string.find(rawMessage, ":") ~= nil
    
    if isCmd then
        appendToChatLog(senderName, string.format("%s used a command: %s", senderName, rawMessage), true)
    end
    
    if chatLogActive and not isCmd then
        appendToChatLog(senderName, rawMessage, false)
    end
end

if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    local conn = textChatService.MessageReceived:Connect(function(message)
        if scriptRunning and message.TextSource then
            task.spawn(function()
                local unmaskedText = ""
                pcall(function()
                    if message.Metadata and message.Metadata ~= "" then
                        unmaskedText = message.Metadata
                    elseif message.Text and message.Text ~= "" then
                        unmaskedText = message.Text
                    end
                end)
                if unmaskedText == "" then return end
                handleIncomingText(message.TextSource.Name, unmaskedText)
            end)
        end
    end)
    table.insert(chatConnections, conn)
else
    local function hookPlayer(p)
        if chatConnections[p] then return end
        chatConnections[p] = p.Chatted:Connect(function(msg)
            if scriptRunning then handleIncomingText(p.Name, msg) end
        end)
    end
    for _, p in pairs(players:GetPlayers()) do hookPlayer(p) end
    local conn = players.PlayerAdded:Connect(hookPlayer)
    table.insert(chatConnections, conn)
    local dconn = players.PlayerRemoving:Connect(function(p)
        if chatConnections[p] then
            chatConnections[p]:Disconnect()
            chatConnections[p] = nil
        end
    end)
    table.insert(chatConnections, dconn)
end

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

local flyBtn = createBtn("FLY: OFF", UDim2.new(0, 10, 0, 195), moveMenu, Color3.fromRGB(120, 40, 40))
local antiAfkBtn = createBtn("ANTI-AFK: OFF", UDim2.new(0, 10, 0, 230), moveMenu, Color3.fromRGB(120, 40, 40))
local freecamBtn = createBtn("FREE CAM: OFF", UDim2.new(0, 10, 0, 265), moveMenu, Color3.fromRGB(40, 80, 120))

toggleBoxBtn.MouseButton1Click:Connect(function()
    boxActive = not boxActive
    toggleBoxBtn.Text = boxActive and "BOX ESP: ON" or "BOX ESP: OFF"
    toggleBoxBtn.TextColor3 = boxActive and Color3.new(0,1,0) or Color3.new(1,1,1)
end)

toggleNameBtn.MouseButton1Click:Connect(function()
    nameActive = not nameActive
    toggleNameBtn.Text = nameActive and "NAME/HP ESP: ON" or "NAME ESP: OFF"
    toggleNameBtn.TextColor3 = nameActive and Color3.new(0,1,0) or Color3.new(1,1,1)
end)

toggleTracerBtn.MouseButton1Click:Connect(function()
    tracerActive = not tracerActive
    toggleTracerBtn.Text = tracerActive and "TRACERS: ON" or "TRACERS: OFF"
    toggleTracerBtn.TextColor3 = tracerActive and Color3.new(0,1,0) or Color3.new(1,1,1)
end)

toggleSkeletonBtn.MouseButton1Click:Connect(function()
    skeletonActive = not skeletonActive
    toggleSkeletonBtn.Text = skeletonActive and "SKELETON ESP: ON" or "SKELETON ESP: OFF"
    toggleSkeletonBtn.TextColor3 = skeletonActive and Color3.new(0,1,0) or Color3.new(1,1,1)
end)

maxZoomBtn.MouseButton1Click:Connect(function()
    maxZoomActive = not maxZoomActive
    maxZoomBtn.Text = maxZoomActive and "MAX ZOOM: ON" or "MAX ZOOM: OFF"
    maxZoomBtn.TextColor3 = maxZoomActive and Color3.new(0,1,0) or Color3.new(1,1,1)
    player.CameraMaxZoomDistance = maxZoomActive and 1000 or 400
end)

freecamBtn.MouseButton1Click:Connect(function()
    freecamActive = not freecamActive
    freecamBtn.Text = freecamActive and "FREE CAM: ON" or "FREE CAM: OFF"
    freecamBtn.TextColor3 = freecamActive and Color3.new(0,1,0) or Color3.new(1,1,1)
    
    if freecamActive then
        flyActive = false
        flyBtn.Text = "FLY: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
        originalCameraType = camera.CameraType
        originalMouseBehavior = userInputService.MouseBehavior
        freecamCFrame = camera.CFrame
        local startRotation = camera.CFrame - camera.CFrame.Position
        local _, y, _ = startRotation:ToEulerAnglesYXZ()
        cameraX = 0; cameraY = math.deg(y)
        camera.CameraType = Enum.CameraType.Scriptable

        if not focusPart then
            focusPart = Instance.new("Part")
            focusPart.Name = "CamStreamingFocus"
            focusPart.Anchored = true; focusPart.CanCollide = false; focusPart.Transparency = 1; focusPart.Size = Vector3.new(1, 1, 1)
            focusPart.Parent = workspace
        end
        focusPart.CFrame = freecamCFrame
        player.ReplicationFocus = focusPart
    else
        camera.CameraType = originalCameraType
        userInputService.MouseBehavior = Enum.MouseBehavior.Default
        player.ReplicationFocus = nil
        if focusPart then focusPart:Destroy() focusPart = nil end
        cameraX = 0; cameraY = 0
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            camera.CameraSubject = hum
            hum.WalkSpeed = customWalkSpeed; hum.JumpPower = customJumpPower
        end
    end
end)

toggleFogBtn.MouseButton1Click:Connect(function()
    noFogActive = not noFogActive
    toggleFogBtn.Text = noFogActive and "NO FOG: ON" or "NO FOG: OFF"
    toggleFogBtn.TextColor3 = noFogActive and Color3.new(0,1,0) or Color3.new(1,1,1)
end)

chatLogToggleBtn.MouseButton1Click:Connect(function()
    chatLogActive = not chatLogActive
    chatLogToggleBtn.Text = chatLogActive and "CHAT LOG: ON" or "CHAT LOG: OFF"
    chatLogToggleBtn.TextColor3 = chatLogActive and Color3.new(0,1,0) or Color3.new(1,1,1)
end)

local function updateButtonVisuals()
    farmBtn.Text = farmActive and "AUTOFARM: ACTIVE [F1]" or "AUTOFARM: OFF [F1]"
    farmBtn.BackgroundColor3 = farmActive and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(120, 40, 40)
    illegalBtn.Text = illegalActive and "ILLEGAL FARM: ACTIVE [F2]" or "ILLEGAL FARM: OFF [F2]"
    illegalBtn.BackgroundColor3 = illegalActive and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(120, 40, 40)
end

local function toggleFarm() farmActive = not farmActive; if farmActive then illegalActive = false end; updateButtonVisuals() end
local function toggleIllegal() illegalActive = not illegalActive; if illegalActive then farmActive = false end; updateButtonVisuals() end
local function toggleNoclip() noclip = not noclip; noclipBtn.Text = noclip and "NOCLIP: ACTIVE" or "NOCLIP: OFF"; noclipBtn.TextColor3 = noclip and Color3.new(0,1,0) or Color3.new(1,1,1) end

applySpeedBtn.MouseButton1Click:Connect(function()
    local targetSpeed = tonumber(speedBox.Text)
    if targetSpeed then customWalkSpeed = targetSpeed
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = customWalkSpeed end
    end
end)

applyJumpBtn.MouseButton1Click:Connect(function()
    local targetJump = tonumber(jumpBox.Text)
    if targetJump then customJumpPower = targetJump
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            hum.UseJumpPower = true; hum.JumpPower = customJumpPower
        end
    end
end)

antiAfkBtn.MouseButton1Click:Connect(function()
    antiAfkActive = not antiAfkActive
    antiAfkBtn.Text = antiAfkActive and "ANTI-AFK: ACTIVE" or "ANTI-AFK: OFF"
    antiAfkBtn.BackgroundColor3 = antiAfkActive and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(120, 40, 40)
end)

flyBtn.MouseButton1Click:Connect(function()
    flyActive = not flyActive
    flyBtn.Text = flyActive and "FLY: ACTIVE" or "FLY: OFF"
    flyBtn.BackgroundColor3 = flyActive and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(120, 40, 40)
    if flyActive then
        freecamActive = false
        freecamBtn.Text = "FREE CAM: OFF"
        freecamBtn.TextColor3 = Color3.new(1,1,1)
    else
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            root.Velocity = Vector3.new(0,0,0)
            root.RotVelocity = Vector3.new(0,0,0)
        end
    end
end)

farmBtn.MouseButton1Click:Connect(toggleFarm)
illegalBtn.MouseButton1Click:Connect(toggleIllegal)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)

toggleMoveBtn.MouseButton1Click:Connect(function() moveMenu.Visible = not moveMenu.Visible end)
toggleTpBtn.MouseButton1Click:Connect(function() tpFrame.Visible = not tpFrame.Visible end)
toggleEspMenuBtn.MouseButton1Click:Connect(function() espMenu.Visible = not espMenu.Visible end)

removeBtn.MouseButton1Click:Connect(function()
    scriptRunning = false; farmActive = false; illegalActive = false; noclip = false; antiAfkActive = false; flyActive = false
    boxActive = false; nameActive = false; tracerActive = false; skeletonActive = false; freecamActive = false; noFogActive = false
    camera.CameraType = originalCameraType; userInputService.MouseBehavior = Enum.MouseBehavior.Default
    player.CameraMaxZoomDistance = 400; player.ReplicationFocus = nil
    cameraX = 0; cameraY = 0
    if focusPart then focusPart:Destroy() focusPart = nil end
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = 16; hum.JumpPower = 50; camera.CameraSubject = hum
    end
    if afkConnection then afkConnection:Disconnect() end
    disconnectChat()
    sg:Destroy()
    drawOverlay:Destroy()
end)

userInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.F1 then toggleFarm()
    elseif i.KeyCode == Enum.KeyCode.F2 then toggleIllegal()
    elseif i.KeyCode == Enum.KeyCode.F3 then moveMenu.Visible = not moveMenu.Visible
    elseif i.KeyCode == Enum.KeyCode.F4 then tpFrame.Visible = not tpFrame.Visible
    elseif i.KeyCode == Enum.KeyCode.F5 then espMenu.Visible = not espMenu.Visible 
    elseif i.UserInputType == Enum.UserInputType.MouseButton1 and userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local mousePos = userInputService:GetMouseLocation()
            local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {player.Character}
            local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 5000, raycastParams)
            if raycastResult then
                farmActive = false; illegalActive = false; updateButtonVisuals()
                player.Character.HumanoidRootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

local function createTp(name, pos)
    local b = createBtn(name, UDim2.new(0, 0, 0, 0), tpScroll)
    b.Size = UDim2.new(1, -10, 0, 28)
    b.MouseButton1Click:Connect(function()
        farmActive = false; illegalActive = false; updateButtonVisuals()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = CFrame.new(pos) end
    end)
end

createTp("Apartments", Vector3.new(51, 14, 149))
createTp("Bank", Vector3.new(-22, 18, 588))
createTp("Black Market", Vector3.new(-94, 14, 165))
createTp("Border Roof", Vector3.new(-175, 56, 269))
createTp("Burger Shop", Vector3.new(-98, 14, 568))
createTp("Cart Ride", Vector3.new(-307, -20, 110))
createTp("Cart Spawn", Vector3.new(-697, 37, 348))
createTp("Cartel", Vector3.new(-71, -15, -106))
createTp("Clothing Store", Vector3.new(-211, 14, 573))
createTp("Gun Store", Vector3.new(-20, 15, 526))
createTp("Hat Store", Vector3.new(60, 17, -70))
createTp("Houses", Vector3.new(30, 13, 433))
createTp("Illegal Guns", Vector3.new(-219, 14, 78))
createTp("Illegal Shop", Vector3.new(-67, 14, 60))
createTp("Mines", Vector3.new(-285, 14, 433))
createTp("Permits Shop", Vector3.new(-143, 14, -10))
createTp("Rope", Vector3.new(-224, 38, 95))
createTp("Tacos", Vector3.new(-142, 14, 55))
createTp("Water Fountain", Vector3.new(-179, 14, 346)) 

tpScroll.CanvasSize = UDim2.new(0, 0, 0, tpListLayout.AbsoluteContentSize.Y + 10)
tpListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tpScroll.CanvasSize = UDim2.new(0, 0, 0, tpListLayout.AbsoluteContentSize.Y + 10) end)

runService.Stepped:Connect(function()
    if scriptRunning and noFogActive then
        pcall(function()
            lighting.FogStart = 999999
            lighting.FogEnd = 999999
            lighting.FogColor = Color3.fromRGB(0, 0, 0)
            for _, v in pairs(lighting:GetChildren()) do
                if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("Clouds") then
                    v:Destroy()
                end
            end
        end)
    end
    if scriptRunning and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        
        if freecamActive then
            if hum then hum.WalkSpeed = 0; hum.JumpPower = 0 end
            if userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                local mouseDelta = userInputService:GetMouseDelta()
                cameraX = cameraX - (mouseDelta.Y * 0.4)
                cameraY = cameraY - (mouseDelta.X * 0.4)
                cameraX = math.clamp(cameraX, -80, 80)
            else userInputService.MouseBehavior = Enum.MouseBehavior.Default end
            
            local lookVector = camera.CFrame.LookVector
            local rightVector = camera.CFrame.RightVector
            local moveDirection = Vector3.new()
            if userInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + lookVector end
            if userInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - lookVector end
            if userInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - rightVector end
            if userInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + rightVector end
            if userInputService:IsKeyDown(Enum.KeyCode.E) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if userInputService:IsKeyDown(Enum.KeyCode.Q) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
            
            if moveDirection.Magnitude > 0 then freecamCFrame = freecamCFrame + (moveDirection.Unit * freecamSpeed) end
            camera.CFrame = CFrame.new(freecamCFrame.Position) * CFrame.Angles(0, math.rad(cameraY), 0) * CFrame.Angles(math.rad(cameraX), 0, 0)
            freecamCFrame = camera.CFrame
            if focusPart then focusPart.CFrame = freecamCFrame end
        else
            if flyActive and root then
                local flySpeed = (customWalkSpeed / 16) * 1.5
                local look = camera.CFrame.LookVector
                local right = camera.CFrame.RightVector
                local vel = Vector3.new(0,0,0)
                if userInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + look end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - look end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - right end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + right end
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, 1, 0) end
                
                if vel.Magnitude > 0 then
                    root.Velocity = vel.Unit * (flySpeed * 30)
                else
                    root.Velocity = Vector3.new(0, 0, 0)
                end
                root.RotVelocity = Vector3.new(0, 0, 0)
            else
                if noclip then
                    for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
                end
                if hum then
                    if hum.WalkSpeed ~= customWalkSpeed then hum.WalkSpeed = customWalkSpeed end
                    if hum.JumpPower ~= customJumpPower then hum.UseJumpPower = true; hum.JumpPower = customJumpPower end
                end
            end
        end
    end
end)

local function fireClosestPrompt(pos)
    local bestPrompt = nil
    local minDistance = 45
    for _, d in pairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local pPart = d.Parent
            if pPart and pPart:IsA("BasePart") then
                local dMag = (pPart.Position - pos).Magnitude
                if dMag < minDistance then minDistance = dMag; bestPrompt = d end
            end
        end
    end
    if bestPrompt then pcall(function() fireproximityprompt(bestPrompt) end) end
end

task.spawn(function()
    while scriptRunning do
        task.wait(0.08)
        if (farmActive or illegalActive) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local currentCharacter = player.Character
            local currentBackpack = player:FindFirstChild("Backpack")
            local root = currentCharacter:FindFirstChild("HumanoidRootPart")
            local hum = currentCharacter:FindFirstChildOfClass("Humanoid")
            
            if root and hum then
                local buyPos = farmActive and REGULAR_BUY or ILLEGAL_BUY
                local sellPos = farmActive and REGULAR_SELL or ILLEGAL_SELL
                local crateName = farmActive and REGULAR_NAME or ILLEGAL_NAME
                
                local crateInBackpack = currentBackpack and currentBackpack:FindFirstChild(crateName)
                local crateInCharacter = currentCharacter:FindFirstChild(crateName)
                
                if not crateInBackpack and not crateInCharacter then
                    root.CFrame = CFrame.new(buyPos + Vector3.new(0, 2, 0))
                    task.wait(0.15)
                    fireClosestPrompt(buyPos)
                else
                    if crateInBackpack then 
                        hum:EquipTool(crateInBackpack) 
                        task.wait(0.05)
                    end
                    root.CFrame = CFrame.new(sellPos + Vector3.new(0, 2, 0))
                    task.wait(0.15)
                    fireClosestPrompt(sellPos)
                end
            end
        end
    end
end)
