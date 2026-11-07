--[[
    Cobalt Aimbot + ESP Framework (Mobile Compatible)
    - 手机视角锁定（CFrame Lerp）
    - Drawing 防崩溃（pcall 包裹）
    - 触摸支持（Touch + MouseButton1 双输入）
    - 掩体/队伍识别、居中 FOV 圈、全手写 UI
    - ESP 使用 Drawing API（Text + Square）
    - 完整关闭/销毁功能
]]

-- ============ 基础服务 ============
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============ 渲染连接管理 ============
local renderConnections = {}
local destroyed = false

local function addRenderConnection(conn)
    table.insert(renderConnections, conn)
    return conn
end

local function disconnectAllRender()
    for _, conn in ipairs(renderConnections) do
        pcall(function()
            if conn and conn.Disconnect then
                conn:Disconnect()
            end
        end)
    end
    renderConnections = {}
end

-- ============ 统一的屏幕中心（自瞄与 FOV 圈共用） ============
local function getScreenCenter()
    local vs = Camera.ViewportSize
    return Vector2.new(vs.X / 2, vs.Y / 2)
end

-- ============ 安全的 Drawing 封装 ============
local SafeDrawing = {}
SafeDrawing.Circle = nil
SafeDrawing.Available = false
SafeDrawing.TextLibrary = false

pcall(function()
    if Drawing and Drawing.new then
        SafeDrawing.TextLibrary = true
        SafeDrawing.Circle = Drawing.new("Circle")
        if SafeDrawing.Circle then
            SafeDrawing.Circle.Visible = false
            SafeDrawing.Circle.Filled = false
            SafeDrawing.Circle.Transparency = 1
            SafeDrawing.Circle.Thickness = 1.5
            SafeDrawing.Circle.NumSides = 64
            SafeDrawing.Circle.Color = Color3.fromRGB(255, 255, 255)
            SafeDrawing.Circle.Position = getScreenCenter()
            SafeDrawing.Available = true
        end
    end
end)

local function safeNewDraw(drawType)
    if not SafeDrawing.TextLibrary then return nil end
    local obj = nil
    pcall(function()
        obj = Drawing.new(drawType)
    end)
    return obj
end

local function safeRemove(obj)
    pcall(function()
        if obj and obj.Remove then
            obj:Remove()
        end
    end)
end

local function safeSet(obj, prop, value)
    pcall(function()
        if obj then
            obj[prop] = value
        end
    end)
end

-- ============ ESP Drawing 对象池 ============
local espPool = {}
local espIndex = 0

local function getEspObject()
    espIndex = espIndex + 1
    if espPool[espIndex] then
        return espPool[espIndex]
    end

    local box = safeNewDraw("Square")
    local name = safeNewDraw("Text")
    local snapline = safeNewDraw("Line")

    if name then
        name.Center = true
        name.Outline = true
        name.Size = 13
    end

    local obj = {
        Box = box,
        Name = name,
        Snapline = snapline,
        Active = false,
    }
    espPool[espIndex] = obj
    return obj
end

local function resetEspPool()
    espIndex = 0
end

local function hideAllEsp()
    for _, obj in ipairs(espPool) do
        if obj.Box then safeSet(obj.Box, "Visible", false) end
        if obj.Name then safeSet(obj.Name, "Visible", false) end
        if obj.Snapline then safeSet(obj.Snapline, "Visible", false) end
    end
end

-- ============ 工具函数 ============
local function clamp(v, a, b)
    return math.max(a, math.min(b, v))
end

local function getCharacter(player)
    if not player or player == LocalPlayer then return nil end
    local character = player.Character
    if not character then
        local ok, char = pcall(function() return player.CharacterAdded:Wait() end)
        if not ok then return nil end
        character = char
    end
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    local head = character:FindFirstChild("Head")
    return character, root, head
end

