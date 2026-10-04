-- ================= FPS Locker v3.0 (iPhone 12 + Delta) =================
-- 自定义帧率 15~120 | 滑块+预设按钮 | 移动端优化 | 紫红霓虹
-- ======================================================================

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ============ 配置 ============
local Config = {
    Enabled = true,
    TargetFPS = 60,
    ShowFPS = true,
    FPS_MIN = 15,
    FPS_MAX = 120,
}

-- ============ 帧率统计 ============
local frameCount = 0
local lastTime = tick()
local currentFPS = 60

-- ============ 智能锁帧核心 ============
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

-- ============ UI ============
if game.CoreGui:FindFirstChild("FPSLockerUI") then
    game.CoreGui.FPSLockerUI:Destroy()
end

local parentGui = (gethui and gethui()) or game.CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "FPSLockerUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Parent = parentGui

local QUICK_BOUNCE = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local BOUNCE_OUT = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ========== 悬浮球（iPhone 左侧，不挡摇杆） ==========
local ball = Instance.new("TextButton")
ball.Size = UDim2.new(0, 52, 0, 52)
ball.Position = UDim2.new(0, 16, 0, 380)
ball.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
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
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128)),
})
ballGrad.Parent = ballStroke

local ballIcon = Instance.new("TextLabel")
ballIcon.Size = UDim2.new(1, 0, 1, 0)
ballIcon.BackgroundTransparency = 1
ballIcon.Text = "⏱"
ballIcon.TextColor3 = Color3.fromRGB(200, 150, 255)
ballIcon.Font = Enum.Font.GothamBold
ballIcon.TextSize = 24
ballIcon.Parent = ball

-- ========== FPS 显示（左上角小巧） ==========
local fpsDisplay = Instance.new("Frame")
fpsDisplay.Size = UDim2.new(0, 120, 0, 32)
fpsDisplay.Position = UDim2.new(0, 16, 0, 16)
fpsDisplay.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
fpsDisplay.BackgroundTransparency = 0.3
fpsDisplay.BorderSizePixel = 0
fpsDisplay.ZIndex = 5
fpsDisplay.Parent = gui
Instance.new("UICorner", fpsDisplay).CornerRadius = UDim.new(0, 8)

local fpsStroke = Instance.new("UIStroke")
fpsStroke.Thickness = 1
fpsStroke.Transparency = 0.4
fpsStroke.Parent = fpsDisplay
local fpsGrad = Instance.new("UIGradient")
fpsGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128)),
})
fpsGrad.Parent = fpsStroke

local fpsText = Instance.new("TextLabel")
fpsText.Size = UDim2.new(1, 0, 1, 0)
fpsText.BackgroundTransparency = 1
fpsText.Text = "FPS: 0"
fpsText.TextColor3 = Color3.fromRGB(0, 255, 130)
fpsText.Font = Enum.Font.GothamBold
fpsText.TextSize = 13
fpsText.ZIndex = 6
fpsText.Parent = fpsDisplay

-- ========== 主面板（iPhone 12 适配，底部预留安全区） ==========
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 280, 0, 320)
panel.Position = UDim2.new(0.5, -140, 0.5, -160)
panel.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
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
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128)),
})
psGrad.Parent = panelStroke

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundTransparency = 1
titleBar.ZIndex = 2
titleBar.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FPS LOCKER"
title.TextColor3 = Color3.fromRGB(200, 150, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -44, 0.5, -18)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.AutoButtonColor = false
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- ========== 锁帧开关 ==========
local lockRow = Instance.new("TextButton")
lockRow.Size = UDim2.new(1, -20, 0, 44)
lockRow.Position = UDim2.new(0, 10, 0, 50)
lockRow.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
lockRow.Text = ""
lockRow.AutoButtonColor = false
lockRow.BorderSizePixel = 0
lockRow.Parent = panel
Instance.new("UICorner", lockRow).CornerRadius = UDim.new(0, 10)

local lkLabel = Instance.new("TextLabel")
lkLabel.Size = UDim2.new(1, -100, 1, 0)
lkLabel.Position = UDim2.new(0, 14, 0, 0)
lkLabel.BackgroundTransparency = 1
lkLabel.Text = "锁定帧率"
lkLabel.TextColor3 = Color3.fromRGB(220, 230, 255)
lkLabel.Font = Enum.Font.GothamBold
lkLabel.TextSize = 14
lkLabel.TextXAlignment = Enum.TextXAlignment.Left
lkLabel.Parent = lockRow

