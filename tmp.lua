local library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/ALPHAneegy/library/refs/heads/main/src.lua"
))()

local Window = library:CreateWindow({
	Title = "it doesent matter"
})

local player = Window:Tab({
    Name = "Player"
})


player:Section("Exploits")

--// SET SPEED + AUTO SET SPEED
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local function getHumanoid()
    local character = LP.Character
    return character and character:FindFirstChildWhichIsA("Humanoid")
end

--// INFINITE JUMP
local infiniteJump = false

player:Toggle("Infinite Jump", false, function(value)
    infiniteJump = value == true
    return true
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local humanoid = getHumanoid()
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

player:Section("CFrame")

--// CFrame Speed v2
local RunService = game:GetService("RunService")
local cframeSpeedMultiplier = 0.2
local cframeSpeedConnection = nil

local function startCFrameSpeed()
    if cframeSpeedConnection then return end
    cframeSpeedConnection = RunService.Stepped:Connect(function()
        local character = LP.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if root and humanoid then
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + moveDirection * cframeSpeedMultiplier
            end
        end
    end)
end

local function stopCFrameSpeed()
    if cframeSpeedConnection then
        cframeSpeedConnection:Disconnect()
        cframeSpeedConnection = nil
    end
end

player:Toggle("CFrame Speed v2", false, function(value)
    if value == true then
        startCFrameSpeed()
    else
        stopCFrameSpeed()
    end
    return true
end)

player:Slider("Multiplier", 0.1, 2, cframeSpeedMultiplier, function(value)
    cframeSpeedMultiplier = value
end)


player:Section("Fly")

--// FLY
local flyEnabled = false
local flyLevel = 10
local flyGyro = nil
local flyVelocity = nil
local mobileFlyUp = false
local mobileFlyDown = false

local function clearFlyMovers()
    if flyGyro then
        flyGyro:Destroy()
        flyGyro = nil
    end
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    local humanoid = getHumanoid()
    if humanoid then humanoid.PlatformStand = false end
end

local PlayerGui = LP:WaitForChild("PlayerGui")

local flyControlsFrame = Instance.new("Frame")
flyControlsFrame.Name = "FlyControls"
flyControlsFrame.Size = UDim2.fromOffset(106, 48)
flyControlsFrame.Position = UDim2.new(1, -120, 1, -70)
flyControlsFrame.BackgroundTransparency = 1
flyControlsFrame.Visible = false
flyControlsFrame.ZIndex = 100
flyControlsFrame.Parent = PlayerGui

local function makeFlyButton(text, x)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(48, 48)
    button.Position = UDim2.fromOffset(x, 0)
    button.BackgroundColor3 = Color3.fromRGB(28, 39, 65)
    button.BackgroundTransparency = 0.18
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(246, 248, 252)
    button.Font = Enum.Font.FredokaOne
    button.TextSize = 20
    button.AutoButtonColor = false
    button.ZIndex = 101
    button.Parent = flyControlsFrame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
    return button
end

local flyUpButton = makeFlyButton("\u{25B2}", 0)
local flyDownButton = makeFlyButton("\u{25BC}", 58)

flyUpButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mobileFlyUp = true
    end
end)
flyUpButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mobileFlyUp = false
    end
end)
flyDownButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mobileFlyDown = true
    end
end)
flyDownButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mobileFlyDown = false
    end
end)

local function setFly(enabled)
    flyEnabled = enabled == true
    flyControlsFrame.Visible = flyEnabled and UserInputService.TouchEnabled
    if not flyEnabled then clearFlyMovers() end
end

RunService.Heartbeat:Connect(function()
    if not flyEnabled then
        if flyGyro or flyVelocity then clearFlyMovers() end
        return
    end

    local humanoid = getHumanoid()
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    if not (humanoid and root and camera) then
        clearFlyMovers()
        return
    end

    if not flyGyro or flyGyro.Parent ~= root then
        clearFlyMovers()
        flyGyro = Instance.new("BodyGyro")
        flyGyro.Name = "FlyGyro"
        flyGyro.P = 12000
        flyGyro.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
        flyGyro.Parent = root
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Name = "FlyVelocity"
        flyVelocity.P = 15000
        flyVelocity.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
        flyVelocity.Parent = root
    end

    local speed = 160 + (math.clamp(flyLevel, 1, 30) - 1) * 24
    local unit = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then unit = unit + camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then unit = unit - camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then unit = unit + camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then unit = unit - camera.CFrame.RightVector end
    if unit.Magnitude < 0.05 and humanoid.MoveDirection.Magnitude > 0.05 then
        unit = humanoid.MoveDirection
    end
    if unit.Magnitude > 0 then unit = unit.Unit end

    local vertical = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump or mobileFlyUp then
        vertical = 1
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or mobileFlyDown then
        vertical = -1
    end

    humanoid.PlatformStand = true
    flyGyro.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
    flyGyro.CFrame = camera.CFrame
    flyVelocity.Velocity = unit * speed + Vector3.new(0, vertical * speed, 0)
end)

player:Toggle("Fly", false, function(value)
    setFly(value)
    return true
end)

player:Slider("Fly Speed", 1, 30, flyLevel, function(value)
    flyLevel = value
end)


local aim = Window:Tab({
	Name = "Silent Aim"
})

aim:Section("Best Silent Aim")

aim:Label(
    "Rage  Silent Aim:                                                                         ",
    Color3.fromRGB(246, 248, 252)
)

local function loadScripts()
	local urls = {
		"https://raw.githubusercontent.com/ALPHAneegy/nigals/refs/heads/main/idk4.lua",
		"https://raw.githubusercontent.com/ALPHAneegy/nigals/refs/heads/main/idk3.lua",
		"https://raw.githubusercontent.com/ALPHAneegy/nigals/refs/heads/main/idk.lua"
	}

	local loaded = 0

	for _, url in ipairs(urls) do
		local success, content = pcall(game.HttpGet, game, url)
		if success and content then
			local fn = loadstring(content)
			if fn then
				pcall(fn)
				loaded += 1
			end
		end
	end

	return loaded -- devuelve cuántos se cargaron para el feedback
end

-- Botón con estado: evita doble clic y muestra progreso
local isLoading = false
local alreadyLoaded = false

aim:Button("Load Script (it takes 20s - 40s to load)", function(button)
	if isLoading then return end
	if alreadyLoaded then
		button.Text = "Scripts ya cargados"
		task.delay(1.1, function()
			if button and button.Parent then
				button.Text = "Load Scripts"
			end
		end)
		return
	end

	isLoading = true
	button.Text = "Cargando..."

	local ok, loaded = pcall(loadScripts)

	if ok and loaded and loaded > 0 then
		alreadyLoaded = true
		button.Text = "Cargados (" .. loaded .. "/" .. 3 .. ")"
	else
		button.Text = "Error al cargar"
		task.delay(1.5, function()
			if button and button.Parent then
				button.Text = "Load Scripts"
			end
		end)
	end

	isLoading = false
end)

aim:Section("Mid Silent Aim")

aim:Label(
    "Mid  Silent Aim:                                                                          ",
    Color3.fromRGB(246, 248, 252)
)

local aimActive = false

getgenv().Config = {
    HitPart = "Head",
    FOVRadius = 85,
    ShowFOV = true,
}

local reps = game:GetService("ReplicatedStorage")
local plrs = game:GetService("Players")
local runs = game:GetService("RunService")
local cs = game:GetService("CollectionService")