local function isTeammate(player)
    if not player.Team then return false end
    if not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function isVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local target = part.Position
    local direction = target - origin
    if direction.Magnitude < 0.01 then return true end
    local ray = Ray.new(origin, direction.Unit * direction.Magnitude)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    if not hit then return true end
    local p = hit
    while p do
        if p == part or p == part.Parent then return true end
        p = p.Parent
    end
    return false
end

local function worldToScreen(worldPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- ============ 设置 ============
local Settings = {
    Aimbot = {
        Enabled = true,
        TeamCheck = true,
        WallCheck = true,
        FOV = 180,
        Smoothness = 0.35,
        HitPart = "Head",
    },
    ESP = {
        Enabled = true,
        TeamCheck = true,
        WallCheck = true,
        Boxes = true,
        Names = true,
        Snaplines = false,
        Health = true,
        MaxDistance = 1000,
    },
    Visual = {
        TeamCheck = true,
        TeamColor = Color3.fromRGB(80, 180, 255),
        EnemyColor = Color3.fromRGB(255, 60, 60),
        FOVColor = Color3.fromRGB(255, 255, 255),
    },
}

-- ============ 目标选择（中心点与 FOV 圈一致） ============
local function getClosestTarget()
    local closest = nil
    local closestDist = Settings.Aimbot.FOV
    local viewportCenter = getScreenCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.Aimbot.TeamCheck and isTeammate(player) then continue end
            local character, root, head = getCharacter(player)
            if not character or not root then continue end

            local targetPart = head or root
            local screenPos, onScreen = worldToScreen(targetPart.Position)
            if not onScreen then continue end

            local dist = (screenPos - viewportCenter).Magnitude
            if dist < closestDist then
                if Settings.Aimbot.WallCheck and not isVisible(targetPart) then continue end
                closestDist = dist
                closest = {Player = player, Part = targetPart}
            end
        end
    end

    return closest
end

-- ============ 自瞄逻辑（手机视角锁定） ============
addRenderConnection(RunService.RenderStepped:Connect(function()
    if destroyed then return end

    if Settings.Aimbot.Enabled then
        local target = getClosestTarget()
        if target and target.Part then
            local targetPos = target.Part.Position
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, targetPos),
                Settings.Aimbot.Smoothness
            )
        end
    end

    -- FOV 圆圈更新（严格使用统一中心点）
    pcall(function()
        if SafeDrawing.Available and SafeDrawing.Circle then
            local center = getScreenCenter()
            SafeDrawing.Circle.Visible = Settings.Aimbot.Enabled
            SafeDrawing.Circle.Position = center
            SafeDrawing.Circle.Radius = Settings.Aimbot.FOV
            SafeDrawing.Circle.Color = Settings.Visual.FOVColor
        end
    end)
end))

