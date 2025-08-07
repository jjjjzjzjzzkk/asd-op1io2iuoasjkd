

local function initAimbot(ui, silent_aim, cheat)
    silent_aim = silent_aim or {}
    
    local RunService = cloneref(game:GetService("RunService"))
    local workspace = cloneref(game:GetService("Workspace"))
    local TweenService = game:GetService("TweenService")
    local Players = cloneref(game:GetService("Players"))
    local LocalPlayer = Players.LocalPlayer
    local Lighting = cloneref(game:GetService("Lighting"))
    local UserInputService = cloneref(game:GetService("UserInputService"))
    local HttpService = cloneref(game:GetService("HttpService"))
    local GuiInset = cloneref(game:GetService("GuiService")):GetGuiInset()
    local CoreGui = cloneref(game:GetService("CoreGui"))
    local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
    local Camera = workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()
    local detectmods  = false
    local detectedmods = {}
    local mdetect = false
    local espmapactive = false
    local handleESPMAP = function() do end end
    local espmapmarkers = {}
    local espmaptarget = nil
    local aimresolver = false
    local aimresolvertime = tick()
    local aimresolverhh = false
    local _CFramenew = CFrame.new
    local _Vector2new = Vector2.new
    local _IsDescendantOf = game.IsDescendantOf
    local _FindFirstChild = game.FindFirstChild
    local _FindFirstChildOfClass = game.FindFirstChildOfClass
    local _Raycast = workspace.Raycast
    local _WorldToViewportPoint = Camera.WorldToViewportPoint
    local mathround = math.round
    local tostring = tostring
    local unpack = unpack
    local rawget = rawget
    local globals = {
    fov_enabled = false,
    zoom_enabled = false,
}

getgenv().animpos = 2.3
getgenv().underground = -2.4
getgenv().xrotation = 90
getgenv().upangle = 5

getgenv().cameraOffset = Vector3.new(0, -2, -4)

character = LocalPlayer.Character
humanoid = character:WaitForChild("Humanoid")
rootPart = character:WaitForChild("HumanoidRootPart")
originalOffset = humanoid.CameraOffset

local anderanim = Instance.new("Animation")
anderanim.AnimationId = "rbxassetid://15609995579"
track = humanoid:LoadAnimation(anderanim)
track:Play()
track:AdjustSpeed(0)

local dysenc = {}

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if Method == "FireServer" and self.Name == "UpdateTilt" then
        Args[1] = getgenv().upangle
        return oldNamecall(self, table.unpack(Args))
    end
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

local function toggleCameraOffset(enable)
     if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid.CameraOffset = enable and getgenv().cameraOffset or originalOffset
    end
end
local cameraMt = getrawmetatable(game)
local oldIndex = cameraMt.__newindex
setreadonly(cameraMt, false)

cameraMt.__newindex = newcclosure(function(self, index, value)
    if tostring(self) == "Humanoid" and index == "CameraOffset" and enabled then
        return oldIndex(self, index, getgenv().cameraOffset)
    end
    return oldIndex(self, index, value)
end)

setreadonly(cameraMt, true)
local vischeck_params = RaycastParams.new()
vischeck_params.FilterType = Enum.RaycastFilterType.Exclude
vischeck_params.CollisionGroup = "WeaponRay"
vischeck_params.IgnoreWater = true
local instrelOGfunc = require(game.ReplicatedStorage.Modules.FPS).reload
local instrelMODfunc
local function is_visible(cframe, target, target_part)
    if not (target and target_part and cframe) then return false end
    vischeck_params.FilterDescendantsInstances = { workspace.NoCollision, Camera, LocalPlayer.Character }
    local castresults = _Raycast(workspace, cframe.p, target_part.CFrame.p - cframe.p, vischeck_params)
    return castresults and castresults.Instance and _IsDescendantOf(castresults.Instance, target)
end


local function predict_velocity(Origin, Destination, DestinationVelocity, ProjectileSpeed)
    local Distance = (Destination - Origin).Magnitude;
    local TimeToHit = (Distance / ProjectileSpeed);
    local Predicted = Destination + DestinationVelocity * TimeToHit;
    local Delta = (Predicted - Origin).Magnitude / ProjectileSpeed;
    TimeToHit = TimeToHit + (Delta / ProjectileSpeed);
    local Actual = Destination + DestinationVelocity * TimeToHit;
    return Actual;
end;

local function get_closest_target(usefov, fov_size, aimpart, npc)
    local closest_part = nil
    local is_npc = false
    local max_distance = usefov and fov_size or math.huge
    local mousepos = _Vector2new(Mouse.X, Mouse.Y)
    if npc then
            for _, __no in pairs(workspace.AiZones:GetChildren()) do for _, npcs in pairs(__no:GetChildren()) do
                local part = _FindFirstChild(npcs, aimpart)
                local humanoid = _FindFirstChildOfClass(npcs, "Humanoid")
                if part and humanoid and humanoid.Health > 0 then
                    local position, onscreen = _WorldToViewportPoint(Camera, part.Position)
                    local distance = (_Vector2new(position.X, position.Y - GuiInset.Y) - mousepos).Magnitude
                    if (usefov and onscreen or not usefov) and distance < maximum_distance then
                        ermm_part = part
                        maximum_distance = distance
                        isnpc = true
                    end
                end
            end end
        end
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer then
            local character = player.Character
            if character then
                local part = character:FindFirstChild(aimpart)
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if part and humanoid and humanoid.Health > 0 then
                    local screen_pos, on_screen = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(part.Position)
                    local screen_vec = Vector2.new(screen_pos.X, screen_pos.Y - game:GetService("GuiService"):GetGuiInset().Y)
                    local distance = (screen_vec - mousepos).Magnitude
                    
                    if (usefov and on_screen or not usefov) and distance <= max_distance then
                        closest_part = part
                        max_distance = distance
                        is_npc = false
                    end
                end
            end
        end
    end
    return closest_part, is_npc
end
local hitsoundlib = {
    ["TF2"]       = "rbxassetid://8255306220",
    ["Gamesense"] = "rbxassetid://4817809188",
    ["Rust"]      = "rbxassetid://1255040462",
    ["Neverlose"] = "rbxassetid://8726881116",
    ['UwU'] = "rbxassetid://120904325097533",
    ['Tuturu'] = 'rbxassetid://121879336468415',
    ['EE'] = 'rbxassetid://102421680378225',
    ['ARA ARA'] = 'rbxassetid://18341750130',
    ['NYA'] = 'rbxassetid://123358629855878',
    ["Bubble"]    = "rbxassetid://198598793",
    ["Quake"]     = "rbxassetid://1455817260",
    ["Among-Us"]  = "rbxassetid://7227567562",
    ["Ding"]      = "rbxassetid://2868331684",
    ["Minecraft"] = "rbxassetid://6361963422",
    ["Blackout"]  = "rbxassetid://3748776946",
    ["Osu!"]      = "rbxassetid://7151989073",
}
local hitsoundlibUI = {}
for i, v in pairs(hitsoundlib) do
    table.insert(hitsoundlibUI, i)
