-- RXZ BQM STREETS
-- Base: شوارع | Interface: ui_only | Red tracers: RXZ BLOCK SPIN
-- All gameplay switches start OFF. No remote UI downloads required.
local PlayersService = game:GetService("Players")
local me = PlayersService.LocalPlayer
if not me then warn("RXZ BQM STREETS: client-side only") return end
if _G.RXZ_BQM_STREETS and _G.RXZ_BQM_STREETS.Destroy then
    pcall(_G.RXZ_BQM_STREETS.Destroy)
end
local uiShutdown
local result = (function()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = me:WaitForChild("PlayerGui")
local PURPLE = Color3.fromRGB(146, 112, 255)
local LILAC  = Color3.fromRGB(196, 178, 255)
local INK    = Color3.fromRGB(236, 232, 250)
local DIM    = Color3.fromRGB(152, 144, 184)
local WHITE  = Color3.fromRGB(255, 255, 255)

local SURFACE_2 = Color3.fromRGB(31, 33, 41)
local SURFACE_3 = Color3.fromRGB(42, 44, 54)
local STROKE    = Color3.fromRGB(62, 65, 78)
local VIOLET    = Color3.fromRGB(196, 38, 65)
local ORCHID    = Color3.fromRGB(255, 115, 127)
local MIST      = Color3.fromRGB(48, 39, 50)
local BASE      = Color3.fromRGB(20, 22, 28)   
local CARD      = Color3.fromRGB(29, 31, 39)   
local CARD_HI   = Color3.fromRGB(40, 42, 53)   

local GLASS    = 0.18   
local GLASS_HI = 0.04   

local ACCENT_GRADIENT = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, VIOLET),
    ColorSequenceKeypoint.new(0.55, PURPLE),
    ColorSequenceKeypoint.new(1.00, ORCHID),
})

local SHINE_GRADIENT = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, LILAC),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 180, 190)),
    ColorSequenceKeypoint.new(0.50, WHITE),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(255, 180, 190)),
    ColorSequenceKeypoint.new(1.00, LILAC),
})

local COLORS = {
    up     = Color3.fromRGB(72, 199, 142),
    down   = Color3.fromRGB(255, 92, 110),
    middle = Color3.fromRGB(255, 168, 64),
}

local Fx = {
    enabled     = true,
    clock       = 0,
    flow        = 0,     
    energy      = 0,     
    flash       = 0,     
    order       = 0,
    connections = {},
    animators   = {},
    shines      = {},
}

local function bind(signal, fn)
    local connection = signal:Connect(fn)
    table.insert(Fx.connections, connection)
    return connection
end

local function animate(fn)
    table.insert(Fx.animators, fn)
    return fn
end

local function nextOrder()
    Fx.order = Fx.order + 1
    return Fx.order
end

local function tween(object, time, props, style, direction)
    local playing = nil
    pcall(function()
        playing = TweenService:Create(object, TweenInfo.new(time or 0.22,
            style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), props)
        playing:Play()
    end)
    return playing
end

local function corner(parent, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = (typeof(radius) == "UDim") and radius or UDim.new(0, radius or 12)
    item.Parent = parent
    return item
end

local function round(parent)
    return corner(parent, UDim.new(1, 0))
end

local function outline(parent, color, thickness, transparency)
    local item = Instance.new("UIStroke")
    item.Color = color or STROKE
    item.Thickness = thickness or 1
    item.Transparency = transparency or 0
    item.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    item.Parent = parent
    return item
end

local function gradient(parent, colors, rotation, transparency)
    local item = Instance.new("UIGradient")
    item.Color = colors or ACCENT_GRADIENT
    item.Rotation = rotation or 0
    if transparency then item.Transparency = transparency end
    item.Parent = parent
    return item
end

local function fade(points)
    local keys = {}
    for index, point in ipairs(points) do
        keys[index] = NumberSequenceKeypoint.new(point[1], point[2])
    end
    return NumberSequence.new(keys)
end

local function pad(parent, left, right, top, bottom)
    local item = Instance.new("UIPadding")
    item.PaddingLeft = UDim.new(0, left or 0)
    item.PaddingRight = UDim.new(0, right or 0)
    item.PaddingTop = UDim.new(0, top or 0)
    item.PaddingBottom = UDim.new(0, bottom or 0)
    item.Parent = parent
    return item
end

local function frame(parent, props)
    local item = Instance.new("Frame")
    item.BorderSizePixel = 0
    item.BackgroundColor3 = WHITE
    for key, value in pairs(props or {}) do item[key] = value end
    item.Parent = parent
    return item
end

local function label(parent, size, weight, color)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency = 1
    if weight == "black" then
        item.Font = Enum.Font.GothamBlack
    elseif weight then
        item.Font = Enum.Font.GothamBold
    else
        item.Font = Enum.Font.GothamMedium
    end
    item.TextSize = size or 12
    item.TextColor3 = color or INK
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.Text = ""
    item.Parent = parent
    return item
end

local function softOrb(parent, color, diameter, strength)
    local holder = frame(parent, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(diameter, diameter),
    })

    local layers = 9
    local alpha = 1 - (1 - math.clamp(strength, 0, 0.99)) ^ (1 / layers)

    for index = 1, layers do
        local scale = (index / layers) ^ 0.8
        local ring = frame(holder, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(scale, scale),
            BackgroundColor3 = color,
            BackgroundTransparency = 1 - alpha,
        })
        round(ring)
    end

    return holder
end

local function focusRing(box, stroke, host)
    box.Focused:Connect(function()
        tween(stroke, 0.2, { Color = PURPLE, Thickness = 1.5 })
        tween(box, 0.2, { BackgroundTransparency = 0 })
        if host then tween(host, 0.2, { BackgroundTransparency = GLASS_HI }) end
    end)
    box.FocusLost:Connect(function()
        tween(stroke, 0.25, { Color = STROKE, Thickness = 1 })
        tween(box, 0.25, { BackgroundTransparency = 0.15 })
        if host then tween(host, 0.25, { BackgroundTransparency = GLASS }) end
    end)
end

local guiParent = CoreGui
pcall(function()
    if type(gethui) == "function" then guiParent = gethui() end
end)

do
    local previous = guiParent:FindFirstChild("RXZ_BQM_STREETS_UI")
    if previous then pcall(function() previous:Destroy() end) end
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "RXZ_BQM_STREETS_UI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 100000
Gui.Parent = guiParent

local WIDTH, HEIGHT = 600, 452

local Screen = frame(Gui, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 })

local Glow = frame(Screen, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(WIDTH, HEIGHT),
    BackgroundTransparency = 1,
    ZIndex = 0,
})

local GlowLayers = {}
for index = 1, 7 do
    local spread = index * 6
    local layer = frame(Glow, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 4 + index * 1.5),
        Size = UDim2.new(1, spread * 2, 1, spread * 2),
        BackgroundColor3 = (index <= 2) and LILAC or PURPLE,
        BackgroundTransparency = 0.9,
    })
    corner(layer, 22 + spread)
    GlowLayers[index] = layer
end

local Window = frame(Screen, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(WIDTH, HEIGHT),
    BackgroundTransparency = 1,
    ZIndex = 1,
})

local WindowScale = Instance.new("UIScale")
WindowScale.Scale = 0.86
WindowScale.Parent = Window

local Backdrop = nil
do
    local ok = pcall(function() Backdrop = Instance.new("CanvasGroup") end)
    if not ok or not Backdrop then
        Backdrop = Instance.new("Frame")
        Backdrop.ClipsDescendants = true
    end
end
Backdrop.Name = "Fluid"
Backdrop.Size = UDim2.fromScale(1, 1)
Backdrop.BackgroundColor3 = BASE
Backdrop.BorderSizePixel = 0
Backdrop.ZIndex = 0
Backdrop.Parent = Window
corner(Backdrop, 22)

do
    local rim = frame(Window, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 1 })
    corner(rim, 22)
    local stroke = outline(rim, WHITE, 1.5, 0)
    local rimGradient = gradient(stroke, ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, LILAC),
        ColorSequenceKeypoint.new(0.50, ORCHID),
        ColorSequenceKeypoint.new(1.00, PURPLE),
    }), 0, fade({ { 0, 0.35 }, { 0.5, 0.8 }, { 1, 0.5 } }))

    animate(function(t)
        if Fx.enabled and Window.Visible then rimGradient.Rotation = (t * 36) % 360 end
    end)
end

local Header = frame(Window, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 64),
    Active = true,
    ZIndex = 2,
})