-- ============ ESP 绘制（Drawing API） ============
local function updateESP()
    if destroyed then return end
    if not SafeDrawing.TextLibrary then
        hideAllEsp()
        return
    end

    resetEspPool()

    if not Settings.ESP.Enabled then
        hideAllEsp()
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character, root, head = getCharacter(player)
        if not character or not root then continue end

        if Settings.ESP.WallCheck and not isVisible(head or root) then continue end

        local isTeam = isTeammate(player)
        local hidden = Settings.ESP.TeamCheck and isTeam
        local color = (Settings.Visual.TeamCheck and isTeam) and Settings.Visual.TeamColor or Settings.Visual.EnemyColor

        local headPos = head and (head.Position + Vector3.new(0, 0.3, 0)) or (root.Position + Vector3.new(0, 2, 0))
        local rootPos = root.Position
        local footPos = rootPos - Vector3.new(0, 3, 0)

        local headScreen, headOn = worldToScreen(headPos)
        local footScreen, footOn = worldToScreen(footPos)

        if not headOn or not footOn then continue end
        if headScreen.X < -100 or headScreen.X > Camera.ViewportSize.X + 100 or headScreen.Y < -100 or headScreen.Y > Camera.ViewportSize.Y + 100 then continue end
        if footScreen.X < -100 or footScreen.X > Camera.ViewportSize.X + 100 or footScreen.Y < -100 or footScreen.Y > Camera.ViewportSize.Y + 100 then continue end

        local height = math.abs(headScreen.Y - footScreen.Y)
        if height < 10 then continue end
        local width = height * 0.55
        local x = headScreen.X - width / 2
        local y = headScreen.Y

        local esp = getEspObject()
        esp.Active = true

        -- 方框
        if esp.Box then
            safeSet(esp.Box, "Visible", Settings.ESP.Boxes and not hidden)
            safeSet(esp.Box, "Color", color)
            safeSet(esp.Box, "Thickness", 1.5)
            safeSet(esp.Box, "Transparency", 1)
            safeSet(esp.Box, "Filled", false)
            safeSet(esp.Box, "Position", Vector2.new(x, y))
            safeSet(esp.Box, "Size", Vector2.new(width, height))
        end

        -- 名字
        if esp.Name then
            safeSet(esp.Name, "Visible", Settings.ESP.Names and not hidden)
            safeSet(esp.Name, "Text", player.Name)
            safeSet(esp.Name, "Color", color)
            safeSet(esp.Name, "Position", Vector2.new(headScreen.X, y - 16))
        end

        -- 连线（起点同样用统一中心点）
        if esp.Snapline then
            local center = getScreenCenter()
            safeSet(esp.Snapline, "Visible", Settings.ESP.Snaplines and not hidden)
            safeSet(esp.Snapline, "Color", color)
            safeSet(esp.Snapline, "Thickness", 1)
            safeSet(esp.Snapline, "Transparency", 0.7)
            safeSet(esp.Snapline, "From", Vector2.new(center.X, Camera.ViewportSize.Y))
            safeSet(esp.Snapline, "To", Vector2.new(headScreen.X, headScreen.Y))
        end
    end

    for i = espIndex + 1, #espPool do
        local obj = espPool[i]
        if obj then
            if obj.Box then safeSet(obj.Box, "Visible", false) end
            if obj.Name then safeSet(obj.Name, "Visible", false) end
            if obj.Snapline then safeSet(obj.Snapline, "Visible", false) end
        end
    end
end

addRenderConnection(RunService.RenderStepped:Connect(function()
    updateESP()
end))

-- ============ UI ============
local gui = Instance.new("ScreenGui")
gui.Name = "CobaltUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 560, 0, 380)
mainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25)),
})
gradient.Rotation = 90
gradient.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Cobalt - Aimbot & ESP"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -70, 0, 2)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

local function fullDestroy()
    if destroyed then return end
    destroyed = true

    disconnectAllRender()

    for _, obj in ipairs(espPool) do
        if obj.Box then safeRemove(obj.Box) end
        if obj.Name then safeRemove(obj.Name) end
        if obj.Snapline then safeRemove(obj.Snapline) end
    end
    espPool = {}

    if SafeDrawing.Circle then
        safeRemove(SafeDrawing.Circle)
        SafeDrawing.Circle = nil
    end
    SafeDrawing.Available = false

    pcall(function()
        if gui then
            gui:Destroy()
        end
    end)

    print("[Cobalt] Fully destroyed.")
end

closeBtn.MouseButton1Click:Connect(function()
    fullDestroy()
end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 120, 1, -36)
sidebar.Position = UDim2.new(0, 0, 0, 36)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local categories = {"Aimbot", "ESP", "Visual", "Settings"}
local buttons = {}

for i, name in ipairs(categories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 40)
    btn.Position = UDim2.new(0, 8, 0, 12 + (i - 1) * 48)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 60, 100) or Color3.fromRGB(35, 35, 55)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = sidebar

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    buttons[name] = btn
end

local panelFrame = Instance.new("Frame")
panelFrame.Size = UDim2.new(1, -136, 1, -52)
panelFrame.Position = UDim2.new(0, 128, 0, 44)
panelFrame.BackgroundTransparency = 1
panelFrame.Parent = mainFrame

