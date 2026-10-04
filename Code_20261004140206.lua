-- ================= FPS Locker v2.1 (Mobile Optimized) =================
-- 移动端专用 | 极简UI | 智能锁60帧 | 不挡摇杆 | 省电
-- ======================================================================

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ============ 配置 ============
local Config = {
    Enabled = true,
    TargetFPS = 60,
    ShowFPS = true,
}

-- ============ 帧率统计 ============
local frameCount = 0
local lastTime = tick()
local currentFPS = 60

-- ============ 智能锁帧 ============
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

-- ========== 悬浮球（小尺寸，靠边） ==========
local ball = Instance.new("TextButton")
ball.Size = UDim2.new(0, 50, 0, 50)
ball.Position = UDim2.new(0, 20, 0, 400)
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
ballIcon.TextSize = 22
ballIcon.Parent = ball

-- ========== FPS 显示（小巧，靠左上） ==========
local fpsDisplay = Instance.new("Frame")
fpsDisplay.Size = UDim2.new(0, 110, 0, 30)
fpsDisplay.Position = UDim2.new(0, 20, 0, 20)
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

-- ========== 控制面板（紧凑，240x140） ==========
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 240, 0, 140)
panel.Position = UDim2.new(0.5, -120, 0.5, -70)
panel.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

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
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundTransparency = 1
titleBar.ZIndex = 2
titleBar.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FPS 锁 60"
title.TextColor3 = Color3.fromRGB(200, 150, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.AutoButtonColor = false
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- 开关生成（紧凑）
local function createToggle(yPos, labelText, getter, setter)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -20, 0, 40)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
    row.Text = ""
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Parent = panel
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -90, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(220, 230, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local state = Instance.new("TextLabel")
    state.Size = UDim2.new(0, 40, 1, 0)
    state.Position = UDim2.new(1, -50, 0, 0)
    state.BackgroundTransparency = 1
    state.Text = getter() and "ON" or "OFF"
    state.TextColor3 = getter() and Color3.fromRGB(0, 255, 130) or Color3.fromRGB(255, 80, 80)
    state.Font = Enum.Font.GothamBold
    state.TextSize = 13
    state.TextXAlignment = Enum.TextXAlignment.Right
    state.Parent = row

    local function updateUI()
        state.Text = getter() and "ON" or "OFF"
        state.TextColor3 = getter() and Color3.fromRGB(0, 255, 130) or Color3.fromRGB(255, 80, 80)
    end

    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setter(not getter())
            updateUI()
            TweenService:Create(row, QUICK_BOUNCE, {BackgroundColor3 = getter() and Color3.fromRGB(35, 25, 55) or Color3.fromRGB(25, 18, 40)}):Play()
        end
    end)
    return updateUI
end

createToggle(40, "锁定 60 帧", function() return Config.Enabled end, function(v) Config.Enabled = v end)
createToggle(85, "显示实时 FPS", function() return Config.ShowFPS end, function(v) Config.ShowFPS = v; fpsDisplay.Visible = v end)

-- ========== 帧率刷新（低频刷新，省电） ==========
task.spawn(function()
    while gui.Parent do
        if Config.ShowFPS then
            fpsText.Text = string.format("FPS: %d", currentFPS)
            if currentFPS >= 55 then
                fpsText.TextColor3 = Color3.fromRGB(0, 255, 130)
            elseif currentFPS >= 40 then
                fpsText.TextColor3 = Color3.fromRGB(255, 200, 0)
            else
                fpsText.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
        end
        task.wait(0.5)
    end
end)

-- ========== 拖拽（限制在屏幕内） ==========
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
        TweenService:Create(ball, QUICK_BOUNCE, {Size = UDim2.new(0, 42, 0, 42)}):Play()
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
            newX = math.clamp(newX, 0, vp.X - 50)
            newY = math.clamp(newY, 0, vp.Y - 50)
            ball.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if ballDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        ballDragging = false
        TweenService:Create(ball, QUICK_BOUNCE, {Size = UDim2.new(0, 50, 0, 50)}):Play()

        local holdTime = os.clock() - ballHoldStart
        if holdTime < 0.3 and not ballMoved then
            if panel.Visible then
                panel.Visible = false
            else
                panel.Visible = true
                panel.Size = UDim2.new(0, 0, 0, 0)
                panel.Position = UDim2.new(0.5, -120, 0.5, -70)
                TweenService:Create(panel, BOUNCE_OUT, {Size = UDim2.new(0, 240, 0, 140)}):Play()
            end
        end
    end
end)

-- 关闭面板
closeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        panel.Visible = false
    end
end)

print("[FPS Locker v2.1 - Mobile] 已加载 | 固定 60 帧")