do
    local halo = softOrb(Header, PURPLE, 70, 0.28)
    halo.Position = UDim2.fromOffset(33, 32)

    local logo = frame(Header, { Position = UDim2.fromOffset(16, 15), Size = UDim2.fromOffset(34, 34), ZIndex = 2 })
    corner(logo, 11)
    local logoGradient = gradient(logo, ACCENT_GRADIENT, 45)

    local gloss = frame(logo, { Size = UDim2.new(1, 0, 0.5, 0), BackgroundTransparency = 0.6 })
    corner(gloss, 11)
    gradient(gloss, ColorSequence.new(WHITE), 90, fade({ { 0, 0.2 }, { 1, 1 } }))

    local glyph = label(logo, 17, "black", WHITE)
    glyph.Size = UDim2.fromScale(1, 1)
    glyph.TextXAlignment = Enum.TextXAlignment.Center
    glyph.Text = "R"
    glyph.ZIndex = 2

    local title = label(Header, 17, "black", WHITE)
    title.Position = UDim2.fromOffset(60, 13)
    title.Size = UDim2.fromOffset(0, 20)
    title.AutomaticSize = Enum.AutomaticSize.None
    title.Size = UDim2.new(1, -270, 0, 20)
    title.TextScaled = true
    title.Text = "RXZ BQM STREETS"
    table.insert(Fx.shines, gradient(title, SHINE_GRADIENT, 0))

    local subtitle = label(Header, 10, false, DIM)
    subtitle.Position = UDim2.fromOffset(60, 34)
    subtitle.Size = UDim2.fromOffset(240, 14)
    subtitle.Text = "STREETS  /  RXZ"

    animate(function(t)
        if not Window.Visible then return end
        logoGradient.Rotation = (t * 45) % 360
        local pulse = 70 + math.sin(t * 2.1) * 8
        halo.Size = UDim2.fromOffset(pulse, pulse)
    end)
end

local Pill = frame(Header, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -88, 0, 19),
    Size = UDim2.fromOffset(118, 26),
    BackgroundColor3 = SURFACE_3,
    BackgroundTransparency = 0.15,
})
round(Pill)
outline(Pill, STROKE, 1, 0)

local PillPulse = frame(Pill, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromOffset(15, 13),
    Size = UDim2.fromOffset(7, 7),
    BackgroundColor3 = COLORS.up,
})
round(PillPulse)

local PillDot = frame(Pill, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromOffset(15, 13),
    Size = UDim2.fromOffset(7, 7),
    BackgroundColor3 = COLORS.up,
    ZIndex = 2,
})
round(PillDot)

local PillText = label(Pill, 9, true, DIM)
PillText.Position = UDim2.fromOffset(27, 0)
PillText.Size = UDim2.new(1, -34, 1, 0)
PillText.TextTruncate = Enum.TextTruncate.AtEnd
PillText.Text = "READY"

animate(function(t)
    if not Window.Visible then return end
    local phase = (t * 0.8) % 1
    local size = 7 + phase * 14
    PillPulse.Size = UDim2.fromOffset(size, size)
    PillPulse.BackgroundTransparency = 0.35 + phase * 0.65
end)

local function headerButton(glyph, offsetX, callback)
    local button = Instance.new("TextButton")
    button.AnchorPoint = Vector2.new(1, 0)
    button.Position = UDim2.new(1, offsetX, 0, 19)
    button.Size = UDim2.fromOffset(26, 26)
    button.BackgroundColor3 = SURFACE_3
    button.BackgroundTransparency = 0.15
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.TextColor3 = DIM
    button.Text = glyph
    button.Parent = Header
    round(button)
    outline(button, STROKE, 1, 0)

    local scale = Instance.new("UIScale")
    scale.Parent = button

    button.MouseEnter:Connect(function()
        tween(button, 0.18, { BackgroundColor3 = PURPLE, BackgroundTransparency = 0, TextColor3 = WHITE })
        tween(scale, 0.3, { Scale = 1.1 }, Enum.EasingStyle.Back)
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.22, { BackgroundColor3 = SURFACE_3, BackgroundTransparency = 0.15, TextColor3 = DIM })
        tween(scale, 0.22, { Scale = 1 })
    end)
    button.MouseButton1Down:Connect(function() tween(scale, 0.1, { Scale = 0.9 }) end)
    button.MouseButton1Up:Connect(function() tween(scale, 0.3, { Scale = 1.1 }, Enum.EasingStyle.Back) end)
    button.MouseButton1Click:Connect(callback)

    return button
end

do
    local divider = frame(Window, {
        Position = UDim2.fromOffset(18, 64),
        Size = UDim2.new(1, -36, 0, 1),
        ZIndex = 2,
    })
    local dividerGradient = gradient(divider, ACCENT_GRADIENT, 0, fade({ { 0, 1 }, { 0.5, 0.6 }, { 1, 1 } }))

    animate(function(t)
        if Fx.enabled and Window.Visible then
            dividerGradient.Offset = Vector2.new(math.sin(t * 0.6) * 0.35, 0)
        end
    end)
end

local Sidebar = frame(Window, {
    Position = UDim2.fromOffset(16, 76),
    Size = UDim2.new(0, 140, 1, -92),
    BackgroundColor3 = CARD,
    BackgroundTransparency = 0.3,
    ZIndex = 2,
})
corner(Sidebar, 16)
outline(Sidebar, STROKE, 1, 0)

local Indicator = frame(Sidebar, {
    Position = UDim2.fromOffset(8, 8),
    Size = UDim2.new(1, -16, 0, 36),
    BackgroundTransparency = 1,
    ZIndex = 2,
})

do
    local bloom = frame(Indicator, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 3),
        Size = UDim2.new(1, 8, 1, 8),
        BackgroundColor3 = PURPLE,
        BackgroundTransparency = 0.84,
        ZIndex = 1,
    })
    corner(bloom, 14)

    local pill = frame(Indicator, { Size = UDim2.fromScale(1, 1), ZIndex = 2 })
    corner(pill, 11)
    local pillGradient = gradient(pill, ACCENT_GRADIENT, 0)

    local gloss = frame(pill, { Size = UDim2.new(1, 0, 0.5, 0), BackgroundTransparency = 0.82 })
    corner(gloss, 11)

    animate(function(t)
        if not (Fx.enabled and Window.Visible) then return end
        pillGradient.Rotation = math.sin(t * 0.7) * 25
        bloom.BackgroundTransparency = 0.9 + math.sin(t * 2) * 0.03
    end)
end

local Side = {}
do
    local foot = frame(Sidebar, {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 8, 1, -8),
        Size = UDim2.new(1, -16, 0, 70),
        BackgroundColor3 = SURFACE_2,
        BackgroundTransparency = 0.1,
        ZIndex = 2,
    })
    corner(foot, 12)
    outline(foot, STROKE, 1, 0)

    local caption = label(foot, 9, true, DIM)
    caption.Position = UDim2.fromOffset(12, 10)
    caption.Size = UDim2.new(1, -24, 0, 12)
    caption.Text = "RXZ BQM"

    local value = label(foot, 16, "black", WHITE)
    value.Position = UDim2.fromOffset(12, 22)
    value.Size = UDim2.new(1, -24, 0, 26)
    value.Text = "STREETS"
    table.insert(Fx.shines, gradient(value, SHINE_GRADIENT, 0))

    local best = label(foot, 9, false, DIM)
    best.Position = UDim2.fromOffset(12, 48)
    best.Size = UDim2.new(1, -24, 0, 12)
    best.TextTruncate = Enum.TextTruncate.AtEnd
    best.Text = "RXZ BQM STREETS"

    Side.hits = value
    Side.best = best
end

local Content = frame(Window, {
    Position = UDim2.fromOffset(168, 76),
    Size = UDim2.new(1, -184, 1, -92),
    BackgroundColor3 = CARD,
    BackgroundTransparency = 0.3,
    ZIndex = 2,
})
corner(Content, 16)
outline(Content, STROKE, 1, 0)

local Toast = { serial = 0 }
do
    local holder = nil
    local ok = pcall(function() holder = Instance.new("CanvasGroup") end)
    if not ok or not holder then holder = Instance.new("Frame") end
    holder.AnchorPoint = Vector2.new(1, 0)
    holder.Position = UDim2.new(1, -18, 0, 78)
    holder.Size = UDim2.fromOffset(240, 54)
    holder.BackgroundColor3 = SURFACE_2
    holder.BorderSizePixel = 0
    holder.Visible = false
    holder.ZIndex = 20
    holder.Parent = Window
    corner(holder, 14)
    outline(holder, PURPLE, 1, 0.45)

    local icon = frame(holder, { Position = UDim2.fromOffset(11, 11), Size = UDim2.fromOffset(32, 32) })
    corner(icon, 10)
    gradient(icon, ACCENT_GRADIENT, 45)

    local iconText = label(icon, 10, "black", WHITE)
    iconText.Size = UDim2.fromScale(1, 1)
    iconText.TextXAlignment = Enum.TextXAlignment.Center

    local heading = label(holder, 9, true, LILAC)
    heading.Position = UDim2.fromOffset(53, 11)
    heading.Size = UDim2.new(1, -64, 0, 12)

    local body = label(holder, 11, true, INK)
    body.Position = UDim2.fromOffset(53, 25)
    body.Size = UDim2.new(1, -64, 0, 16)
    body.TextTruncate = Enum.TextTruncate.AtEnd

    local progress = frame(holder, { Position = UDim2.new(0, 12, 1, -5), Size = UDim2.new(1, -24, 0, 2) })
    round(progress)
    gradient(progress, ACCENT_GRADIENT, 0)

    local SHOWN_AT, HIDDEN_AT = UDim2.new(1, -18, 0, 78), UDim2.new(1, 0, 0, 78)

    function Toast.show(headingText, bodyText, badge)
        if not Window.Visible or not Content.Visible then return end

        Toast.serial = Toast.serial + 1
        local serial = Toast.serial

        heading.Text = string.upper(headingText or "")
        body.Text = bodyText or ""
        iconText.Text = badge or "!"

        if not holder.Visible then
            holder.Position = HIDDEN_AT
            pcall(function() holder.GroupTransparency = 1 end)
        end
        holder.Visible = true
        tween(holder, 0.5, { Position = SHOWN_AT }, Enum.EasingStyle.Back)
        tween(holder, 0.3, { GroupTransparency = 0 })

        progress.Size = UDim2.new(1, -24, 0, 2)
        tween(progress, 2.8, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

        task.delay(2.9, function()
            if serial ~= Toast.serial then return end
            tween(holder, 0.3, { Position = HIDDEN_AT }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tween(holder, 0.25, { GroupTransparency = 1 })
            task.delay(0.32, function()
                if serial == Toast.serial then holder.Visible = false end
            end)
        end)
    end
end

local Pages = {}
local Tabs = {}
local currentTab = nil
local activate = nil

local TAB_HEIGHT, TAB_GAP = 36, 6

local function newPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Position = UDim2.fromOffset(10, 10)
    page.Size = UDim2.new(1, -20, 1, -20)
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = PURPLE
    page.ScrollBarImageTransparency = 0.45
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    pad(page, 1, 8, 1, 10)

    Pages[name] = page
    return page
end

local function newTab(name, order)
    local y = 8 + (order - 1) * (TAB_HEIGHT + TAB_GAP)

    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = UDim2.fromOffset(8, y)
    button.Size = UDim2.new(1, -16, 0, TAB_HEIGHT)
    button.BackgroundColor3 = SURFACE_3
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.ZIndex = 3
    button.Parent = Sidebar
    corner(button, 11)

    local marker = frame(button, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 16, 0.5, 0),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = LILAC,
    })
    round(marker)

    local text = label(button, 12, false, DIM)
    text.Position = UDim2.fromOffset(30, 0)
    text.Size = UDim2.new(1, -36, 1, 0)
    text.Text = name

    Tabs[name] = { button = button, marker = marker, text = text, y = y, page = newPage(name) }

    button.MouseEnter:Connect(function()
        if currentTab == name then return end
        tween(button, 0.18, { BackgroundTransparency = 0.45 })
        tween(text, 0.18, { TextColor3 = LILAC, Position = UDim2.fromOffset(33, 0) })
    end)
    button.MouseLeave:Connect(function()
        if currentTab == name then return end
        tween(button, 0.22, { BackgroundTransparency = 1 })
        tween(text, 0.22, { TextColor3 = DIM, Position = UDim2.fromOffset(30, 0) })
    end)
    button.MouseButton1Click:Connect(function()
        if activate then activate(name) end
    end)

    return Tabs[name].page