-- ============ 滑条控件（支持触摸） ============
local function createSlider(parent, y, label, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 50)
    container.Position = UDim2.new(0, 10, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 0, 20)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.25, 0, 0, 20)
    valLabel.Position = UDim2.new(0.75, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 13
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = container

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    track.BorderSizePixel = 0
    track.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    local pct = (default - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(pct, -10, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local value = default

    local function update(input)
        local pos = input.Position
        local rel = pos.X - track.AbsolutePosition.X
        local pct2 = clamp(rel / track.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * pct2
        fill.Size = UDim2.new(pct2, 0, 1, 0)
        knob.Position = UDim2.new(pct2, -10, 0.5, -10)
        valLabel.Text = string.format("%.1f", value)
        if callback then callback(value) end
    end

    local function isPrimary(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end

    local function isMove(input)
        return input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
    end

    knob.InputBegan:Connect(function(input)
        if isPrimary(input) then dragging = true end
    end)

    knob.InputEnded:Connect(function(input)
        if isPrimary(input) then dragging = false end
    end)

    track.InputBegan:Connect(function(input)
        if isPrimary(input) then
            dragging = true
            update(input)
        end
    end)

    track.InputEnded:Connect(function(input)
        if isPrimary(input) then dragging = false end
    end)

    local sliderChangedConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and isMove(input) then
            update(input)
        end
    end)

    local sliderEndedConn = UserInputService.InputEnded:Connect(function(input)
        if isPrimary(input) then dragging = false end
    end)

    table.insert(renderConnections, sliderChangedConn)
    table.insert(renderConnections, sliderEndedConn)

    return {
        SetValue = function(v)
            value = v
            local pct2 = (v - min) / (max - min)
            fill.Size = UDim2.new(pct2, 0, 1, 0)
            knob.Position = UDim2.new(pct2, -10, 0.5, -10)
            valLabel.Text = string.format("%.1f", value)
        end,
        GetValue = function() return value end,
    }
end

-- ============ 开关控件 ============
local function createToggle(parent, y, label, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.Position = UDim2.new(0, 10, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 44, 0, 22)
    toggle.Position = UDim2.new(1, -50, 0.5, -11)
    toggle.BackgroundColor3 = default and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(80, 80, 100)
    toggle.BorderSizePixel = 0
    toggle.Parent = container

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggle

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = default
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggle

    btn.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(80, 80, 100)
        knob.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        if callback then callback(state) end
    end)

    return {
        SetState = function(s)
            state = s
            toggle.BackgroundColor3 = state and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(80, 80, 100)
            knob.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        end,
        GetState = function() return state end,
    }
end

-- ============ 面板内容 ============
local panels = {}
local currentPanel = nil

local function showPanel(name)
    if currentPanel then
        currentPanel.Visible = false
    end
    if panels[name] then
        panels[name].Visible = true
        currentPanel = panels[name]
    end
end

panels.Aimbot = Instance.new("ScrollingFrame")
panels.Aimbot.Size = UDim2.new(1, 0, 1, 0)
panels.Aimbot.BackgroundTransparency = 1
panels.Aimbot.ScrollBarThickness = 4
panels.Aimbot.CanvasSize = UDim2.new(0, 0, 0, 320)
panels.Aimbot.Visible = true
panels.Aimbot.Parent = panelFrame

createToggle(panels.Aimbot, 8, "Enable Aimbot", Settings.Aimbot.Enabled, function(v) Settings.Aimbot.Enabled = v end)
createToggle(panels.Aimbot, 52, "Team Check", Settings.Aimbot.TeamCheck, function(v) Settings.Aimbot.TeamCheck = v end)
createToggle(panels.Aimbot, 96, "Wall Check (Cover)", Settings.Aimbot.WallCheck, function(v) Settings.Aimbot.WallCheck = v end)
createSlider(panels.Aimbot, 144, "FOV Radius", 10, 500, Settings.Aimbot.FOV, function(v) Settings.Aimbot.FOV = v end)
createSlider(panels.Aimbot, 204, "Smoothness", 0.01, 1, Settings.Aimbot.Smoothness, function(v) Settings.Aimbot.Smoothness = v end)

panels.ESP = Instance.new("ScrollingFrame")
panels.ESP.Size = UDim2.new(1, 0, 1, 0)
panels.ESP.BackgroundTransparency = 1
panels.ESP.ScrollBarThickness = 4
panels.ESP.CanvasSize = UDim2.new(0, 0, 0, 360)
panels.ESP.Visible = false
panels.ESP.Parent = panelFrame

createToggle(panels.ESP, 8, "Enable ESP", Settings.ESP.Enabled, function(v) Settings.ESP.Enabled = v end)
createToggle(panels.ESP, 52, "Team Check", Settings.ESP.TeamCheck, function(v) Settings.ESP.TeamCheck = v end)
createToggle(panels.ESP, 96, "Wall Check (Cover)", Settings.ESP.WallCheck, function(v) Settings.ESP.WallCheck = v end)
createToggle(panels.ESP, 140, "Box ESP", Settings.ESP.Boxes, function(v) Settings.ESP.Boxes = v end)
createToggle(panels.ESP, 184, "Name ESP", Settings.ESP.Names, function(v) Settings.ESP.Names = v end)
createToggle(panels.ESP, 228, "Snaplines", Settings.ESP.Snaplines, function(v) Settings.ESP.Snaplines = v end)
createSlider(panels.ESP, 276, "Max Distance", 100, 3000, Settings.ESP.MaxDistance, function(v) Settings.ESP.MaxDistance = v end)

panels.Visual = Instance.new("ScrollingFrame")
panels.Visual.Size = UDim2.new(1, 0, 1, 0)
panels.Visual.BackgroundTransparency = 1
panels.Visual.ScrollBarThickness = 4
panels.Visual.CanvasSize = UDim2.new(0, 0, 0, 160)
panels.Visual.Visible = false
panels.Visual.Parent = panelFrame

local fovColorLabel = Instance.new("TextLabel")
fovColorLabel.Size = UDim2.new(0.5, 0, 0, 30)
fovColorLabel.Position = UDim2.new(0, 10, 0, 10)
fovColorLabel.BackgroundTransparency = 1
fovColorLabel.Text = "FOV Circle Color"
fovColorLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
fovColorLabel.Font = Enum.Font.Gotham
fovColorLabel.TextSize = 13
fovColorLabel.TextXAlignment = Enum.TextXAlignment.Left
fovColorLabel.Parent = panels.Visual

local colorPresets = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(255, 60, 60),
    Color3.fromRGB(60, 255, 60),
    Color3.fromRGB(60, 150, 255),
    Color3.fromRGB(255, 200, 50),
}
local colorIdx = 1

local colorPreview = Instance.new("TextButton")
colorPreview.Size = UDim2.new(0, 40, 0, 24)
colorPreview.Position = UDim2.new(0, 150, 0, 10)
colorPreview.BackgroundColor3 = colorPresets[1]
colorPreview.Text = ""
colorPreview.Parent = panels.Visual

local colorPreviewCorner = Instance.new("UICorner")
colorPreviewCorner.CornerRadius = UDim.new(0, 4)
colorPreviewCorner.Parent = colorPreview

colorPreview.MouseButton1Click:Connect(function()
    colorIdx = colorIdx % #colorPresets + 1
    Settings.Visual.FOVColor = colorPresets[colorIdx]
    colorPreview.BackgroundColor3 = colorPresets[colorIdx]
end)

createToggle(panels.Visual, 52, "Team Check (Color)", Settings.Visual.TeamCheck, function(v) Settings.Visual.TeamCheck = v end)

panels.Settings = Instance.new("ScrollingFrame")
panels.Settings.Size = UDim2.new(1, 0, 1, 0)
panels.Settings.BackgroundTransparency = 1
panels.Settings.ScrollBarThickness = 4
panels.Settings.CanvasSize = UDim2.new(0, 0, 0, 200)
panels.Settings.Visible = false
panels.Settings.Parent = panelFrame

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -20, 0, 180)
hint.Position = UDim2.new(0, 10, 0, 10)
hint.BackgroundTransparency = 1
hint.Text = "Aimbot: Auto-lock when enabled (FOV based)\nFOV Circle: White (default), screen-centered\n\nDrag sliders to adjust values.\nClick color preview to cycle colors.\n\nTouch supported on all UI elements.\n\n[X] button fully destroys the script."
hint.TextColor3 = Color3.fromRGB(160, 160, 180)
hint.Font = Enum.Font.Gotham
hint.TextSize = 12
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.TextYAlignment = Enum.TextYAlignment.Top
hint.TextWrapped = true
hint.Parent = panels.Settings

for _, name in ipairs(categories) do
    buttons[name].MouseButton1Click:Connect(function()
        for _, b in pairs(buttons) do
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        end
        buttons[name].BackgroundColor3 = Color3.fromRGB(60, 60, 100)
        showPanel(name)
    end)
end

-- ============ 悬浮窗 ============
local floatingBtn = Instance.new("TextButton")
floatingBtn.Size = UDim2.new(0, 56, 0, 56)
floatingBtn.Position = UDim2.new(1, -70, 1, -70)
floatingBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
floatingBtn.Text = "Co"
floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingBtn.Font = Enum.Font.GothamBold
floatingBtn.TextSize = 18
floatingBtn.Visible = false
floatingBtn.Parent = gui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = floatingBtn

local minimized = false

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    mainFrame.Visible = not minimized
    floatingBtn.Visible = minimized
end)

-- ============ 悬浮窗拖拽 ============
local draggingFloat = false
local floatStart = nil
local startPosFloat = nil
local floatMoved = false

floatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFloat = true
        floatMoved = false
        floatStart = input.Position
        startPosFloat = floatingBtn.Position
    end
end)

floatingBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFloat = false
        if not floatMoved then
            minimized = false
            mainFrame.Visible = true
            floatingBtn.Visible = false
        end
    end
end)

local floatChangedConn = UserInputService.InputChanged:Connect(function(input)
    if draggingFloat and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - floatStart
        if math.abs(delta.X) > 2 or math.abs(delta.Y) > 2 then
            floatMoved = true
        end
        floatingBtn.Position = UDim2.new(
            startPosFloat.X.Scale,
            startPosFloat.X.Offset + delta.X,
            startPosFloat.Y.Scale,
            startPosFloat.Y.Offset + delta.Y
        )
    end
end)
table.insert(renderConnections, floatChangedConn)

-- ============ 标题栏拖拽 ============
local draggingMain = false
local dragStartMain = nil
local startPosMain = nil

local function isPrimary(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

titleBar.InputBegan:Connect(function(input)
    if isPrimary(input) then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if isPrimary(input) then
        draggingMain = false
    end
end)

local mainChangedConn = UserInputService.InputChanged:Connect(function(input)
    if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartMain
        mainFrame.Position = UDim2.new(
            startPosMain.X.Scale,
            startPosMain.X.Offset + delta.X,
            startPosMain.Y.Scale,
            startPosMain.Y.Offset + delta.Y
        )
    end
end)
table.insert(renderConnections, mainChangedConn)

local mainEndedConn = UserInputService.InputEnded:Connect(function(input)
    if isPrimary(input) then
        draggingMain = false
        draggingFloat = false
    end
end)
table.insert(renderConnections, mainEndedConn)

-- ============ 清理 ============
LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer.Parent then
        fullDestroy()
    end
end)

print("[Cobalt] Loaded successfully! (Mobile Compatible)")