end
local ICON_SIZE = UDim2.new(0, 40, 0, 40)
local CLOTHING_OFFSET = UDim2.new(0.5, 0, 0, 10) 
local INVENTORY_OFFSET =  UDim2.new(0.5, 0, 0, 60) 
local ICON_SPACING = 5
local MAX_ICONS_PER_ROW = 10
local IGNORED_ITEMS = {"CamoPants", "CamoShirt", "WastelandShirt", "GhillieLegs", "GorkaShirt","GorkaPants", "GhillieTorso", "KneePads", "WastelandPants", "Balaclava"} 

PlayerData = {}
local MainFrame = nil

local function createMainUI()
    if MainFrame then MainFrame:Destroy() end
    
    MainFrame = Instance.new("ScreenGui")
    MainFrame.Name = "ESP_Icons_Container"
    MainFrame.DisplayOrder = 10 
    MainFrame.ResetOnSpawn = false
    MainFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainFrame.Parent = CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainContainer"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.Parent = MainFrame
    
    return mainFrame
end

local function shouldIgnoreItem(itemName)
    itemName = string.lower(itemName)
    for _, ignoredName in pairs(IGNORED_ITEMS) do
        if string.lower(ignoredName) == itemName then
            return true
        end
    end
    return false
end

local function clearPlayerIcons(player)
    if PlayerData[player] then
        if PlayerData[player].InventoryFrame then
            PlayerData[player].InventoryFrame:Destroy()
            PlayerData[player].InventoryFrame = nil
        end
        if PlayerData[player].ClothingFrame then
            PlayerData[player].ClothingFrame:Destroy()
            PlayerData[player].ClothingFrame = nil
        end
    end
end

