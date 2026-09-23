local plrs = game:GetService("Players")
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local guiService = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local contentProv = game:GetService("ContentProvider")
local coreGui = game:GetService("CoreGui")

local config = {
	UseKeySystem = true,
	Key = "VELOCITY_2026",
	KeyLink = "https://discord.gg/QVTsmm352y",
	KeyHint = "Join our Discord server and open the #key channel to receive key.",
	Name = "VelocityHUB",
	ToggleKey = Enum.KeyCode.RightControl,
	AccentColor = Color3.fromRGB(108, 92, 255),
	ShowBanner = true,
	LogoId = "rbxassetid://79065395294292",
	BannerId = "rbxassetid://86528416919779",
}

local theme = {
	bg = Color3.fromRGB(15, 15, 21),
	sidebar = Color3.fromRGB(19, 19, 27),
	card = Color3.fromRGB(27, 27, 38),
	cardHover = Color3.fromRGB(36, 36, 50),
	input = Color3.fromRGB(20, 20, 29),
	off = Color3.fromRGB(58, 58, 78),
	stroke = Color3.fromRGB(46, 46, 64),
	text = Color3.fromRGB(240, 240, 250),
	subText = Color3.fromRGB(148, 148, 172),
	success = Color3.fromRGB(80, 220, 140),
	danger = Color3.fromRGB(255, 90, 105),
	accent = config.AccentColor,
}

local fonts = {
	reg = Enum.Font.Gotham,
	med = Enum.Font.GothamMedium,
	bold = Enum.Font.GothamBold,
}

local accentHooks = {}
local function hookAccent(fn)
	table.insert(accentHooks, fn)
	fn(theme.accent)
end

local function setAccent(newColor)
	theme.accent = newColor
	for _, fn in ipairs(accentHooks) do fn(newColor) end
end

local transHooks = {}
local currentTrans = 0
local function updateTrans(t)
	currentTrans = t
	for _, fn in ipairs(transHooks) do fn() end
end

local function make(class, props, parent)
	local obj = Instance.new(class)
	
	if obj:IsA("GuiObject") then
		obj.BorderSizePixel = 0
	end
	
	if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
		obj.BackgroundTransparency = 1
		obj.Font = fonts.med
		obj.TextColor3 = theme.text
		obj.TextSize = 13
		obj.Text = ""
		obj.TextXAlignment = Enum.TextXAlignment.Left
	end
	
	if obj:IsA("TextButton") or obj:IsA("ImageButton") then
		obj.AutoButtonColor = false
	end
	
	if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
		obj.BackgroundTransparency = 1
	end
	
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	
	if parent then
		obj.Parent = parent
	end
	
	return obj
end

local function tween(obj, props, time, style, dir)
	time = time or 0.25
	style = style or Enum.EasingStyle.Quint
	dir = dir or Enum.EasingDirection.Out
	local t = ts:Create(obj, TweenInfo.new(time, style, dir), props)
	t:Play()
	return t
end

local function round(obj, rad)
	return make("UICorner", {CornerRadius = UDim.new(0, rad)}, obj)
end

local function addStroke(obj, color, thick, trans)
	return make("UIStroke", {
		Color = color, 
		Thickness = thick or 1, 
		Transparency = trans or 0, 
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, obj)
end

local shadowId = "rbxassetid://6014261993"

local function createShadow(parent, spread, fade, minDist)
	spread = spread or 30
	minDist = minDist or 200
	
	local holder = make("Frame", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, math.floor(spread * 0.25)),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0
	}, parent)
	
	local layers = { {1.00, 0.93}, {0.72, 0.88}, {0.46, 0.82}, {0.22, 0.74} }
	
	for _, l in ipairs(layers) do
		local curSpread = spread * l[1]
		local img = make("ImageLabel", {
			Image = shadowId,
			ImageColor3 = Color3.new(0, 0, 0),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			SliceScale = math.clamp((minDist + curSpread * 2) / 110, 0.25, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, curSpread * 2, 1, curSpread * 2),
			ZIndex = 0
		}, holder)
		img:SetAttribute("Base", l[2])
		img.ImageTransparency = l[2] + (1 - l[2]) * (fade or 0)
	end
	
	return holder
end

local function updateShadow(holder, fade)
	for _, img in ipairs(holder:GetChildren()) do
		if img:IsA("ImageLabel") then
			local base = img:GetAttribute("Base") or 0.8
			img.ImageTransparency = base + (1 - base) * fade
		end
	end
end

local activeCons = {}
local function connect(sig, fn)
	local c = sig:Connect(fn)
	table.insert(activeCons, c)
	return c
end

local isTyping = false

local function isClick(inp)
	return inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch
end

local function makeRipple(card, x, y)
	local sz = math.max(card.AbsoluteSize.X, card.AbsoluteSize.Y) * 2.4
	local r = make("Frame", {
		BackgroundColor3 = theme.accent,
		BackgroundTransparency = 0.72,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x - card.AbsolutePosition.X, y - card.AbsolutePosition.Y),
		Size = UDim2.fromOffset(0, 0),
		ZIndex = 0,
	}, card)
	round(r, 999)
	tween(r, {Size = UDim2.fromOffset(sz, sz), BackgroundTransparency = 1}, 0.65, Enum.EasingStyle.Quad)
	task.delay(0.7, function() r:Destroy() end)
end

local function draggable(hitbox, onDrag, onStart, onEnd)
	local dragging = false
	
	local function update(pos)
		local abs, sz = hitbox.AbsolutePosition, hitbox.AbsoluteSize
		local xp = math.clamp((pos.X - abs.X) / math.max(sz.X, 1), 0, 1)
		local yp = math.clamp((pos.Y - abs.Y) / math.max(sz.Y, 1), 0, 1)
		onDrag(xp, yp)
	end
	
	hitbox.InputBegan:Connect(function(inp)
		if isClick(inp) then
			dragging = true
			if onStart then onStart() end
			update(inp.Position)
			
			local c
			c = inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					dragging = false
					if onEnd then onEnd() end
					c:Disconnect()
				end
			end)
		end
	end)
	
	connect(uis.InputChanged, function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			update(inp.Position)
		end
	end)
end

local function getGuiParent()
	local checks = {
		function() return gethui() end,
		function() return coreGui end,
		function() return plrs.LocalPlayer:WaitForChild("PlayerGui") end,
	}
	for _, chk in ipairs(checks) do
		local s, res = pcall(chk)
		if s and res then
			local test = pcall(function()
				local f = Instance.new("Folder")
				f.Parent = res
				f:Destroy()
			end)
			if test then return res end
		end
	end
	return plrs.LocalPlayer:WaitForChild("PlayerGui")
end

local container = getGuiParent()
local old = container:FindFirstChild("VelocityHUB")
if old then old:Destroy() end

local mainGui = make("ScreenGui", {
	Name = "VelocityHUB",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999
}, container)

pcall(function() if syn and syn.protect_gui then syn.protect_gui(mainGui) end end)

local VelocityHUB = { Config = config, Theme = theme, Flags = {} }

function VelocityHUB:Destroy()
	for _, c in ipairs(activeCons) do pcall(function() c:Disconnect() end) end
	table.clear(activeCons)
	
	for _, v in ipairs(lighting:GetChildren()) do
		if v:IsA("BlurEffect") and v.Name == "VelocityBlur" then v:Destroy() end
	end
	mainGui:Destroy()
end

local notifs = make("Frame", {
	Name = "Notifications",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -20, 1, -20),
	Size = UDim2.new(0, 290, 1, -40),
	ZIndex = 50
}, mainGui)
make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8)}, notifs)

