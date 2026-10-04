-- Guts & Blackpowder 专用画质与锁帧脚本
-- 移动端适配版 | 降低渲染负担 | 稳定帧率

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- ============ 配置 ============
local Config = {
    Enabled = true,
    TargetFPS = 60,
    CurrentQuality = "低",
}

-- ============ FPS 统计与锁帧 ============
local frameCount = 0
local lastTime = tick()
local currentFPS = 60
local targetInterval = 1 / Config.TargetFPS
local lastFrameTime = tick()

RunService.RenderStepped:Connect(function()
    local now = tick()
    local actualDelta = now - lastFrameTime
    lastFrameTime = now

    if Config.Enabled then
        local waitTime = targetInterval - actualDelta
        if waitTime > 0.001 then
            task.wait(waitTime)
        end
    end

    frameCount = frameCount + 1
    if now - lastTime >= 1 then
        currentFPS = frameCount
        frameCount = 0
        lastTime = now
    end
end)

-- ============ 画质预设 ============
local QualityPresets = {
    ["低"] = {
        renderDistance = 300,
        shadows = false,
        particles = false,
        postProcessing = false,
        technology = "Legacy",
        waterWaveSize = 0,
        waterReflectance = 0,
        lightBrightness = 1,
        globalShadows = false,
        fogEnd = 500,
    },
    ["中"] = {
        renderDistance = 900,
        shadows = true,
        particles = true,
        postProcessing = "Basic",
        technology = "ShadowMap",
        waterWaveSize = 0.25,
        waterReflectance = 0.3,
        lightBrightness = 1.5,
        globalShadows = true,
        fogEnd = 1000,
    },
    ["高"] = {
        renderDistance = 1800,
        shadows = true,
        particles = true,
        postProcessing = "Full",
        technology = "Future",
        waterWaveSize = 0.5,
        waterReflectance = 0.5,
        lightBrightness = 2,
        globalShadows = true,
        fogEnd = 1500,
    },
}

-- ============ 应用画质 ============
local function applyQuality(qualityName)
    local preset = QualityPresets[qualityName]
    if not preset then return end

    Config.CurrentQuality = qualityName

    -- 照明设置
    Lighting.GlobalShadows = preset.globalShadows
    Lighting.Brightness = preset.lightBrightness
    Lighting.FogEnd = preset.fogEnd
    Lighting.EnvironmentDiffuseScale = preset.globalShadows and 0.5 or 0
    Lighting.EnvironmentSpecularScale = preset.globalShadows and 0.5 or 0

    -- 地形水设置
    if workspace.Terrain then
        workspace.Terrain.WaterWaveSize = preset.waterWaveSize
        workspace.Terrain.WaterReflectance = preset.waterReflectance
        workspace.Terrain.WaterTransparency = 0.5
    end

    -- 遍历工作区调整渲染
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CastShadow = preset.shadows
            if preset.renderDistance < 1000 then
                obj.Material = Enum.Material.SmoothPlastic
            end
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = preset.particles
        elseif obj:IsA("PostEffect") then
            obj.Enabled = (preset.postProcessing ~= false)
        end
    end

    -- 清理并应用后处理
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") then
            obj:Destroy()
        end
    end

    if preset.postProcessing == "Basic" then
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.3
        bloom.Size = 16
        bloom.Parent = Lighting
    elseif preset.postProcessing == "Full" then
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.5
        bloom.Size = 24
        bloom.Parent = Lighting

        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Brightness = 0.02
        colorCorrection.Contrast = 0.1
        colorCorrection.Parent = Lighting
    end
end

-- 默认应用低画质（G&B 僵尸多，低画质最稳）
applyQuality("低")

-- ============ UI ============
if game.CoreGui:FindFirstChild("GBQualityUI") then
    game.CoreGui.GBQualityUI:Destroy()
end

local parentGui = (gethui and gethui()) or game.CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "GBQualityUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 2147483647
gui.Parent = parentGui