local lplr = plrs.LocalPlayer
local cam = workspace.CurrentCamera

local U = require(reps.Modules.Utility)
local EL = require(reps.Modules.EnumLibrary)
local GU = require(reps.Modules.GameplayUtility)

--------------------------------------------------
-- GUN
--------------------------------------------------

local e, gun = pcall(require, lplr.PlayerScripts.Modules.ItemTypes.Gun)

if e and gun and gun.IsFullyAiming then
    gun.IsFullyAiming = function()
        return true
    end
end

--------------------------------------------------
-- FOV
--------------------------------------------------

local FOV = Drawing.new("Circle")

FOV.Color = Color3.fromRGB(255, 255, 255)
FOV.Thickness = 1
FOV.Filled = false

runs.RenderStepped:Connect(function()
    FOV.Position = cam.ViewportSize / 2
    FOV.Radius = getgenv().Config.FOVRadius
    FOV.Visible = getgenv().Config.ShowFOV and aimActive
end)

--------------------------------------------------
-- TARGET
--------------------------------------------------

local function target()
    -- Silent Aim apagado
    if not aimActive then
        return nil
    end

    local center = cam.ViewportSize / 2

    local bestPart = nil
    local bestDist = getgenv().Config.FOVRadius

    for _, entity in cs:GetTagged("Entity") do
        if entity == lplr.Character then
            continue
        end

        local part = entity:FindFirstChild(
            getgenv().Config.HitPart,
            true
        )

        if not part or not part:IsA("BasePart") then
            continue
        end

        local sp, onScreen =
            cam:WorldToViewportPoint(part.Position)

        if not onScreen then
            continue
        end

        local d = (
            Vector2.new(sp.X, sp.Y) - center
        ).Magnitude

        if d < bestDist then
            bestDist = d
            bestPart = part
        end
    end

    return bestPart
end

--------------------------------------------------
-- CFD
--------------------------------------------------

local function CFD(origin, part)
    local cf = part.CFrame
    local d = {}

    d[utf8.char(1)] = {
        [utf8.char(0)] =
            U:EncodeCFrame(
                CFrame.lookAt(
                    origin,
                    part.Position
                )
            ),

        [utf8.char(1)] =
            U:EncodeCFrame(cf),

        [utf8.char(2)] =
            part,

        [utf8.char(3)] =
            U:EncodeCFrame(
                cf:ToObjectSpace(
                    CFrame.new(part.Position)
                )
            ),
    }

    return d
end

--------------------------------------------------
-- RAYCAST REDIRECT
--------------------------------------------------

local visual = GU.GetEntitiesFromRaycast

GU.GetEntitiesFromRaycast = function(
    self,
    envID,
    params,
    origin,
    dir,
    maxDist,
    ...
)
    if aimActive then
        local t = target()

        if t then
            local dist =
                (t.Position - origin).Magnitude

            dir =
                (t.Position - origin).Unit

            if dist > maxDist then
                maxDist = dist + 5
            end
        end
    end

    return visual(
        self,
        envID,
        params,
        origin,
        dir,
        maxDist,
        ...
    )
end

--------------------------------------------------
-- SHOOTING HOOK
--------------------------------------------------

local UseItem =
    reps.Remotes.Replication.Fighter.UseItem

local hook

hook = hookfunction(
    UseItem.FireServer,
    newcclosure(function(
        self,
        objID,
        enumVal,
        camdata,
        extra
    )
        if aimActive and enumVal == EL:ToEnum("StartShooting") then
            local root =
                lplr.Character
                and lplr.Character:FindFirstChild(
                    "HumanoidRootPart"
                )

            local t = target()

            if root and t then
                camdata = CFD(
                    root.Position,
                    t
                )
            end
        end

        return hook(
            self,
            objID,
            enumVal,
            camdata,
            extra
        )
    end)
)

--------------------------------------------------
-- SILENT AIM TOGGLE
--------------------------------------------------

aim:Toggle("SilentAim", false, function(value)
    aimActive = value
end)

local Test = Window:Tab({
    Name = "Visuals"
})

Test:Section("Visuals")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local espActive = false
local colourChosen = Color3.fromRGB(10, 10, 10)

local connections = {}