local function updateIconsDisplay(player, folderName, position)
    if not silent_aim.IconESP then 
        return 
    end
    
    if not PlayerData[player] then 
        return 
    end
    
    
    local targetPart, _ = get_closest_target(silent_aim.fov, silent_aim.fov_size, silent_aim.part, silent_aim.target_ai)
    if not targetPart or player.Character ~= targetPart.Parent then 
        clearPlayerIcons(player)
        return 
    end
    
    if not MainFrame then
        createMainUI()
    end
    
    local frameKey = folderName .. "Frame"
    if PlayerData[player][frameKey] then
        PlayerData[player][frameKey]:Destroy()
    end
    
    local character = player.Character
    if not character then 
        return 
    end
    
    local icons = {}
    local folder = ReplicatedStorage.Players[player.Name]:FindFirstChild(folderName)
    if folder then
        for _, item in ipairs(folder:GetChildren()) do
            if not shouldIgnoreItem(item.Name) then
                local props = item:FindFirstChild("ItemProperties")
                if props then
                    local icon = props:FindFirstChild("ItemIcon")
                    if icon and icon.Image then
                        table.insert(icons, icon.Image)
                    end
                end
            end
        end
    end
    
    if #icons == 0 then 
        return 
    end
    
    
    local container = Instance.new("Frame")
    container.Name = folderName .. "_" .. player.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(
        0, ICON_SIZE.X.Offset * math.min(#icons, MAX_ICONS_PER_ROW) + ICON_SPACING * (math.min(#icons, MAX_ICONS_PER_ROW) - 1),
        0, ICON_SIZE.Y.Offset * math.ceil(#icons / MAX_ICONS_PER_ROW) + (ICON_SPACING * 2) * (math.ceil(#icons / MAX_ICONS_PER_ROW) - 1)
    )
    container.Position = position
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.ZIndex = 10
    container.Parent = MainFrame
    
    local debugBackground = Instance.new("Frame")
    debugBackground.Size = UDim2.new(1, 0, 1, 0)
    debugBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    debugBackground.BackgroundTransparency = 0.7
    debugBackground.ZIndex = 1
    debugBackground.Parent = container

    for i, iconId in ipairs(icons) do
        local row = math.ceil(i / MAX_ICONS_PER_ROW) - 1
        local col = (i - 1) % MAX_ICONS_PER_ROW
        
        local icon = Instance.new("ImageLabel")
        icon.Name = "ItemIcon_" .. i
        icon.Size = ICON_SIZE
        icon.Position = UDim2.new(0, col * (ICON_SIZE.X.Offset + ICON_SPACING), 
                        0, row * (ICON_SIZE.Y.Offset + ICON_SPACING * 2 ))
        icon.BackgroundColor3 = Color3.fromRGB(60, 60, 60) 
        icon.BackgroundTransparency = 0.3
        icon.Image = iconId
        icon.ZIndex = 12
        icon.Parent = container
        
        local border = Instance.new("UIStroke")
        border.Color = Color3.new(1, 1, 1)
        border.Thickness = 1
        border.Parent = icon
        
    end
    
    PlayerData[player][frameKey] = container
end

local function setupFolderTracking(player, folderName)
    local playerFolder = ReplicatedStorage.Players:FindFirstChild(player.Name)
    if not playerFolder then return end

    local folder = playerFolder:FindFirstChild(folderName)
    if not folder then return end

    local function updateIcons()
        if folderName == "Clothing" then
            updateIconsDisplay(player, "Clothing", CLOTHING_OFFSET)
        else
            updateIconsDisplay(player, "Inventory", INVENTORY_OFFSET)
        end
    end

    folder.ChildAdded:Connect(updateIcons)
    folder.ChildRemoved:Connect(updateIcons)
    updateIcons()
end

local function initPlayer(player)
    if not PlayerData[player] then
        PlayerData[player] = {
            InventoryFrame = nil,
            ClothingFrame = nil,
            Connections = {}
        }
    end
    
    for _, conn in pairs(PlayerData[player].Connections) do
        conn:Disconnect()
    end
    PlayerData[player].Connections = {}

    local function onCharacterAdded(character)
        setupFolderTracking(player, "Clothing")
        setupFolderTracking(player, "Inventory")
    end

    table.insert(PlayerData[player].Connections, player.CharacterAdded:Connect(onCharacterAdded))
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

local function cleanup()
    if MainFrame then
        MainFrame:Destroy()
        MainFrame = nil
    end
    
    for player, data in pairs(PlayerData) do
        clearPlayerIcons(player)
    end
end
createMainUI()
do
    local norecoil, nobob = false, false
    local instantreload, rapidfire, forceauto, instantaim = false, false, false, false
    local autoshoot, packetautoshoot, packetpred, packetscan, packetthruscan, shootspeed = false, false, false, false, false, 1
    local target_part, is_npc, isvisible;
    local salobox = ui.box.aimbot:AddTab('silent aim')
    local gunmodbox = ui.box.mods:AddTab('gun mods')
    local hitsound = ui.box.hitsound:AddTab('hit sound')
    local hitmark = ui.box.hitmark:AddTab('hit marker')
    local hitmark2 = ui.box.hitmark:AddTab("hit tracer")
    local got_that = false
    repeat
        for i, gc in pairs(getgc(true)) do
            if type(gc) == "table" then
                if rawget(gc, "shove") and rawget(gc, "update") then
                    local originalShove = gc.shove
                    local originalUpdate = gc.update
                    
                    gc.shove = function(...)
                        return norecoil and Vector3.zero or originalShove(...)
                    end
                    
                    gc.update = function(...)
                        return nobob and Vector3.zero or originalUpdate(...)
                    end
                end
                
                if type(rawget(gc, "create")) == "function" and debug.getinfo(gc.create).short_src == "ReplicatedStorage.Modules.SpringV2" then
                    local originalCreate = gc.create
                    
                    gc.create = function(...)
                        local spring = originalCreate(...)
                        
                        if spring then
                            local originalSpringShove = spring.shove
                            local originalSpringUpdate = spring.update
                            
                            spring.shove = function(...)
                                return norecoil and Vector3.zero or originalSpringShove(...)
                            end
                            
                            spring.update = function(...)
                                return nobob and Vector3.zero or originalSpringUpdate(...)
                            end
                        end
                        
                        return spring
                    end
                end
                
                
                  if rawget(gc, "CreateBullet") then
                    local old_bullet = gc.CreateBullet
                    gc.CreateBullet = function(self, ...)
                        local args = { ... }
                        if silent_aim.enabled then
                            local loadedammo, aimpart_index
                            for i, v in args do
                                if typeof(v) == "Instance" and v.Name == "AimPart" then
                                    aimpart_index = i
                                end
                                if type(v) == "string" then
                                    local tmp = _FindFirstChild(game:GetService("ReplicatedStorage").AmmoTypes, v)
                                    if tmp then
                                        loadedammo = tmp
                                    end
                                end
                            end

                            if not (loadedammo and aimpart_index) then
                                return old_bullet(self, unpack(args))
                            end

                            if silent_aim.instant then
                                if silent_aim.target_part then
                                    runhitmark(silent_aim.target_part)
                                    if silent_aim.tracbool then
                                        task.spawn(function()
                                            task.wait(0.05)
                                            runtracer(Camera.ViewModel.Item.ItemRoot.Position, silent_aim.target_part)
                                        end)
                                    end
                                end

                                return old_bullet(self, unpack(args))
                            end

                            if not silent_aim.target_part or silent_aim.instant then
                                return old_bullet(self, unpack(args))
                            end

                            local ProjectileSpeed = loadedammo:GetAttribute("MuzzleVelocity")
                            local Destination = silent_aim.target_part.Position
                            local DestinationVelocity = silent_aim.target_part.Velocity
                            local Origin = Camera.CFrame.p
                            Destination = predict_velocity(Origin, Destination, DestinationVelocity, ProjectileSpeed)
                            args[aimpart_index] = { CFrame = _CFramenew(Origin, Destination) }
                        end
                        return old_bullet(self, unpack(args))
                    end
                end


                if rawget(gc, "updateClient") then
                    local originalUpdateClient = gc.updateClient
                    
                    gc.updateClient = function(...)
                        local args = {...}
                        
                       
                        if silent_aim.instantreload and args[1] and args[1].viewModel and args[1].clientAnimationTracks then
                            for _, anim in pairs(args[1].clientAnimationTracks) do
                                if anim.Name:find("Reload") then
                                    anim:AdjustSpeed(10)
                                end
                            end
                        end
                        
                        if instantaim and args[1] then
                            args[1].AimInSpeed = 0
                            args[1].AimOutSpeed = 0
                        end

                        if (forceauto or rapidfire) and args[1] then
                            if rapidfire then args[1].FireRate = 0 end
                            args[1].FireMode = "Auto"
                        end
                        
                        return originalUpdateClient(unpack(args))
                    end
                    
                    success = true
                end
            end
        end
        
        if not success then
            task.wait(1)
        end
    until success
     gunmodbox:AddToggle('unlockfiremnodes', {Text = 'unlock firemodes',Default = false,Callback = function(first)
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            local inv = game.ReplicatedStorage.Players:FindFirstChild(LocalPlayer.Name).Inventory
            if not inv then return end
            for _, v in pairs(inv:GetChildren()) do
                if not v:FindFirstChild("SettingsModule") then return end
                local sett = require(v.SettingsModule)
                sett.FireModes = {"Auto", "Semi"}
            end
    end})
    gunmodbox:AddToggle('gunmods_norecoil', {Text = 'no recoil',Default = false,Callback = function(first)
        norecoil = first
    end})
    gunmodbox:AddToggle('gunmods_nospread', {Text = 'no spread',Default = false,Callback = function(first)
        silent_aim.nospread = first
    end})
    gunmodbox:AddToggle('gunmods_instantaim', {Text = 'instant aim',Default = false,Callback = function(first)
        instantaim = first
    end})
    gunmodbox:AddToggle('gunmods_instanteq', {Text = 'instant equip',Default = false,Callback = function(first)
        silent_aim.instantequip = first
    end})
    gunmodbox:AddToggle('gunmods_instantreload', {Text = 'instant reload',Default = false,Callback = function(first)
        silent_aim.instantreload = first
         if first then 
            require(game.ReplicatedStorage.Modules.FPS).reload = instrelMODfunc
        else
            require(game.ReplicatedStorage.Modules.FPS).reload = instrelOGfunc
        end
    end})
    gunmodbox:AddToggle('gunmods_rapidfire', {Text = 'rapid fire',Default = false,Callback = function(first)
        rapidfire = first
    end})

    local silenttoogle = salobox:AddToggle('silentaim_enabled', {Text = 'silent aim',Default = false,Callback = function(first)
        silent_aim.enabled = first
    end})
     salobox:AddToggle('silentaim_npcaim', {Text = 'target AI',Default = false,Callback = function(first)
        silent_aim.target_ai = first
    end})
    silenttoogle:AddKeyPicker('aimsilentKey', {
    Default = 'B',
    SyncToggleState = true,
    Mode = 'Toggle', 
    Text = 'silent aim',
    NoUI = false, 
    })
    salobox:AddToggle('antiaim', {Text = 'anti aim',Default = false,Callback = function(first)
        silent_aim.antiaim = first
        if first then 
            track = humanoid:LoadAnimation(anderanim)
            track:Play()
            track:AdjustSpeed(0)
            toggleCameraOffset(true)
        else 
            if track then
                track:Stop()
            end
            toggleCameraOffset(false)
        end
    end}):AddKeyPicker('anti aimd', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'anti aim',NoUI = false})
    salobox:AddToggle('resolver ', {Text = 'resolver down',Default = false,Callback = function(first)
        aimresolver = first
    end}):AddKeyPicker('anti aimddd', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'resolver',NoUI = false})
    salobox:AddToggle('resolver', {Text = 'resolver up',Default = false,Callback = function(first)
        aimresolverhh = first
    end}):AddKeyPicker('anti aimddddddd', {Default = 'None',SyncToggleState = true,Mode = 'Toggle',Text = 'resolver up',NoUI = false})

    salobox:AddToggle('silentaim_fov', {Text = 'use fov',Default = false,Callback = function(Value)
        silent_aim.fov = Value
    end})

    local Depbox1 = salobox:AddDependencyBox();

    Depbox1:AddToggle('silentaim_fov_show', {Text = 'show fov',Default = false,Callback = function(Value)
        silent_aim.fov_show = Value
    end}):AddColorPicker('silentaim_fov_color',{Default = Color3.new(1, 1, 1),Title = 'fov color',Transparency = 0,Callback = function(Value)
        silent_aim.fov_color = Value
    end})
    local fovl = Depbox1:AddToggle('aimbot_fovcheckline', 
    {Text = 'fov line',
    Default = false,
    Callback = function(state)
        silent_aim.fovline = state
    end})
    fovl:AddColorPicker('fov_linecolor', {
        Default = Color3.fromRGB(255, 255, 255),
        Title   = "fov line color",
        Callback = function(color)
            silent_aim.fovlinecolor = color
        end
    })
    Depbox1:AddToggle('aimbot_fovwallcheck', 
    {Text = 'fov wallcheck',
    Default = false,
    Callback = function(v)
        silent_aim.showvisible = v
    end})
    Depbox1:AddToggle('ShowHP', {
    Text = 'show hp',
    Default = false,
    Callback = function(v)
        silent_aim.showhp = v
    end
    })
    Depbox1:AddToggle('silentaim_indicator', {Text = 'show name',Default = false,Callback = function(first)
        silent_aim.indicator = first
    end})
    Depbox1:AddToggle('ShowDist', {
        Text = 'show distance',
        Default = false,
        Callback = function(v)
            silent_aim.showdistance = v
        end
    })
    Depbox1:AddToggle('ShowDist2', {
        Text = 'show tool',
        Default = false,
        Callback = function(v)
            silent_aim.IconESP = v

        
        if v then
            createMainUI() 

            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if PlayerData[player] then
                    updateIconsDisplay(player, "Inventory", INVENTORY_OFFSET)
                    updateIconsDisplay(player, "Clothing", CLOTHING_OFFSET)
                end
            end
        else
            cleanup()
        end
        
        end
    })
    Depbox1:AddToggle('silentaim_fov_outline', {Text = 'fov outline',Default = false,Callback = function(Value)
        silent_aim.fov_outline = Value
    end})

    Depbox1:AddSlider('silentaim_fov_size',{Text = 'target fov',Default = 100,Min = 10,Max = 1000,Rounding = 0,Compact = true,Callback = function(State)
        silent_aim.fov_size = State
    end})
    Depbox1:AddSlider('fov_line_th', {
    Default = 1,
    Text = "fov line size",
    Min = 1,
    Max = 3,
    Rounding = 1,
    Callback = function(value)
        silent_aim.FOVLineTH = value  
    end
    })
    Depbox1:SetupDependencies({
        { cheat.Toggles.silentaim_fov, true }
    });
    salobox:AddSlider('aimbot_distance', {
    Default = 100,
    Text = "check distance",
    Min = 0,
    Max = 3000,
    Compact = true,
    Rounding = 2,
    Callback = function(state)
        silent_aim.silentdistance = state
    end
    })
    salobox:AddDropdown('silent aim hit part', {Values = {'Head','FaceHitBox','HeadTopHitbox','UpperTorso','LowerTorso','HumanoidRootPart','LeftFoot','LeftLowerLeg','LeftUpperLeg','LeftHand','LeftLowerArm','LeftUpperArm','RightFoot','RightLowerLeg','RightUpperLeg','RightHand','RightLowerArm','RightUpperArm'},Default = 1,Multi = false,Text = 'silent aim part',Tooltip = 'select part',Callback = function(Value)
        silent_aim.part = Value
    end})
    hitsound:AddToggle('Hitsound', {
    Text = 'enabled',
    Default = false,
    Tooltip = 'enables hitsounds',
    Callback = function(v)
        silent_aim.hitsoundbool = v
    end
    })
    hitsound:AddDropdown('HitsoundHead', {
        Values = hitsoundlibUI,
        Default = "Ding",
        Multi = false,
        Text = 'head sound',
        Callback = function(a)
            if hitsoundlib == nil or a == nil then return end
            silent_aim.hitsoundhead = a
            local preview = Instance.new("Sound", workspace)
            preview.SoundId = hitsoundlib[a]
            preview.Volume = silent_aim.hitsoundvolume
            preview:Play()
            task.wait(1)
            preview:Destroy()
        end
    })
    hitsound:AddDropdown('HitsoundBody', {
        Values = hitsoundlibUI,
        Default = "Blackout",
        Multi = false,
        Text = 'body sound',
        Callback = function(a)
            if hitsoundlib == nil or a == nil then return end
            silent_aim.hitsoundbody = a
            local preview = Instance.new("Sound", workspace)
            preview.SoundId = hitsoundlib[a]
            preview.Volume = silent_aim.hitsoundvolume
            preview:Play()
            task.wait(1)
            preview:Destroy()
        end
    })
    hitsound:AddSlider('hitsoundslidervolume', {
        Default = 1,
        Text = "volume",
        Min = 0,
        Max = 10,
        Rounding = 2,
        Callback = function(state)
            silent_aim.hitsoundvolume = state
        end
    })
    local hitcoloren = hitmark:AddToggle('Hitmarker', {
    Text = 'enabled',
    Default = false,
    Callback = function(v)
        silent_aim.hitmarkbool = v
    end
    })
    hitmark:AddSlider('Hitmarker fade', {
        Text = 'hitmarker time',
        Default = 2,
        Min = 0,
        Max = 10,
        Rounding = 1,
        Compact = false,
        Callback = function(c)
            silent_aim.hitmarkfade = c
        end
    })
    hitcoloren:AddColorPicker('HitmarkColorPick', {
        Default = Color3.new(1, 1, 1),
        Title = 'hitmarker color',
        Callback = function(a)
            silent_aim.hitmarkcolor = a
        end
    })
    local trchit = hitmark2:AddToggle('Tracers hit', {
    Text = 'tracers hit',
    Default = false,
    Callback = function(v)
        silent_aim.tracbool = v
    end
    })
    trchit:AddColorPicker('tracer hits color', {
            Default = Color3.fromRGB(255, 0, 0),
            Title = "tracer hits color",
            Callback = function(color)
                silent_aim.traccolor = color
            end
        })
    hitmark2:AddInput('traceridhit', {
        Default = "131326755401058",
        Numeric = true,
        Finished = false,
        Text = 'image id',
        Tooltip = 'just roblox decal id',
        Placeholder = 'put Id',
        Callback = function(a)
            silent_aim.tractexture = "rbxassetid://"..a
        end
    })
    local CircleOutline = Drawing.new("Circle")
    local CircleInline = Drawing.new("Circle")
    CircleInline.Transparency = 1
    CircleInline.Thickness = 1
    CircleInline.ZIndex = 2
    CircleOutline.Thickness = 3
    CircleOutline.Color = Color3.new()
    CircleOutline.ZIndex = 1
    local indicatortext = cheat.utility.new_drawing("Text", {
        Visible = false,
        Font = Drawing.Fonts.System,
        Size = 13,
        Color = Color3.new(1, 1, 1),
        ZIndex = 3,
        Transparency = 1,
        Text = "",
        Center = true,
        Outline = true,
        Position = _Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 + silent_aim.fov_size + 10)
    })
    local aimtargetshots = cheat.utility.new_drawing("Text", {
        Visible = false,
        Font = Drawing.Fonts.System,
        Size = 13,
        Color = Color3.new(1, 1, 1),
        ZIndex = 3,
        Transparency = 1,
        Text = "",
        Center = true,
        Position = _Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 + silent_aim.fov_size + 30), 
        Outline = true,
    })
    local fovlinedraw = cheat.utility.new_drawing("Line", {
        Thickness = silent_aim.FOVLineTH,
        Color = silent_aim.fovlinecolor,
        Transparency = 1,
        Visible = false  
    })
    local aimtargetname = cheat.utility.new_drawing("Text", {
        Visible = false,
        Font = Drawing.Fonts.System,
        Size = 13,
        Color = Color3.new(1, 1, 1),
        ZIndex = 3,
        Transparency = 1,
        Text = "",
        Center = true,
        Position = _Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 + silent_aim.fov_size + 50), 
        Outline = true,
    })
    local aimtargetvis = cheat.utility.new_drawing("Text", {
        Visible = false,
        Font = Drawing.Fonts.System,
        Size = 13,
        Color = Color3.new(1, 1, 1),
        ZIndex = 3,
        Transparency = 1,
        Text = "",
        Center = true,
        Position = _Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 + silent_aim.fov_size + 70), 
        Outline = true,
    })
    RunService.RenderStepped:Connect((function()
        CircleOutline.Position = (_Vector2new(Mouse.X, Mouse.Y + GuiInset.Y))
        CircleInline.Position = (_Vector2new(Mouse.X, Mouse.Y + GuiInset.Y))
        CircleInline.Radius = silent_aim.fov_size
        CircleInline.Color = silent_aim.fov_color
        CircleInline.Visible = silent_aim.fov and silent_aim.fov_show
        CircleOutline.Radius = silent_aim.fov_size
        CircleOutline.Visible = (silent_aim.fov and silent_aim.fov_show and silent_aim.fov_outline)
        indicatortext.Color = Color3.fromRGB(255,255,255)
        indicatortext.Font = Drawing.Fonts.System
        indicatortext.Text = silent_aim.indicator_text
    end))
    local lastTargetUpdate = 0
    RunService.RenderStepped:Connect((function(dt)
        lastTargetUpdate += dt
        if silent_aim.fov then
        local indtxt = ""
        local infotarget
        silent_aim.isvisible = silent_aim.target_part and is_visible(Camera.CFrame, silent_aim.target_part.Parent, silent_aim.target_part) or nil;
        silent_aim.target_part, silent_aim.is_npc = get_closest_target(silent_aim.fov, silent_aim.fov_size, silent_aim.part, silent_aim.target_ai);
        if silent_aim.target_part then
            infotarget = silent_aim.target_part.Parent
            indtxt = indtxt..(silent_aim.target_part.Parent.Name)
            if silent_aim.is_npc then
                indtxt = indtxt.." (ai)"
            end
            if silent_aim.showhp then
            aimtargetshots.Visible = true
            aimtargetshots.Text = math.floor(infotarget.Humanoid.Health) .. " / " .. math.floor(infotarget.Humanoid.MaxHealth) .. " HP"
            else
                aimtargetshots.Text = ''
                aimtargetname.Visible = false
            end
            if silent_aim.fovline then
                local headpos = Camera:WorldToViewportPoint(silent_aim.target_part.Position)
                fovlinedraw.From =  _Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                fovlinedraw.To =   _Vector2new(headpos.X, headpos.Y)
                fovlinedraw.Color = silent_aim.fovlinecolor
                fovlinedraw.Thickness = silent_aim.FOVLineTH
                fovlinedraw.Visible = true
            else
                fovlinedraw.Visible = false
            end
            if silent_aim.showvisible then
                        aimtargetvis.Visible = true 
                        if silent_aim.isvisible then   
                        aimtargetvis.Text = "[Y] visible"
                        aimtargetvis.Color = Color3.fromRGB(105, 255, 41)
                        else
                        aimtargetvis.Color = Color3.fromRGB(255, 41, 41)
                        aimtargetvis.Text = "[Y] not visible"
                        end 
                    else
                        aimtargetvis.Visible = false
                    end
                    if silent_aim.indicator then
                            indicatortext.Visible = true
                            silent_aim.indicator_text = indtxt
                    else
                        indicatortext.Visible = false
                        silent_aim.indicator_text = ''
                    end
            if silent_aim.showdistance then
            aimtargetname.Visible = true
            local targetdist = math.floor((LocalPlayer.Character.PrimaryPart.Position - infotarget.HumanoidRootPart.Position).Magnitude * 0.3336)
            aimtargetname.Text = targetdist.."m"
            else
                aimtargetname.Visible = false
            end
        else
            fovlinedraw.Visible = false
            aimtargetvis.Text = ""
            aimtargetshots.Text = ''
            aimtargetname.Text = ""
            indtxt = ""
        end
        
        silent_aim.indicator_text = indtxt
    else    
            fovlinedraw.Visible = false
            aimtargetname.Visible = false
            aimtargetvis.Visible = false
            indicatortext.Visible = false
            aimtargetname.Visible = false
            aimtargetvis.Text = ""
            aimtargetshots.Text = ''
            aimtargetname.Text = ""
            silent_aim.indicator_text = ''
        end
    end))