end

activate = function(name)
    local previousTab = currentTab
    currentTab = name

    for key, tab in pairs(Tabs) do
        local active = (key == name)
        tab.page.Visible = active
        tab.text.Font = active and Enum.Font.GothamBold or Enum.Font.GothamMedium

        tween(tab.button, 0.2, { BackgroundTransparency = 1 })
        tween(tab.text, 0.25, {
            TextColor3 = active and WHITE or DIM,
            Position = UDim2.fromOffset(active and 32 or 30, 0),
        })
        tween(tab.marker, 0.35, {
            BackgroundColor3 = active and WHITE or LILAC,
            Size = active and UDim2.fromOffset(8, 8) or UDim2.fromOffset(6, 6),
        }, Enum.EasingStyle.Back)

        if active then
            tween(Indicator, 0.45, { Position = UDim2.fromOffset(8, tab.y) })
            if previousTab ~= name then
                tab.page.Position = UDim2.fromOffset(10, 26)
                tween(tab.page, 0.45, { Position = UDim2.fromOffset(10, 10) })
            end
        end
    end
end

local UI = {}

local function ripple(host, color, centred)
    pcall(function()
        local origin, size = host.AbsolutePosition, host.AbsoluteSize
        local x, y = size.X / 2, size.Y / 2

        if not centred then
            local mouse = UserInputService:GetMouseLocation()
            local mx, my = mouse.X - origin.X, mouse.Y - origin.Y
            if mx >= 0 and my >= 0 and mx <= size.X and my <= size.Y then x, y = mx, my end
        end

        local scale = math.max(WindowScale.Scale, 0.01)
        local diameter = math.max(size.X, size.Y) * 2.4 / scale

        local dot = frame(host, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(x / scale, y / scale),
            Size = UDim2.fromOffset(0, 0),
            BackgroundColor3 = color or PURPLE,
            BackgroundTransparency = 0.75,
            ZIndex = 0,
        })
        round(dot)

        tween(dot, 0.6, { Size = UDim2.fromOffset(diameter, diameter), BackgroundTransparency = 1 },
            Enum.EasingStyle.Quad)
        task.delay(0.65, function() pcall(function() dot:Destroy() end) end)
    end)
end

local function card(page, height)
    local item = frame(page, {
        Size = UDim2.new(1, -2, 0, height),
        BackgroundColor3 = CARD,
        BackgroundTransparency = GLASS,
        ClipsDescendants = true,
        LayoutOrder = nextOrder(),
    })
    corner(item, 13)

    local stroke = outline(item, WHITE, 1, 0)
    gradient(stroke, ColorSequence.new(Color3.fromRGB(94, 63, 76), STROKE), 90)

    return item, stroke
end

local function hoverable(row, hit, stroke)
    hit.MouseEnter:Connect(function()
        tween(row, 0.18, { BackgroundTransparency = GLASS_HI, BackgroundColor3 = CARD_HI })
        if stroke then tween(stroke, 0.18, { Color = LILAC }) end
    end)
    hit.MouseLeave:Connect(function()
        tween(row, 0.3, { BackgroundTransparency = GLASS, BackgroundColor3 = CARD })
        if stroke then tween(stroke, 0.3, { Color = WHITE }) end
    end)
end

function UI.section(page, titleText)
    local holder = frame(page, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -2, 0, 22),
        LayoutOrder = nextOrder(),
    })

    local dot = frame(holder, {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(6, 6),
    })
    round(dot)
    gradient(dot, ACCENT_GRADIENT, 45)

    local text = label(holder, 10, true, LILAC)
    text.Position = UDim2.fromOffset(16, 0)
    text.Size = UDim2.new(0, 0, 1, 0)
    text.AutomaticSize = Enum.AutomaticSize.X
    text.Text = string.upper(titleText)

    local line = frame(holder, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(1, -120, 0, 1),
    })
    gradient(line, ACCENT_GRADIENT, 0, fade({ { 0, 0.55 }, { 1, 1 } }))

    local function fit()
        line.Size = UDim2.new(1, -(text.AbsoluteSize.X / math.max(WindowScale.Scale, 0.01) + 30), 0, 1)
    end
    text:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
    task.defer(fit)

    return holder
end

function UI.button(page, opt)
    local hasDesc = opt.desc ~= nil and opt.desc ~= ""
    local row, stroke = card(page, hasDesc and 52 or 40)

    local hit = Instance.new("TextButton")
    hit.BackgroundTransparency = 1
    hit.Size = UDim2.fromScale(1, 1)
    hit.Text = ""
    hit.AutoButtonColor = false
    hit.ZIndex = 3
    hit.Parent = row

    local title = label(row, 12, true, INK)
    title.Position = UDim2.fromOffset(14, hasDesc and 10 or 0)
    title.Size = UDim2.new(1, -56, 0, hasDesc and 16 or 40)
    title.Text = opt.name

    if hasDesc then
        local desc = label(row, 10, false, DIM)
        desc.Position = UDim2.fromOffset(14, 28)
        desc.Size = UDim2.new(1, -56, 0, 14)
        desc.TextTruncate = Enum.TextTruncate.AtEnd
        desc.Text = opt.desc
    end

    local badge = frame(row, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = MIST,
    })
    round(badge)

    local chevron = label(badge, 15, true, LILAC)
    chevron.Size = UDim2.fromScale(1, 1)
    chevron.Position = UDim2.fromOffset(1, -1)
    chevron.TextXAlignment = Enum.TextXAlignment.Center
    chevron.Text = "›"

    hoverable(row, hit, stroke)
    hit.MouseEnter:Connect(function()
        tween(badge, 0.25, { BackgroundColor3 = PURPLE, Position = UDim2.new(1, -9, 0.5, 0) })
        tween(chevron, 0.25, { TextColor3 = WHITE })
    end)
    hit.MouseLeave:Connect(function()
        tween(badge, 0.3, { BackgroundColor3 = MIST, Position = UDim2.new(1, -12, 0.5, 0) })
        tween(chevron, 0.3, { TextColor3 = LILAC })
    end)

    hit.MouseButton1Click:Connect(function()
        ripple(row, PURPLE)
        if opt.callback then pcall(opt.callback) end
    end)

    return row
end

function UI.label(page, value, muted)
    local holder = frame(page, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -2, 0, 16),
        LayoutOrder = nextOrder(),
    })

    local text = label(holder, 10, false, muted and DIM or INK)
    text.Position = UDim2.fromOffset(4, 0)
    text.Size = UDim2.new(1, -8, 1, 0)
    text.Text = value

    return text
end