local function addHighlight(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp and not hrp:FindFirstChild("ESP_Highlight") then
		local h = Instance.new("Highlight")
		h.Name = "ESP_Highlight"
		h.Adornee = character
		h.Parent = hrp
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.FillColor = colourChosen
		h.FillTransparency = 0.3
		h.OutlineColor = Color3.fromRGB(255, 255, 255)
	end
end

local function removeHighlight(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local h = hrp and hrp:FindFirstChild("ESP_Highlight")
	if h then h:Destroy() end
end

-- Vigila un personaje: lo ilumina si el ESP está ON, y se limpia solo al morir
local function watchCharacter(player, character)
	if connections[character] then
		connections[character]:Disconnect()
	end
	connections[character] = character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			if connections[character] then
				connections[character]:Disconnect()
				connections[character] = nil
			end
		end
	end)

	if espActive then
		addHighlight(character)
	end
end

local function watchPlayer(player)
	if player == LocalPlayer then return end

	-- personaje actual (por si ya spawneó)
	if player.Character then
		watchCharacter(player, player.Character)
	end

	-- personajes futuros (respawns)
	player.CharacterAdded:Connect(function(character)
		watchCharacter(player, character)
	end)

	player.AncestryChanged:Connect(function(_, parent)
		if not parent and player.Character then
			removeHighlight(player.Character)
		end
	end)
end

-- conectar a los que ya están
for _, player in ipairs(Players:GetPlayers()) do
	watchPlayer(player)
end

-- conectar a los que entren al servidor
Players.PlayerAdded:Connect(watchPlayer)

-- loop de seguridad: reaplica el highlight si falta (por si el juego destruye instancias, etc.)
RunService.RenderStepped:Connect(function()
	if not espActive then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			addHighlight(player.Character)
		end
	end
end)

-- UN SOLO toggle: solo enciende/apaga la variable, todo lo demás es automático
Test:Toggle("Frame ESP", false, function(value)
	espActive = value
	if not value then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				removeHighlight(player.Character)
			end
		end
	end
end)

local eskActive = false

getgenv().Config.ShowSkeleton = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SkeletonESP = {}

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function createLine()
    local line = Drawing.new("Line")

    line.Color = Color3.fromRGB(255, 255, 255)
    line.Thickness = 1
    line.Transparency = 1
    line.Visible = false

    return line
end

local function getSkeleton(entity)
    if SkeletonESP[entity] then
        return SkeletonESP[entity]
    end

    local skeleton = {
        HeadTorso = createLine(),

        TorsoLeftArm = createLine(),
        LeftArm1 = createLine(),
        LeftArm2 = createLine(),

        TorsoRightArm = createLine(),
        RightArm1 = createLine(),
        RightArm2 = createLine(),

        TorsoLower = createLine(),

        LeftLeg1 = createLine(),
        LeftLeg2 = createLine(),
        LeftLeg3 = createLine(),

        RightLeg1 = createLine(),
        RightLeg2 = createLine(),
        RightLeg3 = createLine()
    }

    SkeletonESP[entity] = skeleton

    return skeleton
end

local function hideSkeleton(skeleton)
    for _, line in pairs(skeleton) do
        line.Visible = false
    end
end

local function removeSkeleton(entity)
    local skeleton = SkeletonESP[entity]

    if not skeleton then
        return
    end

    for _, line in pairs(skeleton) do
        line:Remove()
    end

    SkeletonESP[entity] = nil
end

local function setLine(line, part1, part2)
    if not part1 or not part2 then
        line.Visible = false
        return
    end

    local p1, visible1 =
        Camera:WorldToViewportPoint(part1.Position)

    local p2, visible2 =
        Camera:WorldToViewportPoint(part2.Position)

    if visible1 and visible2 then
        line.From = Vector2.new(p1.X, p1.Y)
        line.To = Vector2.new(p2.X, p2.Y)
        line.Visible = true
    else
        line.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    local active = {}

    -- NUEVO: respeta el toggle
    if not eskActive or not getgenv().Config.ShowSkeleton then
        for entity, skeleton in pairs(SkeletonESP) do
            hideSkeleton(skeleton)
        end
        return
    end

    for _, entity in CollectionService:GetTagged("Entity") do
        if entity == LocalPlayer.Character then
            continue
        end

        local head = entity:FindFirstChild("Head", true)

        if not head or not head:IsA("BasePart") then
            continue
        end

        active[entity] = true

        local skeleton = getSkeleton(entity)

        if not getgenv().Config.ShowSkeleton then
            hideSkeleton(skeleton)
            continue
        end

        local upperTorso =
            entity:FindFirstChild("UpperTorso", true)
            or entity:FindFirstChild("Torso", true)

        local lowerTorso =
            entity:FindFirstChild("LowerTorso", true)
            or entity:FindFirstChild("Torso", true)

        local leftUpperArm =
            entity:FindFirstChild("LeftUpperArm", true)
            or entity:FindFirstChild("Left Arm", true)

        local leftLowerArm =
            entity:FindFirstChild("LeftLowerArm", true)
            or entity:FindFirstChild("Left Arm", true)

        local leftHand =
            entity:FindFirstChild("LeftHand", true)
            or entity:FindFirstChild("Left Arm", true)

        local rightUpperArm =
            entity:FindFirstChild("RightUpperArm", true)
            or entity:FindFirstChild("Right Arm", true)

        local rightLowerArm =
            entity:FindFirstChild("RightLowerArm", true)
            or entity:FindFirstChild("Right Arm", true)

        local rightHand =
            entity:FindFirstChild("RightHand", true)
            or entity:FindFirstChild("Right Arm", true)

        local leftUpperLeg =
            entity:FindFirstChild("LeftUpperLeg", true)
            or entity:FindFirstChild("Left Leg", true)

        local leftLowerLeg =
            entity:FindFirstChild("LeftLowerLeg", true)
            or entity:FindFirstChild("Left Leg", true)

        local leftFoot =
            entity:FindFirstChild("LeftFoot", true)
            or entity:FindFirstChild("Left Leg", true)

        local rightUpperLeg =
            entity:FindFirstChild("RightUpperLeg", true)
            or entity:FindFirstChild("Right Leg", true)

        local rightLowerLeg =
            entity:FindFirstChild("RightLowerLeg", true)
            or entity:FindFirstChild("Right Leg", true)

        local rightFoot =
            entity:FindFirstChild("RightFoot", true)
            or entity:FindFirstChild("Right Leg", true)

        -- Head
        setLine(
            skeleton.HeadTorso,
            head,
            upperTorso
        )

        -- Left arm
        setLine(
            skeleton.TorsoLeftArm,
            upperTorso,
            leftUpperArm
        )

        setLine(
            skeleton.LeftArm1,
            leftUpperArm,
            leftLowerArm
        )

        setLine(
            skeleton.LeftArm2,
            leftLowerArm,
            leftHand
        )

        -- Right arm
        setLine(
            skeleton.TorsoRightArm,
            upperTorso,
            rightUpperArm
        )

        setLine(
            skeleton.RightArm1,
            rightUpperArm,
            rightLowerArm
        )

        setLine(
            skeleton.RightArm2,
            rightLowerArm,
            rightHand
        )

        -- Torso
        setLine(
            skeleton.TorsoLower,
            upperTorso,
            lowerTorso
        )

        -- Left leg
        setLine(
            skeleton.LeftLeg1,
            lowerTorso,
            leftUpperLeg
        )

        setLine(
            skeleton.LeftLeg2,
            leftUpperLeg,
            leftLowerLeg
        )

        setLine(
            skeleton.LeftLeg3,
            leftLowerLeg,
            leftFoot
        )

        -- Right leg
        setLine(
            skeleton.RightLeg1,
            lowerTorso,
            rightUpperLeg
        )

        setLine(
            skeleton.RightLeg2,
            rightUpperLeg,
            rightLowerLeg
        )

        setLine(
            skeleton.RightLeg3,
            rightLowerLeg,
            rightFoot
        )
    end

    for entity in pairs(SkeletonESP) do
        if not active[entity] or not entity.Parent then
            removeSkeleton(entity)
        end
    end
end)

Test:Toggle("SKELETON", false, function(value)
    eskActive = value

    if not value then
        for _, skeleton in pairs(SkeletonESP) do
            hideSkeleton(skeleton)
        end
    end
end)

getgenv().HealthBarEnabled = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HealthESP = {}

getgenv().SetHealthBar = function(value)
    getgenv().HealthBarEnabled = value
end

--------------------------------------------------
-- HEALTH BAR
--------------------------------------------------

local function createHealthBar()
    local bg = Drawing.new("Square")

    bg.Filled = true
    bg.Color = Color3.fromRGB(20, 20, 20)
    bg.Transparency = 0.8
    bg.Visible = false

    local fill = Drawing.new("Square")

    fill.Filled = true
    fill.Color = Color3.fromRGB(255, 255, 255)
    fill.Transparency = 1
    fill.Visible = false

    return {
        Background = bg,
        Fill = fill
    }
end

local function hideHealthBar(bar)
    bar.Background.Visible = false
    bar.Fill.Visible = false
end

--------------------------------------------------
-- ESP LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()

    local active = {}

    for _, entity in CollectionService:GetTagged("Entity") do

        if entity == LocalPlayer.Character then
            continue
        end

        local humanoid =
            entity:FindFirstChildOfClass("Humanoid")

        local root =
            entity:FindFirstChild("HumanoidRootPart", true)

        local head =
            entity:FindFirstChild("Head", true)

        if not humanoid or not root or not head then
            continue
        end

        if humanoid.MaxHealth <= 0 then
            continue
        end

        active[entity] = true

        if not HealthESP[entity] then
            HealthESP[entity] = createHealthBar()
        end

        local hpBar = HealthESP[entity]

        --------------------------------------------------
        -- TOGGLE OFF
        --------------------------------------------------

        if not getgenv().HealthBarEnabled then
            hideHealthBar(hpBar)
            continue
        end

        --------------------------------------------------
        -- SCREEN POSITION
        --------------------------------------------------

        local headScreen, headVisible =
            Camera:WorldToViewportPoint(
                head.Position + Vector3.new(0, 1.5, 0)
            )

        local bottomScreen, bottomVisible =
            Camera:WorldToViewportPoint(
                root.Position - Vector3.new(0, 3, 0)
            )

        if not headVisible or not bottomVisible then
            hideHealthBar(hpBar)
            continue
        end

        local topY = headScreen.Y
        local bottomY = bottomScreen.Y

        if bottomY < topY then
            topY, bottomY = bottomY, topY
        end

        local height =
            math.max(bottomY - topY, 10)

        local centerX =
            (headScreen.X + bottomScreen.X) / 2

        -- Health bar a la izquierda
        local x = centerX - 25

        --------------------------------------------------
        -- HEALTH
        --------------------------------------------------

        local hpPercent =
            math.clamp(
                humanoid.Health / humanoid.MaxHealth,
                0,
                1
            )

        local barWidth = 4
        local padding = 1

        --------------------------------------------------
        -- BACKGROUND
        --------------------------------------------------

        hpBar.Background.Position =
            Vector2.new(
                x,
                topY
            )

        hpBar.Background.Size =
            Vector2.new(
                barWidth + padding * 2,
                height
            )

        hpBar.Background.Visible = true

        --------------------------------------------------
        -- FILL
        --------------------------------------------------

        local innerHeight =
            math.max(
                height - padding * 2,
                1
            )

        local fillHeight =
            innerHeight * hpPercent

        hpBar.Fill.Position =
            Vector2.new(
                x + padding,
                topY
                    + padding
                    + (innerHeight - fillHeight)
            )

        hpBar.Fill.Size =
            Vector2.new(
                barWidth,
                fillHeight
            )

        -- Rojo -> Amarillo -> Verde
        hpBar.Fill.Color =
            Color3.fromRGB(
                math.floor(255 * (1 - hpPercent)),
                math.floor(255 * hpPercent),
                0
            )

        hpBar.Fill.Visible = true
    end

    --------------------------------------------------
    -- CLEANUP
    --------------------------------------------------

    for entity, bar in pairs(HealthESP) do

        if not active[entity] or not entity.Parent then

            bar.Background:Remove()
            bar.Fill:Remove()

            HealthESP[entity] = nil
        end
    end