end
workspace.Camera.ChildAdded:Connect(function(ch)
    if silent_aim.instantequip and ch:IsA("Model") then
        task.wait(0.015)
        for i,v in ch.Humanoid.Animator:GetPlayingAnimationTracks() do
            if v.Animation.Name == "Equip" then
                v:AdjustSpeed(15)
                v.TimePosition = v.Length - 0.01
            end
        end
    end
end)
LocalPlayer.CharacterAdded:Connect(function(lchar)
    if LocalPlayer.PlayerGui:WaitForChild("MainGui") then
        LocalPlayer.PlayerGui.MainGui.ChildAdded:Connect(function(Sound)
            if Sound:IsA("Sound") and silent_aim.hitsoundbool then
                if Sound.SoundId == "rbxassetid://4585351098" or Sound.SoundId == "rbxassetid://4585382589" then --headshot
                    Sound.SoundId = hitsoundlib[silent_aim.hitsoundhead]
                elseif Sound.SoundId == "rbxassetid://4585382046" or Sound.SoundId == "rbxassetid://4585364605" then --bodyshot
                    Sound.SoundId = hitsoundlib[silent_aim.hitsoundbody]
                end
            end
        end)
    end
end)
LocalPlayer.PlayerGui.MainGui.ChildAdded:Connect(function(Sound)
    if Sound:IsA("Sound") and silent_aim.hitsoundbool then
        if Sound.SoundId == "rbxassetid://4585351098" or Sound.SoundId == "rbxassetid://4585382589" then --headshot
            Sound.SoundId = hitsoundlib[silent_aim.hitsoundhead]
        elseif Sound.SoundId == "rbxassetid://4585382046" or Sound.SoundId == "rbxassetid://4585364605" then --bodyshot
            Sound.SoundId = hitsoundlib[silent_aim.hitsoundbody]
        end
    end
end)
function runhitmark(v140)
    if silent_aim.hitmarkbool then
        local hitpart = Instance.new("Part", workspace)
        hitpart.Transparency = 1
        hitpart.CanCollide = false
        hitpart.CanQuery = false
        hitpart.Size = Vector3.new(0.01,0.01,0.01)
        hitpart.Anchored = true
        hitpart.Position = v140.Position

        local hit = Instance.new("BillboardGui")
        hit.Name = "hit"
        hit.AlwaysOnTop = true
        hit.Parent = hitpart
        local hit_img = Instance.new("ImageLabel")
        hit_img.Name = "hit_img"
        hit_img.Image = "http://www.roblox.com/asset/?id=13298929624"
        hit_img.BackgroundTransparency = 1
        hit_img.Size = UDim2.new(0, 50, 0, 50)
        hit_img.Visible = true
        hit_img.ImageColor3 = silent_aim.hitmarkcolor
        hit_img.Rotation = 45
        hit_img.AnchorPoint = Vector2.new(0.5, 0.5)
        hit_img.Parent = hit

        task.spawn(function()
            local tweninfo = TweenInfo.new(silent_aim.hitmarkfade, Enum.EasingStyle.Sine)
            local tweninfo2 = TweenInfo.new(silent_aim.hitmarkfade, Enum.EasingStyle.Linear)
            TweenService:Create(hit_img, tweninfo, {ImageTransparency = 1}):Play()
            TweenService:Create(hit_img, tweninfo2, {Rotation = 180}):Play()
            task.wait(silent_aim.hitmarkfade)
            hit_img:Destroy()
            hit:Destroy()
        end)
    end