function UI.entry(page)
    local row, stroke = card(page, 52)
    hoverable(row, row, stroke)

    local bar = frame(row, {
        Position = UDim2.fromOffset(9, 11),
        Size = UDim2.new(0, 3, 1, -22),
    })
    round(bar)
    gradient(bar, ACCENT_GRADIENT, 90)

    local title = label(row, 12, true, INK)
    title.Position = UDim2.fromOffset(22, 9)
    title.Size = UDim2.new(1, -100, 0, 16)
    title.TextTruncate = Enum.TextTruncate.AtEnd

    local body = label(row, 10, false, DIM)
    body.Position = UDim2.fromOffset(22, 27)
    body.Size = UDim2.new(1, -100, 0, 14)
    body.TextTruncate = Enum.TextTruncate.AtEnd

    local chip = frame(row, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(60, 20),
        Visible = false,
    })
    round(chip)
    local chipGradient = gradient(chip, ACCENT_GRADIENT, 0)
    local chipStroke = outline(chip, PURPLE, 1, 0.5)

    local chipText = label(chip, 9, true, WHITE)
    chipText.Size = UDim2.fromScale(1, 1)
    chipText.TextXAlignment = Enum.TextXAlignment.Center

    local entry = { frame = row }

    function entry.Set(_, data)
        pcall(function()
            title.Text = data.Title or ""
            body.Text = data.Text or ""

            local rarity = data.Rarity
            chip.Visible = type(rarity) == "string" and #rarity > 0
            if rarity == "Secret" then
                chipGradient.Enabled = true
                chip.BackgroundColor3 = WHITE
                chipText.TextColor3 = WHITE
                chipStroke.Transparency = 1
            else
                chipGradient.Enabled = false
                chip.BackgroundColor3 = MIST
                chipText.TextColor3 = LILAC
                chipStroke.Transparency = 0.5
            end
            chipText.Text = string.upper(tostring(rarity or ""))
        end)
    end

    function entry.Flash()
        pcall(function()
            row.BackgroundColor3 = Color3.fromRGB(80, 43, 59)
            row.BackgroundTransparency = 0
            tween(row, 1.1, { BackgroundColor3 = CARD, BackgroundTransparency = GLASS }, Enum.EasingStyle.Quad)
            bar.Size = UDim2.new(0, 3, 0, 0)
            tween(bar, 0.5, { Size = UDim2.new(0, 3, 1, -22) }, Enum.EasingStyle.Back)
            ripple(row, ORCHID, true)
        end)
    end

    function entry.Destroy()
        pcall(function() row:Destroy() end)
    end

    return entry
end

function UI.toggle(page, opt)
    local row, stroke = card(page, 52)

    local title = label(row, 12, true, INK)
    title.Position = UDim2.fromOffset(14, opt.desc and 10 or 0)
    title.Size = UDim2.new(1, -84, 0, opt.desc and 16 or 52)
    title.Text = opt.name

    if opt.desc then
        local desc = label(row, 10, false, DIM)
        desc.Position = UDim2.fromOffset(14, 28)
        desc.Size = UDim2.new(1, -84, 0, 14)
        desc.TextTruncate = Enum.TextTruncate.AtEnd
        desc.Text = opt.desc
    end

    local track = frame(row, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(46, 26),
        BackgroundColor3 = MIST,
    })
    round(track)

    local fill = frame(track, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 })
    round(fill)
    gradient(fill, ACCENT_GRADIENT, 0)

    local knob = frame(track, {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 2,
    })
    round(knob)
    outline(knob, STROKE, 1, 0)

    local hit = Instance.new("TextButton")
    hit.BackgroundTransparency = 1
    hit.Size = UDim2.fromScale(1, 1)
    hit.Text = ""
    hit.AutoButtonColor = false
    hit.ZIndex = 3
    hit.Parent = row

    hoverable(row, hit, stroke)

    local on = opt.value and true or false

    local function paint()
        tween(fill, 0.25, { BackgroundTransparency = on and 0 or 1 })
        tween(knob, 0.4, { Position = on and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) },
            Enum.EasingStyle.Back)
    end

    paint()

    hit.MouseButton1Click:Connect(function()
        on = not on
        paint()
        ripple(row, PURPLE)
        if opt.callback then pcall(opt.callback, on) end
    end)

    return {
        Set = function(_, value)
            on = value and true or false
            paint()
        end,
        Get = function() return on end,
    }
end

function UI.slider(page, opt)
    local row, stroke = card(page, 62)

    local title = label(row, 12, true, INK)
    title.Position = UDim2.fromOffset(14, 11)
    title.Size = UDim2.new(1, -110, 0, 16)
    title.Text = opt.name

    local valuePill = frame(row, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 9),
        Size = UDim2.fromOffset(72, 20),
        BackgroundColor3 = MIST,
    })
    round(valuePill)

    local valueLabel = label(valuePill, 10, true, LILAC)
    valueLabel.Size = UDim2.fromScale(1, 1)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center

    local track = frame(row, {
        Position = UDim2.fromOffset(16, 42),
        Size = UDim2.new(1, -32, 0, 6),
        BackgroundColor3 = MIST,
    })
    round(track)

    local fill = frame(track, { Size = UDim2.new(0, 0, 1, 0) })
    round(fill)
    gradient(fill, ACCENT_GRADIENT, 0)

    local knob = frame(track, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(16, 16),
        ZIndex = 2,
    })
    round(knob)
    outline(knob, PURPLE, 2, 0)

    local knobScale = Instance.new("UIScale")
    knobScale.Parent = knob

    local grab = frame(row, {
        Position = UDim2.fromOffset(8, 32),
        Size = UDim2.new(1, -16, 0, 26),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 3,
    })

    hoverable(row, row, stroke)

    local minimum, maximum = opt.min, opt.max
    local value = math.clamp(opt.value or minimum, minimum, maximum)
    local dragging = false

    local function paint()
        local alpha = (maximum == minimum) and 0 or (value - minimum) / (maximum - minimum)
        alpha = math.clamp(alpha, 0, 1)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = opt.format and opt.format(value) or tostring(value)
    end

    local function applyFromX(x)
        local alpha = (x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
        alpha = math.clamp(alpha, 0, 1)

        local raw = minimum + (maximum - minimum) * alpha
        if opt.increment and opt.increment > 0 then
            raw = math.floor(raw / opt.increment + 0.5) * opt.increment
        end

        local nextValue = math.clamp(raw, minimum, maximum)
        if nextValue ~= value then
            value = nextValue
            paint()
            if opt.callback then pcall(opt.callback, value) end
        end
    end

    grab.MouseEnter:Connect(function()
        if not dragging then tween(knobScale, 0.25, { Scale = 1.18 }, Enum.EasingStyle.Back) end
    end)
    grab.MouseLeave:Connect(function()
        if not dragging then tween(knobScale, 0.25, { Scale = 1 }) end
    end)

    grab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            tween(knobScale, 0.25, { Scale = 1.35 }, Enum.EasingStyle.Back)
            tween(valuePill, 0.2, { BackgroundColor3 = PURPLE })
            tween(valueLabel, 0.2, { TextColor3 = WHITE })
            applyFromX(input.Position.X)
        end
    end)

    bind(UserInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            applyFromX(input.Position.X)
        end
    end)

    bind(UserInputService.InputEnded, function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            tween(knobScale, 0.3, { Scale = 1 })
            tween(valuePill, 0.3, { BackgroundColor3 = MIST })
            tween(valueLabel, 0.3, { TextColor3 = LILAC })
        end
    end)

    paint()

    return {
        Set = function(_, newValue)
            value = math.clamp(newValue, minimum, maximum)
            paint()
        end,
    }
end

function UI.input(page, opt)
    local row = card(page, 56)

    local title = label(row, 12, true, INK)
    title.Position = UDim2.fromOffset(14, 10)
    title.Size = UDim2.new(1, -160, 0, 16)
    title.Text = opt.name

    local desc = label(row, 10, false, DIM)
    desc.Position = UDim2.fromOffset(14, 28)
    desc.Size = UDim2.new(1, -160, 0, 14)
    desc.TextTruncate = Enum.TextTruncate.AtEnd
    desc.Text = opt.desc or ""

    local box = Instance.new("TextBox")
    box.AnchorPoint = Vector2.new(1, 0.5)
    box.Position = UDim2.new(1, -12, 0.5, 0)
    box.Size = UDim2.fromOffset(128, 32)
    box.BackgroundColor3 = SURFACE_2
    box.BackgroundTransparency = 0.15
    box.BorderSizePixel = 0
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.TextColor3 = LILAC
    box.PlaceholderText = opt.placeholder or ""
    box.PlaceholderColor3 = DIM
    box.Text = opt.value or ""
    box.ClearTextOnFocus = false
    box.Parent = row
    corner(box, 10)
    pad(box, 10, 10)

    focusRing(box, outline(box, STROKE, 1, 0), row)

    box.FocusLost:Connect(function()
        if opt.callback then pcall(opt.callback, box.Text) end
    end)

    return {
        Set = function(_, value) box.Text = value end,
        Get = function() return box.Text end,
    }
end


local UIState = { shown = true, minimized = false, width = WIDTH, height = HEIGHT }

local Drag = { active = false, start = nil, origin = nil, target = nil }

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        Drag.active = true
        Drag.start = input.Position
        Drag.origin = Drag.target or Window.Position
        Drag.target = Drag.origin

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Drag.active = false
            end
        end)
    end
end)

bind(UserInputService.InputChanged, function(input)
    if not Drag.active or not Drag.start or not Drag.origin then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - Drag.start
        Drag.target = UDim2.new(
            Drag.origin.X.Scale, Drag.origin.X.Offset + delta.X,
            Drag.origin.Y.Scale, Drag.origin.Y.Offset + delta.Y
        )
    end
end)