local lkState = Instance.new("TextLabel")
lkState.Size = UDim2.new(0, 40, 1, 0)
lkState.Position = UDim2.new(1, -50, 0, 0)
lkState.BackgroundTransparency = 1
lkState.Text = "ON"
lkState.TextColor3 = Color3.fromRGB(0, 255, 130)
lkState.Font = Enum.Font.GothamBold
lkState.TextSize = 14
lkState.TextXAlignment = Enum.TextXAlignment.Right
lkState.Parent = lockRow

-- ========== 自定义帧率滑块 ==========
local sliderRow = Instance.new("Frame")
sliderRow.Size = UDim2.new(1, -20, 0, 72)
sliderRow.Position = UDim2.new(0, 10, 0, 102)
sliderRow.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
sliderRow.BorderSizePixel = 0
sliderRow.Parent = panel
Instance.new("UICorner", sliderRow).CornerRadius = UDim.new(0, 10)

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, -24, 0, 22)
sliderLabel.Position = UDim2.new(0, 14, 0, 6)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "自定义帧率: " .. Config.TargetFPS
sliderLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
sliderLabel.Font = Enum.Font.GothamBold
sliderLabel.TextSize = 13
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = sliderRow

local trackBg = Instance.new("Frame")
trackBg.Size = UDim2.new(1, -28, 0, 8)
trackBg.Position = UDim2.new(0, 14, 1, -26)
trackBg.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
trackBg.BorderSizePixel = 0
trackBg.Parent = sliderRow
Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size = UDim2.new((Config.TargetFPS - Config.FPS_MIN) / (Config.FPS_MAX - Config.FPS_MIN), 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
fill.BorderSizePixel = 0
fill.Parent = trackBg
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new((Config.TargetFPS - Config.FPS_MIN) / (Config.FPS_MAX - Config.FPS_MIN), -10, 0.5, -10)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel = 0
knob.ZIndex = 2
knob.Parent = trackBg
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

-- ========== 预设按钮行 ==========
local presetRow = Instance.new("Frame")
presetRow.Size = UDim2.new(1, -20, 0, 44)
presetRow.Position = UDim2.new(0, 10, 0, 184)
presetRow.BackgroundTransparency = 1
presetRow.Parent = panel

local presets = {30, 60, 90, 120}
for i, fps in ipairs(presets) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 44)
    btn.Position = UDim2.new(0, (i-1) * 64, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 22, 48)
    btn.Text = tostring(fps)
    btn.TextColor3 = Color3.fromRGB(200, 150, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = presetRow
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    -- 初始高亮 60
    if fps == 60 then
        btn.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Config.TargetFPS = fps
            targetInterval = 1 / Config.TargetFPS
            sliderLabel.Text = "自定义帧率: " .. fps
            -- 更新滑块位置
            local relX = (fps - Config.FPS_MIN) / (Config.FPS_MAX - Config.FPS_MIN)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            knob.Position = UDim2.new(relX, -10, 0.5, -10)
            -- 高亮当前按钮
            for _, c in ipairs(presetRow:GetChildren()) do
                if c:IsA("TextButton") then
                    TweenService:Create(c, QUICK_BOUNCE, {BackgroundColor3 = Color3.fromRGB(30, 22, 48), TextColor3 = Color3.fromRGB(200, 150, 255)}):Play()
                end
            end
            TweenService:Create(btn, QUICK_BOUNCE, {BackgroundColor3 = Color3.fromRGB(180, 0, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
    end)
end

-- ========== 显示 FPS 开关 ==========
local showRow = Instance.new("TextButton")
showRow.Size = UDim2.new(1, -20, 0, 44)
showRow.Position = UDim2.new(0, 10, 0, 238)
showRow.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
showRow.Text = ""
showRow.AutoButtonColor = false
showRow.BorderSizePixel = 0
showRow.Parent = panel
Instance.new("UICorner", showRow).CornerRadius = UDim.new(0, 10)

local sfLabel = Instance.new("TextLabel")
sfLabel.Size = UDim2.new(1, -100, 1, 0)
sfLabel.Position = UDim2.new(0, 14, 0, 0)
sfLabel.BackgroundTransparency = 1
sfLabel.Text = "显示实时 FPS"
sfLabel.TextColor3 = Color3.fromRGB(220, 230, 255)
sfLabel.Font = Enum.Font.GothamBold
sfLabel.TextSize = 14
sfLabel.TextXAlignment = Enum.TextXAlignment.Left
sfLabel.Parent = showRow

local sfState = Instance.new("TextLabel")
sfState.Size = UDim2.new(0, 40, 1, 0)
sfState.Position = UDim2.new(1, -50, 0, 0)
sfState.BackgroundTransparency = 1
sfState.Text = "ON"
sfState.TextColor3 = Color3.fromRGB(0, 255, 130)
sfState.Font = Enum.Font.GothamBold
sfState.TextSize = 14
sfState.TextXAlignment = Enum.TextXAlignment.Right
sfState.Parent = showRow

-- ========== 事件绑定 ==========
lockRow.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Config.Enabled = not Config.Enabled
        lkState.Text = Config.Enabled and "ON" or "OFF"
        lkState.TextColor3 = Config.Enabled and Color3.fromRGB(0, 255, 130) or Color3.fromRGB(255, 80, 80)
    end
end)

showRow.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Config.ShowFPS = not Config.ShowFPS
        sfState.Text = Config.ShowFPS and "ON" or "OFF"
        sfState.TextColor3 = Config.ShowFPS and Color3.fromRGB(0, 255, 130) or Color3.fromRGB(255, 80, 80)
        fpsDisplay.Visible = Config.ShowFPS
    end
end)

-- ========== 滑块拖拽 ==========
local draggingSlider = false
local function updateSlider(inputX)
    local relX = math.clamp((inputX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
    local val = math.floor(Config.FPS_MIN + relX * (Config.FPS_MAX - Config.FPS_MIN) + 0.5)
    Config.TargetFPS = val
    targetInterval = 1 / val
    sliderLabel.Text = "自定义帧率: " .. val
    fill.Size = UDim2.new(relX, 0, 1, 0)
    knob.Position = UDim2.new(relX, -10, 0.5, -10)
end

trackBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        updateSlider(input.Position.X)
        TweenService:Create(knob, QUICK_BOUNCE, {Size = UDim2.new(0, 26, 0, 26)}):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if draggingSlider then
            draggingSlider = false
            TweenService:Create(knob, QUICK_BOUNCE, {Size = UDim2.new(0, 20, 0, 20)}):Play()
        end
    end
end)

-- ========== FPS 刷新（低频） ==========
task.spawn(function()
    while gui.Parent do
        if Config.ShowFPS then
            fpsText.Text = string.format("FPS: %d", currentFPS)
            if currentFPS >= Config.TargetFPS - 5 then
                fpsText.TextColor3 = Color3.fromRGB(0, 255, 130)
            elseif currentFPS >= Config.TargetFPS * 0.6 then
                fpsText.TextColor3 = Color3.fromRGB(255, 200, 0)
            else
                fpsText.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
        end
        task.wait(0.5)
    end
end)

-- ========== 拖拽（限制屏幕内） ==========
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

-- ========== 悬浮球（长按拖动，轻点开关面板） ==========
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
        TweenService:Create(ball, QUICK_BOUNCE, {Size = UDim2.new(0, 44, 0, 44)}):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if ballDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - ballDragStart
        if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then ballMoved = true end
        if ballMoved then
            local newX = ballStartPos.X.Offset + delta.X
            local newY = ballStartPos.Y.Offset + delta.Y
            local vp = gui.AbsoluteSize
            newX = math.clamp(newX, 0, vp.X - 52)
            newY = math.clamp(newY, 0, vp.Y - 52)
            ball.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if ballDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        ballDragging = false
        TweenService:Create(ball, QUICK_BOUNCE, {Size = UDim2.new(0, 52, 0, 52)}):Play()

        local holdTime = os.clock() - ballHoldStart
        if holdTime < 0.3 and not ballMoved then
            if panel.Visible then
                panel.Visible = false
            else
                panel.Visible = true
                panel.Size = UDim2.new(0, 0, 0, 0)
                panel.Position = UDim2.new(0.5, -140, 0.5, -160)
                TweenService:Create(panel, BOUNCE_OUT, {Size = UDim2.new(0, 280, 0, 320)}):Play()
            end
        end
    end
end)

closeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        panel.Visible = false
    end
end)

print("[FPS Locker v3.0 - iPhone 12] 已加载 | 15~120 帧可调 | 滑块+预设")