end
do
    local mod = require(game.ReplicatedStorage.Modules.FPS)
    local ogfunc = mod.updateClient

    mod.updateClient = function(a1,a2,a3)
        arg1, arg2, arg3 = ogfunc(a1,a2,a3)
        
        a1table = a1

        if nojumptilt then
            a1.springs.jumpCameraTilt.Position = Vector3.new(0,0,0)
        end
        return arg1, arg2, arg3
    end
end
function runtracer(start, endp)
    local beam = Instance.new("Beam")
    beam.Name = "LineBeam"
    beam.Parent = game.Workspace
    local startpart = Instance.new("Part")
    startpart.CanCollide = false
    startpart.CanQuery = false
    startpart.Transparency = 1
    startpart.Position = start
    startpart.Parent = workspace
    startpart.Anchored = true
    startpart.Size = Vector3.new(0.01, 0.01, 0.01)
    local endpart = Instance.new("Part")
    endpart.CanCollide = false
    endpart.CanQuery = false
    endpart.Transparency = 1
    endpart.Position = endp.Position
    endpart.Parent = workspace
    endpart.Anchored = true
    endpart.Size = Vector3.new(0.01, 0.01, 0.01)
    beam.Attachment0 = Instance.new("Attachment", startpart)
    beam.Attachment1 = Instance.new("Attachment", endpart)
    beam.Color = ColorSequence.new(silent_aim.traccolor,  silent_aim.traccolor)
    beam.Width0 = 0.05
    beam.Width1 = 0.05
    beam.FaceCamera = true
    beam.Transparency = NumberSequence.new(0)
    beam.LightEmission = 1

    if silent_aim.tractexture ~= nil then
        beam.Texture = silent_aim.tractexture
        beam.TextureSpeed = 3
        beam.TextureLength = (endp.Position - start).Magnitude
        beam.Width0 = 0.3
        beam.Width1 = 0.3
    end
    wait(2)

    beam:Destroy()
    startpart:Destroy()
    endpart:Destroy()