animate(function(_, dt)
    if not Drag.target then return end
    local current = Window.Position
    Window.Position = current:Lerp(Drag.target, math.min(1, dt * 20))

    if not Drag.active
        and math.abs(Window.Position.X.Offset - Drag.target.X.Offset) < 0.5
        and math.abs(Window.Position.Y.Offset - Drag.target.Y.Offset) < 0.5 then
        Window.Position = Drag.target
        Drag.target = nil
    end
end)

animate(function(t)
    Glow.Visible = Window.Visible
    if not Window.Visible then return end

    local scale = WindowScale.Scale
    Glow.Position = Window.Position
    Glow.Size = UDim2.fromOffset(Window.Size.X.Offset * scale, Window.Size.Y.Offset * scale)

    local pulse = Fx.enabled and math.sin(t * 1.6) * 0.012 or 0
    for index, layer in ipairs(GlowLayers) do
        layer.BackgroundTransparency = 0.935 + index * 0.008 - pulse - Fx.energy * 0.02
    end
end)

animate(function(t)
    if not Window.Visible or not Fx.enabled then return end
    local offset = ((t * 0.32) % 2.6) - 1.3
    for _, shine in ipairs(Fx.shines) do
        shine.Offset = Vector2.new(offset, 0)
    end
end)

local Grip = Instance.new("TextButton")
Grip.AnchorPoint = Vector2.new(1, 1)
Grip.Position = UDim2.new(1, -5, 1, -5)
Grip.Size = UDim2.fromOffset(18, 18)
Grip.BackgroundTransparency = 1
Grip.AutoButtonColor = false
Grip.Text = ""
Grip.ZIndex = 8
Grip.Parent = Window

do
    local dots = {}
    for index, spot in ipairs({ { 14, 14 }, { 9, 14 }, { 14, 9 }, { 4, 14 }, { 9, 9 }, { 14, 4 } }) do
        local dot = frame(Grip, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(spot[1], spot[2]),
            Size = UDim2.fromOffset(3, 3),
            BackgroundColor3 = LILAC,
        })
        round(dot)
        dots[index] = dot
    end

    local function paintDots(color)
        for _, dot in ipairs(dots) do tween(dot, 0.18, { BackgroundColor3 = color }) end
    end

    local Resize = { active = false }

    Grip.MouseEnter:Connect(function() paintDots(PURPLE) end)
    Grip.MouseLeave:Connect(function() if not Resize.active then paintDots(LILAC) end end)

    Grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Resize.active = true
            Resize.start = input.Position
            Resize.size = Vector2.new(Window.Size.X.Offset, Window.Size.Y.Offset)
            Resize.origin = Drag.target or Window.Position
            Drag.target = nil
            Window.Position = Resize.origin
        end
    end)

    bind(UserInputService.InputChanged, function(input)
        if not Resize.active then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = (input.Position - Resize.start) / math.max(WindowScale.Scale, 0.01)
            local width = math.clamp(Resize.size.X + delta.X, 520, 980)
            local height = math.clamp(Resize.size.Y + delta.Y, 400, 760)

            Window.Size = UDim2.fromOffset(width, height)
            Window.Position = UDim2.new(
                Resize.origin.X.Scale, Resize.origin.X.Offset + (width - Resize.size.X) / 2,
                Resize.origin.Y.Scale, Resize.origin.Y.Offset + (height - Resize.size.Y) / 2
            )
            UIState.width, UIState.height = width, height
        end
    end)

    bind(UserInputService.InputEnded, function(input)
        if not Resize.active then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Resize.active = false
            paintDots(LILAC)
        end
    end)
end

local function setMinimized(state)
    UIState.minimized = state
    if state then
        Sidebar.Visible = false
        Content.Visible = false
        Grip.Visible = false
        tween(Window, 0.4, { Size = UDim2.fromOffset(UIState.width, 66) })
    else
        tween(Window, 0.45, { Size = UDim2.fromOffset(UIState.width, UIState.height) })
        task.delay(0.12, function()
            if not UIState.minimized then
                Sidebar.Visible = true
                Content.Visible = true
                Grip.Visible = true
            end
        end)
    end
end

local Reopen = Instance.new("TextButton")
Reopen.AnchorPoint = Vector2.new(0.5, 0.5)
Reopen.Position = UDim2.fromOffset(42, 42)
Reopen.Size = UDim2.fromOffset(46, 46)
Reopen.BackgroundColor3 = WHITE
Reopen.BorderSizePixel = 0
Reopen.AutoButtonColor = false
Reopen.Font = Enum.Font.GothamBlack
Reopen.TextSize = 19
Reopen.TextColor3 = WHITE
Reopen.Text = "R"
Reopen.Visible = false
Reopen.ZIndex = 3
Reopen.Parent = Screen
round(Reopen)
outline(Reopen, WHITE, 1.5, 0.3)

do
    local reopenGradient = gradient(Reopen, ACCENT_GRADIENT, 45)
    local reopenScale = Instance.new("UIScale")
    reopenScale.Parent = Reopen

    local halo = softOrb(Screen, PURPLE, 96, 0.3)
    halo.Position = Reopen.Position
    halo.ZIndex = 2
    halo.Visible = false

    UIState.reopenScale = reopenScale

    Reopen.MouseEnter:Connect(function() tween(reopenScale, 0.3, { Scale = 1.1 }, Enum.EasingStyle.Back) end)
    Reopen.MouseLeave:Connect(function() tween(reopenScale, 0.25, { Scale = 1 }) end)

    animate(function(t)
        halo.Visible = Reopen.Visible
        if not Reopen.Visible then return end
        reopenGradient.Rotation = (t * 60) % 360
        local size = 92 + math.sin(t * 2.4) * 10
        halo.Size = UDim2.fromOffset(size, size)
    end)
end