function VelocityHUB:Notify(opts)
	opts = opts or {}
	local dur = opts.Duration or 4
	local color = theme.accent
	if opts.Type == "Success" then color = theme.success elseif opts.Type == "Error" then color = theme.danger end

	local wrap = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 70)}, notifs)
	local mover = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Position = UDim2.new(1, 330, 0, 0)}, wrap)
	
	createShadow(mover, 24, 0, 70)
	
	local card = make("Frame", {BackgroundColor3 = theme.card, Size = UDim2.fromScale(1, 1), ClipsDescendants = true}, mover)
	round(card, 10)
	addStroke(card, theme.stroke, 1, 0.3)
	
	local bar = make("Frame", {BackgroundColor3 = color, Position = UDim2.new(0, 8, 0, 12), Size = UDim2.new(0, 3, 1, -24)}, card)
	round(bar, 2)
	
	make("TextLabel", {Text = opts.Title or "VelocityHUB", Font = fonts.bold, TextSize = 14, Position = UDim2.new(0, 22, 0, 9), Size = UDim2.new(1, -34, 0, 18)}, card)
	make("TextLabel", {Text = opts.Content or "", TextSize = 12, TextColor3 = theme.subText, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.new(0, 22, 0, 29), Size = UDim2.new(1, -34, 0, 34)}, card)
	
	local timer = make("Frame", {BackgroundColor3 = color, Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2)}, card)

	task.spawn(function()
		tween(mover, {Position = UDim2.new(0, 0, 0, 0)}, 0.55, Enum.EasingStyle.Back)
		tween(timer, {Size = UDim2.new(0, 0, 0, 2)}, dur, Enum.EasingStyle.Linear)
		task.wait(dur)
		tween(mover, {Position = UDim2.new(1, 330, 0, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.wait(0.4)
		tween(wrap, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
		task.wait(0.2)
		wrap:Destroy()
	end)
end

local function makeBg()
	local insets = guiService:GetGuiInset()
	local bg = make("Frame", {
		Name = "Backdrop",
		BackgroundColor3 = Color3.fromRGB(8, 8, 12),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, -insets.Y),
		Size = UDim2.new(1, 0, 1, insets.Y),
		Active = true,
		ZIndex = 10,
	}, mainGui)
	
	tween(bg, {BackgroundTransparency = 0.3}, 0.6)

	local blur
	pcall(function()
		blur = Instance.new("BlurEffect")
		blur.Name = "VelocityBlur"
		blur.Size = 0
		blur.Parent = lighting
		tween(blur, {Size = 18}, 0.7)
	end)

	return bg, function()
		tween(bg, {BackgroundTransparency = 1}, 0.6)
		if blur then
			local t = tween(blur, {Size = 0}, 0.6)
			t.Completed:Connect(function() blur:Destroy() end)
		end
		task.delay(0.65, function() bg:Destroy() end)
	end
end

local function keySys(bg)
	local ev = Instance.new("BindableEvent")
	local verified = false

	local hold = make("Frame", {
		Name = "KeySystem",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(420, 384)
	}, bg)
	
	local scl = make("UIScale", {Scale = 0.85}, hold)
	local shadow = createShadow(hold, 44, 1, 384)
	
	local card = make("CanvasGroup", {BackgroundColor3 = theme.bg, GroupTransparency = 1, Size = UDim2.fromScale(1, 1)}, hold)
	round(card, 16)
	addStroke(card, theme.stroke, 1, 0.3)

	tween(scl, {Scale = 1}, 0.6, Enum.EasingStyle.Back)
	tween(card, {GroupTransparency = 0}, 0.5)
	
	for _, v in ipairs(shadow:GetChildren()) do
		if v:IsA("ImageLabel") then
			local b = v:GetAttribute("Base") or 0.8
			tween(v, {ImageTransparency = b + (1 - b) * 0.15}, 0.6)
		end
	end

	local topStrip = make("Frame", {Size = UDim2.new(1, 0, 0, 3)}, card)
	hookAccent(function(c) topStrip.BackgroundColor3 = c end)
	make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.9)})}, topStrip)

	local logo = make("ImageLabel", {
		Image = config.LogoId, BackgroundColor3 = theme.card, BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 24), Size = UDim2.fromOffset(84, 84), ScaleType = Enum.ScaleType.Fit
	}, card)
	round(logo, 20)
	local strk = addStroke(logo, theme.accent, 2, 0.15)
	hookAccent(function(c) strk.Color = c end)
	ts:Create(logo, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(0.5, 0, 0, 31)}):Play()

	make("TextLabel", {Text = config.Name, Font = fonts.bold, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 0, 0, 122), Size = UDim2.new(1, 0, 0, 30)}, card)
	make("TextLabel", {Text = "Enter your key to continue", TextSize = 13, TextColor3 = theme.subText, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 0, 0, 152), Size = UDim2.new(1, 0, 0, 18)}, card)

	local inpBg = make("Frame", {BackgroundColor3 = theme.input, Position = UDim2.new(0, 24, 0, 184), Size = UDim2.new(1, -48, 0, 44)}, card)
	round(inpBg, 10)
	local inpStrk = addStroke(inpBg, theme.stroke, 1.5, 0)
	
	local box = make("TextBox", {
		PlaceholderText = "Enter your key here...", PlaceholderColor3 = theme.subText, ClearTextOnFocus = false,
		Font = fonts.med, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -24, 1, 0)
	}, inpBg)
	
	local stat = make("TextLabel", {Text = "", TextSize = 12, TextColor3 = theme.subText, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 24, 0, 234), Size = UDim2.new(1, -48, 0, 16)}, card)

	box.Focused:Connect(function() if not verified then tween(inpStrk, {Color = theme.accent}, 0.2) end end)
	box.FocusLost:Connect(function() if not verified then tween(inpStrk, {Color = theme.stroke}, 0.25) end end)

	local chkBtn = make("TextButton", {Text = "Verify Key", Font = fonts.bold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, Position = UDim2.new(0, 24, 0, 258), Size = UDim2.new(0.58, -29, 0, 40)}, card)
	round(chkBtn, 10)
	hookAccent(function(c) chkBtn.BackgroundColor3 = c end)
	chkBtn.MouseEnter:Connect(function() tween(chkBtn, {BackgroundColor3 = theme.accent:Lerp(Color3.new(1,1,1), 0.18)}, 0.2) end)
	chkBtn.MouseLeave:Connect(function() tween(chkBtn, {BackgroundColor3 = theme.accent}, 0.25) end)

	local getBtn = make("TextButton", {Text = "Get Key", Font = fonts.bold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, BackgroundColor3 = theme.card, BackgroundTransparency = 0, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24, 0, 258), Size = UDim2.new(0.42, -29, 0, 40)}, card)
	round(getBtn, 10)
	addStroke(getBtn, theme.stroke, 1, 0.2)
	getBtn.MouseEnter:Connect(function() tween(getBtn, {BackgroundColor3 = theme.cardHover}, 0.2) end)
	getBtn.MouseLeave:Connect(function() tween(getBtn, {BackgroundColor3 = theme.card}, 0.25) end)

	local hBlock = make("Frame", {BackgroundColor3 = theme.card, Position = UDim2.new(0, 24, 0, 312), Size = UDim2.new(1, -48, 0, 56)}, card)
	round(hBlock, 10)
	local hLine = make("Frame", {Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 3, 1, -20)}, hBlock)
	round(hLine, 2)
	hookAccent(function(c) hLine.BackgroundColor3 = c end)
	
	local hintTxt = make("TextLabel", {RichText = true, TextSize = 12, TextWrapped = true, TextColor3 = theme.subText, TextYAlignment = Enum.TextYAlignment.Center, Position = UDim2.new(0, 24, 0, 0), Size = UDim2.new(1, -34, 1, 0)}, hBlock)
	hookAccent(function(c) hintTxt.Text = string.format('<font color="#%s"><b>HINT</b></font>  %s', c:ToHex(), config.KeyHint) end)

	local xBtn = make("TextButton", {Text = "x", Font = fonts.bold, TextSize = 16, TextColor3 = theme.subText, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(1, -38, 0, 10), Size = UDim2.fromOffset(28, 28)}, card)
	xBtn.MouseEnter:Connect(function() tween(xBtn, {TextColor3 = theme.danger}, 0.2) end)
	xBtn.MouseLeave:Connect(function() tween(xBtn, {TextColor3 = theme.subText}, 0.2) end)

	local function kill(passed)
		tween(card, {GroupTransparency = 1}, 0.4)
		tween(scl, {Scale = 0.92}, 0.4)
		for _, v in ipairs(shadow:GetChildren()) do
			if v:IsA("ImageLabel") then tween(v, {ImageTransparency = 1}, 0.4) end
		end
		task.wait(0.45)
		hold:Destroy()
		ev:Fire(passed)
	end

	local function check()
		if verified then return end
		local k = string.match(box.Text, "^%s*(.-)%s*$")
		if k == "" then
			stat.Text = "Please enter your key."
			stat.TextColor3 = theme.danger
		elseif k == config.Key then
			verified = true
			stat.Text = "Key verified. Welcome!"
			stat.TextColor3 = theme.success
			tween(inpStrk, {Color = theme.success}, 0.25)
			task.delay(0.7, function() kill(true) end)
		else
			stat.Text = "Invalid key. Please try again."
			stat.TextColor3 = theme.danger
			tween(inpStrk, {Color = theme.danger}, 0.2)
			task.spawn(function()
				local base = hold.Position
				for _, off in ipairs({-10, 10, -7, 7, -4, 4, 0}) do
					tween(hold, {Position = UDim2.new(base.X.Scale, base.X.Offset + off, base.Y.Scale, base.Y.Offset)}, 0.05, Enum.EasingStyle.Sine)
					task.wait(0.05)
				end
			end)
			task.delay(1.3, function()
				if not verified and not box:IsFocused() then tween(inpStrk, {Color = theme.stroke}, 0.3) end
			end)
		end
	end

	chkBtn.MouseButton1Click:Connect(check)
	box.FocusLost:Connect(function(ent) if ent then check() end end)
	
	getBtn.MouseButton1Click:Connect(function()
		local s = pcall(setclipboard, config.KeyLink)
		if s then
			stat.Text = "Link copied to clipboard!"
			stat.TextColor3 = theme.success
		else
			stat.Text = config.KeyLink
			stat.TextColor3 = theme.accent
		end
	end)
	
	xBtn.MouseButton1Click:Connect(function()
		if not verified then
			verified = true
			kill(false)
		end
	end)

	return ev.Event:Wait()