end
instrelMODfunc = function(a1,a2)
    local function aaa(a1)
        local v27_2_ = a1.weapon
        local v27_1_ = v27_2_.Attachments
        local v27_3_ = "Magazine"
        v27_1_ = v27_1_:FindFirstChild(v27_3_)
        if v27_1_ then
            local v27_4_ = a1.weapon
            v27_3_ = v27_4_.Attachments
            v27_2_ = v27_3_.Magazine
            v27_2_ = v27_2_:GetChildren()
            v27_1_ = v27_2_[-1]
            if v27_1_ then
                v27_2_ = v27_1_.ItemProperties
                v27_4_ = "LoadedAmmo"
                v27_2_ = v27_2_:GetAttribute(v27_4_)
                a1.Bullets = v27_2_
                v27_2_ = {}
                a1.BulletsList = v27_2_
                v27_3_ = v27_1_.ItemProperties
                v27_2_ = v27_3_.LoadedAmmo
                v27_3_ = v27_2_:GetChildren()
                local v27_6_ = 1
                v27_4_ = #v27_3_
                local v27_5_ = 1
                for v27_6_ = v27_6_, v27_4_, v27_5_ do
                    local v27_7_ = a1.BulletsList
                    local v27_10_ = v27_3_[v27_6_]
                    local v27_9_ = v27_10_.Name
                    local v27_8_ = tonumber
                    v27_8_ = v27_8_(v27_9_)
                    v27_9_ = {}
                    v27_10_ = v27_3_[v27_6_]
                    local v27_12_ = "AmmoType"
                    v27_10_ = v27_10_:GetAttribute(v27_12_)
                    v27_9_.AmmoType = v27_10_
                    v27_10_ = v27_3_[v27_6_]
                    v27_12_ = "Amount"
                    v27_10_ = v27_10_:GetAttribute(v27_12_)
                    v27_9_.Amount = v27_10_
                    v27_7_[v27_8_] = v27_9_
                end
            end
            v27_2_ = 0
            a1.movementModifier = v27_2_
            v27_2_ = a1.weapon
            if v27_2_ then
                v27_2_ = a1.movementModifier
                local v27_6_ = a1.weapon
                local v27_5_ = v27_6_.ItemProperties
                v27_4_ = v27_5_.Tool
                v27_6_ = "MovementModifer"
                v27_4_ = v27_4_:GetAttribute(v27_6_)
                v27_3_ = v27_4_ or 0.000000
                v27_2_ += v27_3_
                a1.movementModifier = v27_2_
                v27_2_ = a1.weapon
                v27_4_ = "Attachments"
                v27_2_ = v27_2_:FindFirstChild(v27_4_)
                if v27_2_ then
                    v27_3_ = a1.weapon
                    v27_2_ = v27_3_.Attachments
                    v27_2_ = v27_2_:GetChildren()
                    v27_5_ = 1
                    v27_3_ = #v27_2_
                    v27_4_ = 1
                    for v27_5_ = v27_5_, v27_3_, v27_4_ do
                        v27_6_ = v27_2_[v27_5_]
                        local v27_8_ = "StringValue"
                        v27_6_ = v27_6_:FindFirstChildOfClass(v27_8_)
                        if v27_6_ then
                            local v27_7_ = v27_6_.ItemProperties
                            local v27_9_ = "Attachment"
                            v27_7_ = v27_7_:FindFirstChild(v27_9_)
                            if v27_7_ then
                                v27_7_ = a1.movementModifier
                                local v27_10_ = v27_6_.ItemProperties
                                v27_9_ = v27_10_.Attachment
                                local v27_11_ = "MovementModifer"
                                v27_9_ = v27_9_:GetAttribute(v27_11_)
                                v27_8_ = v27_9_ or 0.000000
                                v27_7_ += v27_8_
                                a1.movementModifier = v27_7_
                            end
                        end
                        return
                    end
                end
            end
        end
        v27_2_ = a1.weapon
        v27_1_ = v27_2_.ItemProperties
        v27_3_ = "LoadedAmmo"
        v27_1_ = v27_1_:GetAttribute(v27_3_)
        a1.Bullets = v27_1_
        v27_1_ = {}
        a1.BulletsList = v27_1_
        v27_3_ = a1.weapon
        v27_2_ = v27_3_.ItemProperties
        v27_1_ = v27_2_.LoadedAmmo
        v27_2_ = v27_1_:GetChildren()
        local v27_5_ = 1
        v27_3_ = #v27_2_
        local v27_4_ = 1
        for v27_5_ = v27_5_, v27_3_, v27_4_ do
            local v27_6_ = a1.BulletsList
            local v27_9_ = v27_2_[v27_5_]
            local v27_8_ = v27_9_.Name
            local v27_7_ = tonumber
            v27_7_ = v27_7_(v27_8_)
            v27_8_ = {}
            v27_9_ = v27_2_[v27_5_]
            local v27_11_ = "AmmoType"
            v27_9_ = v27_9_:GetAttribute(v27_11_)
            v27_8_.AmmoType = v27_9_
            v27_9_ = v27_2_[v27_5_]
            v27_11_ = "Amount"
            v27_9_ = v27_9_:GetAttribute(v27_11_)
            v27_8_.Amount = v27_9_
            v27_6_[v27_7_] = v27_8_
        end
    end
    local v103_2_ = a1.viewModel
    if v103_2_ then
        local v103_3_ = a1.viewModel
        v103_2_ = v103_3_.Item
        local v103_4_ = "AmmoTypes"
        v103_2_ = v103_2_:FindFirstChild(v103_4_)
        if v103_2_ then
            local v103_5_ = a1.weapon
            v103_4_ = v103_5_.ItemProperties
            v103_3_ = v103_4_.AmmoType
            v103_2_ = v103_3_.Value
            v103_5_ = a1.viewModel
            v103_4_ = v103_5_.Item
            v103_3_ = v103_4_.AmmoTypes
            v103_3_ = v103_3_:GetChildren()
            local v103_6_ = 1
            v103_4_ = #v103_3_
            v103_5_ = 1
            for v103_6_ = v103_6_, v103_4_, v103_5_ do
                local v103_7_ = v103_3_[v103_6_]
                local v103_8_ = 1
                v103_7_.Transparency = v103_8_
            end
            v103_6_ = a1.viewModel
            v103_5_ = v103_6_.Item
            v103_4_ = v103_5_.AmmoTypes
            v103_6_ = v103_2_
            v103_4_ = v103_4_:FindFirstChild(v103_6_)
            v103_5_ = 0
            v103_4_.Transparency = v103_5_
            v103_5_ = a1.viewModel
            v103_4_ = v103_5_.Item
            v103_6_ = "AmmoTypes2"
            v103_4_ = v103_4_:FindFirstChild(v103_6_)
            if v103_4_ then
                v103_6_ = a1.viewModel
                v103_5_ = v103_6_.Item
                v103_4_ = v103_5_.AmmoTypes2
                v103_4_ = v103_4_:GetChildren()
                local v103_7_ = 1
                v103_5_ = #v103_4_
                v103_6_ = 1
                for v103_7_ = v103_7_, v103_5_, v103_6_ do
                    local v103_8_ = v103_4_[v103_7_]
                    local v103_9_ = 1
                    v103_8_.Transparency = v103_9_
                end
                v103_7_ = a1.viewModel
                v103_6_ = v103_7_.Item
                v103_5_ = v103_6_.AmmoTypes2
                v103_7_ = v103_2_
                v103_5_ = v103_5_:FindFirstChild(v103_7_)
                v103_6_ = 0
                v103_5_.Transparency = v103_6_
            end
        end
        v103_2_ = a1.reloading
        if v103_2_ == false then
            v103_2_ = a1.cancellingReload
            if v103_2_ == false then
                v103_2_ = a1.MaxAmmo
                v103_3_ = 0
                if v103_3_ < v103_2_ then
                    v103_3_ = true
                    local v103_6_ = 1
                    local v103_7_ = a1.CancelTables
                    v103_4_ = #v103_7_
                    local v103_5_ = 1
                    for v103_6_ = v103_6_, v103_4_, v103_5_ do
                        local v103_9_ = a1.CancelTables
                        local v103_8_ = v103_9_[v103_6_]
                        v103_7_ = v103_8_.Visible
                        if v103_7_ == true then
                            v103_3_ = false
                        else
                        end
                    end
                    v103_2_ = v103_3_
                    if v103_2_ then
                        v103_3_ = a1.clientAnimationTracks
                        v103_2_ = v103_3_.Inspect
                        if v103_2_ then
                            v103_3_ = a1.clientAnimationTracks
                            v103_2_ = v103_3_.Inspect
                            v103_2_:Stop()
                            v103_3_ = a1.serverAnimationTracks
                            v103_2_ = v103_3_.Inspect
                            v103_2_:Stop()
                            v103_4_ = a1.WeldedTool
                            v103_3_ = v103_4_.ItemRoot
                            v103_2_ = v103_3_.Sounds.Inspect
                            v103_2_:Stop()
                        end
                        v103_3_ = a1.settings
                        v103_2_ = v103_3_.AimWhileActing
                        if not v103_2_ then
                            v103_2_ = a1.isAiming
                            if v103_2_ then
                                v103_4_ = false
                                a1:aim(v103_4_)
                            end
                        end
                        
                        if a1.reloadType == "loadByHand" then
                            local count = a1.Bullets
                            local maxcount = a1.MaxAmmo

                            for i=count, maxcount do 
                                game.ReplicatedStorage.Remotes.Reload:InvokeServer(nil, 0.001, nil)
                            end

                            aaa(a1)
                        else
                            game.ReplicatedStorage.Remotes.Reload:InvokeServer(nil, 0.001, nil)

                            require(game.ReplicatedStorage.Modules.FPS).equip(a1, a1.weapon, nil)

                            aaa(a1)
                        end      
                    end
                end
            end
        end
    end