end)

Test:Toggle("HEALTH BAR", false, function(value)
    getgenv().HealthBarEnabled = value
end)


local mods = Window:Tab({
	Name = "Gun Mods"
})

mods:Section("Gun Mods")

local GunOriginals = {}
local GunsActive = false

mods:Toggle("GUNS", false, function(value)
    local Storage = game:GetService("ReplicatedStorage")
    local Items = require(Storage.Modules.ItemLibrary).Items

    if value and not GunsActive then
        GunsActive = true
        GunOriginals = {}

        local gunExceptions = {
            ["Sniper"] = false,
            ["Crossbow"] = false,
            ["Bow"] = false,
            ["RPG"] = false,
        }

        for name, data in pairs(Items) do
            if typeof(data) == "table" and not gunExceptions[name] then
                GunOriginals[name] = {}

                for _, property in ipairs({
                    "ShootSpread",
                    "ShootAccuracy",
                    "ShootRecoil",
                    "ShootCooldown",
                    "ShootBurstCooldown"
                }) do
                    if data[property] ~= nil then
                        GunOriginals[name][property] = data[property]
                    end
                end

                if data.ShootSpread then
                    data.ShootSpread = 0
                end

                if data.ShootAccuracy then
                    data.ShootAccuracy = 0
                end

                if data.ShootRecoil then
                    data.ShootRecoil = 0
                end

                if data.ShootCooldown then
                    data.ShootCooldown = 0.001
                end

                if data.ShootBurstCooldown then
                    data.ShootBurstCooldown = 0.001
                end
            end
        end

    elseif not value and GunsActive then
        GunsActive = false

        for name, properties in pairs(GunOriginals) do
            local data = Items[name]

            if typeof(data) == "table" then
                for property, originalValue in pairs(properties) do
                    data[property] = originalValue
                end
            end
        end

        GunOriginals = {}
    end
end)

mods:Section("Mlee Mods")

local MeleeOriginals = {}
local MeleeActive = false

mods:Toggle("MELEE", false, function(value)
    local Storage = game:GetService("ReplicatedStorage")
    local Items = require(Storage.Modules.ItemLibrary).Items

    if value and not MeleeActive then
        MeleeActive = true
        MeleeOriginals = {}

        for name, data in pairs(Items) do
            if typeof(data) == "table" then
                MeleeOriginals[name] = {}

                for _, property in ipairs({
                    "AttackCooldown",
                    "SwingCooldown",
                    "MeleeCooldown",
                    "Cooldown",
                    "RecoveryTime",
                    "ResetTime"
                }) do
                    if data[property] ~= nil then
                        MeleeOriginals[name][property] = data[property]
                    end
                end

                if data.AttackCooldown then
                    data.AttackCooldown = 0.001
                end

                if data.SwingCooldown then
                    data.SwingCooldown = 0.001
                end

                if data.MeleeCooldown then
                    data.MeleeCooldown = 0.001
                end

                if data.Cooldown then
                    data.Cooldown = 0.001
                end

                if data.RecoveryTime then
                    data.RecoveryTime = 0.001
                end

                if data.ResetTime then
                    data.ResetTime = 0.001
                end
            end
        end

    elseif not value and MeleeActive then
        MeleeActive = false

        for name, properties in pairs(MeleeOriginals) do
            local data = Items[name]

            if typeof(data) == "table" then
                for property, originalValue in pairs(properties) do
                    data[property] = originalValue
                end
            end
        end

        MeleeOriginals = {}
    end
end)


local ua = Window:Tab({
    Name = "Unlock All"
})

ua:Section("Unlocker")


local unlockAllLoaded = false