end

local function bootLoader(bg)
	local grp = make("CanvasGroup", {Name = "Loader", BackgroundTransparency = 1, GroupTransparency = 1, Size = UDim2.fromScale(1, 1)}, bg)

	local rPar = make("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -70), Size = UDim2.fromOffset(150, 150)}, grp)

	local bRing = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, rPar)
	round(bRing, 46)
	addStroke(bRing, theme.stroke, 3, 0.4)

	local fRing = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, rPar)
	round(fRing, 46)
	local sRing = addStroke(fRing, Color3.new(1, 1, 1), 3, 0)
	local grad = make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.55, 1), NumberSequenceKeypoint.new(1, 0)})}, sRing)
	hookAccent(function(c) grad.Color = ColorSequence.new(c) end)
	ts:Create(grad, TweenInfo.new(1.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()

	local mLogo = make("ImageLabel", {
		Image = config.LogoId, BackgroundColor3 = theme.card, BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(112, 112), ScaleType = Enum.ScaleType.Fit
	}, rPar)
	round(mLogo, 28)
	local pScale = make("UIScale", {}, mLogo)
	ts:Create(pScale, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Scale = 1.06}):Play()

	make("TextLabel", {Text = string.upper(config.Name), Font = Enum.Font.GothamBold, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 26), Size = UDim2.fromOffset(400, 32)}, grp)

	local txtStat = make("TextLabel", {Text = "Starting...", TextSize = 12, TextColor3 = theme.subText, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 68), Size = UDim2.fromOffset(300, 18)}, grp)
	local txtPct = make("TextLabel", {Text = "0%", TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 68), Size = UDim2.fromOffset(300, 18)}, grp)
	hookAccent(function(c) txtPct.TextColor3 = c end)

	local lBg = make("Frame", {BackgroundColor3 = theme.card, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 94), Size = UDim2.fromOffset(300, 6)}, grp)
	round(lBg, 3)
	local lFill = make("Frame", {Size = UDim2.new(0, 0, 1, 0)}, lBg)
	round(lFill, 3)
	local fGrad = make("UIGradient", {}, lFill)
	hookAccent(function(c) fGrad.Color = ColorSequence.new(c, c:Lerp(Color3.new(1,1,1), 0.45)) end)
	
	lFill:GetPropertyChangedSignal("Size"):Connect(function()
		txtPct.Text = math.floor(lFill.Size.X.Scale * 100 + 0.5) .. "%"
	end)

	local ready = false
	task.spawn(function()
		local p = make("ImageLabel", {Image = config.BannerId, Visible = false}, grp)
		pcall(function() contentProv:PreloadAsync({mLogo, p}) end)
		ready = true
	end)

	tween(grp, {GroupTransparency = 0}, 0.5)
	task.wait(0.5)

	local function ld(alp, dr, msg)
		txtStat.Text = msg
		tween(lFill, {Size = UDim2.new(alp, 0, 1, 0)}, dr, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut).Completed:Wait()
	end

	ld(0.25, 0.6, "Initializing core modules...")
	txtStat.Text = "Preloading assets..."
	tween(lFill, {Size = UDim2.new(0.6, 0, 1, 0)}, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut).Completed:Wait()
	
	local start = os.clock()
	while not ready and os.clock() - start < 3 do task.wait() end
	
	ld(0.88, 0.7, "Building interface...")
	ld(1, 0.5, "Ready!")
	task.wait(0.3)

	tween(grp, {GroupTransparency = 1}, 0.5)
	task.wait(0.5)
	grp:Destroy()
end