local QUICK_BOUNCE = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local BOUNCE_OUT = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- 悬浮球
local ball = Instance.new("TextButton")
ball.Size = UDim2.new(0, 60, 0, 60)
ball.Position = UDim2.new(0, 20, 0, 350)
ball.BackgroundColor3 = Color3.fromRGB(15, 12, 25)
ball.Text = ""
ball.AutoButtonColor = false
ball.BorderSizePixel = 0
ball.Parent = gui
Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

local ballStroke = Instance.new("UIStroke")
ballStroke.Thickness = 1.5
ballStroke.Transparency = 0.15
ballStroke.Parent = ball
local ballGrad = Instance.new("UIGradient")
ballGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 50)),
})
ballGrad.Parent = ballStroke

local ballIcon = Instance.new("TextLabel")
ballIcon.Size = UDim2.new(1, 0, 1, 0)
ballIcon.BackgroundTransparency = 1
ballIcon.Text = "⚙"
ballIcon.TextColor3 = Color3.fromRGB(255, 180, 100)
ballIcon.Font = Enum.Font.GothamBold
ballIcon.TextSize = 26
ballIcon.Parent = ball

-- FPS 显示
local fpsDisplay = Instance.new("TextLabel")
fpsDisplay.Size = UDim2.new(0, 110, 0, 30)
fpsDisplay.Position = UDim2.new(0, 16, 0, 16)
fpsDisplay.BackgroundColor3 = Color3.fromRGB(15, 12, 25)
fpsDisplay.BackgroundTransparency = 0.3
fpsDisplay.BorderSizePixel = 0
fpsDisplay.Text = "FPS: 0"
fpsDisplay.TextColor3 = Color3.fromRGB(0, 255, 130)
fpsDisplay.Font = Enum.Font.GothamBold
fpsDisplay.TextSize = 13
fpsDisplay.ZIndex = 5
fpsDisplay.Parent = gui
Instance.new("UICorner", fpsDisplay).CornerRadius = UDim.new(0, 8)

local fpsStroke = Instance.new("UIStroke")
fpsStroke.Color = Color3.fromRGB(200, 50, 50)
fpsStroke.Thickness = 1
fpsStroke.Transparency = 0.4
fpsStroke.Parent = fpsDisplay

-- 主面板
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 260, 0, 260)
panel.Position = UDim2.new(0.5, -130, 0.5, -130)
panel.BackgroundColor3 = Color3.fromRGB(15, 12, 25)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

local panelStroke = Instance.new("UIStroke")
panelStroke.Thickness = 1.5
panelStroke.Transparency = 0.3
panelStroke.Parent = panel
local psGrad = Instance.new("UIGradient")
psGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 50)),
})
psGrad.Parent = panelStroke

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundTransparency = 1
titleBar.ZIndex = 2
titleBar.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "G&B 优化"
title.TextColor3 = Color3.fromRGB(255, 180, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -42, 0.5, -17)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.AutoButtonColor = false
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- 画质选择
local qualityLabel = Instance.new("TextLabel")
qualityLabel.Size = UDim2.new(1, -20, 0, 22)
qualityLabel.Position = UDim2.new(0, 10, 0, 46)
qualityLabel.BackgroundTransparency = 1
qualityLabel.Text = "画质档位"
qualityLabel.TextColor3 = Color3.fromRGB(220, 230, 255)
qualityLabel.Font = Enum.Font.GothamBold
qualityLabel.TextSize = 13
qualityLabel.TextXAlignment = Enum.TextXAlignment.Left
qualityLabel.Parent = panel

local qualityRow = Instance.new("Frame")
qualityRow.Size = UDim2.new(1, -20, 0, 46)
qualityRow.Position = UDim2.new(0, 10, 0, 70)
qualityRow.BackgroundTransparency = 1
qualityRow.Parent = panel

local qualities = {"低", "中", "高"}
local qualityButtons = {}

for i, q in ipairs(qualities) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 72, 0, 46)
    btn.Position = UDim2.new(0, (i-1) * 76, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
    btn.Text = q
    btn.TextColor3 = Color3.fromRGB(200, 180, 220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = qualityRow
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    qualityButtons[q] = btn

    if q == "低" then
        btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            applyQuality(q)
            for k, b in pairs(qualityButtons) do
                TweenService:Create(b, QUICK_BOUNCE, {
                    BackgroundColor3 = (k == q) and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(30, 25, 45),
                    TextColor3 = (k == q) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 180, 220),
                }):Play()
            end
        end
    end)
