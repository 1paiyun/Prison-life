local _0x025F = game:GetService("RunService")
local _0x5C2F = game:GetService("UserInputService")
local _0xF9FF = game:GetService("Players")
local _0xE973 = game:GetService("Workspace")
local _0x315F = game:GetService("CoreGui")
local _0x287F = _0xF9FF.LocalPlayer
local _0x9708 = _0xE973.CurrentCameralocal _0x4AAA = {}
local _0x247E = false
local function _0x2491(conn)
table.insert(_0x4AAA, conn)
return conn
end
local function _0x6955()
for _, conn in ipairs(_0x4AAA) do
pcall(function()
if conn and conn.Disconnect then
conn:Disconnect()
end
end)
end
_0x4AAA = {}
endlocal function _0x9CF8()
local _0x358E = _0x9708.ViewportSize
return Vector2.new(_0x358E.X / 2, _0x358E.Y / 2)
endlocal _0x19CD = {}
_0x19CD.Circle = nil
_0x19CD.Available = false
_0x19CD.TextLibrary = false
pcall(function()
if Drawing and Drawing.new then
_0x19CD.TextLibrary = true
_0x19CD.Circle = Drawing.new("Circle")
if _0x19CD.Circle then
_0x19CD.Circle.Visible = false
_0x19CD.Circle.Filled = false
_0x19CD.Circle.Transparency = 1
_0x19CD.Circle.Thickness = 1.5
_0x19CD.Circle.NumSides = 64
_0x19CD.Circle.Color = Color3.fromRGB(255, 255, 255)
_0x19CD.Circle.Position = _0x9CF8()
_0x19CD.Available = true
end
end
end)
local function _0xA6CF(drawType)
if not _0x19CD.TextLibrary then return nil end
local _0x7FB5 = nil
pcall(function()
_0x7FB5 = Drawing.new(drawType)
end)
return _0x7FB5
end
local function _0xF3CA(_0x7FB5)
pcall(function()
if _0x7FB5 and _0x7FB5.Remove then
_0x7FB5:Remove()
end
end)
end
local function _0x36E0(_0x7FB5, prop, _0xA288)
pcall(function()
if _0x7FB5 then
_0x7FB5[prop] = _0xA288
end
end)
endlocal _0x0AFA = {}
local _0xE2FD = 0
local function _0x8545()
_0xE2FD = _0xE2FD + 1
if _0x0AFA[_0xE2FD] then
return _0x0AFA[_0xE2FD]
end
local _0x6C2F = _0xA6CF("Square")
local _0xCA76 = _0xA6CF("Text")
local _0x36EE = _0xA6CF("Line")
if _0xCA76 then
_0xCA76.Center = true
_0xCA76.Outline = true
_0xCA76.Size = 13
end
local _0x7FB5 = {
Box = _0x6C2F,
Name = _0xCA76,
Snapline = _0x36EE,
Active = false,
}
_0x0AFA[_0xE2FD] = _0x7FB5
return _0x7FB5
end
local function _0x2CC8()
_0xE2FD = 0
end
local function _0x80C9()
for _, _0x7FB5 in ipairs(_0x0AFA) do
if _0x7FB5.Box then _0x36E0(_0x7FB5.Box,"Visible", false) end
if _0x7FB5.Name then _0x36E0(_0x7FB5.Name,"Visible", false) end
if _0x7FB5.Snapline then _0x36E0(_0x7FB5.Snapline,"Visible", false) end
end
endlocal function _0x3302(v, a, b)
return math.max(a, math.min(b, v))
end
local function _0x6EA5(player)
if not player or player == _0x287F then return nil end
local _0x1C30 = player.Character
if not _0x1C30 then
local _0x29D6, _0xEA57 = pcall(function() return player.CharacterAdded:Wait() end)
if not _0x29D6 then return nil end
_0x1C30 = _0xEA57
end
if not _0x1C30 then return nil end
local _0xC19E = _0x1C30:FindFirstChild("HumanoidRootPart") or _0x1C30:FindFirstChild("Torso")
local _0x0BE6 = _0x1C30:FindFirstChild("Head")
return _0x1C30, _0xC19E, _0x0BE6
end
local function _0x4C4C(player)
if not player.Team then return false end
if not _0x287F.Team then return false end
return player.Team == _0x287F.Team
end
local function _0xB4A2(part)
if not part then return false end
local _0x07D5 = _0x9708.CFrame.Position
local _0xE0AD = part.Position
local _0x1198 = _0xE0AD - _0x07D5
if _0x1198.Magnitude < 0.01 then return true end
local _0x8098 = Ray.new(_0x07D5, _0x1198.Unit * _0x1198.Magnitude)
local _0x94AE = _0xE973:FindPartOnRayWithIgnoreList(_0x8098, {_0x287F.Character, _0x9708})
if not _0x94AE then return true end
local _0xD74D = _0x94AE
while _0xD74D do
if _0xD74D == part or _0xD74D == part.Parent then return true end
_0xD74D = _0xD74D.Parent
end
return false
end
local function _0x0135(worldPos)
local _0x7094, _0xF180 = _0x9708:WorldToViewportPoint(worldPos)
return Vector2.new(_0x7094.X, _0x7094.Y), _0xF180, _0x7094.Z
endlocal _0x928F = {
Aimbot = {
Enabled = true,
TeamCheck = true,
WallCheck = true,
FOV = 180,
Smoothness = 0.35,
HitPart ="Head",
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
}local function _0x2869()
local _0x8116 = nil
local _0x41A2 = _0x928F.Aimbot.FOV
local _0x19AB = _0x9CF8()
for _, player in ipairs(_0xF9FF:GetPlayers()) do
if player ~= _0x287F then
if _0x928F.Aimbot.TeamCheck and _0x4C4C(player) then continue end
local _0x1C30, _0xC19E, _0x0BE6 = _0x6EA5(player)
if not _0x1C30 or not _0xC19E then continue end
local _0x1051 = _0x0BE6 or _0xC19E
local _0x7094, _0xF180 = _0x0135(_0x1051.Position)
if not _0xF180 then continue end
local _0x7276 = (_0x7094 - _0x19AB).Magnitude
if _0x7276 < _0x41A2 then
if _0x928F.Aimbot.WallCheck and not _0xB4A2(_0x1051) then continue end
_0x41A2 = _0x7276
_0x8116 = {Player = player, Part = _0x1051}
end
end
end
return _0x8116
end_0x2491(_0x025F.RenderStepped:Connect(function()
if _0x247E then return end
if _0x928F.Aimbot.Enabled then
local _0xE0AD = _0x2869()
if _0xE0AD and _0xE0AD.Part then
local _0xFD69 = _0xE0AD.Part.Position
_0x9708.CFrame = _0x9708.CFrame:Lerp(
CFrame.new(_0x9708.CFrame.Position, _0xFD69),
_0x928F.Aimbot.Smoothness
)
end
endpcall(function()
if _0x19CD.Available and _0x19CD.Circle then
local _0x7881 = _0x9CF8()
_0x19CD.Circle.Visible = _0x928F.Aimbot.Enabled
_0x19CD.Circle.Position = _0x7881
_0x19CD.Circle.Radius = _0x928F.Aimbot.FOV
_0x19CD.Circle.Color = _0x928F.Visual.FOVColor
end
end)
end))local function _0x400E()
if _0x247E then return end
if not _0x19CD.TextLibrary then
_0x80C9()
return
end
_0x2CC8()
if not _0x928F.ESP.Enabled then
_0x80C9()
return
end
for _, player in ipairs(_0xF9FF:GetPlayers()) do
if player == _0x287F then continue end
local _0x1C30, _0xC19E, _0x0BE6 = _0x6EA5(player)
if not _0x1C30 or not _0xC19E then continue end
if _0x928F.ESP.WallCheck and not _0xB4A2(_0x0BE6 or _0xC19E) then continue end
local _0x9999 = _0x4C4C(player)
local _0xFEA4 = _0x928F.ESP.TeamCheck and _0x9999
local _0xFCA8 = (_0x928F.Visual.TeamCheck and _0x9999) and _0x928F.Visual.TeamColor or _0x928F.Visual.EnemyColor
local _0x3F45 = _0x0BE6 and (_0x0BE6.Position + Vector3.new(0, 0.3, 0)) or (_0xC19E.Position + Vector3.new(0, 2, 0))
local _0xF042 = _0xC19E.Position
local _0xFDA0 = _0xF042 - Vector3.new(0, 3, 0)
local _0x83CC, _0x7BB2 = _0x0135(_0x3F45)
local _0xBEE0, _0x4254 = _0x0135(_0xFDA0)
if not _0x7BB2 or not _0x4254 then continue end
if _0x83CC.X < -100 or _0x83CC.X > _0x9708.ViewportSize.X + 100 or _0x83CC.Y < -100 or _0x83CC.Y > _0x9708.ViewportSize.Y + 100 then continue end
if _0xBEE0.X < -100 or _0xBEE0.X > _0x9708.ViewportSize.X + 100 or _0xBEE0.Y < -100 or _0xBEE0.Y > _0x9708.ViewportSize.Y + 100 then continue end
local _0x91E6 = math.abs(_0x83CC.Y - _0xBEE0.Y)
if _0x91E6 < 10 then continue end
local _0xDCD4 = _0x91E6 * 0.55
local _0x5A8D = _0x83CC.X - _0xDCD4 / 2
local _0x3BDA = _0x83CC.Y
local _0x4D13 = _0x8545()
_0x4D13.Active = trueif _0x4D13.Box then
_0x36E0(_0x4D13.Box,"Visible", _0x928F.ESP.Boxes and not _0xFEA4)
_0x36E0(_0x4D13.Box,"Color", _0xFCA8)
_0x36E0(_0x4D13.Box,"Thickness", 1.5)
_0x36E0(_0x4D13.Box,"Transparency", 1)
_0x36E0(_0x4D13.Box,"Filled", false)
_0x36E0(_0x4D13.Box,"Position", Vector2.new(_0x5A8D, _0x3BDA))
_0x36E0(_0x4D13.Box,"Size", Vector2.new(_0xDCD4, _0x91E6))
endif _0x4D13.Name then
_0x36E0(_0x4D13.Name,"Visible", _0x928F.ESP.Names and not _0xFEA4)
_0x36E0(_0x4D13.Name,"Text", player.Name)
_0x36E0(_0x4D13.Name,"Color", _0xFCA8)
_0x36E0(_0x4D13.Name,"Position", Vector2.new(_0x83CC.X, _0x3BDA - 16))
endif _0x4D13.Snapline then
local _0x7881 = _0x9CF8()
_0x36E0(_0x4D13.Snapline,"Visible", _0x928F.ESP.Snaplines and not _0xFEA4)
_0x36E0(_0x4D13.Snapline,"Color", _0xFCA8)
_0x36E0(_0x4D13.Snapline,"Thickness", 1)
_0x36E0(_0x4D13.Snapline,"Transparency", 0.7)
_0x36E0(_0x4D13.Snapline,"From", Vector2.new(_0x7881.X, _0x9708.ViewportSize.Y))
_0x36E0(_0x4D13.Snapline,"To", Vector2.new(_0x83CC.X, _0x83CC.Y))
end
end
for i = _0xE2FD + 1, #_0x0AFA do
local _0x7FB5 = _0x0AFA[i]
if _0x7FB5 then
if _0x7FB5.Box then _0x36E0(_0x7FB5.Box,"Visible", false) end
if _0x7FB5.Name then _0x36E0(_0x7FB5.Name,"Visible", false) end
if _0x7FB5.Snapline then _0x36E0(_0x7FB5.Snapline,"Visible", false) end
end
end
end
_0x2491(_0x025F.RenderStepped:Connect(function()
_0x400E()
end))local _0x43C3 = Instance.new("ScreenGui")
_0x43C3.Name ="CobaltUI"_0x43C3.ResetOnSpawn = false
_0x43C3.IgnoreGuiInset = true
_0x43C3.Parent = _0x315F
local _0xFEBD = Instance.new("Frame")
_0xFEBD.Size = UDim2.new(0, 560, 0, 380)
_0xFEBD.Position = UDim2.new(0.5, -280, 0.5, -190)
_0xFEBD.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
_0xFEBD.BorderSizePixel = 0
_0xFEBD.Parent = _0x43C3
local _0xB220 = Instance.new("UIGradient")
_0xB220.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25)),
})
_0xB220.Rotation = 90
_0xB220.Parent = _0xFEBD
local _0xBA66 = Instance.new("UICorner")
_0xBA66.CornerRadius = UDim.new(0, 8)
_0xBA66.Parent = _0xFEBD
local _0x71F0 = Instance.new("Frame")
_0x71F0.Size = UDim2.new(1, 0, 0, 36)
_0x71F0.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
_0x71F0.BorderSizePixel = 0
_0x71F0.Parent = _0xFEBD
local _0x0E0E = Instance.new("UICorner")
_0x0E0E.CornerRadius = UDim.new(0, 8)
_0x0E0E.Parent = _0x71F0
local _0x6F99 = Instance.new("TextLabel")
_0x6F99.Size = UDim2.new(1, -80, 1, 0)
_0x6F99.Position = UDim2.new(0, 12, 0, 0)
_0x6F99.BackgroundTransparency = 1
_0x6F99.Text ="Cobalt - Aimbot & ESP"_0x6F99.TextColor3 = Color3.fromRGB(255, 255, 255)
_0x6F99.Font = Enum.Font.GothamBold
_0x6F99.TextSize = 15
_0x6F99.TextXAlignment = Enum.TextXAlignment.Left
_0x6F99.Parent = _0x71F0
local _0x8598 = Instance.new("TextButton")
_0x8598.Size = UDim2.new(0, 32, 0, 32)
_0x8598.Position = UDim2.new(1, -70, 0, 2)
_0x8598.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
_0x8598.Text ="-"_0x8598.TextColor3 = Color3.fromRGB(255, 255, 255)
_0x8598.Font = Enum.Font.GothamBold
_0x8598.TextSize = 20
_0x8598.Parent = _0x71F0
local _0xCE18 = Instance.new("UICorner")
_0xCE18.CornerRadius = UDim.new(0, 6)
_0xCE18.Parent = _0x8598
local _0xADAD = Instance.new("TextButton")
_0xADAD.Size = UDim2.new(0, 32, 0, 32)
_0xADAD.Position = UDim2.new(1, -36, 0, 2)
_0xADAD.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
_0xADAD.Text ="X"_0xADAD.TextColor3 = Color3.fromRGB(255, 255, 255)
_0xADAD.Font = Enum.Font.GothamBold
_0xADAD.TextSize = 16
_0xADAD.Parent = _0x71F0
local _0xCC34 = Instance.new("UICorner")
_0xCC34.CornerRadius = UDim.new(0, 6)
_0xCC34.Parent = _0xADAD
local function _0x98F3()
if _0x247E then return end
_0x247E = true
_0x6955()
for _, _0x7FB5 in ipairs(_0x0AFA) do
if _0x7FB5.Box then _0xF3CA(_0x7FB5.Box) end
if _0x7FB5.Name then _0xF3CA(_0x7FB5.Name) end
if _0x7FB5.Snapline then _0xF3CA(_0x7FB5.Snapline) end
end
_0x0AFA = {}
if _0x19CD.Circle then
_0xF3CA(_0x19CD.Circle)
_0x19CD.Circle = nil
end
_0x19CD.Available = false
pcall(function()
if _0x43C3 then
_0x43C3:Destroy()
end
end)
print("[Cobalt] Fully destroyed.")
end
_0xADAD.MouseButton1Click:Connect(function()
_0x98F3()
end)
local _0xFF0A = Instance.new("Frame")
_0xFF0A.Size = UDim2.new(0, 120, 1, -36)
_0xFF0A.Position = UDim2.new(0, 0, 0, 36)
_0xFF0A.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
_0xFF0A.BorderSizePixel = 0
_0xFF0A.Parent = _0xFEBD
local _0xAA69 = {"Aimbot","ESP","Visual","Settings"}
local _0xE0B4 = {}
for i, _0xCA76 in ipairs(_0xAA69) do
local _0x8756 = Instance.new("TextButton")
_0x8756.Size = UDim2.new(1, -16, 0, 40)
_0x8756.Position = UDim2.new(0, 8, 0, 12 + (i - 1) * 48)
_0x8756.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 60, 100) or Color3.fromRGB(35, 35, 55)
_0x8756.Text = _0xCA76
_0x8756.TextColor3 = Color3.fromRGB(255, 255, 255)
_0x8756.Font = Enum.Font.Gotham
_0x8756.TextSize = 14
_0x8756.Parent = _0xFF0A
local _0x7DD6 = Instance.new("UICorner")
_0x7DD6.CornerRadius = UDim.new(0, 6)
_0x7DD6.Parent = _0x8756
_0xE0B4[_0xCA76] = _0x8756
end
local _0x5F6D = Instance.new("Frame")
_0x5F6D.Size = UDim2.new(1, -136, 1, -52)
_0x5F6D.Position = UDim2.new(0, 128, 0, 44)
_0x5F6D.BackgroundTransparency = 1
_0x5F6D.Parent = _0xFEBDlocal function _0x60C6(parent, _0x3BDA, label, min, max, default, callback)
local _0xD845 = Instance.new("Frame")
_0xD845.Size = UDim2.new(1, -20, 0, 50)
_0xD845.Position = UDim2.new(0, 10, 0, _0x3BDA)
_0xD845.BackgroundTransparency = 1
_0xD845.Parent = parent
local _0x77DB = Instance.new("TextLabel")
_0x77DB.Size = UDim2.new(0.4, 0, 0, 20)
_0x77DB.Position = UDim2.new(0, 0, 0, 0)
_0x77DB.BackgroundTransparency = 1
_0x77DB.Text = label
_0x77DB.TextColor3 = Color3.fromRGB(200, 200, 220)
_0x77DB.Font = Enum.Font.Gotham
_0x77DB.TextSize = 13
_0x77DB.TextXAlignment = Enum.TextXAlignment.Left
_0x77DB.Parent = _0xD845
local _0x3362 = Instance.new("TextLabel")
_0x3362.Size = UDim2.new(0.25, 0, 0, 20)
_0x3362.Position = UDim2.new(0.75, 0, 0, 0)
_0x3362.BackgroundTransparency = 1
_0x3362.Text = tostring(default)
_0x3362.TextColor3 = Color3.fromRGB(255, 255, 255)
_0x3362.Font = Enum.Font.GothamBold
_0x3362.TextSize = 13
_0x3362.TextXAlignment = Enum.TextXAlignment.Right
_0x3362.Parent = _0xD845
local _0x4A3B = Instance.new("Frame")
_0x4A3B.Size = UDim2.new(1, 0, 0, 6)
_0x4A3B.Position = UDim2.new(0, 0, 0, 28)
_0x4A3B.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
_0x4A3B.BorderSizePixel = 0
_0x4A3B.Parent = _0xD845
local _0x9AF7 = Instance.new("UICorner")
_0x9AF7.CornerRadius = UDim.new(0, 3)
_0x9AF7.Parent = _0x4A3B
local _0x9F3C = Instance.new("Frame")
local _0x3B9B = (default - min) / (max - min)
_0x9F3C.Size = UDim2.new(_0x3B9B, 0, 1, 0)
_0x9F3C.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
_0x9F3C.BorderSizePixel = 0
_0x9F3C.Parent = _0x4A3B
local _0x099C = Instance.new("UICorner")
_0x099C.CornerRadius = UDim.new(0, 3)
_0x099C.Parent = _0x9F3C
local _0xB6EC = Instance.new("Frame")
_0xB6EC.Size = UDim2.new(0, 20, 0, 20)
_0xB6EC.Position = UDim2.new(_0x3B9B, -10, 0.5, -10)
_0xB6EC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_0xB6EC.BorderSizePixel = 0
_0xB6EC.Parent = _0x4A3B
local _0x9985 = Instance.new("UICorner")
_0x9985.CornerRadius = UDim.new(1, 0)
_0x9985.Parent = _0xB6EC
local _0xD4B7 = false
local _0xA288 = default
local function _0xA61F(input)
local _0xC1A5 = input.Position
local _0xA1DA = _0xC1A5.X - _0x4A3B.AbsolutePosition.X
local _0x91B6 = _0x3302(_0xA1DA / _0x4A3B.AbsoluteSize.X, 0, 1)
_0xA288 = min + (max - min) * _0x91B6
_0x9F3C.Size = UDim2.new(_0x91B6, 0, 1, 0)
_0xB6EC.Position = UDim2.new(_0x91B6, -10, 0.5, -10)
_0x3362.Text = string.format("%.1f", _0xA288)
if callback then callback(_0xA288) end
end
local function _0x9431(input)
return input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
end
local function _0xAF23(input)
return input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
end
_0xB6EC.InputBegan:Connect(function(input)
if _0x9431(input) then _0xD4B7 = true end
end)
_0xB6EC.InputEnded:Connect(function(input)
if _0x9431(input) then _0xD4B7 = false end
end)
_0x4A3B.InputBegan:Connect(function(input)
if _0x9431(input) then
_0xD4B7 = true
_0xA61F(input)
end
end)
_0x4A3B.InputEnded:Connect(function(input)
if _0x9431(input) then _0xD4B7 = false end
end)
local _0xA591 = _0x5C2F.InputChanged:Connect(function(input)
if _0xD4B7 and _0xAF23(input) then
_0xA61F(input)
end
end)
local _0x52D6 = _0x5C2F.InputEnded:Connect(function(input)
if _0x9431(input) then _0xD4B7 = false end
end)
table.insert(_0x4AAA, _0xA591)
table.insert(_0x4AAA, _0x52D6)
return {
SetValue = function(v)
_0xA288 = v
local _0x91B6 = (v - min) / (max - min)
_0x9F3C.Size = UDim2.new(_0x91B6, 0, 1, 0)
_0xB6EC.Position = UDim2.new(_0x91B6, -10, 0.5, -10)
_0x3362.Text = string.format("%.1f", _0xA288)
end,
GetValue = function() return _0xA288 end,
}
endlocal function _0x4E7B(parent, _0x3BDA, label, default, callback)
local _0xD845 = Instance.new("Frame")
_0xD845.Size = UDim2.new(1, -20, 0, 36)
_0xD845.Position = UDim2.new(0, 10, 0, _0x3BDA)
_0xD845.BackgroundTransparency = 1
_0xD845.Parent = parent
local _0x77DB = Instance.new("TextLabel")
_0x77DB.Size = UDim2.new(0.7, 0, 1, 0)
_0x77DB.Position = UDim2.new(0, 0, 0, 0)
_0x77DB.BackgroundTransparency = 1
_0x77DB.Text = label
_0x77DB.TextColor3 = Color3.fromRGB(200, 200, 220)
_0x77DB.Font = Enum.Font.Gotham
_0x77DB.TextSize = 13
_0x77DB.TextXAlignment = Enum.TextXAlignment.Left
_0x77DB.Parent = _0xD845
local _0x7D03 = Instance.new("Frame")
_0x7D03.Size = UDim2.new(0, 44, 0, 22)
_0x7D03.Position = UDim2.new(1, -50, 0.5, -11)
_0x7D03.BackgroundColor3 = default and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(80, 80, 100)
_0x7D03.BorderSizePixel = 0
_0x7D03.Parent = _0xD845
local _0xBDD5 = Instance.new("UICorner")
_0xBDD5.CornerRadius = UDim.new(1, 0)
_0xBDD5.Parent = _0x7D03
local _0xB6EC = Instance.new("Frame")
_0xB6EC.Size = UDim2.new(0, 18, 0, 18)
_0xB6EC.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
_0xB6EC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_0xB6EC.BorderSizePixel = 0
_0xB6EC.Parent = _0x7D03
local _0x9985 = Instance.new("UICorner")
_0x9985.CornerRadius = UDim.new(1, 0)
_0x9985.Parent = _0xB6EC
local _0xC9AD = default
local _0x8756 = Instance.new("TextButton")
_0x8756.Size = UDim2.new(1, 0, 1, 0)
_0x8756.BackgroundTransparency = 1
_0x8756.Text =""_0x8756.Parent = _0x7D03
_0x8756.MouseButton1Click:Connect(function()
_0xC9AD = not _0xC9AD
_0x7D03.BackgroundColor3 = _0xC9AD and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(80, 80, 100)
_0xB6EC.Position = _0xC9AD and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
if callback then callback(_0xC9AD) end
end)
return {
SetState = function(s)
_0xC9AD = s
_0x7D03.BackgroundColor3 = _0xC9AD and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(80, 80, 100)
_0xB6EC.Position = _0xC9AD and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
end,
GetState = function() return _0xC9AD end,
}
endlocal _0x31E7 = {}
local _0x14D9 = nil
local function _0xB78D(_0xCA76)
if _0x14D9 then
_0x14D9.Visible = false
end
if _0x31E7[_0xCA76] then
_0x31E7[_0xCA76].Visible = true
_0x14D9 = _0x31E7[_0xCA76]
end
end
_0x31E7.Aimbot = Instance.new("ScrollingFrame")
_0x31E7.Aimbot.Size = UDim2.new(1, 0, 1, 0)
_0x31E7.Aimbot.BackgroundTransparency = 1
_0x31E7.Aimbot.ScrollBarThickness = 4
_0x31E7.Aimbot.CanvasSize = UDim2.new(0, 0, 0, 320)
_0x31E7.Aimbot.Visible = true
_0x31E7.Aimbot.Parent = _0x5F6D
_0x4E7B(_0x31E7.Aimbot, 8,"Enable Aimbot", _0x928F.Aimbot.Enabled, function(v) _0x928F.Aimbot.Enabled = v end)
_0x4E7B(_0x31E7.Aimbot, 52,"Team Check", _0x928F.Aimbot.TeamCheck, function(v) _0x928F.Aimbot.TeamCheck = v end)
_0x4E7B(_0x31E7.Aimbot, 96,"Wall Check (Cover)", _0x928F.Aimbot.WallCheck, function(v) _0x928F.Aimbot.WallCheck = v end)
_0x60C6(_0x31E7.Aimbot, 144,"FOV Radius", 10, 500, _0x928F.Aimbot.FOV, function(v) _0x928F.Aimbot.FOV = v end)
_0x60C6(_0x31E7.Aimbot, 204,"Smoothness", 0.01, 1, _0x928F.Aimbot.Smoothness, function(v) _0x928F.Aimbot.Smoothness = v end)
_0x31E7.ESP = Instance.new("ScrollingFrame")
_0x31E7.ESP.Size = UDim2.new(1, 0, 1, 0)
_0x31E7.ESP.BackgroundTransparency = 1
_0x31E7.ESP.ScrollBarThickness = 4
_0x31E7.ESP.CanvasSize = UDim2.new(0, 0, 0, 360)
_0x31E7.ESP.Visible = false
_0x31E7.ESP.Parent = _0x5F6D
_0x4E7B(_0x31E7.ESP, 8,"Enable ESP", _0x928F.ESP.Enabled, function(v) _0x928F.ESP.Enabled = v end)
_0x4E7B(_0x31E7.ESP, 52,"Team Check", _0x928F.ESP.TeamCheck, function(v) _0x928F.ESP.TeamCheck = v end)
_0x4E7B(_0x31E7.ESP, 96,"Wall Check (Cover)", _0x928F.ESP.WallCheck, function(v) _0x928F.ESP.WallCheck = v end)
_0x4E7B(_0x31E7.ESP, 140,"Box ESP", _0x928F.ESP.Boxes, function(v) _0x928F.ESP.Boxes = v end)
_0x4E7B(_0x31E7.ESP, 184,"Name ESP", _0x928F.ESP.Names, function(v) _0x928F.ESP.Names = v end)
_0x4E7B(_0x31E7.ESP, 228,"Snaplines", _0x928F.ESP.Snaplines, function(v) _0x928F.ESP.Snaplines = v end)
_0x60C6(_0x31E7.ESP, 276,"Max Distance", 100, 3000, _0x928F.ESP.MaxDistance, function(v) _0x928F.ESP.MaxDistance = v end)
_0x31E7.Visual = Instance.new("ScrollingFrame")
_0x31E7.Visual.Size = UDim2.new(1, 0, 1, 0)
_0x31E7.Visual.BackgroundTransparency = 1
_0x31E7.Visual.ScrollBarThickness = 4
_0x31E7.Visual.CanvasSize = UDim2.new(0, 0, 0, 160)
_0x31E7.Visual.Visible = false
_0x31E7.Visual.Parent = _0x5F6D
local _0xCA2F = Instance.new("TextLabel")
_0xCA2F.Size = UDim2.new(0.5, 0, 0, 30)
_0xCA2F.Position = UDim2.new(0, 10, 0, 10)
_0xCA2F.BackgroundTransparency = 1
_0xCA2F.Text ="FOV Circle Color"_0xCA2F.TextColor3 = Color3.fromRGB(200, 200, 220)
_0xCA2F.Font = Enum.Font.Gotham
_0xCA2F.TextSize = 13
_0xCA2F.TextXAlignment = Enum.TextXAlignment.Left
_0xCA2F.Parent = _0x31E7.Visual
local _0xE725 = {
Color3.fromRGB(255, 255, 255),
Color3.fromRGB(255, 60, 60),
Color3.fromRGB(60, 255, 60),
Color3.fromRGB(60, 150, 255),
Color3.fromRGB(255, 200, 50),
}
local _0xFC85 = 1
local _0x54C9 = Instance.new("TextButton")
_0x54C9.Size = UDim2.new(0, 40, 0, 24)
_0x54C9.Position = UDim2.new(0, 150, 0, 10)
_0x54C9.BackgroundColor3 = _0xE725[1]
_0x54C9.Text =""_0x54C9.Parent = _0x31E7.Visual
local _0x56A4 = Instance.new("UICorner")
_0x56A4.CornerRadius = UDim.new(0, 4)
_0x56A4.Parent = _0x54C9
_0x54C9.MouseButton1Click:Connect(function()
_0xFC85 = _0xFC85 % #_0xE725 + 1
_0x928F.Visual.FOVColor = _0xE725[_0xFC85]
_0x54C9.BackgroundColor3 = _0xE725[_0xFC85]
end)
_0x4E7B(_0x31E7.Visual, 52,"Team Check (Color)", _0x928F.Visual.TeamCheck, function(v) _0x928F.Visual.TeamCheck = v end)
_0x31E7.Settings = Instance.new("ScrollingFrame")
_0x31E7.Settings.Size = UDim2.new(1, 0, 1, 0)
_0x31E7.Settings.BackgroundTransparency = 1
_0x31E7.Settings.ScrollBarThickness = 4
_0x31E7.Settings.CanvasSize = UDim2.new(0, 0, 0, 200)
_0x31E7.Settings.Visible = false
_0x31E7.Settings.Parent = _0x5F6D
local _0x9A53 = Instance.new("TextLabel")
_0x9A53.Size = UDim2.new(1, -20, 0, 180)
_0x9A53.Position = UDim2.new(0, 10, 0, 10)
_0x9A53.BackgroundTransparency = 1
_0x9A53.Text ="Aimbot: Auto-lock when enabled (FOV based)\nFOV Circle: White (default), screen-centered\n\nDrag sliders to adjust values.\nClick color preview to cycle colors.\n\nTouch supported on all UI elements.\n\n[X] button fully destroys the script."_0x9A53.TextColor3 = Color3.fromRGB(160, 160, 180)
_0x9A53.Font = Enum.Font.Gotham
_0x9A53.TextSize = 12
_0x9A53.TextXAlignment = Enum.TextXAlignment.Left
_0x9A53.TextYAlignment = Enum.TextYAlignment.Top
_0x9A53.TextWrapped = true
_0x9A53.Parent = _0x31E7.Settings
for _, _0xCA76 in ipairs(_0xAA69) do
_0xE0B4[_0xCA76].MouseButton1Click:Connect(function()
for _, b in pairs(_0xE0B4) do
b.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
end
_0xE0B4[_0xCA76].BackgroundColor3 = Color3.fromRGB(60, 60, 100)
_0xB78D(_0xCA76)
end)
endlocal _0x53E6 = Instance.new("TextButton")
_0x53E6.Size = UDim2.new(0, 56, 0, 56)
_0x53E6.Position = UDim2.new(1, -70, 1, -70)
_0x53E6.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
_0x53E6.Text ="Co"_0x53E6.TextColor3 = Color3.fromRGB(255, 255, 255)
_0x53E6.Font = Enum.Font.GothamBold
_0x53E6.TextSize = 18
_0x53E6.Visible = false
_0x53E6.Parent = _0x43C3
local _0xEB85 = Instance.new("UICorner")
_0xEB85.CornerRadius = UDim.new(1, 0)
_0xEB85.Parent = _0x53E6
local _0x27FF = false
_0x8598.MouseButton1Click:Connect(function()
_0x27FF = not _0x27FF
_0xFEBD.Visible = not _0x27FF
_0x53E6.Visible = _0x27FF
end)local _0xD08B = false
local _0xD5A9 = nil
local _0x618A = nil
local _0x0719 = false
_0x53E6.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
_0xD08B = true
_0x0719 = false
_0xD5A9 = input.Position
_0x618A = _0x53E6.Position
end
end)
_0x53E6.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
_0xD08B = false
if not _0x0719 then
_0x27FF = false
_0xFEBD.Visible = true
_0x53E6.Visible = false
end
end
end)
local _0x0419 = _0x5C2F.InputChanged:Connect(function(input)
if _0xD08B and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
local _0x6AD8 = input.Position - _0xD5A9
if math.abs(_0x6AD8.X) > 2 or math.abs(_0x6AD8.Y) > 2 then
_0x0719 = true
end
_0x53E6.Position = UDim2.new(
_0x618A.X.Scale,
_0x618A.X.Offset + _0x6AD8.X,
_0x618A.Y.Scale,
_0x618A.Y.Offset + _0x6AD8.Y
)
end
end)
table.insert(_0x4AAA, _0x0419)local _0xE4A2 = false
local _0x8C5C = nil
local _0x4CC8 = nil
local function _0x9431(input)
return input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
end
_0x71F0.InputBegan:Connect(function(input)
if _0x9431(input) then
_0xE4A2 = true
_0x8C5C = input.Position
_0x4CC8 = _0xFEBD.Position
end
end)
_0x71F0.InputEnded:Connect(function(input)
if _0x9431(input) then
_0xE4A2 = false
end
end)
local _0x3C89 = _0x5C2F.InputChanged:Connect(function(input)
if _0xE4A2 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
local _0x6AD8 = input.Position - _0x8C5C
_0xFEBD.Position = UDim2.new(
_0x4CC8.X.Scale,
_0x4CC8.X.Offset + _0x6AD8.X,
_0x4CC8.Y.Scale,
_0x4CC8.Y.Offset + _0x6AD8.Y
)
end
end)
table.insert(_0x4AAA, _0x3C89)
local _0xF366 = _0x5C2F.InputEnded:Connect(function(input)
if _0x9431(input) then
_0xE4A2 = false
_0xD08B = false
end
end)
table.insert(_0x4AAA, _0xF366)_0x287F.AncestryChanged:Connect(function()
if not _0x287F.Parent then
_0x98F3()
end
end)
print("[Cobalt] Loaded successfully! (Mobile Compatible)")