end
do
    local nan = 0.001
    local game_TweenService = game:GetService("TweenService")

    local __newindex; __newindex = hookmetamethod(game, "__newindex", newcclosure((function(self, k, v)
        if checkcaller() then return __newindex(self, k, v) end
        if self == Camera then
            if k == "FieldOfView" and (globals.fov_enabled or globals.zoom_enabled) then
                return
            end
        end
        return __newindex(self, k, v)
    end)))
    local __namecall; __namecall = hookmetamethod(game, "__namecall", newcclosure((function(self,...)
        if checkcaller() then return __namecall(self, ...) end
        local args = {...}
        local method = getnamecallmethod()
        if self == game_TweenService and method == "Create" and args[1] == Camera and rawget(args[3], "FieldOfView") and (globals.fov_enabled or globals.zoom_enabled) then
            args[3] = {}
            return __namecall(self, unpack(args))
        end
        if method == "GetAttribute" then
            local attribute = args[1]
            if silent_aim.nospread and attribute == "AccuracyDeviation" then
                return 0
            end
            if silent_aim.enabled then
                if attribute == "ProjectileDrop" then
                    return 0
                end
                if attribute == "Drag" then
                    return 0
                end
            end
        end
        if method == "InvokeServer" then
            if self.Name == "FireProjectile" and silent_aim.enabled and silent_aim.instant and silent_aim.target_part then
                args[3] = 0/0
                return __namecall(self, unpack(args))
            end
        end
        if method == "FireServer" then
            if self.Name == "ProjectileInflict" then
                if debug.traceback() and debug.traceback():find("CharacterController") then
                    return coroutine.yield()
                end
                args[4] = 0/0
                return __namecall(self, unpack(args))
            end
        end
        if method == "Raycast" and silent_aim.enabled and silent_aim.instant and silent_aim.target_part then
            local hitpart = silent_aim.target_part
            if hitpart then
                args[2] = (hitpart.Position - args[1])
                if silent_aim.testwallbang then
                    return {
                        Instance = hitpart,
                        Position = hitpart.Position,
                        Normal = Vector3.new(1, 0, 0),
                        Material = hitpart.Material,
                        Distance = (hitpart.Position - args[1]).Magnitude
                    }
                end
            end
            return __namecall(self, unpack(args))
        end
        return __namecall(self, ...)
    end)))