end

-- 帧率锁
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -20, 0, 22)
fpsLabel.Position = UDim2.new(0, 10, 0, 126)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "锁帧"
fpsLabel.TextColor3 = Color3.fromRGB(220, 230, 255)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 13
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = panel

local fpsRow = Instance.new("Frame")
fpsRow.Size = UDim2.new(1, -20, 0, 46)
fpsRow.Position = UDim2.new(0, 10, 0, 150)
fpsRow.BackgroundTransparency = 1
fpsRow.Parent = panel

local fpsOptions = {30, 60, 120}
local fpsButtons = {}

for i, f in ipairs(fpsOptions) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 72, 0, 46)
    btn.Position = UDim2.new(0, (i-1) * 76, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
    btn.Text = tostring(f)
    btn.TextColor3 = Color3.fromRGB(200, 180, 220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = fpsRow
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    fpsButtons[f] = btn

    if f == 60 then
        btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Config.TargetFPS = f
            targetInterval = 1 / f
            for k, b in pairs(fpsButtons) do
                TweenService:Create(b, QUICK_BOUNCE, {
                    BackgroundColor3 = (k == f) and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(30, 25, 45),
                    TextColor3 = (k == f) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 180, 220),
                }):Play()
            end
        end
    end)
end

-- FPS 刷新
task.spawn(function()
    while gui.Parent do
        fpsDisplay.Text = string.format("FPS: %d", currentFPS)
        if currentFPS >= Config.TargetFPS - 5 then
            fpsDisplay.TextColor3 = Color3.fromRGB(0, 255, 130)
        elseif currentFPS >= Config.TargetFPS * 0.6 then
            fpsDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
        else
            fpsDisplay.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
        task.wait(0.5)
    end
end)

-- ============ 拖拽与开关 ============
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            local vp = gui.AbsoluteSize
            newX = math.clamp(newX, 0, vp.X - frame.AbsoluteSize.X)
            newY = math.clamp(newY, 0, vp.Y - frame.AbsoluteSize.Y)
            frame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

makeDraggable(panel)
makeDraggable(fpsDisplay)

local ballHoldStart = 0
local ballMoved = false
local ballDragging = false
local ballDragStart, ballStartPos

ball.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ballHoldStart = os.clock()
        ballMoved = false
        ballDragging = true
        ballDragStart = input.Position
        ballStartPos = ball.Position
        TweenService:Create(ball, QUICK_BOUNCE, {Size = UDim2.new(0, 52, 0, 52)}):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if ballDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - ballDragStart
        if math.abs(delta.X) > 12 or math.abs(delta.Y) > 12 then ballMoved = true end
        if ballMoved then
            local newX = ballStartPos.X.Offset + delta.X
            local newY = ballStartPos.Y.Offset + delta.Y
            local vp = gui.AbsoluteSize
            newX = math.clamp(newX, 0, vp.X - 60)
            newY = math.clamp(newY, 0, vp.Y - 60)
            ball.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if ballDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        ballDragging = false
        TweenService:Create(ball, QUICK_BOUNCE, {Size = UDim2.new(0, 60, 0, 60)}):Play()

        local holdTime = os.clock() - ballHoldStart
        if holdTime < 0.5 and not ballMoved then
            if panel.Visible then
                panel.Visible = false
            else
                panel.Visible = true
                panel.Size = UDim2.new(0, 0, 0, 0)
                panel.Position = UDim2.new(0.5, -130, 0.5, -130)
                TweenService:Create(panel, BOUNCE_OUT, {Size = UDim2.new(0, 260, 0, 260)}):Play()
            end
        end
    end
end)

closeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        panel.Visible = false
    end
end)

print("[G&B 优化脚本] 已加载 | 低/中/高画质 + 锁帧 30/60/120")