function VelocityHUB:CreateWindow(o)
	o = o or {}
	local win = { Flags = VelocityHUB.Flags }
	local useKey = o.UseKeySystem
	if useKey == nil then useKey = config.UseKeySystem end
	local hubName = o.Name or config.Name
	win.ToggleKey = o.ToggleKey or config.ToggleKey

	local bg, killBg = makeBg()
	if useKey then
		local pass = keySys(bg)
		if not pass then
			killBg()
			task.wait(0.7)
			VelocityHUB:Destroy()
			Instance.new("BindableEvent").Event:Wait()
		end
	end
	bootLoader(bg)
	killBg()

	local wX, wY, sbW = 680, 460, 184
	local cam = workspace.CurrentCamera
	local baseScl = 1
	if cam then
		local v = cam.ViewportSize
		baseScl = math.clamp(math.min(v.X / (wX + 60), v.Y / (wY + 60)), 0.5, 1)
	end

	local mainWrap = make("Frame", {
		Name = "Window", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(wX, wY)
	}, mainGui)
	
	local body = make("Frame", {
		Name = "Body", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1)
	}, mainWrap)
	
	local uiScl = make("UIScale", {Scale = baseScl * 0.85}, body)

	local shadow = createShadow(body, 46, 0, wY)
	table.insert(transHooks, function() updateShadow(shadow, currentTrans) end)

	local main = make("Frame", {Name = "Main", BackgroundColor3 = theme.bg, Size = UDim2.fromScale(1, 1)}, body)
	round(main, 14)
	addStroke(main, Color3.new(1, 1, 1), 1, 0.86)
	
	table.insert(transHooks, function()
		main.BackgroundTransparency = currentTrans
	end)

	local bDrop = make("CanvasGroup", {Name = "BannerBackdrop", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 0}, main)
	round(bDrop, 14)
	
	local bImg = make("ImageLabel", {Name = "Banner", Image = config.BannerId, ScaleType = Enum.ScaleType.Crop, Size = UDim2.fromScale(1, 1), ZIndex = 1}, bDrop)

	local shH = make("Frame", {BackgroundColor3 = Color3.new(0,0,0), Size = UDim2.fromScale(1,1), ZIndex = 2}, bDrop)
	make("UIGradient", {Rotation = 0, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(0.27, 0.35), NumberSequenceKeypoint.new(1, 0.48)})}, shH)
	
	local shV = make("Frame", {BackgroundColor3 = Color3.new(0,0,0), Size = UDim2.fromScale(1,1), ZIndex = 3}, bDrop)
	make("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.65), NumberSequenceKeypoint.new(1, 0.30)})}, shV)

	local tFrame = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), ZIndex = 4}, bDrop)
	local tGrad = make("UIGradient", {
		Rotation = -35,
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 0.94), NumberSequenceKeypoint.new(1, 0.80)})
	}, tFrame)
	hookAccent(function(c) tGrad.Color = ColorSequence.new(c) end)

	local sbShade = make("Frame", {BackgroundColor3 = theme.sidebar, Size = UDim2.new(0, sbW, 1, 0), ZIndex = 5}, bDrop)

	local bShow = config.ShowBanner
	local bLayers = {shH, shV, tFrame, sbShade}
	
	local function setBgStyle(anim)
		local t = bShow and currentTrans or 1
		local st = bShow and 0.42 + (1-0.42)*currentTrans or 1
		if anim then
			tween(bImg, {ImageTransparency = t}, 0.5)
			for _, f in ipairs({shH, shV, tFrame}) do tween(f, {BackgroundTransparency = t}, 0.5) end
			tween(sbShade, {BackgroundTransparency = st}, 0.5)
		else
			bImg.ImageTransparency = t
			for _, f in ipairs({shH, shV, tFrame}) do f.BackgroundTransparency = t end
			sbShade.BackgroundTransparency = st
		end
	end
	table.insert(transHooks, function() setBgStyle(false) end)
	
	bImg.ImageTransparency = 1
	for _, f in ipairs(bLayers) do f.BackgroundTransparency = 1 end

	local sbMain = make("Frame", {Name = "Sidebar", BackgroundTransparency = 1, Size = UDim2.new(0, sbW, 1, 0)}, main)
	make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.88, Position = UDim2.new(0, sbW, 0, 0), Size = UDim2.new(0, 1, 1, 0)}, main)

	local header = make("Frame", {Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(0, sbW, 0, 68)}, main)
	local hLogo = make("ImageLabel", {Image = config.LogoId, BackgroundColor3 = theme.card, BackgroundTransparency = 0, ScaleType = Enum.ScaleType.Fit, Position = UDim2.new(0, 16, 0, 15), Size = UDim2.fromOffset(38, 38)}, header)
	round(hLogo, 10)
	local lStr = addStroke(hLogo, theme.accent, 1.5, 0.2)
	hookAccent(function(c) lStr.Color = c end)
	
	make("TextLabel", {Text = hubName, Font = fonts.bold, TextSize = 15, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.new(0, 64, 0, 16), Size = UDim2.new(1, -72, 0, 18)}, header)
	make("TextLabel", {Text = "Please Like...", TextSize = 11, TextColor3 = theme.subText, Position = UDim2.new(0, 64, 0, 34), Size = UDim2.new(1, -72, 0, 14)}, header)

	local tabsList = make("ScrollingFrame", {
		Name = "Tabs", BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
		Position = UDim2.new(0, 8, 0, 72), Size = UDim2.new(0, sbW - 16, 1, -84)
	}, sbMain)
	make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, tabsList)

	local content = make("Frame", {Name = "Content", BackgroundTransparency = 1, Position = UDim2.new(0, sbW + 1, 0, 0), Size = UDim2.new(1, -(sbW + 1), 1, 0)}, main)

	local glowLine = make("Frame", {Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -28, 0, 2)}, content)
	hookAccent(function(c) glowLine.BackgroundColor3 = c end)
	make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})}, glowLine)

	local topbar = make("Frame", {Name = "Topbar", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56)}, content)
	local pTitle = make("TextLabel", {Text = "", Font = fonts.bold, TextSize = 18, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -80, 1, 0)}, topbar)

	local qBtn = make("TextButton", {
		Text = "x", Font = fonts.bold, TextSize = 14, TextColor3 = theme.subText, TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundColor3 = theme.card, BackgroundTransparency = 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(30, 30)
	}, topbar)
	round(qBtn, 8)
	qBtn.MouseEnter:Connect(function() tween(qBtn, {TextColor3 = Color3.new(1, 1, 1), BackgroundColor3 = theme.danger}, 0.2) end)
	qBtn.MouseLeave:Connect(function() tween(qBtn, {TextColor3 = theme.subText, BackgroundColor3 = theme.card}, 0.2) end)
	
	local pages = make("Frame", {Name = "Pages", BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.new(0, 12, 0, 56), Size = UDim2.new(1, -24, 1, -68)}, content)

	local function hookDrag(pnl, tgt)
		local drg, strt, pos
		pnl.InputBegan:Connect(function(inp)
			if isClick(inp) then
				drg, strt, pos = true, inp.Position, tgt.Position
				local c
				c = inp.Changed:Connect(function()
					if inp.UserInputState == Enum.UserInputState.End then
						drg = false
						c:Disconnect()
					end
				end)
			end
		end)
		connect(uis.InputChanged, function(inp)
			if drg and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
				local d = inp.Position - strt
				tween(tgt, {Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)}, 0.08, Enum.EasingStyle.Quad)
			end
		end)
	end
	hookDrag(header, mainWrap)
	hookDrag(topbar, mainWrap)

	local vis = true
	local function setVis(v)
		if v == vis then return end
		vis = v
		if v then
			mainWrap.Visible = true
			uiScl.Scale = baseScl * 0.88
			tween(uiScl, {Scale = baseScl}, 0.45, Enum.EasingStyle.Back)
		else
			local t = tween(uiScl, {Scale = baseScl * 0.88}, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			t.Completed:Connect(function() if not vis then mainWrap.Visible = false end end)
		end
	end

	function win:Toggle() setVis(not vis) end
	function win:Show() setVis(true) end
	function win:Hide() setVis(false) end
	function win:Notify(n) VelocityHUB:Notify(n) end
	function win:Destroy() VelocityHUB:Destroy() end
	function win:SetAccent(c) setAccent(c) end
	function win:SetTransparency(t) updateTrans(math.clamp(t, 0, 0.8)) end
	function win:SetToggleKey(k) win.ToggleKey = k end
	function win:SetBannerVisible(v) bShow = v; setBgStyle(true) end

	qBtn.MouseButton1Click:Connect(function()
		setVis(false)
		VelocityHUB:Notify({ Title = hubName, Content = "Hidden. Press " .. win.ToggleKey.Name .. " to open it again.", Duration = 3 })
	end)

	connect(uis.InputBegan, function(inp, prc)
		if prc or isTyping then return end
		if inp.KeyCode == win.ToggleKey then setVis(not vis) end
	end)

	if uis.TouchEnabled and not uis.KeyboardEnabled then
		local mobBtn = make("ImageButton", {
			Image = config.LogoId, BackgroundColor3 = theme.card, BackgroundTransparency = 0,
			Position = UDim2.new(0, 14, 0.5, -23), Size = UDim2.fromOffset(46, 46), ZIndex = 5
		}, mainGui)
		round(mobBtn, 14)
		local ms = addStroke(mobBtn, theme.accent, 1.5, 0.2)
		hookAccent(function(c) ms.Color = c end)
		mobBtn.MouseButton1Click:Connect(function() setVis(not vis) end)
	end

	local tCount = 0

	function win:CreateTab(name, icon)
		tCount = tCount + 1
		local tab = { Name = name }

		local tBtn = make("TextButton", {Name = name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = tCount}, tabsList)
		round(tBtn, 9)
		hookAccent(function(c) tBtn.BackgroundColor3 = c end)
		
		local tInd = make("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 0)}, tBtn)
		round(tInd, 2)
		hookAccent(function(c) tInd.BackgroundColor3 = c end)

		local tOff = 14
		local iLbl
		if icon then
			iLbl = make("ImageLabel", {Image = icon, ImageColor3 = theme.subText, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.fromOffset(18, 18)}, tBtn)
			tOff = 40
		end
		
		local tLbl = make("TextLabel", {Text = name, TextColor3 = theme.subText, Position = UDim2.new(0, tOff, 0, 0), Size = UDim2.new(1, -(tOff + 8), 1, 0)}, tBtn)

		local pg = make("ScrollingFrame", {
			Name = name, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false
		}, pages)
		hookAccent(function(c) pg.ScrollBarImageColor3 = c end)
		make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, pg)
		make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 12), PaddingRight = UDim.new(0, 8)}, pg)

		local function selTab(act)
			tween(tBtn, {BackgroundTransparency = act and 0.85 or 1}, 0.25)
			tween(tInd, {Size = UDim2.fromOffset(3, act and 18 or 0)}, 0.35, Enum.EasingStyle.Back)
			tween(tLbl, {TextColor3 = act and theme.text or theme.subText}, 0.25)
			if iLbl then tween(iLbl, {ImageColor3 = act and theme.accent or theme.subText}, 0.25) end
		end

		function tab:Select()
			if win.CurrentTab == tab then return end
			if win.CurrentTab then
				win.CurrentTab._setActive(false)
				win.CurrentTab._page.Visible = false
			end
			win.CurrentTab = tab
			selTab(true)
			pTitle.Text = name
			pg.Position = UDim2.fromOffset(0, 18)
			pg.Visible = true
			tween(pg, {Position = UDim2.fromOffset(0, 0)}, 0.4)
		end
		tab._setActive = selTab
		tab._page = pg

		tBtn.MouseEnter:Connect(function() if win.CurrentTab ~= tab then tween(tBtn, {BackgroundTransparency = 0.93}, 0.2) end end)
		tBtn.MouseLeave:Connect(function() if win.CurrentTab ~= tab then tween(tBtn, {BackgroundTransparency = 1}, 0.25) end end)
		tBtn.MouseButton1Click:Connect(function() tab:Select() end)

		local eOrd = 0
		local function getCard(h)
			eOrd = eOrd + 1
			local c = make("Frame", {BackgroundColor3 = theme.card, Size = UDim2.new(1, 0, 0, h), ClipsDescendants = true, LayoutOrder = eOrd}, pg)
			round(c, 10)
			addStroke(c, Color3.new(1, 1, 1), 1, 0.9)
			table.insert(transHooks, function() c.BackgroundTransparency = 0.22 + (1-0.22)*currentTrans end)
			c.BackgroundTransparency = 0.22 + (1-0.22)*currentTrans
			return c
		end

		local function reg(flag, ret)
			if flag then VelocityHUB.Flags[flag] = ret end
			return ret
		end

		function tab:CreateSection(txt)
			eOrd = eOrd + 1
			local f = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = eOrd}, pg)
			local l = make("Frame", {Position = UDim2.new(0, 2, 0.5, -6), Size = UDim2.fromOffset(3, 12)}, f)
			round(l, 2)
			hookAccent(function(c) l.BackgroundColor3 = c end)
			local lbl = make("TextLabel", {Text = string.upper(txt or "Section"), Font = fonts.bold, TextSize = 11, TextColor3 = theme.subText, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -12, 1, 0)}, f)
			return { Set = function(_, nt) lbl.Text = string.upper(nt) end }
		end

		function tab:CreateLabel(txt)
			eOrd = eOrd + 1
			local l = make("TextLabel", {
				Text = txt or "", TextSize = 12, TextColor3 = theme.subText, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
				AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, -8, 0, 0), LayoutOrder = eOrd
			}, pg)
			make("UIPadding", {PaddingLeft = UDim.new(0, 4)}, l)
			return { Set = function(_, nt) l.Text = nt end }
		end

		function tab:CreateButton(opt)
			opt = opt or {}
			local c = getCard(40)
			local lbl = make("TextLabel", {Text = opt.Name or "Button", Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -60, 1, 0)}, c)
			local arrow = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -24, 0.5, 0), Size = UDim2.fromOffset(8, 8), Rotation = 45}, c)
			round(arrow, 2)
			hookAccent(function(clr) arrow.BackgroundColor3 = clr end)

			local hit = make("TextButton", {Size = UDim2.fromScale(1, 1), ZIndex = 3}, c)
			
			hit.MouseEnter:Connect(function() tween(c, {BackgroundColor3 = theme.cardHover}, 0.2) end)
			hit.MouseLeave:Connect(function() tween(c, {BackgroundColor3 = theme.card}, 0.25) end)
			
			hit.InputBegan:Connect(function(inp)
				if isClick(inp) then makeRipple(c, inp.Position.X, inp.Position.Y) end
			end)
			
			hit.MouseButton1Click:Connect(function()
				arrow.Rotation = 45
				tween(arrow, {Rotation = 225}, 0.45)
				if type(opt.Callback) == "function" then
					pcall(opt.Callback)
				end
			end)
			
			local scl = make("UIScale", {}, c)
			hit.MouseButton1Down:Connect(function() tween(scl, {Scale = 0.985}, 0.1) end)
			hit.MouseButton1Up:Connect(function() tween(scl, {Scale = 1}, 0.35, Enum.EasingStyle.Back) end)
			hit.MouseLeave:Connect(function() tween(scl, {Scale = 1}, 0.35, Enum.EasingStyle.Back) end)

			return reg(opt.Flag, { SetText = function(_, nt) lbl.Text = nt end })
		end

		function tab:CreateToggle(opt)
			opt = opt or {}
			local toggled = opt.CurrentValue == true
			
			local c = getCard(40)
			make("TextLabel", {Text = opt.Name or "Toggle", Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -80, 1, 0)}, c)

			local bg = make("Frame", {BackgroundColor3 = theme.off, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(42, 22)}, c)
			round(bg, 11)
			local knob = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16)}, bg)
			round(knob, 8)

			local res = { CurrentValue = toggled }
			
			local function updateVisuals()
				tween(bg, {BackgroundColor3 = toggled and theme.accent or theme.off}, 0.25)
				tween(knob, {Position = toggled and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.35, Enum.EasingStyle.Back)
			end
			
			hookAccent(function(clr) if toggled then bg.BackgroundColor3 = clr end end)
			if toggled then
				bg.BackgroundColor3 = theme.accent
				knob.Position = UDim2.new(1, -19, 0.5, 0)
			end

			function res:Set(val, silent)
				toggled = val == true
				res.CurrentValue = toggled
				updateVisuals()
				if not silent and type(opt.Callback) == "function" then
					pcall(opt.Callback, toggled)
				end
			end

			local hit = make("TextButton", {Size = UDim2.fromScale(1, 1), ZIndex = 3}, c)
			hit.MouseEnter:Connect(function() tween(c, {BackgroundColor3 = theme.cardHover}, 0.2) end)
			hit.MouseLeave:Connect(function() tween(c, {BackgroundColor3 = theme.card}, 0.25) end)
			
			hit.MouseButton1Down:Connect(function() tween(knob, {Size = UDim2.fromOffset(20, 16)}, 0.12) end)
			hit.MouseButton1Up:Connect(function() tween(knob, {Size = UDim2.fromOffset(16, 16)}, 0.2) end)
			hit.MouseLeave:Connect(function() tween(knob, {Size = UDim2.fromOffset(16, 16)}, 0.2) end)
			
			hit.MouseButton1Click:Connect(function() res:Set(not toggled) end)
			return reg(opt.Flag, res)
		end

		function tab:CreateSlider(opt)
			opt = opt or {}
			local min = opt.Range and opt.Range[1] or 0
			local max = opt.Range and opt.Range[2] or 100
			local step = opt.Increment or 1
			local sfx = opt.Suffix or ""
			
			local decs = 0
			local frac = tostring(step):match("%.(%d+)")
			if frac then decs = #frac end
			
			local val = math.clamp(opt.CurrentValue or min, min, max)

			local c = getCard(56)
			make("TextLabel", {Text = opt.Name or "Slider", Position = UDim2.new(0, 14, 0, 8), Size = UDim2.new(1, -120, 0, 18)}, c)
			local vLbl = make("TextLabel", {Text = "", TextColor3 = theme.subText, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 8), Size = UDim2.fromOffset(100, 18)}, c)

			local tBg = make("Frame", {BackgroundColor3 = theme.off, Position = UDim2.new(0, 14, 0, 37), Size = UDim2.new(1, -28, 0, 6)}, c)
			round(tBg, 3)
			local tFill = make("Frame", {Size = UDim2.new(0, 0, 1, 0)}, tBg)
			round(tFill, 3)
			hookAccent(function(clr) tFill.BackgroundColor3 = clr end)
			
			local knob = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14), ZIndex = 2}, tBg)
			round(knob, 7)
			local kStr = addStroke(knob, theme.accent, 2, 0)
			hookAccent(function(clr) kStr.Color = clr end)

			local res = { CurrentValue = val }

			local function draw(fast)
				local a = (max == min) and 0 or (val - min) / (max - min)
				local d = fast and 0.08 or 0.3
				tween(tFill, {Size = UDim2.new(a, 0, 1, 0)}, d, Enum.EasingStyle.Quad)
				tween(knob, {Position = UDim2.new(a, 0, 0.5, 0)}, d, Enum.EasingStyle.Quad)
				vLbl.Text = string.format("%." .. decs .. "f", val) .. sfx
			end

			function res:Set(v, silent, fast)
				v = math.clamp(v, min, max)
				v = min + math.floor((v - min) / step + 0.5) * step
				v = tonumber(string.format("%." .. decs .. "f", v))
				v = math.clamp(v, min, max)
				
				local ch = v ~= val
				val = v
				res.CurrentValue = v
				draw(fast)
				
				if ch and not silent and type(opt.Callback) == "function" then
					pcall(opt.Callback, v)
				end
			end
			draw(false)

			local hit = make("TextButton", {Position = UDim2.new(0, 14, 0, 26), Size = UDim2.new(1, -28, 0, 28), ZIndex = 3}, c)
			
			draggable(hit,
				function(x) res:Set(min + (max - min) * x, false, true) end,
				function() tween(knob, {Size = UDim2.fromOffset(19, 19)}, 0.15, Enum.EasingStyle.Back) end,
				function() tween(knob, {Size = UDim2.fromOffset(14, 14)}, 0.2) end
			)
			
			c.MouseEnter:Connect(function() tween(c, {BackgroundColor3 = theme.cardHover}, 0.2) end)
			c.MouseLeave:Connect(function() tween(c, {BackgroundColor3 = theme.card}, 0.25) end)
			
			return reg(opt.Flag, res)
		end

		function tab:CreateColorPicker(opt)
			opt = opt or {}
			local col = opt.Color or Color3.fromRGB(255, 255, 255)
			local h, s, v = col:ToHSV()
			local open = false

			local c = getCard(40)
			make("TextLabel", {Text = opt.Name or "Color Picker", Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -70, 0, 40)}, c)
			
			local prev = make("Frame", {BackgroundColor3 = col, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 10), Size = UDim2.fromOffset(34, 20)}, c)
			round(prev, 6)
			addStroke(prev, Color3.new(1, 1, 1), 1, 0.75)

			local hitBtn = make("TextButton", {Size = UDim2.new(1, 0, 0, 40), ZIndex = 3}, c)
			hitBtn.MouseEnter:Connect(function() tween(c, {BackgroundColor3 = theme.cardHover}, 0.2) end)
			hitBtn.MouseLeave:Connect(function() tween(c, {BackgroundColor3 = theme.card}, 0.25) end)

			local svArea = make("Frame", {BackgroundColor3 = Color3.fromHSV(h, 1, 1), Position = UDim2.new(0, 14, 0, 50), Size = UDim2.new(1, -66, 0, 112)}, c)
			round(svArea, 8)
			
			local wGrad = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1)}, svArea)
			round(wGrad, 8)
			make("UIGradient", {Transparency = NumberSequence.new(0, 1)}, wGrad)
			
			local bGrad = make("Frame", {BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1)}, svArea)
			round(bGrad, 8)
			make("UIGradient", {Rotation = 90, Transparency = NumberSequence.new(1, 0)}, bGrad)
			
			local svCur = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), ZIndex = 3}, svArea)
			round(svCur, 6)
			addStroke(svCur, Color3.new(0, 0, 0), 1.5, 0.2)

			local hueArea = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.new(1, -40, 0, 50), Size = UDim2.fromOffset(26, 112)}, c)
			round(hueArea, 8)
			make("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
				})
			}, hueArea)
			
			local hueCur = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, h, 0), Size = UDim2.new(1, 6, 0, 6), ZIndex = 3}, hueArea)
			round(hueCur, 3)
			addStroke(hueCur, Color3.new(0, 0, 0), 1.5, 0.2)

			local hexBox = make("TextBox", {
				Font = fonts.bold, TextSize = 12, PlaceholderText = "#FFFFFF", PlaceholderColor3 = theme.subText, ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Center, BackgroundColor3 = theme.input, BackgroundTransparency = 0,
				Position = UDim2.new(0, 14, 0, 174), Size = UDim2.fromOffset(100, 28)
			}, c)
			round(hexBox, 6)
			local hStrk = addStroke(hexBox, theme.stroke, 1, 0)
			
			local rgbLbl = make("TextLabel", {TextSize = 12, TextColor3 = theme.subText, Position = UDim2.new(0, 126, 0, 174), Size = UDim2.new(1, -140, 0, 28)}, c)

			local res = { CurrentValue = col }
			
			local function apply(fire)
				col = Color3.fromHSV(h, s, v)
				res.CurrentValue = col
				
				prev.BackgroundColor3 = col
				svArea.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				svCur.Position = UDim2.fromScale(s, 1 - v)
				hueCur.Position = UDim2.new(0.5, 0, h, 0)
				
				hexBox.Text = "#" .. string.upper(col:ToHex())
				rgbLbl.Text = string.format("R %d   G %d   B %d", math.floor(col.R * 255 + 0.5), math.floor(col.G * 255 + 0.5), math.floor(col.B * 255 + 0.5))
				
				if fire and type(opt.Callback) == "function" then
					pcall(opt.Callback, col)
				end
			end
			apply(false)

			function res:Set(nc, silent)
				h, s, v = nc:ToHSV()
				apply(not silent)
			end

			local svHit = make("TextButton", {Position = svArea.Position, Size = svArea.Size, ZIndex = 4}, c)
			draggable(svHit, function(x, y)
				s = x
				v = 1 - y
				apply(true)
			end)
			
			local hueHit = make("TextButton", {Position = hueArea.Position, Size = hueArea.Size, ZIndex = 4}, c)
			draggable(hueHit, function(_, y)
				h = math.clamp(y, 0, 0.999)
				apply(true)
			end)

			hexBox.Focused:Connect(function() tween(hStrk, {Color = theme.accent}, 0.2) end)
			hexBox.FocusLost:Connect(function()
				tween(hStrk, {Color = theme.stroke}, 0.2)
				local val = string.gsub(hexBox.Text, "#", "")
				if #val == 6 and string.match(val, "^%x+$") then
					local r = tonumber(val:sub(1, 2), 16)
					local g = tonumber(val:sub(3, 4), 16)
					local b = tonumber(val:sub(5, 6), 16)
					h, s, v = Color3.fromRGB(r, g, b):ToHSV()
				end
				apply(true)
			end)

			hitBtn.MouseButton1Click:Connect(function()
				open = not open
				tween(c, {Size = UDim2.new(1, 0, 0, open and 214 or 40)}, 0.45)
			end)
			
			return reg(opt.Flag, res)
		end

		function tab:CreateKeybind(opt)
			opt = opt or {}
			local k = opt.CurrentKeybind or Enum.KeyCode.E
			if type(k) == "string" then
				local s, res = pcall(function() return Enum.KeyCode[k] end)
				k = s and res or Enum.KeyCode.E
			end

			local c = getCard(40)
			make("TextLabel", {Text = opt.Name or "Keybind", Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -130, 1, 0)}, c)
			
			local btn = make("TextButton", {
				Text = k.Name, Font = fonts.bold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd,
				BackgroundColor3 = theme.input, BackgroundTransparency = 0, AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(100, 26), ZIndex = 3
			}, c)
			round(btn, 6)
			
			local strk = addStroke(btn, theme.stroke, 1, 0)
			btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = theme.cardHover}, 0.2) end)
			btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = theme.input}, 0.25) end)
			
			local scl = make("UIScale", {}, btn)
			btn.MouseButton1Down:Connect(function() tween(scl, {Scale = 0.94}, 0.1) end)
			local function rls() tween(scl, {Scale = 1}, 0.35, Enum.EasingStyle.Back) end
			btn.MouseButton1Up:Connect(rls)
			btn.MouseLeave:Connect(rls)

			local res = { CurrentKeybind = k }
			local wait = false

			function res:Set(nk, silent)
				k = nk
				res.CurrentKeybind = nk
				btn.Text = nk.Name
				if not silent and type(opt.OnChange) == "function" then
					pcall(opt.OnChange, nk)
				end
			end

			btn.MouseButton1Click:Connect(function()
				wait = true
				isTyping = true
				btn.Text = "..."
				tween(strk, {Color = theme.accent}, 0.2)
			end)

			connect(uis.InputBegan, function(inp, prc)
				if wait then
					if inp.UserInputType == Enum.UserInputType.Keyboard then
						wait = false
						tween(strk, {Color = theme.stroke}, 0.2)
						if inp.KeyCode == Enum.KeyCode.Escape then
							btn.Text = k.Name
						else
							res:Set(inp.KeyCode)
						end
						task.delay(0.15, function() isTyping = false end)
					end
					return
				end
				
				if not prc and not isTyping and inp.KeyCode == k then
					if type(opt.Callback) == "function" then pcall(opt.Callback, k) end
				end
			end)
			
			return reg(opt.Flag, res)
		end

		function tab:CreateDivider()
			eOrd = eOrd + 1
			local f = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = eOrd}, pg)
			
			local l = make("Frame", {BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -8, 0, 1)}, f)
			make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.8), NumberSequenceKeypoint.new(1, 1)})}, l)
			
			local g = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(46, 2)}, f)
			round(g, 1)
			hookAccent(function(c) g.BackgroundColor3 = c end)
			make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.15), NumberSequenceKeypoint.new(1, 1)})}, g)
			
			return { Destroy = function() f:Destroy() end }
		end

		function tab:CreateTextBox(opt)
			opt = opt or {}
			local num = opt.NumbersOnly == true
			local c = getCard(46)
			
			make("TextLabel", {Text = opt.Name or "TextBox", Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -200, 1, 0)}, c)

			local gl = make("ImageLabel", {
				Image = shadowId, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), SliceScale = 0.4,
				ImageTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(186, 46), ZIndex = 1
			}, c)
			hookAccent(function(clr) gl.ImageColor3 = clr end)

			local fld = make("Frame", {BackgroundColor3 = theme.input, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(170, 30), ZIndex = 2}, c)
			round(fld, 8)
			local strk = addStroke(fld, theme.stroke, 1, 0)
			
			local box = make("TextBox", {
				Text = opt.CurrentValue ~= nil and tostring(opt.CurrentValue) or "",
				PlaceholderText = opt.PlaceholderText or (num and "0" or "Type here..."), PlaceholderColor3 = theme.subText,
				ClearTextOnFocus = false, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), ZIndex = 3
			}, fld)

			local res = { CurrentValue = num and tonumber(box.Text) or box.Text }
			local last = box.Text
			local filt = false

			if num then
				box:GetPropertyChangedSignal("Text"):Connect(function()
					if filt then return end
					local cl = string.gsub(box.Text, "[^%d%.%-]", "")
					if cl ~= box.Text then
						filt = true
						box.Text = cl
						filt = false
					end
				end)
			end

			box.Focused:Connect(function()
				tween(strk, {Color = theme.accent, Thickness = 1.6}, 0.25)
				tween(gl, {ImageTransparency = 0.5}, 0.3)
			end)
			
			box.FocusLost:Connect(function(ent)
				tween(strk, {Color = theme.stroke, Thickness = 1}, 0.3)
				tween(gl, {ImageTransparency = 1}, 0.35)
				
				local v = box.Text
				if num then
					v = tonumber(box.Text)
					if v == nil then
						box.Text = last
						return
					end
					if opt.Min then v = math.max(v, opt.Min) end
					if opt.Max then v = math.min(v, opt.Max) end
					box.Text = tostring(v)
				end
				
				last = box.Text
				res.CurrentValue = v
				if type(opt.Callback) == "function" then pcall(opt.Callback, v, ent) end
				if opt.RemoveTextAfterFocusLost then box.Text = "" end
			end)

			function res:Set(nv, silent)
				box.Text = tostring(nv)
				last = box.Text
				res.CurrentValue = num and tonumber(nv) or box.Text
				if not silent and type(opt.Callback) == "function" then
					pcall(opt.Callback, res.CurrentValue, false)
				end
			end

			local hit = make("TextButton", {Size = UDim2.new(1, -190, 1, 0), ZIndex = 3}, c)
			hit.MouseEnter:Connect(function() tween(c, {BackgroundColor3 = theme.cardHover}, 0.2) end)
			hit.MouseLeave:Connect(function() tween(c, {BackgroundColor3 = theme.card}, 0.25) end)
			hit.MouseButton1Click:Connect(function() box:CaptureFocus() end)
			
			return reg(opt.Flag, res)
		end

		function tab:CreateDropdown(opt)
			opt = opt or {}
			local list = opt.Options or {}
			local open = false
			local items = {}

			local c = getCard(42)
			make("TextLabel", {Text = opt.Name or "Dropdown", Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -200, 0, 42)}, c)
			
			local vLbl = make("TextLabel", {
				Text = "Select...", TextColor3 = theme.subText, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd,
				AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -40, 0, 0), Size = UDim2.fromOffset(160, 42)
			}, c)

			local chv = make("Frame", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -22, 0, 21), Size = UDim2.fromOffset(16, 16)}, c)
			local arms = {}
			for _, def in ipairs({{5, 45}, {11, -45}}) do
				local a = make("Frame", {BackgroundColor3 = theme.subText, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(def[1], 8), Size = UDim2.fromOffset(9, 2), Rotation = def[2]}, chv)
				round(a, 1)
				table.insert(arms, a)
			end

			local hit = make("TextButton", {Size = UDim2.new(1, 0, 0, 42), ZIndex = 3}, c)
			hit.MouseEnter:Connect(function() tween(c, {BackgroundColor3 = theme.cardHover}, 0.2) end)
			hit.MouseLeave:Connect(function() tween(c, {BackgroundColor3 = theme.card}, 0.25) end)

			local scr = make("ScrollingFrame", {
				BackgroundColor3 = theme.input, BackgroundTransparency = 0.15, Position = UDim2.new(0, 8, 0, 44), Size = UDim2.new(1, -16, 0, 0),
				CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollingDirection = Enum.ScrollingDirection.Y
			}, c)
			round(scr, 8)
			hookAccent(function(clr) scr.ScrollBarImageColor3 = clr end)
			make("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, scr)
			make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 6)}, scr)

			local res = { Options = list }
			res.CurrentOption = type(opt.CurrentOption) == "table" and opt.CurrentOption[1] or opt.CurrentOption

			local function getH()
				return math.min(#list * 33 + 5, 160)
			end

			local function updUi()
				vLbl.Text = res.CurrentOption ~= nil and tostring(res.CurrentOption) or "Select..."
				for _, it in ipairs(items) do
					local isSel = it.v == res.CurrentOption
					tween(it.b, {BackgroundTransparency = isSel and 0.8 or 1}, 0.2)
					tween(it.l, {TextColor3 = isSel and theme.text or theme.subText}, 0.2)
					tween(it.m, {Size = UDim2.fromOffset(3, isSel and 14 or 0)}, 0.3, Enum.EasingStyle.Back)
				end
			end

			local function flip(v)
				open = v
				tween(c, {Size = UDim2.new(1, 0, 0, v and (44 + getH() + 8) or 42)}, 0.45)
				tween(scr, {Size = UDim2.new(1, -16, 0, v and getH() or 0)}, 0.45)
				tween(chv, {Rotation = v and 180 or 0}, 0.4)
				for _, a in ipairs(arms) do tween(a, {BackgroundColor3 = v and theme.accent or theme.subText}, 0.3) end
			end

			local function drawOpts()
				for _, it in ipairs(items) do it.b:Destroy() end
				table.clear(items)
				for i, v in ipairs(list) do
					local b = make("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = i}, scr)
					round(b, 7)
					hookAccent(function(clr) b.BackgroundColor3 = clr end)
					local m = make("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(3, 0)}, b)
					round(m, 2)
					hookAccent(function(clr) m.BackgroundColor3 = clr end)
					local l = make("TextLabel", {Text = tostring(v), TextColor3 = theme.subText, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -24, 1, 0)}, b)
					
					b.MouseEnter:Connect(function() if v ~= res.CurrentOption then tween(b, {BackgroundTransparency = 0.92}, 0.15) end end)
					b.MouseLeave:Connect(function() if v ~= res.CurrentOption then tween(b, {BackgroundTransparency = 1}, 0.2) end end)
					b.MouseButton1Click:Connect(function()
						res:Set(v)
						flip(false)
					end)
					table.insert(items, {v = v, b = b, l = l, m = m})
				end
				updUi()
			end

			function res:Set(v, silent)
				res.CurrentOption = v
				updUi()
				if not silent and type(opt.Callback) == "function" then
					pcall(opt.Callback, v)
				end
			end

			function res:Refresh(nl)
				list = nl or {}
				res.Options = list
				local k = false
				for _, ov in ipairs(list) do if ov == res.CurrentOption then k = true end end
				if not k then res.CurrentOption = nil end
				drawOpts()
				if open then flip(true) end
			end

			drawOpts()
			hit.MouseButton1Click:Connect(function() flip(not open) end)

			connect(uis.InputBegan, function(inp)
				if open and isClick(inp) then
					local pos, ca, csz = inp.Position, c.AbsolutePosition, c.AbsoluteSize
					if pos.X < ca.X or pos.X > ca.X + csz.X or pos.Y < ca.Y or pos.Y > ca.Y + csz.Y then flip(false) end
				end
			end)
			
			return reg(opt.Flag, res)
		end

		return tab
	end

	-- setup standard api wrappers
	for _, m in ipairs({"CreateSection", "CreateLabel", "CreateButton", "CreateToggle", "CreateSlider", "CreateColorPicker", "CreateKeybind", "CreateDropdown", "CreateTextBox"}) do
		if not win[m] then
			win[m] = function(self, ...)
				local t = self.LastTab or self:CreateTab("Main")
				return t[m](t, ...)
			end
		end
	end

	local setTab = win:CreateTab("Settings")
	win.SettingsTab = setTab

	setTab:CreateSection("Appearance")
	setTab:CreateColorPicker({
		Name = "Theme Color",
		Color = theme.accent,
		Callback = function(c) setAccent(c) end,
	})
	setTab:CreateSlider({
		Name = "Background Transparency",
		Range = {0, 80},
		Increment = 1,
		Suffix = "%",
		CurrentValue = 0,
		Callback = function(v) updateTrans(v / 100) end,
	})
	setTab:CreateToggle({
		Name = "Show Banner Background",
		CurrentValue = config.ShowBanner,
		Callback = function(v) win:SetBannerVisible(v) end,
	})

	setTab:CreateDivider()
	setTab:CreateSection("Controls")
	setTab:CreateKeybind({
		Name = "Toggle GUI Keybind",
		CurrentKeybind = win.ToggleKey,
		OnChange = function(k)
			win.ToggleKey = k
			VelocityHUB:Notify({Title = "Keybind updated", Content = "Press " .. k.Name .. " to open or close the GUI.", Type = "Success", Duration = 3})
		end,
	})

	setTab:CreateDivider()
	setTab:CreateSection("Interface")
	setTab:CreateButton({ Name = "Unload " .. hubName, Callback = function() VelocityHUB:Destroy() end })
	setTab:CreateLabel(hubName .. " - built with VelocityHUB UI Library v1.0.0")

	tween(uiScl, {Scale = baseScl}, 0.65, Enum.EasingStyle.Back)
	task.delay(0.25, function() setBgStyle(true) end)

	task.defer(function()
		if not win.CurrentTab then setTab:Select() end
	end)

	return win
end

do
	local rs = game:GetService("RunService")
	local lp = plrs.LocalPlayer
	
	local assistSpeed = 20
	local maxTime = 5
	local movThresh = 1.0
	local stopDist = 0.5
	local brake = 3
	local minSpeed = 0.35
	local lerpSpd = 14
	local linger = 0.2
	local chkDelay = 0.5

	local isAssistOn = false
	local goals = {}
	local lastUpd = 0
	local oldHum
	local oldRot
	local lastErr = 0
	local aimPt
	local curAxis
	local curGoal
	local lastThreat = 0
	local strafing = false

	local function resetHum()
		if oldHum then
			local h, v = oldHum, oldRot
			oldHum, oldRot = nil, nil
			pcall(function() h.AutoRotate = v end)
		end
	end

	local function lockHum(h)
		if oldHum ~= h then
			resetHum()
			oldHum, oldRot = h, h.AutoRotate
		end
		h.AutoRotate = false
	end

	local function wipeState()
		resetHum()
		aimPt, curAxis, curGoal = nil, nil, nil
		strafing = false
	end

	local function getChar()
		local c = lp.Character
		if not c then return nil end
		local r = c:FindFirstChild("HumanoidRootPart")
		local h = c:FindFirstChildOfClass("Humanoid")
		if not (r and r:IsA("BasePart") and h) then return nil end
		if h.Health <= 0 or h.Sit then return nil end
		return r, h
	end

	local function fetchGoals(force)
		local t = os.clock()
		if not force and t - lastUpd < chkDelay then return end
		lastUpd = t
		table.clear(goals)

		local f = workspace:FindFirstChild("Goalzz")
		if not f then return end
		for _, m in ipairs(f:GetChildren()) do
			if m.Name == "Goalzzznew" then
				for _, v in ipairs(m:GetDescendants()) do
					if v.Name == "Score1" and v:IsA("BasePart") then
						table.insert(goals, v)
					end
				end
			end
		end
	end

	local function closestGoal(pos)
		local best, dist
		for _, g in ipairs(goals) do
			if g.Parent then
				local d = (g.Position - pos).Magnitude
				if not dist or d < dist then
					best, dist = g, d
				end
			end
		end
		return best
	end

	local function flat(v)
		local f = Vector3.new(v.X, 0, v.Z)
		if f.Magnitude < 1e-3 then return nil end
		return f.Unit
	end

	local function getAxis(g)
		local cf, sz = g.CFrame, g.Size
		local chks = {
			{v = cf.RightVector, l = sz.X},
			{v = cf.UpVector,    l = sz.Y},
			{v = cf.LookVector,  l = sz.Z},
		}
		local bVec, bLen
		for _, c in ipairs(chks) do
			if math.abs(c.v.Y) < 0.5 then
				local fv = flat(c.v)
				if fv and (not bLen or c.l > bLen) then
					bVec, bLen = fv, c.l
				end
			end
		end
		return bVec or flat(cf.RightVector) or Vector3.new(1,0,0)
	end

	local function calcImpact(orig, vel, p, rad)
		local cf = p.CFrame
		local o = cf:PointToObjectSpace(orig)
		local d = cf:VectorToObjectSpace(vel)
		local hlf = p.Size * 0.5
		
		local tMin, tMax = -math.huge, math.huge
		for _, a in ipairs({"X", "Y", "Z"}) do
			local oa, da, h = o[a], d[a], hlf[a] + rad
			if math.abs(da) < 1e-6 then
				if math.abs(oa) > h then return nil end
			else
				local t1, t2 = (-h - oa)/da, (h - oa)/da
				if t1 > t2 then t1, t2 = t2, t1 end
				if t1 > tMin then tMin = t1 end
				if t2 < tMax then tMax = t2 end
				if tMin > tMax then return nil end
			end
		end
		
		if tMax < 0 then return nil end
		local t = math.max(tMin, 0)
		return t, orig + vel * t
	end

	local function findBall(g)
		local bf = workspace:FindFirstChild("Balls")
		if not bf then return nil end

		local bt, bp
		for _, b in ipairs(bf:GetChildren()) do
			if b.Name == "Ball" and b:IsA("BasePart") and b.Parent then
				local v = b.AssemblyLinearVelocity
				if v.Magnitude > assistSpeed then
					local r = math.max(b.Size.X, b.Size.Y, b.Size.Z) * 0.5
					local t, p = calcImpact(b.Position, v, g, r)
					if t and t <= maxTime and (not bt or t < bt) then
						bt, bp = t, p
					end
				end
			end
		end
		return bp
	end

	local function step(dt)
		local root, hum = getChar()
		if not root then wipeState(); return end

		fetchGoals(false)
		local now = os.clock()
		local cg = closestGoal(root.Position)
		local imp = cg and findBall(cg) or nil

		if imp then
			lastThreat = now
			curAxis = getAxis(cg)
			if aimPt and cg == curGoal then
				local a = 1 - math.exp(-lerpSpd * dt)
				aimPt = aimPt:Lerp(imp, a)
			else
				aimPt = imp
			end
			curGoal = cg
		elseif not aimPt or now - lastThreat > linger then
			wipeState()
			return
		end

		local off = (aimPt - root.Position):Dot(curAxis)
		local absOff = math.abs(off)

		if strafing then
			if absOff <= stopDist then strafing = false end
		elseif absOff > movThresh then
			strafing = true
		end

		lockHum(hum)
		if not strafing then
			hum:Move(Vector3.zero, false)
			return
		end

		local s = math.clamp(absOff / brake, minSpeed, 1)
		hum:Move(curAxis * (math.sign(off) * s), false)
	end

	local function onAssist()
		if isAssistOn then return end
		isAssistOn = true
		fetchGoals(true)
		rs:BindToRenderStep("GkAssist", Enum.RenderPriority.Input.Value + 1, function(dt)
			local s, e = pcall(step, dt)
			if not s and os.clock() - lastErr > 5 then
				lastErr = os.clock()
				warn("[VelocityHUB Auto GK] " .. tostring(e))
			end
		end)
	end

	local function offAssist()
		if not isAssistOn then return end
		isAssistOn = false
		pcall(function() rs:UnbindFromRenderStep("GkAssist") end)
		wipeState()
	end

	local oldDestroy = VelocityHUB.Destroy
	VelocityHUB.Destroy = function(self, ...)
		offAssist()
		return oldDestroy(self, ...)
	end

	function VelocityHUB:AddGoalkeeperAssist(gui)
		local t = gui
		if type(gui.CreateTab) == "function" then
			t = gui:CreateTab("Goalkeeper")
		end

		t:CreateSection("Assist")
		local tog = t:CreateToggle({
			Name = "Goalkeeper Assist",
			CurrentValue = false,
			Flag = "GoalkeeperAssist",
			Callback = function(v)
				if v then onAssist() else offAssist() end
				VelocityHUB:Notify({
					Title = "Goalkeeper Assist",
					Content = v and "Enabled" or "Disabled",
					Type = v and "Success" or "Info",
					Duration = 2,
				})
			end,
		})
		
		t:CreateKeybind({
			Name = "Toggle Assist",
			CurrentKeybind = Enum.KeyCode.T,
			Flag = "GoalkeeperAssistKey",
			Callback = function()
				tog:Set(not tog.CurrentValue)
			end,
		})

		return tog
	end
end

local gui = VelocityHUB:CreateWindow({
	Name = "VelocityHUB - Auto GK",
	UseKeySystem = false,
	ToggleKey = Enum.KeyCode.RightControl
})
VelocityHUB:AddGoalkeeperAssist(gui)