local function showWindow(visible)
    UIState.shown = visible

    if visible then
        Reopen.Visible = false
        Window.Visible = true
        WindowScale.Scale = 0.9
        tween(WindowScale, 0.5, { Scale = math.min(1, Screen.AbsoluteSize.X / (UIState.width + 24), Screen.AbsoluteSize.Y / (UIState.height + 24)) }, Enum.EasingStyle.Back)
    else
        tween(WindowScale, 0.18, { Scale = 0.9 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.18, function()
            if UIState.shown then return end
            Window.Visible = false
            Reopen.Visible = true
            UIState.reopenScale.Scale = 0.4
            tween(UIState.reopenScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
        end)
    end
end

headerButton("×", -16, function()
    showWindow(false)
end)

headerButton("–", -48, function()
    setMinimized(not UIState.minimized)
end)

Reopen.MouseButton1Click:Connect(function()
    showWindow(true)
end)

bind(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        showWindow(not UIState.shown)
    end
end)

bind(RunService.Heartbeat, function(dt)
    Fx.clock = Fx.clock + dt
    local t = Fx.clock
    for index = #Fx.animators, 1, -1 do
        local ok, done = pcall(Fx.animators[index], t, dt)
        if not ok or done then table.remove(Fx.animators, index) end
    end
end)

-- First gameplay tab is activated when created.
PillText.Text = "READY"
showWindow(true)

-- Dropdown control using the source interface's cards, typography and colors.
function UI.dropdown(page, opt)
    local row = card(page, 58)
    local heading = label(row, 12, true, INK)
    heading.Position = UDim2.fromOffset(14, 7)
    heading.Size = UDim2.new(1, -28, 0, 18)
    heading.Text = opt.name
    local pick = Instance.new("TextButton")
    pick.Position = UDim2.fromOffset(12, 30)
    pick.Size = UDim2.new(1, -24, 0, 23)
    pick.BackgroundColor3 = SURFACE_2
    pick.TextColor3 = LILAC
    pick.BorderSizePixel = 0
    pick.Font = Enum.Font.GothamBold
    pick.TextSize = 11
    pick.AutoButtonColor = false
    pick.Parent = row
    corner(pick, 6)
    local menu = Instance.new("ScrollingFrame")
    menu.Position = UDim2.fromOffset(12, 60)
    menu.Size = UDim2.new(1, -24, 0, 140)
    menu.BackgroundTransparency = 1
    menu.BorderSizePixel = 0
    menu.ScrollBarThickness = 3
    menu.ScrollBarImageColor3 = PURPLE
    menu.CanvasSize = UDim2.new()
    menu.AutomaticCanvasSize = Enum.AutomaticSize.Y
    menu.Visible = false
    menu.Parent = row
    local layout = Instance.new("UIListLayout", menu)
    layout.Padding = UDim.new(0, 3)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local values = opt.values or {}
    local selected = opt.value or values[1] or ""
    local buttons = {}
    local function paint() pick.Text = tostring(selected) .. "  ▾" end
    local function collapse() menu.Visible = false row.Size = UDim2.new(1, -2, 0, 58) end
    local function rebuild()
        for _, button in ipairs(buttons) do button:Destroy() end
        buttons = {}
        for i, item in ipairs(values) do
            local choice = Instance.new("TextButton")
            choice.Size = UDim2.new(1, -6, 0, 26)
            choice.LayoutOrder = i
            choice.BackgroundColor3 = SURFACE_2
            choice.TextColor3 = INK
            choice.Font = Enum.Font.GothamMedium
            choice.TextSize = 11
            choice.BorderSizePixel = 0
            choice.Text = tostring(item)
            choice.Parent = menu
            corner(choice, 6)
            choice.MouseButton1Click:Connect(function()
                selected = item
                paint() collapse()
                if opt.callback then opt.callback(item) end
            end)
            buttons[#buttons+1] = choice
        end
    end
    pick.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
        row.Size = UDim2.new(1, -2, 0, menu.Visible and 206 or 58)
    end)
    paint() rebuild()
    return { Refresh = function(_, list, value)
        local changed = #list ~= #values
        if not changed then for i, item in ipairs(list) do if item ~= values[i] then changed = true break end end end
        values = list
        local found = false
        for _, item in ipairs(values) do if item == value then found = true end end
        selected = found and value or values[1] or ""
        if not found and opt.callback then opt.callback(selected) end
        paint()
        if changed then rebuild() end
    end }
end
local WindowAdapter = {}
local tabCount = 0
function WindowAdapter:Tab(opt)
    tabCount = tabCount + 1
    local page = newTab(opt.Title, tabCount)
    if tabCount == 1 then activate(opt.Title) end
    local tab = {}
    function tab:Section(o) return UI.section(page, o.Title) end
    function tab:Toggle(o) return UI.toggle(page, { name=o.Title, desc=o.Desc, value=o.Value, callback=o.Callback }) end
    function tab:Dropdown(o) return UI.dropdown(page, { name=o.Title, values=o.Values, value=o.Default, callback=o.Callback }) end
    function tab:Input(o) return UI.input(page, { name=o.Title, desc=o.Desc, value=o.Default, placeholder=o.Placeholder, callback=o.Callback }) end
    function tab:Slider(o) return UI.slider(page, { name=o.Title, min=o.Min, max=o.Max, increment=o.Step or 1, value=o.Value, callback=o.Callback }) end
    function tab:Button(o) return UI.button(page, { name=o.Title, desc=o.Desc, callback=o.Callback }) end
    return tab
end
local settingsTab = function()
    local page = newTab("الواجهة", tabCount + 1)
    UI.section(page, "RXZ BQM STREETS")
    UI.toggle(page, { name="حركة الواجهة", value=true, callback=function(on) Fx.enabled=on end })
    UI.slider(page, { name="حجم الواجهة", min=0.45, max=1, increment=0.05, value=WindowScale.Scale,
        format=function(v) return tostring(math.floor(v*100+0.5)) .. "%" end,
        callback=function(v) WindowScale.Scale=math.min(v, Screen.AbsoluteSize.X/(UIState.width+24), Screen.AbsoluteSize.Y/(UIState.height+24)) end })
    UI.button(page, { name="إغلاق السكربت", callback=function() if uiShutdown then uiShutdown() end end })
end
function WindowAdapter:AddSettings() settingsTab() end
local destroyed = false
local function destroyUI()
    if destroyed then return end
    destroyed = true
    Fx.animators = {}
    for _, c in ipairs(Fx.connections) do c:Disconnect() end
    Fx.connections = {}
    Gui:Destroy()
end
WindowAdapter.DestroyUI = destroyUI
return { CreateWindow=function() return WindowAdapter end }
end)()

local players = game:GetService("Players")
local workspaceService = game:GetService("Workspace")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer
local currentCamera = workspace.CurrentCamera

local v1 = {
  AimbotEnabled = false,
  AimbotTargetPart = "Head",
  Wallbang = true,
  AimbotSmoothness = 4,
  SelectedTargetName = "الكل",
  SpeedEnabled = false,
  SpeedLevel = 1,
  ESPEnabled = false,
  ESPLines = false,
  ESPLineThickness = 2,
  ESPMaxRange = 2500,
  NameAndItemESP = false,
  DeathProtectEnabled = false,
  ManualUnderground = false,
  UndergroundLevel = 3,
  IsHidden = false,
  OriginalPosition = nil,
}

local v2 = {
  C9 = { Color = Color3.fromRGB(0, 255, 0) },
  G3 = { Color = Color3.fromRGB(0, 255, 0) },
  P226 = { Color = Color3.fromRGB(0, 255, 0) },
  Uzi = { Color = Color3.fromRGB(0, 255, 0) },
  ["Sawed Off"] = { Color = Color3.fromRGB(0, 255, 0) },
  ["Hunting Rifle"] = { Color = Color3.fromRGB(0, 255, 0) },
  Crossbow = { Color = Color3.fromRGB(0, 255, 0) },
  ["Fire Cracker"] = { Color = Color3.fromRGB(0, 255, 0) },
  ["Rusty Shovel"] = { Color = Color3.fromRGB(0, 255, 0) },
  ["Nailed Wooden Board"] = { Color = Color3.fromRGB(0, 255, 0) },
  ["Chair Leg / Club"] = { Color = Color3.fromRGB(0, 255, 0) },
  ["Tire Iron"] = { Color = Color3.fromRGB(0, 255, 0) },
  ["Baseball Bat"] = { Color = Color3.fromRGB(0, 255, 0) },
  ["Dumbbell Plate"] = { Color = Color3.fromRGB(0, 255, 0) },
  Brick = { Color = Color3.fromRGB(0, 255, 0) },
  Glock = { Color = Color3.fromRGB(100, 100, 100) },
  Bottle = { Color = Color3.fromRGB(100, 100, 100) },
  ["Frying Pan"] = { Color = Color3.fromRGB(0, 170, 255) },
  Switchblade = { Color = Color3.fromRGB(0, 170, 255) },
  ["Butcher Knife"] = { Color = Color3.fromRGB(0, 170, 255) },
  Wrench = { Color = Color3.fromRGB(0, 170, 255) },
  Axe = { Color = Color3.fromRGB(0, 170, 255) },
  ["Metal Bat"] = { Color = Color3.fromRGB(0, 170, 255) },
  ["Metal Baseball Bat"] = { Color = Color3.fromRGB(0, 170, 255) },
  Sawnoff = { Color = Color3.fromRGB(0, 170, 255) },
  ["Jerry Can"] = { Color = Color3.fromRGB(0, 170, 255) },
  ["Double Barrel"] = { Color = Color3.fromRGB(170, 0, 255) },
  M24 = { Color = Color3.fromRGB(170, 0, 255) },
  Draco = { Color = Color3.fromRGB(170, 0, 255) },
  ["Machete and Shovel"] = { Color = Color3.fromRGB(170, 0, 255) },
  ["Combat Axe"] = { Color = Color3.fromRGB(170, 0, 255) },
  ["Sledge Hammer"] = { Color = Color3.fromRGB(170, 0, 255) },
  ["Barbed Bat"] = { Color = Color3.fromRGB(170, 0, 255) },
  Hammer = { Color = Color3.fromRGB(170, 0, 255) },
  Crowbar = { Color = Color3.fromRGB(170, 0, 255) },
  Molotov = { Color = Color3.fromRGB(170, 0, 255) },
  RPG = { Color = Color3.fromRGB(255, 180, 0) },
  Remington = { Color = Color3.fromRGB(255, 180, 0) },
  AK47K = { Color = Color3.fromRGB(255, 180, 0) },
  MP5 = { Color = Color3.fromRGB(255, 180, 0) },
  Minigun = { Color = Color3.fromRGB(255, 180, 0) },
  ["Tactical Axe"] = { Color = Color3.fromRGB(255, 180, 0) },
  ["Tactical Knife"] = { Color = Color3.fromRGB(255, 180, 0) },
  ["Tactical Shovel"] = { Color = Color3.fromRGB(255, 180, 0) },
  Anaconda = { Color = Color3.fromRGB(255, 0, 0) },
  ["Pumpkin Bomb"] = { Color = Color3.fromRGB(120, 0, 120) },
  ["Pumpkin Launcher"] = { Color = Color3.fromRGB(120, 0, 120) },
}

local tracerGui
local list = {}
local flag = true

local window = result:CreateWindow({
  Title = "RXZ BQM STREETS",
  Icon = "crosshair",
  Author = "RXZ BQM STREETS",
  Folder = "RXZ_BQM_STREETS",
  Size = UDim2.fromOffset(580, 440),
  Transparent = true,
  Theme = "Dark",
})

local tab = window:Tab({ Title = "الإيمبوت", Icon = "target" })
tab:Section({ Title = "نظام القفل الدقيق للاستهداف" })

tab:Toggle({
  Title = "تفعيل الايمبوت الثابت",
  Desc = "قفل حديدي على الهدف عند مسك السلاح",
  Value = false,
  Callback = function(value) v1.AimbotEnabled = value end,
})

local dropdown = tab:Dropdown({
  Title = "اختر لاعب محدد للايمبوت",
  Desc = "تحديد لاعب معين لتثبيت الايم عليه",
  Values = { "الكل" },
  Default = "الكل",
  Callback = function(value2) v1.SelectedTargetName = value2 end,
})

local function f1()
  local list2 = { "الكل" }

  for _, value3 in pairs(players:GetPlayers()) do
    if value3 ~= localPlayer then
      table.insert(list2, value3.Name)
    end
  end

  if dropdown and dropdown.Refresh then
    dropdown:Refresh(list2, v1.SelectedTargetName)
  end
end

table.insert(list, players.PlayerAdded:Connect(f1))
table.insert(list, players.PlayerRemoving:Connect(f1))

task.spawn(function()
  while flag do
    task.wait(2)
    f1()
  end
end)

tab:Dropdown({
  Title = "اماكن الاستهداف",
  Desc = "اختيار مكان القفل (الرأس أو الجسم)",
  Values = { "Head", "HumanoidRootPart" },
  Default = "Head",
  Callback = function(value4) v1.AimbotTargetPart = value4 end,
})

tab:Toggle({
  Title = "تجاوز الجدران (Wallbang)",
  Desc = "الاستهداف من خلف الجدران",
  Value = true,
  Callback = function(value5) v1.Wallbang = value5 end,
})

tab:Input({
  Title = "سرعة سلاسة الايم (الأقل = أسرع)",
  Desc = "اكتب القيمة (مثل 2 أو 4)",
  Default = "4",
  Placeholder = "أدخل السرعة...",
  Callback = function(value6)
    local aimbotSmoothness = tonumber(value6)

    if aimbotSmoothness then
      v1.AimbotSmoothness = math.clamp(aimbotSmoothness, 1, 100)
    end
  end,
})

local tab2 = window:Tab({ Title = "الكشف", Icon = "eye" })
tab2:Section({ Title = "الكشف المرئي الشامل" })

tab2:Toggle({
  Title = "تفعيل الكشف المرئي",
  Desc = "تحديد اللاعبين بألوان الندرة الأصلية",
  Value = false,
  Callback = function(value7) v1.ESPEnabled = value7 end,
})

tab2:Toggle({
  Title = "إظهار الفلوس والمسافة والأسماء",
  Desc = "يعرض الفلوس والاسم والمسافة والدم والأسلحة",
  Value = false,
  Callback = function(value8) v1.NameAndItemESP = value8 end,
})

local tab3 = window:Tab({ Title = "السرعة", Icon = "zap" })
tab3:Section({ Title = "السرعة الواقعية وتجميد الطاقة" })

tab3:Toggle({
  Title = "تفعيل السرعة",
  Desc = "تفعيل السرعة المتدرجة الواقعية بدون نفاذ الطاقة",
  Value = false,
  Callback = function(value9) v1.SpeedEnabled = value9 end,
})

tab3:Dropdown({
  Title = "مستوى السرعة",
  Desc = "اختر سرعة الحركة من 1 إلى 5",
  Values = { "1", "2", "3", "4", "5" },
  Default = "1",
  Callback = function(value10)
    local speedLevel = tonumber(value10)

    if speedLevel then
      v1.SpeedLevel = speedLevel
    end
  end,
})

local tab4 = window:Tab({ Title = "حماية الموت", Icon = "shield" })
tab4:Section({ Title = "نظام الحماية الذكي والنزول اليدوي" })

tab4:Toggle({
  Title = "تفعيل حماية الموت التلقائية",
  Desc = "لا ينزلك تحت الأرض إلا إذا وصل دمك 40 أو أقل لتجنب التفنيش",
  Value = false,
  Callback = function(value11) v1.DeathProtectEnabled = value11 end,
})

tab4:Toggle({
  Title = "نزول فوري تحت الأرض والثبات",
  Desc = "الخيار اليدوي للنزول الفوري والرجوع لمكانك عند إطفائه",
  Value = false,
  Callback = function(value12)
    v1.ManualUnderground = value12
    local character = localPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    if value12 then
      if humanoidRootPart then
        v1.OriginalPosition = humanoidRootPart.CFrame
      end
    else
      if v1.OriginalPosition and humanoidRootPart then
        humanoidRootPart.CFrame = v1.OriginalPosition
      end

      v1.OriginalPosition = nil
      v1.IsHidden = false
    end
  end,
})

tab4:Dropdown({
  Title = "مسافة العمق تحت الأرض",
  Desc = "من 1 (قريب جداً للأرض) إلى 10 (بعيد وعميق جداً)",
  Values = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" },
  Default = "3",
  Callback = function(value13)
    local undergroundLevel = tonumber(value13)

    if undergroundLevel then
      v1.UndergroundLevel = undergroundLevel
    end
  end,
})

tab2:Toggle({Title="خطوط اللاعبين الحمراء", Desc="خط من أسفل الشاشة إلى اللاعب", Value=false,
 Callback=function(on) v1.ESPLines=on end})
tab2:Slider({Title="سماكة الخط", Min=1, Max=5, Step=1, Value=2, Callback=function(v) v1.ESPLineThickness=v end})
tab2:Slider({Title="مدى الخطوط", Min=100, Max=10000, Step=100, Value=2500, Callback=function(v) v1.ESPMaxRange=v end})
window:AddSettings()

local function getColor(key)
  if not key or key == "None" or key == "" or key == "Fists" then
    return Color3.fromRGB(220, 220, 220)
  end

  local v3 = v2[key]

  if v3 then
    return v3.Color
  end

  return Color3.fromRGB(255, 255, 255)
end

local function f2(p1)
  if not p1.Character then
    return "Fists"
  end

  local tool = p1.Character:FindFirstChildOfClass("Tool")

  if tool and v2[tool.Name] then
    return tool.Name
  end

  for _, value14 in pairs(p1.Character:GetChildren()) do
    if v2[value14.Name] then
      return value14.Name
    end
  end

  local hotbar = p1.Character:FindFirstChild("Hotbar")
    or p1.Character:FindFirstChild("EquippedTools") or p1.Character:FindFirstChild("QuickSlot")

  if hotbar then
    for _, value15 in pairs(hotbar:GetChildren()) do
      if v2[value15.Name] then
        return value15.Name
      end
    end
  end

  for _, value16 in pairs(p1.Character:GetDescendants()) do
    if value16:IsA("Tool") and v2[value16.Name] then
      return value16.Name
    end
  end

  if tool then
    return tool.Name
  end

  return "Fists"
end

local function f3(instance)
  local leaderstats = instance:FindFirstChild("leaderstats")

  if leaderstats then
    local cash = leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money")
      or leaderstats:FindFirstChild("فلوس")

    if cash then
      return cash.Value
    end
  end

  return 0
end

local function f4()
  for _, value17 in pairs(players:GetPlayers()) do
    if value17.Character then
      local txnESP = value17.Character:FindFirstChild("RXZ_BQM_ESP")


      if txnESP then
        txnESP:Destroy()
      end

      local head = value17.Character:FindFirstChild("Head")

      local humanoidRootPart2 = head
      humanoidRootPart2 = head or value17.Character:FindFirstChild("HumanoidRootPart")

      if humanoidRootPart2 then
        local txnNAMEITEMESP = humanoidRootPart2:FindFirstChild("RXZ_BQM_NAME_ITEM_ESP")

        if txnNAMEITEMESP then
          txnNAMEITEMESP:Destroy()
        end
      end
    end
  end
end

local function f5(character2)
  if not character2 then
    return false
  end

  return character2:FindFirstChildOfClass("Tool") ~= nil
end

local function f6()
  flag = false

  for _, value18 in ipairs(list) do
    value18:Disconnect()
  end

  table.clear(list)
  f4()
  if tracerGui then tracerGui:Destroy() end
  window.DestroyUI()
  _G.RXZ_BQM_STREETS = nil
end

if window.OnClose then
  function window.OnClose()
    f6()
  end
end

local function f7()
  if v1.SelectedTargetName ~= "الكل" then
    local findFirstChild = players:FindFirstChild(v1.SelectedTargetName)

    if findFirstChild and findFirstChild.Character
      and findFirstChild.Character:FindFirstChild("Humanoid")
      and findFirstChild.Character.Humanoid.Health > 0 then
      return findFirstChild, true
    end
  end

  local huge = math.huge
  local vector = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
  local v4

  for _, value19 in pairs(players:GetPlayers()) do
    if value19 ~= localPlayer and value19.Character
      and value19.Character:FindFirstChild("Humanoid") and value19.Character.Humanoid.Health > 0 then
      local findFirstChild2 = value19.Character:FindFirstChild(v1.AimbotTargetPart)

      if findFirstChild2 then
        local screenPoint, onScreen = currentCamera:WorldToViewportPoint(findFirstChild2.Position)

        if onScreen then
          local flag2 = true

          if not v1.Wallbang then
            if #currentCamera:GetPartsObscuringTarget({ findFirstChild2.Position }, {
              localPlayer.Character, value19.Character,
            }) > 0 then
              flag2 = false
            end
          end

          if flag2 then
            local magnitude = (Vector2.new(screenPoint.X, screenPoint.Y) - vector).Magnitude

            if magnitude < huge then
              v4 = value19
              huge = magnitude
            end
          end
        end
      end
    end
  end

  return v4, false