ua:Button("Unlock all", function()
    if unlockAllLoaded then
        return
    end

    unlockAllLoaded = true

    local success, err = pcall(function()

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local HttpService = game:GetService("HttpService")
        local player = Players.LocalPlayer
        local playerScripts = player.PlayerScripts
        local controllers = playerScripts.Controllers
        local EnumLibrary = require(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 10))
        if EnumLibrary then EnumLibrary:WaitForEnumBuilder() end
        local CosmeticLibrary = require(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 10))
        local ItemLibrary = require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 10))
        local DataController = require(controllers:WaitForChild("PlayerDataController", 10))
        local equipped, favorites = {}, {}
        local constructingWeapon, viewingProfile = nil, nil
        local lastUsedWeapon = nil

        local function cloneCosmetic(name, cosmeticType, options)
            local base = CosmeticLibrary.Cosmetics[name]
            if not base then return nil end
            local data = {}
            for key, value in pairs(base) do data[key] = value end
            data.Name = name
            data.Type = data.Type or cosmeticType
            data.Seed = data.Seed or math.random(1, 1000000)
            if EnumLibrary then
                local success, enumId = pcall(EnumLibrary.ToEnum, EnumLibrary, name)
                if success and enumId then data.Enum, data.ObjectID = enumId, data.ObjectID or enumId end
            end
            if options then
                if options.inverted ~= nil then data.Inverted = options.inverted end
                if options.favoritesOnly ~= nil then data.OnlyUseFavorites = options.favoritesOnly end
            end
            return data
        end

        local saveFile = "unlockall/config.json"
        local saveCooldown = false

        local function saveConfig()
            if not writefile or saveCooldown then return end
            saveCooldown = true
            task.spawn(function()
                task.wait(0.5)
                pcall(function()
                    local config = {equipped = {}, favorites = favorites}
                    for weapon, cosmetics in pairs(equipped) do
                        config.equipped[weapon] = {}
                        for cosmeticType, cosmeticData in pairs(cosmetics) do
                            if cosmeticData and cosmeticData.Name then
                                config.equipped[weapon][cosmeticType] = {
                                    name = cosmeticData.Name,
                                    seed = cosmeticData.Seed,
                                    inverted = cosmeticData.Inverted
                                }
                            end
                        end
                    end
                    makefolder("unlockall")
                    writefile(saveFile, HttpService:JSONEncode(config))
                end)
                saveCooldown = false
            end)
        end

        local function loadConfig()
            if not readfile or not isfile or not isfile(saveFile) then return end
            pcall(function()
                local config = HttpService:JSONDecode(readfile(saveFile))
                if config.equipped then
                    for weapon, cosmetics in pairs(config.equipped) do
                        equipped[weapon] = {}
                        for cosmeticType, cosmeticData in pairs(cosmetics) do
                            local cloned = cloneCosmetic(cosmeticData.name, cosmeticType, {inverted = cosmeticData.inverted})
                            if cloned then cloned.Seed = cosmeticData.seed equipped[weapon][cosmeticType] = cloned end
                        end
                    end
                end
                favorites = config.favorites or {}
            end)
        end

        CosmeticLibrary.OwnsCosmeticNormally = function(self, inventory, name, weapon)
            local cosmetic = CosmeticLibrary.Cosmetics[name]
            if cosmetic and cosmetic.Type == "Skin" then return true end
            return false
        end

        CosmeticLibrary.OwnsCosmeticUniversally = function(self, inventory, name, weapon)
            local cosmetic = CosmeticLibrary.Cosmetics[name]
            if cosmetic and cosmetic.Type == "Skin" then return true end
            return false
        end

        CosmeticLibrary.OwnsCosmeticForWeapon = function(self, inventory, name, weapon)
            local cosmetic = CosmeticLibrary.Cosmetics[name]
            if cosmetic and cosmetic.Type == "Skin" then return true end
            return false
        end

        local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
        CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
            if name:find("MISSING_") then return originalOwnsCosmetic(self, inventory, name, weapon) end
            local cosmetic = CosmeticLibrary.Cosmetics[name]
            if cosmetic and cosmetic.Type == "Skin" then return true end
            return originalOwnsCosmetic(self, inventory, name, weapon)
        end

        local originalGet = DataController.Get
        DataController.Get = function(self, key)
            local data = originalGet(self, key)
            if key == "CosmeticInventory" then
                local proxy = {}
                if data then for k, v in pairs(data) do 
                    local cosmetic = CosmeticLibrary.Cosmetics[k]
                    if cosmetic and cosmetic.Type == "Skin" then proxy[k] = v end
                end end
                return setmetatable(proxy, {__index = function(t, k)
                    local cosmetic = CosmeticLibrary.Cosmetics[k]
                    if cosmetic and cosmetic.Type == "Skin" then return true end
                    return nil
                end})
            end
            if key == "FavoritedCosmetics" then
                local result = data and table.clone(data) or {}
                for weapon, favs in pairs(favorites) do
                    result[weapon] = result[weapon] or {}
                    for name, isFav in pairs(favs) do 
                        local cosmetic = CosmeticLibrary.Cosmetics[name]
                        if cosmetic and cosmetic.Type == "Skin" then result[weapon][name] = isFav end
                    end
                end
                return result
            end
            return data
        end

        local originalGetWeaponData = DataController.GetWeaponData
        DataController.GetWeaponData = function(self, weaponName)
            local data = originalGetWeaponData(self, weaponName)
            if not data then return nil end
            local merged = {}
            for key, value in pairs(data) do merged[key] = value end
            merged.Name = weaponName
            if equipped[weaponName] then
                for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do 
                    if cosmeticType == "Skin" then merged[cosmeticType] = cosmeticData end
                end
            end
            return merged
        end

        local FighterController
        pcall(function() FighterController = require(controllers:WaitForChild("FighterController", 10)) end)

        if hookmetamethod then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local dataRemotes = remotes and remotes:FindFirstChild("Data")
            local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
            local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
            local replicationRemotes = remotes and remotes:FindFirstChild("Replication")
            local fighterRemotes = replicationRemotes and replicationRemotes:FindFirstChild("Fighter")
            local useItemRemote = fighterRemotes and fighterRemotes:FindFirstChild("UseItem")
            
            if equipRemote then
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                    local args = {...}
                    if useItemRemote and self == useItemRemote then
                        local objectID = args[1]
                        if FighterController then
                            pcall(function()
                                local fighter = FighterController:GetFighter(player)
                                if fighter and fighter.Items then
                                    for _, item in pairs(fighter.Items) do
                                        if item:Get("ObjectID") == objectID then lastUsedWeapon = item.Name break end
                                    end
                                end
                            end)
                        end
                    end
                    if self == equipRemote then
                        local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
                        if cosmeticType ~= "Skin" then return oldNamecall(self, ...) end
                        if cosmeticName and cosmeticName ~= "None" and cosmeticName ~= "" then
                            local inventory = DataController:Get("CosmeticInventory")
                            if inventory and rawget(inventory, cosmeticName) then return oldNamecall(self, ...) end
                        end
                        equipped[weaponName] = equipped[weaponName] or {}
                        if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                            equipped[weaponName][cosmeticType] = nil
                            if not next(equipped[weaponName]) then equipped[weaponName] = nil end
                        else
                            local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                            if cloned then equipped[weaponName][cosmeticType] = cloned end
                        end
                        task.defer(function()
                            pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
                            saveConfig()
                        end)
                        return
                    end
                    if self == favoriteRemote then
                        local cosmetic = CosmeticLibrary.Cosmetics[args[2]]
                        if cosmetic and cosmetic.Type == "Skin" then
                            favorites[args[1]] = favorites[args[1]] or {}
                            favorites[args[1]][args[2]] = args[3] or nil
                            saveConfig()
                            task.spawn(function() pcall(function() DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
                        end
                        return
                    end
                    return oldNamecall(self, ...)
                end)
            end
        end

        local ClientItem
        pcall(function() ClientItem = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) end)

        if ClientItem and ClientItem._CreateViewModel then
            local originalCreateViewModel = ClientItem._CreateViewModel
            ClientItem._CreateViewModel = function(self, viewmodelRef)
                local weaponName = self.Name
                local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                constructingWeapon = (weaponPlayer == player) and weaponName or nil
                if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Skin and viewmodelRef then
                    local dataKey, skinKey, nameKey = self:ToEnum("Data"), self:ToEnum("Skin"), self:ToEnum("Name")
                    if viewmodelRef[dataKey] then
                        viewmodelRef[dataKey][skinKey] = equipped[weaponName].Skin
                        viewmodelRef[dataKey][nameKey] = equipped[weaponName].Skin.Name
                    elseif viewmodelRef.Data then
                        viewmodelRef.Data.Skin = equipped[weaponName].Skin
                        viewmodelRef.Data.Name = equipped[weaponName].Skin.Name
                    end
                end
                local result = originalCreateViewModel(self, viewmodelRef)
                constructingWeapon = nil
                return result
            end
        end

        local viewModelModule = player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
        if viewModelModule then
            local ClientViewModel = require(viewModelModule)
            local originalNew = ClientViewModel.new
            ClientViewModel.new = function(replicatedData, clientItem)
                local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
                local weaponName = constructingWeapon or clientItem.Name
                if weaponPlayer == player and equipped[weaponName] then
                    local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
                    local dataKey = ReplicatedClass:ToEnum("Data")
                    replicatedData[dataKey] = replicatedData[dataKey] or {}
                    local cosmetics = equipped[weaponName]
                    if cosmetics.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = cosmetics.Skin end
                end
                local result = originalNew(replicatedData, clientItem)
                return result
            end
        end

        local originalGetViewModelImage = ItemLibrary.GetViewModelImageFromWeaponData
        ItemLibrary.GetViewModelImageFromWeaponData = function(self, weaponData, highRes)
            if not weaponData then return originalGetViewModelImage(self, weaponData, highRes) end
            local weaponName = weaponData.Name
            local shouldShowSkin = (weaponData.Skin and equipped[weaponName] and weaponData.Skin == equipped[weaponName].Skin) or (viewingProfile == player and equipped[weaponName] and equipped[weaponName].Skin)
            if shouldShowSkin and equipped[weaponName] and equipped[weaponName].Skin then
                local skinInfo = self.ViewModels[equipped[weaponName].Skin.Name]
                if skinInfo then return skinInfo[highRes and "ImageHighResolution" or "Image"] or skinInfo.Image end
            end
            return originalGetViewModelImage(self, weaponData, highRes)
        end

        local originalOwnsCosmeticCharm = CosmeticLibrary.OwnsCosmetic
        CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
            if name:find("MISSING_") then return originalOwnsCosmeticCharm(self, inventory, name, weapon) end
            local cosmetic = CosmeticLibrary.Cosmetics[name]
            if cosmetic and (cosmetic.Type == "Charm" or name:lower():find("charm")) then return true end
            return originalOwnsCosmeticCharm(self, inventory, name, weapon)
        end

        local originalGetCharm = DataController.Get
        DataController.Get = function(self, key)
            local data = originalGetCharm(self, key)
            if key == "CosmeticInventory" then
                local proxy = {}
                if data then for k, v in pairs(data) do 
                    local cosmetic = CosmeticLibrary.Cosmetics[k]
                    if cosmetic and (cosmetic.Type == "Charm" or k:lower():find("charm")) then proxy[k] = v end
                end end
                return setmetatable(proxy, {__index = function(t, k)
                    local cosmetic = CosmeticLibrary.Cosmetics[k]
                    if cosmetic and (cosmetic.Type == "Charm" or k:lower():find("charm")) then return true end
                    return nil
                end})
            end
            if key == "FavoritedCosmetics" then
                local result = data and table.clone(data) or {}
                for weapon, favs in pairs(favorites) do
                    result[weapon] = result[weapon] or {}
                    for name, isFav in pairs(favs) do 
                        local cosmetic = CosmeticLibrary.Cosmetics[name]
                        if cosmetic and (cosmetic.Type == "Charm" or name:lower():find("charm")) then result[weapon][name] = isFav end
                    end
                end
                return result
            end
            return data
        end

        local originalGetWeaponDataCharm = DataController.GetWeaponData
        DataController.GetWeaponData = function(self, weaponName)
            local data = originalGetWeaponDataCharm(self, weaponName)
            if not data then return nil end
            local merged = {}
            for key, value in pairs(data) do merged[key] = value end
            merged.Name = weaponName
            if equipped[weaponName] then
                for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do 
                    if cosmeticType == "Charm" then merged[cosmeticType] = cosmeticData end
                end
            end
            return merged
        end

        if hookmetamethod then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local dataRemotes = remotes and remotes:FindFirstChild("Data")
            local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
            local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
            
            if equipRemote then
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                    local args = {...}
                    if self == equipRemote then
                        local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
                        if cosmeticType ~= "Charm" then return oldNamecall(self, ...) end
                        if cosmeticName and cosmeticName ~= "None" and cosmeticName ~= "" then
                            local inventory = DataController:Get("CosmeticInventory")
                            if inventory and rawget(inventory, cosmeticName) then return oldNamecall(self, ...) end
                        end
                        equipped[weaponName] = equipped[weaponName] or {}
                        if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                            equipped[weaponName][cosmeticType] = nil
                            if not next(equipped[weaponName]) then equipped[weaponName] = nil end
                        else
                            local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                            if cloned then equipped[weaponName][cosmeticType] = cloned end
                        end
                        task.defer(function()
                            pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
                            saveConfig()
                        end)
                        return
                    end
                    if self == favoriteRemote then
                        local cosmetic = CosmeticLibrary.Cosmetics[args[2]]
                        if cosmetic and (cosmetic.Type == "Charm" or args[2]:lower():find("charm")) then
                            favorites[args[1]] = favorites[args[1]] or {}
                            favorites[args[1]][args[2]] = args[3] or nil
                            saveConfig()
                            task.spawn(function() pcall(function() DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
                        end
                        return
                    end
                    return oldNamecall(self, ...)
                end)
            end
        end

        if ClientItem and ClientItem._CreateViewModel then
            local originalCreateViewModelCharm = ClientItem._CreateViewModel
            ClientItem._CreateViewModel = function(self, viewmodelRef)
                local weaponName = self.Name
                local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                constructingWeapon = (weaponPlayer == player) and weaponName or nil
                if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Charm and viewmodelRef then
                    local dataKey, charmKey, nameKey = self:ToEnum("Data"), self:ToEnum("Charm"), self:ToEnum("Name")
                    if viewmodelRef[dataKey] then
                        viewmodelRef[dataKey][charmKey] = equipped[weaponName].Charm
                        viewmodelRef[dataKey][nameKey] = equipped[weaponName].Charm.Name
                    elseif viewmodelRef.Data then
                        viewmodelRef.Data.Charm = equipped[weaponName].Charm
                        viewmodelRef.Data.Name = equipped[weaponName].Charm.Name
                    end
                end
                local result = originalCreateViewModelCharm(self, viewmodelRef)
                constructingWeapon = nil
                return result
            end
        end

        if viewModelModule then
            local ClientViewModel = require(viewModelModule)
            if ClientViewModel.GetCharm then
                local originalGetCharmFunc = ClientViewModel.GetCharm
                ClientViewModel.GetCharm = function(self)
                    local weaponName = self.ClientItem and self.ClientItem.Name
                    local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                    if weaponName and weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Charm then
                        return equipped[weaponName].Charm
                    end
                    return originalGetCharmFunc(self)
                end
            end
            local originalNewCharm = ClientViewModel.new
            ClientViewModel.new = function(replicatedData, clientItem)
                local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
                local weaponName = constructingWeapon or clientItem.Name
                if weaponPlayer == player and equipped[weaponName] then
                    local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
                    local dataKey = ReplicatedClass:ToEnum("Data")
                    replicatedData[dataKey] = replicatedData[dataKey] or {}
                    local cosmetics = equipped[weaponName]
                    if cosmetics.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = cosmetics.Charm end
                end
                local result = originalNewCharm(replicatedData, clientItem)
                return result
            end
        end

        local originalOwnsCosmeticDance = CosmeticLibrary.OwnsCosmetic
        CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
            if name:find("MISSING_") then return originalOwnsCosmeticDance(self, inventory, name, weapon) end
            local cosmetic = CosmeticLibrary.Cosmetics[name]
            if cosmetic and (cosmetic.Type == "Dance" or cosmetic.Type == "Emote" or name:lower():find("dance") or name:lower():find("emote")) then return true end
            return originalOwnsCosmeticDance(self, inventory, name, weapon)
        end

        local originalGetDance = DataController.Get
        DataController.Get = function(self, key)
            local data = originalGetDance(self, key)
            if key == "CosmeticInventory" then
                local proxy = {}
                if data then for k, v in pairs(data) do 
                    local cosmetic = CosmeticLibrary.Cosmetics[k]
                    if cosmetic and (cosmetic.Type == "Dance" or cosmetic.Type == "Emote" or k:lower():find("dance") or k:lower():find("emote")) then proxy[k] = v end
                end end
                return setmetatable(proxy, {__index = function(t, k)
                    local cosmetic = CosmeticLibrary.Cosmetics[k]
                    if cosmetic and (cosmetic.Type == "Dance" or cosmetic.Type == "Emote" or k:lower():find("dance") or k:lower():find("emote")) then return true end
                    return nil
                end})
            end
            if key == "FavoritedCosmetics" then
                local result = data and table.clone(data) or {}
                for weapon, favs in pairs(favorites) do
                    result[weapon] = result[weapon] or {}
                    for name, isFav in pairs(favs) do 
                        local cosmetic = CosmeticLibrary.Cosmetics[name]
                        if cosmetic and (cosmetic.Type == "Dance" or cosmetic.Type == "Emote" or name:lower():find("dance") or name:lower():find("emote")) then result[weapon][name] = isFav end
                    end
                end
                return result
            end
            return data
        end

        local originalGetWeaponDataDance = DataController.GetWeaponData
        DataController.GetWeaponData = function(self, weaponName)
            local data = originalGetWeaponDataDance(self, weaponName)
            if not data then return nil end
            local merged = {}
            for key, value in pairs(data) do merged[key] = value end
            merged.Name = weaponName
            return merged
        end

        if hookmetamethod then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local dataRemotes = remotes and remotes:FindFirstChild("Data")
            local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
            local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
            
            if equipRemote then
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                    local args = {...}
                    if self == equipRemote then
                        local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
                        if cosmeticType == "Dance" or cosmeticType == "Emote" or (cosmeticName and (cosmeticName:lower():find("dance") or cosmeticName:lower():find("emote"))) then
                            equipped.Dances = equipped.Dances or {}
                            if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                                equipped.Dances[cosmeticType] = nil
                            else
                                local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                                if cloned then equipped.Dances[cosmeticType] = cloned end
                            end
                            task.defer(function()
                                pcall(function() DataController.CurrentData:Replicate("CosmeticInventory") end)
                                saveConfig()
                            end)
                            return
                        end
                        return oldNamecall(self, ...)
                    end
                    if self == favoriteRemote then
                        local cosmetic = CosmeticLibrary.Cosmetics[args[2]]
                        if cosmetic and (cosmetic.Type == "Dance" or cosmetic.Type == "Emote" or args[2]:lower():find("dance") or args[2]:lower():find("emote")) then
                            favorites[args[1]] = favorites[args[1]] or {}
                            favorites[args[1]][args[2]] = args[3] or nil
                            saveConfig()
                            task.spawn(function() pcall(function() DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
                        end
                        return
                    end
                    return oldNamecall(self, ...)
                end)
            end
        end

        local EmoteController
        pcall(function() 
            EmoteController = require(controllers:WaitForChild("EmoteController", 10))
            if EmoteController and EmoteController.GetEmotes then
                local originalGetEmotes = EmoteController.GetEmotes
                EmoteController.GetEmotes = function(self)
                    local emotes = originalGetEmotes(self)
                    for name, cosmetic in pairs(CosmeticLibrary.Cosmetics) do
                        if cosmetic and (cosmetic.Type == "Dance" or cosmetic.Type == "Emote" or name:lower():find("dance") or name:lower():find("emote")) then
                            if not emotes[name] then
                                emotes[name] = {
                                    Name = name,
                                    Type = cosmetic.Type,
                                    ObjectID = cosmetic.ObjectID,
                                    Enum = cosmetic.Enum
                                }
                            end
                        end
                    end
                    return emotes
                end
            end
        end)

        local originalOwnsCosmeticWrap = CosmeticLibrary.OwnsCosmetic
        CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
            if name:find("MISSING_") then return originalOwnsCosmeticWrap(self, inventory, name, weapon) end
            local cosmetic = CosmeticLibrary.Cosmetics[name]
            if cosmetic and (cosmetic.Type == "Wrap" or cosmetic.Type == "Wrapping" or name:lower():find("wrap")) then return true end
            return originalOwnsCosmeticWrap(self, inventory, name, weapon)
        end

        local originalGetWrapVer = DataController.Get
        DataController.Get = function(self, key)
            local data = originalGetWrapVer(self, key)
            if key == "CosmeticInventory" then
                local proxy = {}
                if data then for k, v in pairs(data) do 
                    local cosmetic = CosmeticLibrary.Cosmetics[k]
                    if cosmetic and (cosmetic.Type == "Wrap" or cosmetic.Type == "Wrapping" or k:lower():find("wrap")) then proxy[k] = v end
                end end
                return setmetatable(proxy, {__index = function(t, k)
                    local cosmetic = CosmeticLibrary.Cosmetics[k]
                    if cosmetic and (cosmetic.Type == "Wrap" or cosmetic.Type == "Wrapping" or k:lower():find("wrap")) then return true end
                    return nil
                end})
            end
            if key == "FavoritedCosmetics" then
                local result = data and table.clone(data) or {}
                for weapon, favs in pairs(favorites) do
                    result[weapon] = result[weapon] or {}
                    for name, isFav in pairs(favs) do 
                        local cosmetic = CosmeticLibrary.Cosmetics[name]
                        if cosmetic and (cosmetic.Type == "Wrap" or cosmetic.Type == "Wrapping" or name:lower():find("wrap")) then result[weapon][name] = isFav end
                    end
                end
                return result
            end
            return data
        end

        local originalGetWeaponDataWrap = DataController.GetWeaponData
        DataController.GetWeaponData = function(self, weaponName)
            local data = originalGetWeaponDataWrap(self, weaponName)
            if not data then return nil end
            local merged = {}
            for key, value in pairs(data) do merged[key] = value end
            merged.Name = weaponName
            if equipped[weaponName] then
                for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do 
                    if cosmeticType == "Wrap" or cosmeticType == "Wrapping" then merged[cosmeticType] = cosmeticData end
                end
            end
            return merged
        end

        if hookmetamethod then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local dataRemotes = remotes and remotes:FindFirstChild("Data")
            local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
            local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
            
            if equipRemote then
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                    local args = {...}
                    if self == equipRemote then
                        local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
                        if cosmeticType ~= "Wrap" and cosmeticType ~= "Wrapping" then return oldNamecall(self, ...) end
                        if cosmeticName and cosmeticName ~= "None" and cosmeticName ~= "" then
                            local inventory = DataController:Get("CosmeticInventory")
                            if inventory and rawget(inventory, cosmeticName) then return oldNamecall(self, ...) end
                        end
                        equipped[weaponName] = equipped[weaponName] or {}
                        if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                            equipped[weaponName][cosmeticType] = nil
                            if not next(equipped[weaponName]) then equipped[weaponName] = nil end
                        else
                            local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                            if cloned then equipped[weaponName][cosmeticType] = cloned end
                        end
                        task.defer(function()
                            pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
                            saveConfig()
                        end)
                        return
                    end
                    if self == favoriteRemote then
                        local cosmetic = CosmeticLibrary.Cosmetics[args[2]]
                        if cosmetic and (cosmetic.Type == "Wrap" or cosmetic.Type == "Wrapping" or args[2]:lower():find("wrap")) then
                            favorites[args[1]] = favorites[args[1]] or {}
                            favorites[args[1]][args[2]] = args[3] or nil
                            saveConfig()
                            task.spawn(function() pcall(function() DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
                        end
                        return
                    end
                    return oldNamecall(self, ...)
                end)
            end
        end

        if ClientItem and ClientItem._CreateViewModel then
            local originalCreateViewModelWrap = ClientItem._CreateViewModel
            ClientItem._CreateViewModel = function(self, viewmodelRef)
                local weaponName = self.Name
                local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                constructingWeapon = (weaponPlayer == player) and weaponName or nil
                if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap and viewmodelRef then
                    local dataKey, wrapKey, nameKey = self:ToEnum("Data"), self:ToEnum("Wrap"), self:ToEnum("Name")
                    if viewmodelRef[dataKey] then
                        viewmodelRef[dataKey][wrapKey] = equipped[weaponName].Wrap
                        viewmodelRef[dataKey][nameKey] = equipped[weaponName].Wrap.Name
                    elseif viewmodelRef.Data then
                        viewmodelRef.Data.Wrap = equipped[weaponName].Wrap
                        viewmodelRef.Data.Name = equipped[weaponName].Wrap.Name
                    end
                end
                local result = originalCreateViewModelWrap(self, viewmodelRef)
                constructingWeapon = nil
                return result
            end
        end

        if viewModelModule then
            local ClientViewModel = require(viewModelModule)
            if ClientViewModel.GetWrap then
                local originalGetWrapFunc = ClientViewModel.GetWrap
                ClientViewModel.GetWrap = function(self)
                    local weaponName = self.ClientItem and self.ClientItem.Name
                    local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                    if weaponName and weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap then
                        return equipped[weaponName].Wrap
                    end
                    return originalGetWrapFunc(self)
                end
            end
            local originalNewWrap = ClientViewModel.new
            ClientViewModel.new = function(replicatedData, clientItem)
                local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
                local weaponName = constructingWeapon or clientItem.Name
                if weaponPlayer == player and equipped[weaponName] then
                    local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
                    local dataKey = ReplicatedClass:ToEnum("Data")
                    replicatedData[dataKey] = replicatedData[dataKey] or {}
                    local cosmetics = equipped[weaponName]
                    if cosmetics.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
                end
                local result = originalNewWrap(replicatedData, clientItem)
                if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap and result._UpdateWrap then
                    result:_UpdateWrap()
                    task.delay(0.1, function() if not result._destroyed then result:_UpdateWrap() end end)
                end
                return result
            end
        end

        pcall(function()
            local ViewProfile = require(player.PlayerScripts.Modules.Pages.ViewProfile)
            if ViewProfile and ViewProfile.Fetch then
                local originalFetch = ViewProfile.Fetch
                ViewProfile.Fetch = function(self, targetPlayer)
                    viewingProfile = targetPlayer
                    return originalFetch(self, targetPlayer)
                end
            end
        end)

        loadConfig()
    end)

    if not success then
        unlockAllLoaded = false
        warn("[Unlock all] Error:", err)
    end
end)


ua:Label(
    "This unlocks gun skins, wraps, charms and dances.                                        ",
    Color3.fromRGB(246, 248, 252)
)

local utils = Window:Tab ({
    Name = "Utils"
})

utils:Section("Utils")

--// SET TIME (Set Day/Night) + FullBright
local Lighting = game:GetService("Lighting")

local lightingOriginal = {
    ClockTime = Lighting.ClockTime,
    GeographicLatitude = Lighting.GeographicLatitude,
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ExposureCompensation = Lighting.ExposureCompensation,
    ColorShift_Top = Lighting.ColorShift_Top,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    GlobalShadows = Lighting.GlobalShadows,
}
local originalFadeTime = 0
pcall(function() originalFadeTime = Lighting.FadeTime end)

local lightingController = {
    dayMode = nil,
    fullBright = false,
    fullBrightOriginal = nil,
    restoring = false,
    running = true,
}

local lightingThreads = {}
local lightingConnections = {}

local function trackLighting(connection)
    if connection then lightingConnections[#lightingConnections + 1] = connection end
    return connection
end

local function disconnectLighting()
    for _, connection in ipairs(lightingConnections) do
        pcall(connection.Disconnect, connection)
    end
    table.clear(lightingConnections)
end

local function stopThread(name)
    lightingThreads[name] = nil
end

local function startThread(name, func)
    stopThread(name)
    lightingThreads[name] = true
    task.spawn(function()
        pcall(function()
            func()
        end)
        lightingThreads[name] = nil
    end)
end

local function applyCombinedLighting()
    if lightingController.restoring then return end

    -- Night / Day
    if lightingController.dayMode then
        Lighting.ClockTime = lightingController.dayMode == "Night" and 0 or 14
    end

    -- FullBright
    if lightingController.fullBright then
        if not lightingController.dayMode then Lighting.ClockTime = 14 end
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Lighting.GlobalShadows = false
    end
end

local function ensureLightingLoop()
    if lightingThreads["miscLightingController"] then return end

    pcall(function()
        if Lighting.FadeTime > 0 then Lighting.FadeTime = 0 end
    end)

    trackLighting(Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if lightingController.dayMode then
            pcall(function()
                Lighting.ClockTime = lightingController.dayMode == "Night" and 0 or 14
            end)
        end
    end))

    startThread("miscLightingController", function()
        while lightingController.running and (lightingController.dayMode or lightingController.fullBright) do
            applyCombinedLighting()
            task.wait(0.35)
        end
    end)
end

local function setDayNight(value)
    lightingController.dayMode = value == "Night" and "Night" or "Day"
    applyCombinedLighting()
    ensureLightingLoop()
    return true
end

local function setFullBright(enabled)
    enabled = enabled == true
    if enabled == lightingController.fullBright then
        applyCombinedLighting()
        return true
    end

    if enabled then
        lightingController.fullBrightOriginal = {
            ClockTime = Lighting.ClockTime,
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            GlobalShadows = Lighting.GlobalShadows,
        }
        lightingController.fullBright = true
        applyCombinedLighting()
        ensureLightingLoop()
        return true
    end

    lightingController.fullBright = false
    for property, originalValue in pairs(lightingController.fullBrightOriginal or {}) do
        pcall(function() Lighting[property] = originalValue end)
    end
    lightingController.fullBrightOriginal = nil
    applyCombinedLighting()
    if not lightingController.dayMode then stopThread("miscLightingController") end
    return true
end

local function restoreLighting()
    lightingController.restoring = true
    lightingController.dayMode = nil
    lightingController.fullBright = false
    lightingController.fullBrightOriginal = nil
    stopThread("miscLightingController")
    disconnectLighting()
    pcall(function() Lighting.FadeTime = originalFadeTime end)
    for property, originalValue in pairs(lightingOriginal) do
        pcall(function() Lighting[property] = originalValue end)
    end
end

utils:Dropdown("Set Time", { "Day", "Night" }, "Day", function(value)
    setDayNight(value)
end)

utils:Toggle("FullBright", false, function(value)
    setFullBright(value)
end)

setDayNight("Day")

--// SERVER HOP
local function serverHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId

    local serversUrl =
        "https://games.roblox.com/v1/games/"
        .. placeId
        .. "/servers/Public?sortOrder=Asc&limit=100"

    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(serversUrl))
    end)

    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LP)
                end)
                return
            end
        end
        warn("No alternative public servers found.")
    else
        warn("Failed to fetch server list. Retrying native teleport...")
        pcall(function()
            TeleportService:Teleport(placeId, LP)
        end)
    end
end

utils:Button("Server Hop", function()
    serverHop()
end)

--// REJOIN SERVER
utils:Button("Rejoin Server", function()
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    local jobId = game.JobId

    pcall(function()
        if #game:GetService("Players"):GetPlayers() <= 1 then
            TeleportService:Teleport(placeId, LP)
        else
            TeleportService:TeleportToPlaceInstance(placeId, jobId, LP)
        end
    end)
end)