end

local fpsrequired = require(game.ReplicatedStorage.Modules.FPS)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    originalOffset = humanoid.CameraOffset
    
    if silent_aim.antiaim then
        track = humanoid:LoadAnimation(anderanim)
        track:Play()
        track:AdjustSpeed(0)
        toggleCameraOffset(true)
    end
end)
local __index
__index = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() and resolver_active and key == "CFrame" then
        if typeof(self) == "Instance" and self:IsA("BasePart") and self.Name == "HumanoidRootPart" then
            return self.CFrame * CFrame.new(0, -2, 0)
        end
    end
    return __index(self, key)
end))
local crossgui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
crossgui.ClipToDeviceSafeArea = false
crossgui.ResetOnSpawn = false
crossgui.ScreenInsets = 0
local crosshair = Instance.new("ImageLabel", crossgui)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.Size = UDim2.new(crosssizeog.X.Scale * silent_aim.crosssizek, 0, crosssizeog.Y.Scale * silent_aim.crosssizek, 0)
crosshair.Image = silent_aim.crossimg
crosshair.ImageColor3 = silent_aim.crosscolor
crosshair.BackgroundTransparency = 1
crosshair.Visible = false
local crosshairenabled =  ui.box.crosshair:AddToggle('crosshair_enabled', 
    {Text = 'enabled',
    Default = false,
    Callback = function(state)
        silent_aim.crossbool = state
        print("CrosshairState toggle:", silent_aim.crossbool)
    end})
crosshairenabled:AddColorPicker('crosshair_color', {
    Default = Color3.fromRGB(255, 255, 255),
    Title   = "crosshair color",
    Callback = function(color)
        silent_aim.crosscolor = color
    end
})
ui.box.crosshair:AddInput('CrossId', {
    Default = "15574540229",
    Numeric = true,
    Finished = false,
    Text = 'image id',
    Tooltip = 'just roblox decal id',
    Placeholder = 'put Id',
    Callback = function(a)
        silent_aim.crossimg = "rbxassetid://"..a
    end
})
ui.box.crosshair:AddSlider('rotation speed', {
    Text = 'rotation speed',
    Default = 2,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        silent_aim.crossrot = c
    end
})
ui.box.crosshair:AddSlider('Size', {
    Text = 'Size',
    Default = 1,
    Min = 0.5,
    Max = 30,
    Rounding = 1,
    Compact = false,
    Callback = function(c)
        silent_aim.crosssizek = c
    end
})
RunService.Heartbeat:Connect(function(delta)
if silent_aim.antiaim and character and rootPart then
        track.TimePosition = getgenv().animpos
        
        dysenc[1] = rootPart.CFrame
        dysenc[2] = rootPart.AssemblyLinearVelocity
        
        local spoofCFrame = rootPart.CFrame 
            * CFrame.Angles(math.rad(getgenv().xrotation), 0, 0)
            + Vector3.new(0, getgenv().underground, 0)
        
        rootPart.CFrame = spoofCFrame
        
        RunService.RenderStepped:Wait()
        
        if character and rootPart then
            rootPart.CFrame = dysenc[1]
            rootPart.AssemblyLinearVelocity = dysenc[2]
        end
    end
if silent_aim.crossbool then 
        crosshair.Visible = true
        crosshair.Rotation += silent_aim.crossrot
        crosshair.Size = UDim2.new(crosssizeog.X.Scale * silent_aim.crosssizek, 0, crosssizeog.Y.Scale * silent_aim.crosssizek, 0)
        crosshair.Image = silent_aim.crossimg
        crosshair.ImageColor3 = silent_aim.crosscolor
    else
        crosshair.Visible = false
    end
if aimresolverhh and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
        local aimresolverpos = LocalPlayer.Character.HumanoidRootPart.CFrame
        local char = LocalPlayer.Character
        local hrp = char.HumanoidRootPart
        local mult = CFrame.new(0, 3, 0)
        hrp.AssemblyLinearVelocity = -mult.Position
        char.HumanoidRootPart.CanCollide = false
        char.UpperTorso.CanCollide = false
        char.LowerTorso.CanCollide = false
        char:PivotTo(aimresolverpos * mult)
    end
if aimresolver and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
    local char = LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    
    local targetY = -1.5
    local currentPos = hrp.Position
    local newPos = Vector3.new(currentPos.X, targetY, currentPos.Z)
    
    hrp.CanCollide = false
    char.UpperTorso.CanCollide = false
    char.LowerTorso.CanCollide = false
    
    hrp.CFrame = CFrame.new(newPos)
    hrp.AssemblyLinearVelocity = Vector3.zero 
    
        if hrp.Position.Y < targetY then
            hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, targetY, hrp.Position.Z))
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
end
end)
Camera.ChildAdded:Connect(function(ch)
    if ch:IsA("Model") and ch.Name == "ViewModel" then
        task.wait(0.05)
        handleViewModel()
    end
end)

Players.PlayerAdded:Connect(function(player)
        initPlayer(player)
end)
for _, player in ipairs(Players:GetPlayers()) do
        initPlayer(player)
end




Players.PlayerRemoving:Connect(function(player)
        if PlayerData[player] then
            if PlayerData[player].ClothingGui then PlayerData[player].ClothingGui:Destroy() end
            if PlayerData[player].InventoryGui then PlayerData[player].InventoryGui:Destroy() end
            for _, conn in pairs(PlayerData[player].Connections) do
                conn:Disconnect()
            end
            PlayerData[player] = nil
        end
        clearPlayerIcons(player)
        PlayerData[player] = nil
end)
task.spawn(function()
    while wait(0.1) do 
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer then 
                updateIconsDisplay(player, "Inventory", INVENTORY_OFFSET)
                updateIconsDisplay(player, "Clothing", CLOTHING_OFFSET)
            end
        end
    end
end)
end

return initAimbot