end

local function f8()
  local playerGui = localPlayer:FindFirstChild("PlayerGui")

  if playerGui then
    for _, value20 in ipairs(playerGui:GetDescendants()) do
      local lower = value20.Name:lower()

      if lower:find("combat") or lower:find("tag") or lower:find("skull") or lower:find("fight") then
        if value20:IsA("GuiObject") and value20.Visible then
          return true
        end
      end
    end
  end

  return false
end

table.insert(list, localPlayer.CharacterAdded:Connect(function(character3)
  v1.IsHidden = false
  v1.OriginalPosition = nil
end))


-- RXZ ESP tracer geometry: midpoint, projected length, atan2 rotation.
tracerGui = Instance.new("ScreenGui")
tracerGui.Name = "RXZ_BQM_STREETS_TRACERS"
tracerGui.ResetOnSpawn = false
tracerGui.IgnoreGuiInset = true
tracerGui.DisplayOrder = 10
tracerGui.Parent = localPlayer:WaitForChild("PlayerGui")
local tracers = {}
local red = Color3.fromRGB(255, 50, 70)
local function removeTracer(player)
    if tracers[player] then tracers[player]:Destroy() tracers[player] = nil end
end
table.insert(list, players.PlayerRemoving:Connect(removeTracer))
table.insert(list, runService.RenderStepped:Connect(function()
    if not flag then return end
    local camera = workspace.CurrentCamera
    if not camera or not v1.ESPLines then
        for _, line in pairs(tracers) do line.Visible = false end
        return
    end
    local vp = camera.ViewportSize
    local fromX, fromY = vp.X/2, vp.Y-2
    local ownRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local line = tracers[player]
            local inRange = root and ((root.Position - (ownRoot and ownRoot.Position or camera.CFrame.Position)).Magnitude <= v1.ESPMaxRange)
            if root and hum and hum.Health > 0 and inRange then
                local point, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen and point.Z > 0 then
                    if not line then
                        line = Instance.new("Frame")
                        line.Name = "RXZ_Tracer_" .. player.Name
                        line.AnchorPoint = Vector2.new(0.5, 0.5)
                        line.BorderSizePixel = 0
                        line.BackgroundColor3 = red
                        line.Parent = tracerGui
                        Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
                        tracers[player] = line
                    end
                    local dx, dy = point.X-fromX, point.Y-fromY
                    line.Position = UDim2.fromOffset((fromX+point.X)/2, (fromY+point.Y)/2)
                    line.Size = UDim2.fromOffset(math.sqrt(dx*dx+dy*dy), v1.ESPLineThickness)
                    line.Rotation = math.deg(math.atan2(dy, dx))
                    line.Visible = true
                elseif line then line.Visible = false end
            elseif line then line.Visible = false end
        end
    end
end))
uiShutdown = f6
_G.RXZ_BQM_STREETS = { Destroy = f6, Settings = v1 }

table.insert(list, runService.RenderStepped:Connect(function()
  if not flag then
    return
  end

  currentCamera = workspace.CurrentCamera
  if not currentCamera then return end
  local character4 = localPlayer.Character
  local humanoid = character4 and character4:FindFirstChildOfClass("Humanoid")
  local humanoidRootPart3 = character4 and character4:FindFirstChild("HumanoidRootPart")

  if humanoid and humanoidRootPart3 then
    if humanoid.Health <= 0 then
      v1.IsHidden = false
      v1.OriginalPosition = nil
    else
      local v5 = humanoid.Health <= 40
      local v6 = humanoid.Health >= humanoid.MaxHealth * 0.95
      local v7 = f8()

      if v1.ManualUnderground or v1.DeathProtectEnabled and v5 then
        if not v1.IsHidden then
          if not v1.OriginalPosition then
            v1.OriginalPosition = humanoidRootPart3.CFrame
          end

          v1.IsHidden = true
        end

        if v1.OriginalPosition then
          local y = v1.OriginalPosition.Y
          local undergroundLevel2 = v1.UndergroundLevel
          local position = humanoidRootPart3.Position

          humanoidRootPart3.CFrame = CFrame.new(
            position.X, y - undergroundLevel2 * 4, position.Z
          ) * (humanoidRootPart3.CFrame - humanoidRootPart3.Position)

          humanoidRootPart3.AssemblyLinearVelocity = Vector3.new(
            humanoidRootPart3.AssemblyLinearVelocity.X, 0,
            humanoidRootPart3.AssemblyLinearVelocity.Z
          )
        end
      elseif v1.IsHidden and v6 and not v7 and not v1.ManualUnderground then
        if v1.OriginalPosition then
          humanoidRootPart3.CFrame = v1.OriginalPosition
        end

        v1.IsHidden = false
        v1.OriginalPosition = nil
      end
    end
  end

  if humanoid and humanoidRootPart3 then
    if v1.SpeedEnabled and humanoid.MoveDirection.Magnitude > 0 then
      humanoidRootPart3.CFrame = humanoidRootPart3.CFrame
        + humanoid.MoveDirection * (({ 0.12, 0.2, 0.3, 0.42, 0.58 })[v1.SpeedLevel] or 0.12)
    end
  end

  if character4 and v1.SpeedEnabled then
    pcall(function()
      for _, value21 in ipairs(localPlayer:GetDescendants()) do
        if value21:IsA("NumberValue") or value21:IsA("IntValue") then
          local lower2 = value21.Name:lower()

          if lower2:find("stamina") or lower2:find("energy") or lower2:find("fatigue")
            or lower2:find("power") then
            value21.Value = 100
          end
        end
      end

      for _, value22 in ipairs(character4:GetDescendants()) do
        if value22:IsA("NumberValue") or value22:IsA("IntValue") then
          local lower3 = value22.Name:lower()

          if lower3:find("stamina") or lower3:find("energy") or lower3:find("fatigue")
            or lower3:find("power") then
            value22.Value = 100
          end
        end
      end
    end)
  end

  if v1.AimbotEnabled and f5(character4) then
    local v8, v9 = f7()

    if v8 and v8.Character and v8.Character:FindFirstChild(v1.AimbotTargetPart) then
      local position2 = v8.Character[v1.AimbotTargetPart].Position
      local cframe = CFrame.new(currentCamera.CFrame.Position, position2)

      if v9 or v1.SelectedTargetName ~= "الكل" then
        currentCamera.CFrame = cframe
      else
        currentCamera.CFrame = currentCamera.CFrame:Lerp(cframe, 1 / v1.AimbotSmoothness)
      end
    end
  end
end))

task.spawn(function()
  while flag do
    task.wait(0.1)

    for _, value23 in pairs(players:GetPlayers()) do
      if value23 ~= localPlayer then
        local character5 = value23.Character

        if character5 and character5:FindFirstChild("Humanoid")
          and character5.Humanoid.Health > 0 then
          local text = f2(value23)
          local color = getColor(text)
          local txnESP2 = character5:FindFirstChild("RXZ_BQM_ESP")

          if v1.ESPEnabled then
            if not txnESP2 then
              txnESP2 = Instance.new("Highlight")
              txnESP2.Name = "RXZ_BQM_ESP"
              txnESP2.Adornee = character5
              txnESP2.FillTransparency = 0.4
              txnESP2.OutlineTransparency = 0
              txnESP2.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
              txnESP2.Parent = character5
            end

            txnESP2.FillColor = color
            txnESP2.OutlineColor = Color3.fromRGB(255, 255, 255)
          elseif txnESP2 then
            txnESP2:Destroy()
          end

          local head2 = character5:FindFirstChild("Head")
            or character5:FindFirstChild("HumanoidRootPart")

          if head2 then
            local txnNAMEITEMESP2 = head2:FindFirstChild("RXZ_BQM_NAME_ITEM_ESP")

            if v1.NameAndItemESP then
              local v10 = f3(value23)
              local rounded = 0

              if localPlayer.Character
                and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                rounded = math.floor((localPlayer.Character.HumanoidRootPart.Position
                  - head2.Position).Magnitude)
              end

              local rounded2 = math.floor(character5.Humanoid.Health)

              if not txnNAMEITEMESP2 then
                txnNAMEITEMESP2 = Instance.new("BillboardGui")
                txnNAMEITEMESP2.Name = "RXZ_BQM_NAME_ITEM_ESP"
                txnNAMEITEMESP2.Adornee = head2
                txnNAMEITEMESP2.Size = UDim2.new(0, 160, 0, 95)
                txnNAMEITEMESP2.StudsOffset = Vector3.new(0, 2.5, 0)
                txnNAMEITEMESP2.AlwaysOnTop = true
                txnNAMEITEMESP2.MaxDistance = math.huge
                txnNAMEITEMESP2.Parent = head2

                local function makeTextLabel(name, udim, udim2, color2, textSize)
                  local textLabel = Instance.new("TextLabel")
                  textLabel.Name = name
                  textLabel.Size = udim2
                  textLabel.Position = udim
                  textLabel.BackgroundTransparency = 1
                  textLabel.TextColor3 = color2
                  textLabel.TextStrokeTransparency = 0
                  textLabel.TextSize = textSize
                  textLabel.Font = Enum.Font.SourceSansBold
                  textLabel.Parent = txnNAMEITEMESP2

                  return textLabel
                end

                makeTextLabel(
                  "CashLabel", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0.25, 0),
                  Color3.fromRGB(255, 255, 0), 12
                )

                makeTextLabel(
                  "NameLabel", UDim2.new(0, 0, 0.25, 0), UDim2.new(1, 0, 0.25, 0),
                  Color3.fromRGB(255, 255, 255), 11
                )

                makeTextLabel(
                  "DistHpLabel", UDim2.new(0, 0, 0.5, 0), UDim2.new(1, 0, 0.25, 0),
                  Color3.fromRGB(0, 255, 255), 11
                )

                makeTextLabel(
                  "WeaponLabel", UDim2.new(0, 0, 0.75, 0), UDim2.new(1, 0, 0.25, 0),
                  Color3.fromRGB(255, 255, 255), 11
                )
              end

              txnNAMEITEMESP2.CashLabel.Text = "$" .. tostring(v10)
              txnNAMEITEMESP2.NameLabel.Text = value23.Name
              txnNAMEITEMESP2.DistHpLabel.Text = "[" .. rounded .. "m] | HP: " .. rounded2
              txnNAMEITEMESP2.WeaponLabel.Text = text
              txnNAMEITEMESP2.WeaponLabel.TextColor3 = color
            elseif txnNAMEITEMESP2 then
              txnNAMEITEMESP2:Destroy()
            end
          end
        end
      end
    end
  end
end)


