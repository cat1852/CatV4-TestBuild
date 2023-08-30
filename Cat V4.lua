local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "Cat V4 Test-Build", HidePremium = false, IntroText = "Cat Hub", SaveConfig = true, ConfigFolder = "OrionTest"})

-- Home

local HomeTab = Window:MakeTab({
	Name = "Home",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

HomeTab:AddParagraph("Welcome to Cat V4!","henlo")

local Section = HomeTab:AddSection({
	Name = "Update Logs"
})

HomeTab:AddParagraph("Adds","Added Super Hard Mode Tab, New fullbright, Delete Dupe Doors, Disable Snare Damage, More Entitys for entity spawner, Auras (Misc), Trolling Tab, Door Reach.")
HomeTab:AddParagraph("Removes","nothing")
HomeTab:AddParagraph("Changes","Noclip is now a toggle, Renamed No Seek Arms to No Seek Arms + Fire (It finally removes the fire :D), Renamed Complete Breaker Box Minigame to Auto Complete Breaker Box Minigame.")
HomeTab:AddParagraph("Fixes","Fixed Entity Notifier (idk why it was notifying 2 times, becomes unaccurate when you die), Fixed Complete Breaker Box Minigame not working.")

-- ESP

function esp(what,color,core,name)
    local parts
    
    if typeof(what) == "Instance" then
        if what:IsA("Model") then
            parts = what:GetChildren()
        elseif what:IsA("BasePart") then
            parts = {what,table.unpack(what:GetChildren())}
        end
    elseif typeof(what) == "table" then
        parts = what
    end
    
    local bill
    local boxes = {}
    
    for i,v in pairs(parts) do
        if v:IsA("BasePart") then
            local box = Instance.new("BoxHandleAdornment")
            box.Size = v.Size
            box.AlwaysOnTop = true
            box.ZIndex = 1
            box.AdornCullingMode = Enum.AdornCullingMode.Never
            box.Color3 = color
            box.Transparency = 0.7
            box.Adornee = v
            box.Parent = game.CoreGui
            
            table.insert(boxes,box)
            
            task.spawn(function()
                while box do
                    if box.Adornee == nil or not box.Adornee:IsDescendantOf(workspace) then
                        box.Adornee = nil
                        box.Visible = false
                        box:Destroy()
                    end  
                    task.wait()
                end
            end)
        end
    end
    
    if core and name then
        bill = Instance.new("BillboardGui",game.CoreGui)
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0,400,0,100)
        bill.Adornee = core
        bill.MaxDistance = 2000
        
        local mid = Instance.new("Frame",bill)
        mid.AnchorPoint = Vector2.new(0.5,0.5)
        mid.BackgroundColor3 = color
        mid.Size = UDim2.new(0,8,0,8)
        mid.Position = UDim2.new(0.5,0,0.5,0)
        Instance.new("UICorner",mid).CornerRadius = UDim.new(1,0)
        Instance.new("UIStroke",mid)
        
        local txt = Instance.new("TextLabel",bill)
        txt.AnchorPoint = Vector2.new(0.5,0.5)
        txt.BackgroundTransparency = 1
        txt.BackgroundColor3 = color
        txt.TextColor3 = color
        txt.Size = UDim2.new(1,0,0,20)
        txt.Position = UDim2.new(0.5,0,0.7,0)
        txt.Text = name
        Instance.new("UIStroke",txt)
        
        task.spawn(function()
            while bill do
                if bill.Adornee == nil or not bill.Adornee:IsDescendantOf(workspace) then
                    bill.Enabled = false
                    bill.Adornee = nil
                    bill:Destroy() 
                end  
                task.wait()
            end
        end)
    end
    
    local ret = {}
    
    ret.delete = function()
        for i,v in pairs(boxes) do
            v.Adornee = nil
            v.Visible = false
            v:Destroy()
        end
        
        if bill then
            bill.Enabled = false
            bill.Adornee = nil
            bill:Destroy() 
        end
    end
    
    return ret 
end

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
local LatestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom
local Players = game:GetService("Players")
local inRooms = false
local entitynames = {"RushMoving","AmbushMoving","Snare","A60","A120","JeffTheKiller","Eyes"}

local entityinfo = nil
task.spawn(function()
	if game.ReplicatedStorage:FindFirstChild("EntityInfo") then 
		entityinfo = game.ReplicatedStorage:FindFirstChild("EntityInfo") 
	else
		entityinfo = game.ReplicatedStorage:WaitForChild("EntityInfo")
	end	
end)

local avoidingYvalue = 23
local flags = {
	-- general
	light = false,
	fullbright = false,
	instapp = false,
	noseek = false,
	nogates = false,
	nopuzzle = false,
	noa90 = false,
	noskeledoors = false,
	noscreech = false,
	notimothy = false,
	getcode = false,
	roomsnolock = false,
	heartbeatwin = false,
	noseekarmsfire = false,
	avoidrushambush = false,
	autoplayagain = false,
	anticheatbypass = false,
	noclip = false,
	camfov = 70,
	speed = 0,
	walkspeedtoggle = false,
	camfovtoggle = false,
	customnotifid = "10469938989",
	oldcustomnotifid = "4590657391",
	noeyesdamage = false,

	-- esp
	espdoors = false,
	espkeys = false,
	espitems = false,
	espbooks = false,
	esprush = false,
	espchest = false,
	esplocker = false,
	esphumans = false,
	espgold = false,
	goldespvalue = 0,
	fakeespdoors = false,
	tracers = false,

	-- notifiers
	hintrush = false,
	predictentities = false,

	-- auras
	draweraura = false,
	itemsaura = false,
	keyaura = false,
	breakercollecter = false,
	bookcollecter = false,
	autopulllever = false,

	-- auto a-1000
	autorooms = false,
	autorooms_debug = false,
	autorooms_blockcontrols = false,
}

local DELFLAGS = {table.unpack(flags)}
local esptable = {doors={},keys={},items={},books={},entity={},chests={},lockers={},people={},gold={}}

local VisualsTab = Window:MakeTab({
	Name = "ESP",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = VisualsTab:AddSection({
	Name = "Normal"
})

VisualsTab:AddToggle({
	Name = "Fullbright",
	Default = false,
	Callback = function(Value)
		flags.fullbright = Value

		if Value then
			local oldAmbient = game:GetService("Lighting").Ambient
			local oldColorShift_Bottom = game:GetService("Lighting").ColorShift_Bottom
			local oldColorShift_Top = game:GetService("Lighting").ColorShift_Top

			local function doFullbright()
				if flags.fullbright == true then
					game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
					game:GetService("Lighting").ColorShift_Bottom = Color3.new(1, 1, 1)
					game:GetService("Lighting").ColorShift_Top = Color3.new(1, 1, 1)
				else
					game:GetService("Lighting").Ambient = oldAmbient
					game:GetService("Lighting").ColorShift_Bottom = oldColorShift_Bottom
					game:GetService("Lighting").ColorShift_Top = oldColorShift_Top
				end
			end
			doFullbright()

			local coneee = game:GetService("Lighting").LightingChanged:Connect(doFullbright)
			repeat task.wait() until BOBHUBLOADED == false or not flags.fullbright

			coneee:Disconnect()
			game:GetService("Lighting").Ambient = oldAmbient
			game:GetService("Lighting").ColorShift_Bottom = oldColorShift_Bottom
			game:GetService("Lighting").ColorShift_Top = oldColorShift_Top
		end
	end
})

VisualsTab:AddButton({
    Name = "Get All Achievements",
    Callback = function ()
        local Data = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
        for i,v in pairs(require(game.ReplicatedStorage.Achievements)) do
            spawn(function()
                require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.AchievementUnlock)(nil, i)
            end)
        end
    end
})

local toggleValue = false

local function enableEspKeys()
    flags.espkeys = toggleValue

    if toggleValue then
        local function check(v)
            if v:IsA("Model") and (v.Name == "LeverForGate" or v.Name == "KeyObtain") then
                task.wait(0.1)
                if v.Name == "KeyObtain" then
                    local hitbox = v:WaitForChild("Hitbox")
                    local parts = hitbox:GetChildren()
                    table.remove(parts,table.find(parts,hitbox:WaitForChild("PromptHitbox")))

                    local h = esp(parts,Color3.fromRGB(90,255,40),hitbox,"Key")
                    table.insert(esptable.keys,h)

                elseif v.Name == "LeverForGate" then
                    local h = esp(v,Color3.fromRGB(90,255,40),v.PrimaryPart,"Lever")
                    table.insert(esptable.keys,h)

                    v.PrimaryPart:WaitForChild("SoundToPlay").Played:Connect(function()
                        h.delete()
                    end) 
                end
            end
        end

        local function setup(room)
            local assets = room:WaitForChild("Assets")

            assets.DescendantAdded:Connect(function(v)
                check(v) 
            end)

            for i,v in pairs(assets:GetDescendants()) do
                check(v)
            end 
        end

        local addconnect
        addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
            setup(room)
        end)

        for i,room in pairs(workspace.CurrentRooms:GetChildren()) do
            if room:FindFirstChild("Assets") then
                setup(room) 
            end
        end

        repeat task.wait() until not flags.espkeys
        addconnect:Disconnect()

        for i,v in pairs(esptable.keys) do
            v.delete()
        end 
    end
end

VisualsTab:AddToggle({
    Name = "Key/Lever ESP",
    Default = toggleValue,
    Callback = function(Value)
        toggleValue = Value
        enableEspKeys()
    end    
})

VisualsTab:AddToggle({
    Name = "Book/Breaker ESP",
    Default = false,
    Callback = function(val)
        flags.espbooks = val

        if val then
            local function check(v)
                if v:IsA("Model") and (v.Name == "LiveHintBook" or v.Name == "LiveBreakerPolePickup") then
                    task.wait(0.1)

                    local h = esp(v,Color3.fromRGB(160,190,255),v.PrimaryPart,"Book")
                    table.insert(esptable.books,h)

                    v.AncestryChanged:Connect(function()
                        if not v:IsDescendantOf(room) then
                            h.delete() 
                        end
                    end)
                end
            end
        
            local function setup(room)
                if room.Name == "50" or room.Name == "100" then
                    room.DescendantAdded:Connect(function(v)
                        check(v) 
                    end)

                    for i,v in pairs(room:GetDescendants()) do
                        check(v)
                    end
                end
            end

            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)

            for i,room in pairs(workspace.CurrentRooms:GetChildren()) do
                setup(room) 
            end

            repeat task.wait() until not flags.espbooks
            addconnect:Disconnect()

            for i,v in pairs(esptable.books) do
                v.delete()
            end 
        end
    end
})

local toggleValue = false

local function toggleCallback(newValue)
    toggleValue = newValue

    if toggleValue then
        flags.espitems = true
        
        local function check(v)
            if v:IsA("Model") and (v:GetAttribute("Pickup") or v:GetAttribute("PropType")) then
                task.wait(0.1)
                
                local part = (v:FindFirstChild("Handle") or v:FindFirstChild("Prop"))
                local h = esp(part, Color3.fromRGB(160, 190, 255), part, v.Name)
                table.insert(esptable.items, h)
            end
        end
        
        local function setup(room)
            local assets = room:WaitForChild("Assets")
            
            if assets then  
                local subaddcon
                subaddcon = assets.DescendantAdded:Connect(function(v)
                    check(v) 
                end)
                
                for i, v in pairs(assets:GetDescendants()) do
                    check(v)
                end
                
                task.spawn(function()
                    repeat
                        task.wait()
                    until not flags.espitems
                    subaddcon:Disconnect()  
                end) 
            end 
        end
        
        local addconnect
        addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
            setup(room)
        end)
        
        for i, room in pairs(workspace.CurrentRooms:GetChildren()) do
            if room:FindFirstChild("Assets") then
                setup(room) 
            end
        end
        
        repeat
            task.wait()
        until not flags.espitems
        addconnect:Disconnect()
        
        for i, v in pairs(esptable.items) do
            v.delete()
        end 
    else
        flags.espitems = false
    end
end

VisualsTab:AddToggle({
    Name = "Item ESP",
    Default = false,
    Callback = toggleCallback
})

local function setup(room)
    local door = room:WaitForChild("Door"):WaitForChild("Door")
    
    task.wait(0.1)
    local h = esp(door,Color3.fromRGB(255,240,0),door,"Door")
    table.insert(esptable.doors,h)
    
    door:WaitForChild("Open").Played:Connect(function()
        h.delete()
    end)
    
    door.AncestryChanged:Connect(function()
        h.delete()
    end)
end

local addconnect
local function listenToggle()
    if flags.espdoors then
        addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
            setup(room)
        end)
        
        for i,room in pairs(workspace.CurrentRooms:GetChildren()) do
            if room:FindFirstChild("Assets") then
                setup(room) 
            end
        end
        
        repeat task.wait() until not flags.espdoors
        addconnect:Disconnect()
        
        for i,v in pairs(esptable.doors) do
            v.delete()
        end 
    end
end

VisualsTab:AddToggle({
    Name = "Doors ESP",
    Default = false,
    Callback = function(Value)
        flags.espdoors = Value
        listenToggle()
    end    
})



local MoveTab = Window:MakeTab({
	Name = "Movement",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

MoveTab:AddButton({
    Name = "Speed Bypass",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/finngameandglitch/bypass/main/bypass'))()
              print("Executed!")
      end
})

local TargetWalkspeed
MoveTab:AddSlider({
	Name = "Walkspeed (Use with Speed Bypass or AC Bypass!)",
	Min = 0,
	Max = 50,
	Default = 0,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	Callback = function(Value)
		TargetWalkspeed = Value
	end    
})

game:GetService("RunService").RenderStepped:Connect(function()
    pcall(function()
        if game.Players.LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
            game.Players.LocalPlayer.Character:TranslateBy(game.Players.LocalPlayer.Character.Humanoid.MoveDirection * TargetWalkspeed/50)
        end
    end)
end)

MoveTab:AddParagraph("Tip","You can spam teleport to noclip!")
MoveTab:AddParagraph("Tip number 2","You can use teleport up to avoid entities and still can progress! (but be careful) and teleport down when they are despawned!")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character

local Tab = {}
Tab.Binds = {}

function Tab:AddBind(bindData)
	local bind = {
		Name = bindData.Name,
		KeyCode = bindData.Default,
		Hold = bindData.Hold,
		Callback = bindData.Callback,
		IsPressed = false,
	}

	table.insert(self.Binds, bind)
end

function Tab:CheckBinds()
	for _, bind in ipairs(self.Binds) do
		if bind.Hold then
			if bind.IsPressed then
				bind.Callback()
			end
		else
			if not bind.IsPressed then
				bind.Callback()
				bind.IsPressed = true
			end
		end
	end
end

game:GetService("UserInputService").InputBegan:Connect(function(input)
	for _, bind in ipairs(Tab.Binds) do
		if input.KeyCode == bind.KeyCode then
			bind.IsPressed = true
		end
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	for _, bind in ipairs(Tab.Binds) do
		if input.KeyCode == bind.KeyCode then
			bind.IsPressed = false
		end
	end
end)

if character and character.Parent then
	local currentPivot = character:GetPivot()
	character:PivotTo(currentPivot * CFrame.new(0, 0, -10))
end

MoveTab:AddBind({
	Name = "Teleport Forward",
	Default = Enum.KeyCode.G,
	Hold = false,
	Callback = function()
		if character and character.Parent then
			local currentPivot = character:GetPivot()
			character:PivotTo(currentPivot * CFrame.new(0, 0, -10))
		end
	end    
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character

local Tab = {}
Tab.Binds = {}

function Tab:AddBind(bindData)
	local bind = {
		Name = bindData.Name,
		KeyCode = bindData.Default,
		Hold = bindData.Hold,
		Callback = bindData.Callback,
		IsPressed = false,
	}

	table.insert(self.Binds, bind)
end

function Tab:CheckBinds()
	for _, bind in ipairs(self.Binds) do
		if bind.Hold then
			if bind.IsPressed then
				bind.Callback()
			end
		else
			if not bind.IsPressed then
				bind.Callback()
				bind.IsPressed = true
			end
		end
	end
end

game:GetService("UserInputService").InputBegan:Connect(function(input)
	for _, bind in ipairs(Tab.Binds) do
		if input.KeyCode == bind.KeyCode then
			bind.IsPressed = true
		end
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	for _, bind in ipairs(Tab.Binds) do
		if input.KeyCode == bind.KeyCode then
			bind.IsPressed = false
		end
	end
end)

if character and character.Parent then
	local currentPivot = character:GetPivot()
	character:PivotTo(currentPivot * CFrame.new(0, 0, -10))
end

MoveTab:AddBind({
	Name = "Teleport Up",
	Default = Enum.KeyCode.H,
	Hold = false,
	Callback = function()
		if character and character.Parent then
			local currentPivot = character:GetPivot()
			character:PivotTo(currentPivot * CFrame.new(0, 30, 0))
		end
	end    
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character

local Tab = {}
Tab.Binds = {}

function Tab:AddBind(bindData)
	local bind = {
		Name = bindData.Name,
		KeyCode = bindData.Default,
		Hold = bindData.Hold,
		Callback = bindData.Callback,
		IsPressed = false,
	}

	table.insert(self.Binds, bind)
end

function Tab:CheckBinds()
	for _, bind in ipairs(self.Binds) do
		if bind.Hold then
			if bind.IsPressed then
				bind.Callback()
			end
		else
			if not bind.IsPressed then
				bind.Callback()
				bind.IsPressed = true
			end
		end
	end
end

game:GetService("UserInputService").InputBegan:Connect(function(input)
	for _, bind in ipairs(Tab.Binds) do
		if input.KeyCode == bind.KeyCode then
			bind.IsPressed = true
		end
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	for _, bind in ipairs(Tab.Binds) do
		if input.KeyCode == bind.KeyCode then
			bind.IsPressed = false
		end
	end
end)

if character and character.Parent then
	local currentPivot = character:GetPivot()
	character:PivotTo(currentPivot * CFrame.new(0, 0, -10))
end

MoveTab:AddBind({
	Name = "Teleport Down",
	Default = Enum.KeyCode.J,
	Hold = false,
	Callback = function()
		if character and character.Parent then
			local currentPivot = character:GetPivot()
			character:PivotTo(currentPivot * CFrame.new(0, -30, 0))
		end
	end    
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character

local Tab = {}
Tab.Binds = {}

function Tab:AddBind(bindData)
	local bind = {
		Name = bindData.Name,
		KeyCode = bindData.Default,
		Hold = bindData.Hold,
		Callback = bindData.Callback,
		IsPressed = false,
	}

	table.insert(self.Binds, bind)
end

function Tab:CheckBinds()
	for _, bind in ipairs(self.Binds) do
		if bind.Hold then
			if bind.IsPressed then
				bind.Callback()
			end
		else
			if not bind.IsPressed then
				bind.Callback()
				bind.IsPressed = true
			end
		end
	end
end

game:GetService("UserInputService").InputBegan:Connect(function(input)
	for _, bind in ipairs(Tab.Binds) do
		if input.KeyCode == bind.KeyCode then
			bind.IsPressed = true
		end
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	for _, bind in ipairs(Tab.Binds) do
		if input.KeyCode == bind.KeyCode then
			bind.IsPressed = false
		end
	end
end)

if character and character.Parent then
	local currentPivot = character:GetPivot()
	character:PivotTo(currentPivot * CFrame.new(0, 0, -10))
end

MoveTab:AddBind({
	Name = "Teleport Behind",
	Default = Enum.KeyCode.K,
	Hold = false,
	Callback = function()
		if character and character.Parent then
			local currentPivot = character:GetPivot()
			character:PivotTo(currentPivot * CFrame.new(0, 0, 10))
		end
	end    
})

MoveTab:AddButton({
    Name = "Enable Jump",
    Callback = function()
        -- Place this script in a LocalScript within the character or player's starter characters

-- Get the player's character
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Check if the character has a Humanoid
local humanoid = character:WaitForChild("Humanoid")

-- Enable jumping if it is disabled
if not humanoid.Jump then
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
end
              print("dot")
      end
})

-- Game Itself

local GameTab = Window:MakeTab({
	Name = "Game",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

GameTab:AddButton({
    Name = "Anti-Cheat Bypass",
    Callback = function()
        game:GetService("Players").LocalPlayer.PlayerGui.MainUI.ItemShop:Destroy() require(game:GetService("Players").LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).freemouse = false game:GetService("ReplicatedStorage").ClientModules.EntityModules.Void:Destroy()
              print("Executed!")
      end
})

GameTab:AddToggle({
	Name = "No Screech",
	Default = false,
    Flag = "ScreechToggle",
    Save = true
})

GameTab:AddToggle({
    Name = "No Seek Arms + Fire",
    Default = false,
    Callback = function(val)
        flags.noseekarmsfire = val
    end
})
 
GameTab:AddToggle({
	Name = "Instant Interact",
	Default = false,
    Flag = "InstantToggle",
    Save = true
})

GameTab:AddToggle({
	Name = "Always win heartbeat minigame",
	Default = false,
    Flag = "HeartbeatWin",
    Save = true
})

local autoBox = false

GameTab:AddToggle({
    Name = "Auto Complete Breaker Box Minigame",
    Default = false,
    Callback = function(val)
        autoBox = val
        while task.wait(1) do
            if not autoBox then
                break
            end
            game:GetService("ReplicatedStorage").EntityInfo.EBF:FireServer()
        end
    end
})

game:GetService("ReplicatedStorage").GameData.LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
    task.wait(.1)
    for _, descendant in pairs(game:GetService("Workspace").CurrentRooms:GetDescendants()) do
        if descendant.Name == "Seek_Arm" or descendant.Name == "ChandelierObstruction" then
            descendant.Parent = nil
            descendant:Destroy()
        end
    end
end)
 
game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    if OrionLib.Flags["InstantToggle"].Value == true then
        fireproximityprompt(prompt)
    end
end)

workspace.CurrentCamera.ChildAdded:Connect(function(child)
    if child.Name == "Screech" and OrionLib.Flags["ScreechToggle"].Value == true then
        child:Destroy()
    end
end)

if tostring(self) == 'ClutchHeartbeat' and method == "FireServer" and OrionLib.Flags["HeartbeatWin"].Value == true then
    args[2] = true
    return old(self,unpack(args))
end

GameTab:AddToggle({
	Name = "Entity Notifier",
	Default = false,
	Callback = function(Value)
		flags.hintrush = Value

		local eyesspawned = false
		workspace.ChildAdded:Connect(function(inst)
			task.spawn(function()
				if table.find(entitynames, inst.Name) and flags.hintrush == true then
					if inRooms == true then
						if inst.Name:gsub("Moving","") == "A60" then
							OrionLib:MakeNotification({
								Name = "Entity Notifier",
								Content = inst.Name:gsub("Moving","").." has spawned!",
								Image = "12350986086",
								Time = 5,
								Entity = inst
							})
						elseif inst.Name:gsub("Moving","") == "A120" then
							OrionLib:MakeNotification({
								Name = "Entity Notifier",
								Content = inst.Name:gsub("Moving","").." has spawned!",
								Image = "12351008553",
								Time = 5,
								Entity = inst
							})
						else
							task.wait(.1)
							if plr:DistanceFromCharacter(inst:GetPivot().Position) < 400 and inst:IsDescendantOf(workspace) then
								--OrionLib:MakeNotification({
								--	Name = "Entity Notifier",
								--	Content = inst.Name:gsub("Moving","").." has spawned!",
								--	Image = "0",
								--	Time = 5,
								--	Entity = inst
								--})
							end
						end
					else
						if flags.avoidrushambush == false then
							repeat task.wait() until plr:DistanceFromCharacter(inst:GetPivot().Position) < 1000 or not inst:IsDescendantOf(workspace)
	
							if inst:IsDescendantOf(workspace) then
								if inst.Name:gsub("Moving","") == "Rush" then
									OrionLib:MakeNotification({
										Name = "Entity Notifier",
										Content = inst.Name:gsub("Moving","").." has spawned!",
										Image = "11102256553",
										Time = 5,
										Entity = inst
									})
								elseif inst.Name:gsub("Moving","") == "Ambush" then
									OrionLib:MakeNotification({
										Name = "Entity Notifier",
										Content = inst.Name:gsub("Moving","").." has spawned!",
										Image = "10938726652",
										Time = 5,
										Entity = inst
									})
								elseif inst.Name:gsub("Moving","") == "Eyes" then
									task.spawn(function()
										if flags.noeyesdamage == true then
											eyesspawned = true
											local con = game:GetService("RunService").RenderStepped:Connect(function()
												eyesspawned = true
												local legrot = 0
												local bodypitch = -75 -- legit -65
												local bodyrot = 0
												game:GetService("ReplicatedStorage").EntityInfo.MotorReplication:FireServer(legrot, bodypitch, bodyrot, false)
											end)
											inst.Destroying:Wait()
											con:Disconnect()
											eyesspawned = false
										end
									end)
									OrionLib:MakeNotification({
										Name = "Entity Notifier",
										Content = inst.Name:gsub("Moving","").." has spawned!",
										Image = "10865377903",
										Time = 10
									})
								else
									OrionLib:MakeNotification({
										Name = "Entity Notifier",
										Content = inst.Name:gsub("Moving","").." has spawned!",
										Image = "0",
										Time = 5,
										Entity = inst
									})
								end
								inst.Destroying:Wait()
								--OrionLib:MakeNotification({
								--	Name = "Entity Notifier",
								--	Content = "It's now completely safe to leave the hiding spot.",
								--	Time = 7
								--})
							end
						end
					end
				end
			end)
		
			--[[if flags.avoidrushambush == true then
				if inst.Name == "RushMoving" or inst.Name == "AmbushMoving" then
					repeat task.wait() until plr:DistanceFromCharacter(inst:GetPivot().Position) < 400 or not inst:IsDescendantOf(workspace)
	
					if inst:IsDescendantOf(workspace) then
						if inst.Name:gsub("Moving","") == "Rush" then
							OrionLib:MakeNotification({
								Name = "ENTITIES",
								Content = "Avoiding "..inst.Name:gsub("Moving","").." Please wait...",
								Image = "11102256553",
								Time = 0,
								Entity = inst
							})
						elseif inst.Name:gsub("Moving","") == "Ambush" then
							OrionLib:MakeNotification({
								Name = "ENTITIES",
								Content = "Avoiding "..inst.Name:gsub("Moving","").." Please wait...",
								Image = "10938726652",
								Time = 0,
								Entity = inst
							})
						else
							OrionLib:MakeNotification({
								Name = "ENTITIES",
								Content = "Avoiding "..inst.Name:gsub("Moving","").." Please wait...",
								Image = "0",
								Time = 0,
								Entity = inst
							})
						end
	
						local OldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
						local oldwalkspeed = hum.WalkSpeed
						
						local pos = CFrame.new(
							OldPos + Vector3.new(
								0,
								avoidingYvalue,
								0
							) 
						)
						
						local function getrecentroom(index)
							local rooms = workspace.CurrentRooms:GetChildren() 
							table.sort(rooms,function(a,b)
								return tonumber(a.Name) > tonumber(b.Name) 
							end)
	
							return rooms[index]
						end
						local room = getrecentroom(2)
						local door = room:WaitForChild("Door")
	
						local CFrameValue = Instance.new("CFrameValue")
						CFrameValue.Value = game.Players.LocalPlayer.Character:GetPivot()
						CFrameValue:GetPropertyChangedSignal("Value"):connect(function()
							--game.Players.LocalPlayer.Character:PivotTo(CFrameValue.Value)
							game.Players.LocalPlayer.Character.Collision.CFrame = CFrameValue.Value
						end)
						local tween = game:GetService("TweenService"):Create(CFrameValue, TweenInfo.new(1.5), {
							Value = pos
						})
						tween:Play()
	
						local con
						tween.Completed:connect(function()
							CFrameValue:Destroy() 
							con = game:GetService("RunService").RenderStepped:Connect(function()
								--game.Players.LocalPlayer.Character:PivotTo(pos)
								game.Players.LocalPlayer.Character.Collision.CFrame = pos
							end)
						end)
	
						inst.Destroying:Wait()
						con:Disconnect()
	
						local CFrameValue = Instance.new("CFrameValue")
						CFrameValue.Value = game.Players.LocalPlayer.Character:GetPivot()
						CFrameValue:GetPropertyChangedSignal("Value"):connect(function()
							game.Players.LocalPlayer.Character:PivotTo(CFrameValue.Value)
						end)
						local tween = game:GetService("TweenService"):Create(CFrameValue, TweenInfo.new(1.5), {Value = CFrame.new(OldPos)})
						tween:Play()
						tween.Completed:connect(function()
							CFrameValue:Destroy() 
							--game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
						end)
					end
				end
			end--]]
		end)
	end    
})

-- Player

local PlayerTab = Window:MakeTab({
	Name = "Player",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        flags.noclip = Value

        if Value then
            local Nocliprun =  nil
            Nocliprun = game:GetService("RunService").Stepped:Connect(function()
                if game.Players.LocalPlayer.Character ~= nil then
                    for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            pcall(function()
                                v.CanCollide = false
                            end)
                        end
                    end
                end
                if flags.noclip == false then
                    if Nocliprun then Nocliprun:Disconnect() end
                end
            end)
        end
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    pcall(function()
        if _G.SlowDownnnonononoo then
            local one = false

            game.Players.LocalPlayer.Character.Head.Massless = 1
            game.Players.LocalPlayer.Character.LeftFoot.Massless = 1
            game.Players.LocalPlayer.Character.LeftHand.Massless = 1
            game.Players.LocalPlayer.Character.LeftLowerArm.Massless = 1
            game.Players.LocalPlayer.Character.LeftLowerLeg.Massless = 1
            game.Players.LocalPlayer.Character.LeftUpperArm.Massless = 1
            game.Players.LocalPlayer.Character.LeftUpperLeg.Massless = 1
            game.Players.LocalPlayer.Character.LowerTorso.Massless = 1
            game.Players.LocalPlayer.Character.RightFoot.Massless = 1 
            game.Players.LocalPlayer.Character.RightHand.Massless = 1
            game.Players.LocalPlayer.Character.RightLowerArm.Massless = 1
            game.Players.LocalPlayer.Character.RightLowerLeg.Massless = 1
            game.Players.LocalPlayer.Character.RightUpperArm.Massless = 1
            game.Players.LocalPlayer.Character.RightUpperLeg.Massless = 1
            game.Players.LocalPlayer.Character.UpperTorso.Massless = 1
        end
    end)
end)

PlayerTab:AddButton({
    Name = "God Mode",
    Callback = function()
        local Collison = game.Players.LocalPlayer.Character:FindFirstChild("Collision")
Collison.Position = Collison.Position - Vector3.new(0,10,0)
              print("Executed!")
      end
})

PlayerTab:AddButton({
	Name = "Door Reach",
	Callback = function()
        while task.wait(0.5) do for i,v in pairs(game.Workspace.CurrentRooms:GetDescendants()) do if v.Name == "ClientOpen" then v:FireServer() end end end
      		print("Enabled")
  	end    
})

-- Others

local OtherTab = Window:MakeTab({
	Name = "Others",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

OtherTab:AddButton({
    Name = "Play Again (Wait 3 Seconds!)",
    Callback = function()
        game:GetService("ReplicatedStorage").EntityInfo.PlayAgain:FireServer()
              print("Executed!")
      end
})

OtherTab:AddButton({
    Name = "Go back to the Lobby",
    Callback = function()
        game:GetService("ReplicatedStorage").EntityInfo.Lobby:FireServer()
              print("Executed!")
      end
})

OtherTab:AddButton({
    Name = "Reset",
    Callback = function()
        local player = game.Players.LocalPlayer
local A = player.Character:WaitForChild("Humanoid")
A.Health = 0
              print("Executed!")
      end
})

OtherTab:AddButton({
    Name = "Death Farmer GUI",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/K0t1n/Public/main/Doors%20Death%20Farmer.lua"))()
              print("Executed!")
      end
})

-- Misc

local MiscTab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local toggleValue = false -- initial value

MiscTab:AddToggle({
    Name = "Disable Seek Chase",
    Default = toggleValue,
    Callback = function(Value)
        toggleValue = Value -- update toggleValue with the new value
        print(toggleValue)
        
        -- Update the code here based on the toggle value
        
        if toggleValue then
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                local trigger = room:WaitForChild("TriggerEventCollision", 2)
            
                if trigger then
                    trigger:Destroy() 
                end
            end)
            
            repeat task.wait() until not toggleValue
            addconnect:Disconnect()
        end
    end
})

MiscTab:AddToggle({
    Name = "Disable Snare Damage",
    Default = false,
    Callback = function(Value)
        _G.Snare_Hitbox = Value

        while wait() and _G.Snare_Hitbox == true do
            for i, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "Snare" then
                    local Hitbox = v:FindFirstChild("Hitbox")
                    Hitbox.CanTouch = false
                end
            end
        end
    end
})

local addconnect
local toggleValue = false

local toggleCallback = function(val)
    toggleValue = val
    
    if toggleValue then
        addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
            local gate = room:WaitForChild("Gate", 2)
            
            if gate then
                local door = gate:WaitForChild("ThingToOpen", 2)
                
                if door then
                    door:Destroy() 
                end
            end
        end)
    else
        if addconnect then
            addconnect:Disconnect()
        end
    end
end

MiscTab:AddToggle({
    Name = "Delete Lever Gate",
    Default = false,
    Callback = toggleCallback
})

MiscTab:AddToggle({
    Name = "Delete Skeleton Doors",
    Default = false,
    Callback = function(Value)
        flags.noskeledoors = Value
        
        if Value then
            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                local door = room:WaitForChild("Wax_Door",2)
                
                if door then
                    door:Destroy() 
                end
            end)
            
            repeat task.wait() until not flags.noskeledoors
            addconnect:Disconnect()
        end
    end    
})

MiscTab:AddToggle({
	Name = "Delete Puzzle Door",
	Default = false,
	Callback = function(Value)
		flags.nopuzzle = Value
		
		if Value then
			addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
				local assets = room:FindFirstChild("Assets")
				if assets then
					local paintings = assets:FindFirstChild("Paintings")
					
					if paintings then
						local door = paintings:FindFirstChild("MovingDoor")
						
						if door then
							door:Destroy() 
						end 
					end
				end
			end)
		elseif addconnect then
			addconnect:Disconnect()
		end
	end    
})

MiscTab:AddToggle({
    Name = "Delete Dupe Doors",
    Default = false,
    Callback = function(Value)
        _G.NoDupe = Value
    end    
})

game:GetService("RunService").RenderStepped:Connect(function()
    pcall(function()
        if _G.NoDupe then
            workspace.CurrentRooms(game.ReplicatedStorage.GameData.LatestRoom.Value).Closet.DoorFake:Destroy()
        end
    end)
end)

MiscTab:AddToggle({
    Name = "Delete Halt",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("ReplicatedStorage").ClientModules.EntityModules.Shade:remove()
        end
    end
})

MiscTab:AddButton({
    Name = "Delete Door 51",
    Callback = function()
        game:GetService("Workspace").CurrentRooms:FindFirstChild("50").Door.Door:remove()
              print("Executed!")
      end
})

MiscTab:AddToggle({
    Name = "A-000 No Locks",
    Default = false,
    Callback = function(Value)
        flags.roomsnolock = Value

        if Value then
            local function check(room)
                local door = room:WaitForChild("RoomsDoor_Entrance", 2)

                if door then
                    local prompt = door:WaitForChild("Door"):WaitForChild("EnterPrompt")
                    prompt.Enabled = true
                end
            end

            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                check(room)
            end)

            for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
                check(v)
            end

            repeat task.wait() until not flags.roomsnolock
            addconnect:Disconnect()
        end
    end  
})

MiscTab:AddParagraph("note -9","If you want to use auras, enable them first after launching the script because these aura can lag or even crash your game.")

MiscTab:AddToggle({
    Name = "Loot Aura",
    Default = false,
    Callback = function(Value)
        flags.draweraura = Value

        if Value then
            local function setup(room)
                local function check(v)
                    task.wait()
                    if v:IsA("Model") then
                        task.wait()
                        if v.Name == "DrawerContainer" or v.Name == "RolltopContainer" then
                            if v.Name == "RolltopContainer" then
                                local prompt = v:WaitForChild("ActivateEventPrompt")
                                local interactions = prompt:GetAttribute("Interactions")

                                if not interactions then
                                    task.spawn(function()
                                        repeat task.wait(0.1)
                                            local posok = false
                                            pcall(function()
                                                local posoks, posoke = pcall(function()
                                                    posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                                end)
                                                if posoke then
                                                    local part
                                                    for _,v in pairs(v:GetChildren()) do
                                                        local hasProperty = pcall(function() local t = v["Position"] end)
                                                        if hasProperty then
                                                            part = v
                                                            break
                                                        end
                                                    end
                                                    posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                                end
                                            end)
                                            if posok then
                                                fireproximityprompt(prompt)
                                            end
                                        until prompt:GetAttribute("Interactions") or not flags.draweraura
                                    end)
                                end
                            else
                                local knob = v:WaitForChild("Knobs")

                                if knob then
                                    local prompt = knob:WaitForChild("ActivateEventPrompt")
                                    local interactions = prompt:GetAttribute("Interactions")

                                    if not interactions then
                                        task.spawn(function()
                                            repeat task.wait(0.1)
                                                local posok = false
                                                pcall(function()
                                                    local posoks, posoke = pcall(function()
                                                        posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                                    end)
                                                    if posoke then
                                                        local part
                                                        for _,v in pairs(v:GetChildren()) do
                                                            local hasProperty = pcall(function() local t = v["Position"] end)
                                                            if hasProperty then
                                                                part = v
                                                                break
                                                            end
                                                        end
                                                        posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                                    end
                                                end)
                                                if posok then
                                                    fireproximityprompt(prompt)
                                                end
                                            until prompt:GetAttribute("Interactions") or not flags.draweraura
                                        end)
                                    end
                                end
                            end
                        elseif v.Name == "GoldPile" then
                            local prompt = v:WaitForChild("LootPrompt")
                            local interactions = prompt:GetAttribute("Interactions")

                            if not interactions then
                                task.spawn(function()
                                    repeat task.wait(0.1)
                                        local posok = false
                                        pcall(function()
                                            local posoks, posoke = pcall(function()
                                                posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                            end)
                                            if posoke then
                                                local part
                                                for _,v in pairs(v:GetChildren()) do
                                                    local hasProperty = pcall(function() local t = v["Position"] end)
                                                    if hasProperty then
                                                        part = v
                                                        break
                                                    end
                                                end
                                                posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                            end
                                        end)
                                        if posok then
                                            fireproximityprompt(prompt)
                                        end
                                    until prompt:GetAttribute("Interactions") or not flags.draweraura
                                end)
                            end
                        elseif v.Name:sub(1,8) == "ChestBox" then
                            local prompt = v:WaitForChild("ActivateEventPrompt")
                            local interactions = prompt:GetAttribute("Interactions")

                            if not interactions then
                                task.spawn(function()
                                    repeat task.wait(0.1)
                                        local posok = false
                                        pcall(function()
                                            local posoks, posoke = pcall(function()
                                                posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                            end)
                                            if posoke then
                                                local part
                                                for _,v in pairs(v:GetChildren()) do
                                                    local hasProperty = pcall(function() local t = v["Position"] end)
                                                    if hasProperty then
                                                        part = v
                                                        break
                                                    end
                                                end
                                                posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                            end
                                        end)
                                        if posok then
                                            fireproximityprompt(prompt)
                                        end
                                    until prompt:GetAttribute("Interactions") or not flags.draweraura
                                end)
                            end
                        elseif v.Name == "RolltopContainer" then
                            local prompt = v:WaitForChild("ActivateEventPrompt")
                            local interactions = prompt:GetAttribute("Interactions")

                            if not interactions then
                                task.spawn(function()
                                    repeat task.wait(0.1)
                                        local posok = false
                                        pcall(function()
                                            local posoks, posoke = pcall(function()
                                                posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                            end)
                                            if posoke then
                                                local part
                                                for _,v in pairs(v:GetChildren()) do
                                                    local hasProperty = pcall(function() local t = v["Position"] end)
                                                    if hasProperty then
                                                        part = v
                                                        break
                                                    end
                                                end
                                                posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                            end
                                        end)
                                        if posok then
                                            fireproximityprompt(prompt)
                                        end
                                    until prompt:GetAttribute("Interactions") or not flags.draweraura
                                end)
                            end
                        end
                    end
                end

                local subaddcon
                subaddcon = room.DescendantAdded:Connect(function(ve)
                    check(ve)
                end)

                for _,v in pairs(room:GetDescendants()) do
                    task.spawn(function()
                        check(v)
                    end)
                end

                task.spawn(function()
                    repeat task.wait() until BOBHUBLOADED == false or not flags.draweraura
                    subaddcon:Disconnect()
                end)
            end

            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)

            for i,room in pairs(workspace.CurrentRooms:GetChildren()) do
                if room:FindFirstChild("Assets") then
                    setup(room)
                end
            end
            setup(workspace.CurrentRooms[tostring(game:GetService("ReplicatedStorage").GameData.LatestRoom.Value)])

            repeat task.wait() until BOBHUBLOADED == false or not flags.draweraura
            addconnect:Disconnect()
        end
    end
})

MiscTab:AddToggle({
    Name = "Items Aura",
    Default = false,
    Callback = function(Value)
        flags.itemsaura = Value
        if Value then
            local function setup(room)
                local function check(v)
                    task.wait()
                    if v:IsA("Model") then
                        -- if v.PrimaryPart then
                        task.wait()
                        if v.Name == "PickupItem" then
                            if game:GetService("ReplicatedStorage").GameData.LatestRoom.Value == 51 or game:GetService("ReplicatedStorage").GameData.LatestRoom.Value == 52 then
                                return
                            end

                            local prompt = v:WaitForChild("ModulePrompt")
                            local okcanckl = 0
                            task.spawn(function()
                                repeat
                                    task.wait(0.1)
                                    local posok = false
                                    pcall(function()
                                        local posoks, posoke = pcall(function()
                                            posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                        end)
                                        if posoke then
                                            local part
                                            for _, v in pairs(v:GetChildren()) do
                                                local hasProperty = pcall(function()
                                                    local t = v["Position"]
                                                end)
                                                if hasProperty then
                                                    part = v
                                                    break
                                                end
                                            end
                                            posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                        end
                                    end)
                                    if posok then
                                        fireproximityprompt(prompt)
                                        okcanckl += 1
                                    end
                                until not v:IsDescendantOf(workspace) or not prompt:IsDescendantOf(workspace) or not flags.itemsaura or okcanckl > 20
                            end)
                        elseif v:GetAttribute("Pickup") or v:GetAttribute("PropType") then
                            if game:GetService("ReplicatedStorage").GameData.LatestRoom.Value == 51 or game:GetService("ReplicatedStorage").GameData.LatestRoom.Value == 52 then
                                return
                            end

                            local prompt = v:WaitForChild("ModulePrompt", 2)
                            if prompt == nil then
                                prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                                if prompt == nil then
                                    for _, vvvvv in pairs(v:GetDescendants()) do
                                        if vvvvv:IsA("ProximityPrompt") then
                                            prompt = vvvvv
                                            break
                                        end
                                    end
                                end
                            end

                            task.spawn(function()
                                repeat
                                    task.wait(0.1)
                                    local posok = false
                                    pcall(function()
                                        local posoks, posoke = pcall(function()
                                            posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                        end)
                                        if posoke then
                                            local part
                                            for _, v in pairs(v:GetChildren()) do
                                                local hasProperty = pcall(function()
                                                    local t = v["Position"]
                                                end)
                                                if hasProperty then
                                                    part = v
                                                    break
                                                end
                                            end
                                            posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                        end
                                    end)
                                    if posok then
                                        fireproximityprompt(prompt)
                                    end
                                until not v:IsDescendantOf(workspace) or not prompt:IsDescendantOf(workspace) or not flags.itemsaura
                            end)
                        elseif v.Name == "Green_Herb" then
                            local plant = v:WaitForChild("Plant")

                            if plant then
                                local prompt = plant:WaitForChild("HerbPrompt")
                                local okcanckl = 0
                                task.spawn(function()
                                    repeat
                                        task.wait(0.1)
                                        local posok = false
                                        pcall(function()
                                            local posoks, posoke = pcall(function()
                                                posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                            end)
                                            if posoke then
                                                local part
                                                for _, vv in pairs(v:GetChildren()) do
                                                    local hasProperty = pcall(function()
                                                        local t = vv["Position"]
                                                    end)
                                                    if hasProperty then
                                                        part = vv
                                                        break
                                                    end
                                                end
                                                posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                            end
                                        end)
                                        if posok then
                                            fireproximityprompt(prompt)
                                            okcanckl += 1
                                        end
                                    until prompt:GetAttribute("Interactions") or not flags.draweraura or okcanckl > 35
                                end)
                            end
                        elseif v.Name == "KeyObtain" or v.Name == "ElectricalKeyObtain" then
                            local prompt = v:WaitForChild("ModulePrompt")
                            local interactions = prompt:GetAttribute("Interactions")

                            if not interactions then
                                task.spawn(function()
                                    repeat
                                        task.wait(0.1)
                                        local posok = false
                                        pcall(function()
                                            local posoks, posoke = pcall(function()
                                                posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                            end)
                                            if posoke then
                                                local part
                                                for _, v in pairs(v:GetChildren()) do
                                                    local hasProperty = pcall(function()
                                                        local t = v["Position"]
                                                    end)
                                                    if hasProperty then
                                                        part = v
                                                        break
                                                    end
                                                end
                                                posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                            end
                                        end)
                                        if posok then
                                            fireproximityprompt(prompt)
                                        end
                                    until prompt:GetAttribute("Interactions") or not flags.draweraura
                                end)
                            end
                        elseif v.Name == "RolltopContainer" then
                            local prompt = v:WaitForChild("ActivateEventPrompt")
                            local interactions = prompt:GetAttribute("Interactions")

                            if not interactions then
                                task.spawn(function()
                                    repeat
                                        task.wait(0.1)
                                        local posok = false
                                        pcall(function()
                                            local posoks, posoke = pcall(function()
                                                posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                            end)
                                            if posoke then
                                                local part
                                                for _, v in pairs(v:GetChildren()) do
                                                    local hasProperty = pcall(function()
                                                        local t = v["Position"]
                                                    end)
                                                    if hasProperty then
                                                        part = v
                                                        break
                                                    end
                                                end
                                                posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                            end
                                        end)
                                        if posok then
                                            fireproximityprompt(prompt)
                                        end
                                    until prompt:GetAttribute("Interactions") or not flags.itemsaura
                                end)
                            end
                        end
                        -- end
                    end
                end

                local subaddcon
                subaddcon = room.DescendantAdded:Connect(function(ve)
                    check(ve)
                end)

                for _, v in pairs(room:GetDescendants()) do
                    task.spawn(function()
                        check(v)
                    end)
                end

                task.spawn(function()
                    repeat
                        task.wait()
                    until BOBHUBLOADED == false or not flags.itemsaura
                    subaddcon:Disconnect()
                end)
            end

            local addconnect
            addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                setup(room)
            end)

            for i, room in pairs(workspace.CurrentRooms:GetChildren()) do
                if room:FindFirstChild("Assets") then
                    setup(room)
                end
            end
            setup(workspace.CurrentRooms[tostring(game:GetService("ReplicatedStorage").GameData.LatestRoom.Value)])

            repeat
                task.wait()
            until BOBHUBLOADED == false or not flags.itemsaura
            addconnect:Disconnect()
        end
    end
})

MiscTab:AddToggle({
    Name = "Book Aura",
    Default = false,
    Callback = function(val)
        flags.bookcollecter = val

        if val then
            local function setup(room)
                local function check(v)
                    if v:IsA("Model") then
                        --if v.PrimaryPart then
                        if v.Name == "LiveHintBook" then
                            local prompt = v:WaitForChild("ActivateEventPrompt")

                            local okcanckl = 0
                            task.spawn(function()
                                repeat task.wait(0.1)
                                    local posok = false
                                    pcall(function()
                                        local posoks, posoke = pcall(function()
                                            posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
                                        end)
                                        if posoke then
                                            local part
                                            for _,v in pairs(v:GetChildren()) do
                                                local hasProperty = pcall(function() local t = v["Position"] end)
                                                if hasProperty then
                                                    part = v
                                                    break
                                                end
                                            end
                                            posok = (plr:DistanceFromCharacter(part.Position) <= 12)
                                        end
                                    end)
                                    if posok then
                                        fireproximityprompt(prompt) 
                                        okcanckl += 1
                                    end
                                until not v:IsDescendantOf(workspace) or not prompt:IsDescendantOf(workspace) or not flags.bookcollecter or okcanckl > 50
                            end)
                        end
                        --end
                    end
                end

                local subaddcon
                subaddcon = room.DescendantAdded:Connect(function(v)
                    check(v) 
                end)

                for i,v in pairs(room:GetDescendants()) do
                    check(v)
                end

                task.spawn(function()
                    repeat task.wait() until BOBHUBLOADED == false or not flags.bookcollecter
                    subaddcon:Disconnect() 
                end)
            end

            repeat task.wait() if flags.bookcollecter == false then break end until game:GetService("ReplicatedStorage").GameData.LatestRoom.Value == 50

            if flags.bookcollecter == true then
                local addconnect
                addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
                    setup(room)
                end)

                for i,room in pairs(workspace.CurrentRooms:GetChildren()) do
                    if room:FindFirstChild("Assets") then
                        setup(room) 
                    end
                end
                --  if workspace.CurrentRooms[tostring(game:GetService("ReplicatedStorage").GameData.LatestRoom.Value)]:FindFirstChild("Assets") then
                setup(workspace.CurrentRooms[tostring(game:GetService("ReplicatedStorage").GameData.LatestRoom.Value)])
                --  end

                repeat task.wait() until BOBHUBLOADED == false or not flags.bookcollecter
                addconnect:Disconnect()
            end
        end
    end
})

MiscTab:AddToggle({
	Name = "Breaker Aura",
	Default = false,
	Callback = function(Value)
		flags.breakercollecter = Value

		if Value then
			local function setup(room)
				local function check(v)
					if v:IsA("Model") and v.Name == "LiveBreakerPolePickup" then
						local prompt = v:WaitForChild("ActivateEventPrompt")

						local okcanckl = 0
						task.spawn(function()
							repeat task.wait(0.1)
								local posok = false
								pcall(function()
									local posoks, posoke = pcall(function()
										posok = (plr:DistanceFromCharacter(v.PrimaryPart.Position) <= 12)
									end)
									if posoke then
										local part
										for _,v in pairs(v:GetChildren()) do
											local hasProperty = pcall(function() local t = v["Position"] end)
											if hasProperty then
												part = v
												break
											end
										end
										posok = (plr:DistanceFromCharacter(part.Position) <= 12)
									end
								end)
								if posok then
									fireproximityprompt(prompt) 
									okcanckl += 1
								end
							until not v:IsDescendantOf(workspace) or not prompt:IsDescendantOf(workspace) or not flags.breakercollecter or okcanckl > 50
						end)
					end
				end

				local subaddcon
				subaddcon = room.DescendantAdded:Connect(function(v)
					check(v) 
				end)

				for i,v in pairs(room:GetDescendants()) do
					check(v)
				end

				task.spawn(function()
					repeat task.wait() until BOBHUBLOADED == false or not flags.breakercollecter
					subaddcon:Disconnect() 
				end)
			end

			repeat task.wait() if flags.breakercollecter == false then break end until game:GetService("ReplicatedStorage").GameData.LatestRoom.Value == 100

			if flags.breakercollecter == true then
				local addconnect
				addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
					setup(room)
				end)

				for i,room in pairs(workspace.CurrentRooms:GetChildren()) do
					if room:FindFirstChild("Assets") then
						setup(room) 
					end
				end

				setup(workspace.CurrentRooms[tostring(game:GetService("ReplicatedStorage").GameData.LatestRoom.Value)])

				repeat task.wait() until BOBHUBLOADED == false or not flags.breakercollecter
				addconnect:Disconnect()
			end
		end
	end
})

-- Trolling

local TrollTab = Window:MakeTab({
	Name = "Trolling",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

TrollTab:AddButton({
	Name = "FE Break Door",
	Callback = function()
        print("button pressed")
        
        for i, v in pairs(game.Workspace:GetDescendants()) do
            if v.ClassName == "Attachment" then
                wait(0.1)
                v.WorldCFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
        
        game.Workspace.DescendantAdded:Connect(function(v)
            if v.ClassName == "Attachment" then
                wait(0.1)
                v.WorldCFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end)
    end    
})

-- Super Hard Mode

local HardTab = Window:MakeTab({
	Name = "S. Hard Mode",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local shouldDelete = false

local toggle = HardTab:AddToggle({
    Name = "Delete Banana Peels",
    Default = false,
    Callback = function(Value)
        shouldDelete = Value
        if Value then
            while shouldDelete do
                wait(0.5)
                
                local bananaPeels = workspace:GetDescendants()
                for i = 1, #bananaPeels do
                    if bananaPeels[i]:IsA("Part") and bananaPeels[i].Name == "BananaPeel" then
                        bananaPeels[i]:Destroy()
                    end
                end
            end
        end
    end
})

local toggleEnabled = false

-- Function to delete parent if found
local function deleteParent()
    local parent = workspace:FindFirstChild("JeffTheKiller")
    if parent then
        parent:Destroy()
    end
end

-- Function to run the check and delete every 0.5 seconds if toggle is enabled
local function checkAndDelete()
    while toggleEnabled do
        deleteParent()
        wait(0.5)
    end
end

HardTab:AddToggle({
    Name = "Delete Jeff The Killer",
    Default = false,
    Callback = function(value)
        toggleEnabled = value
        if toggleEnabled then
            checkAndDelete()
        end
        print("Toggle value: " .. tostring(value))
    end
})

-- Fun

local FunTab = Window:MakeTab({
	Name = "Fun",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local soundId = "rbxassetid://1091083826"

FunTab:AddButton({
    Name = "Play a meow noise",
    Callback = function()
        print("meow")
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Parent = game.Workspace
        sound:Play()
    end    
})

-- Items

local ItemsTab = Window:MakeTab({
	Name = "Give Items",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

ItemsTab:AddButton({
    Name = "Remove Items",
    Callback = function()
-- Get the player whose inventory you want to clear
local player = game.Players.LocalPlayer

-- Get the player's character
local character = player.Character or player.CharacterAdded:Wait()

-- Get the player's backpack
local backpack = player.Backpack

-- Clear the player's backpack
for _, item in pairs(backpack:GetChildren()) do
    item:Destroy()
end

-- Clear the player's character
for _, item in pairs(character:GetChildren()) do
    if item:IsA("Tool") or item:IsA("Accessory") then
        item:Destroy()
    end
end   
              print("Items Removed!")
      end
})

ItemsTab:AddButton({
    Name = "F3X (Screen will freeze a bit)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/iimateiYT/Scripts/main/F3X.lua"))()
              print("Item Given!")
      end
})

ItemsTab:AddButton({
    Name = "Flamethrower",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/K0t1n/Public/main/Flamethrower"))()
              print("Item Given!")
      end
})

ItemsTab:AddButton({
    Name = "Magic Book",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/K0t1n/Public/main/Magic%20Book"))()
              print("Item Given!")
      end
})

ItemsTab:AddButton({
    Name = "Gun",
    Callback = function()
        local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()
local UIS = game:GetService("UserInputService")
local exampleTool = LoadCustomInstance("rbxassetid://12848567274") -- wand model

if game:GetService("Players").LocalPlayer.PlayerGui.MainUI.ItemShop.Visible == true then
    -- Create custom shop item
    CustomShop.CreateItem(exampleTool, {
        Title = "Harry Potter Wand",
        Desc = "Works on entities",
        Image = "https://cdn.discordapp.com/attachments/1049016956231102465/1078727375631679688/image_2023-02-24_121721211-removebg-preview.png",
        Price = "gun",
        Stack = 1,
    })
    ----------------------------------------- parenting
else
    exampleTool.Parent = game.Players.LocalPlayer.Backpack
end
local tool = exampleTool
local function Shoot()
    local bullet = game:GetObjects("rbxassetid://12848374097")[1]
    task.wait()
    bullet.Anchored = false
    bullet.Massless = false
    local Sound = Instance.new("Sound", game.StarterPlayer)
    Sound.Volume = 3.5
    Sound.SoundId = "rbxassetid://5238024665"
    Sound.PlayOnRemove = true
    Sound:Destroy()
    HRP = exampleTool.BulletPart.CFrame * CFrame.Angles(0,math.rad(-90),0)
    local Attachment = Instance.new("Attachment", bullet)
    local LV = Instance.new("LinearVelocity", Attachment) -- creating the linear velocity
    LV.MaxForce = math.huge -- no need to worry about this
    LV.VectorVelocity = (game:GetService("Players").LocalPlayer:GetMouse().Hit.Position - tool.BulletPart.Position).Unit * 100-- HRP.lookVector * 50 -- change 100 with how fast you want the projectile to go
    LV.Attachment0 = Attachment --Required Attachment
    bullet.Parent = game.Workspace
    bullet.CFrame = tool.BulletPart.CFrame * CFrame.Angles(math.rad(0),math.rad(90),math.rad(90))
    bullet.Touched:Connect(function(part)
        local Model = part:FindFirstAncestorWhichIsA("Model")
        if Model ~= nil and Model:GetAttribute("IsCustomEntity") == true then
            Model:Destroy()
        end
    end)
    task.wait(0.3)
    bullet:Destroy()
    end
----------------------------------------------- Shooting!
   
UIS.InputBegan:Connect(function(input)
    if tool.Parent == game.Players.LocalPlayer.Character then
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
        getgenv().BulletType = "12848374097"
        Shoot()
       
        end
    end
end)
              print("Item Given!")
      end
})

ItemsTab:AddButton({
    Name = "Scar-H",
    Callback = function()
        local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
local debrisService = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local runservice = game:GetService("RunService")

local SCARH = game:GetObjects("rbxassetid://13125400869")[1] or LoadCustomInstance("rbxassetid://13125400869")
SCARH.Parent = game.Players.LocalPlayer.Backpack

local shot = Instance.new("Sound", SCARH)
shot.SoundId = "rbxassetid://2025903231"
shot.Volume = 1.5
shot.PlaybackSpeed = 1.5

local bullet = game:GetObjects("rbxassetid://13115337607")[1]
bullet.Anchored = true
bullet.Massless = true

local bulletAttachment = Instance.new("Attachment", bullet)
bulletAttachment.Name = "BulletAttachment"
bullet.Parent = workspace


local bolt = SCARH.Bolt
local boltWeld = bolt.ManualWeld

local tweenService = game:GetService("TweenService")

local scopeObject
local camera = workspace.CurrentCamera
for _,deivid in ipairs(SCARH:GetDescendants()) do
    if deivid.Name == "Reticle" then
            scopeObject = deivid -- im so pro -divid
            break
        end
    end


local isTweening = false

local function tween()
    if isTweening then
        return
    end
    isTweening = true

    local startPos = bolt.ManualWeld.C0
    local tween1 = tweenService:Create(bolt.ManualWeld, TweenInfo.new(0.02, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
        C0 = bolt.ManualWeld.C0 * CFrame.new(0, 0, -0.40)
    })
    tween1:Play()
    tween1.Completed:Wait()

    local tween2 = tweenService:Create(bolt.ManualWeld, TweenInfo.new(0.02, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
        C0 = startPos
    })
    tween2:Play()
    tween2.Completed:Wait()
    
    isTweening = false
end

local function shootBullet()
    local mouse = game.Players.LocalPlayer:GetMouse()
    local targetPos = mouse.Hit.p
    local bulletPos = SCARH.Flash.Position

    local shootDirection = (mouse.Hit.p - SCARH.Handle.Position * CFrame.new(mat.random(1,3),math.random(1,3),math.random(1,3))).Unit
    local bulletClone = bullet:Clone()
    bulletClone.CFrame = CFrame.new(bulletPos, targetPos)
    bulletClone.Parent = workspace

    local bulletVelocity = shootDirection * 10000
    bulletClone.Anchored = false
    bulletClone.Massless = false
    bulletClone.CanCollide = true
    bulletClone.CanTouch = true
    bulletClone.Transparency = 0

    local bulletForce = Instance.new("BodyForce", bulletClone)
    bulletForce.Force = bulletVelocity * bulletClone:GetMass()
    bulletClone.Touched:Connect(function(part)
        local Model = part:FindFirstAncestorWhichIsA("Model")
        if Model ~= nil and Model:GetAttribute("IsCustomEntity") == true then
            Model:Destroy()
        end
    end)
    debrisService:AddItem(bulletClone, 5)

    bulletClone.Touched:Connect(function(part)
        local Model = part:FindFirstAncestorWhichIsA("Model")
        if Model ~= nil and Model:GetAttribute("IsCustomEntity") == true then
            Model:Destroy()
        end
    end)
end


SCARH.Activated:Connect(function()
    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do 
        task.wait(0.09)
        spawn(function()
            shot:Play()
            tween()
            shootBullet()
            SCARH.Flash.Light.Enabled = true
            SCARH.Flash.lite.Enabled = true
            task.wait(0.1)
            SCARH.Flash.lite.Enabled = false
            SCARH.Flash.Light.Enabled = false
        end)
    end

end)

local isPressedRight = false
UserInputService.InputBegan:Connect(function (input, _gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isPressedRight = true
    end
end)

UserInputService.InputEnded:Connect(function (input, _gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isPressedRight = false
    end
end)

local rsconnection
local didTween = false

rsconnection = runservice.RenderStepped:Connect(function()
    if SCARH ~= nil then
        if isPressedRight then
            print(didTween)
            if didTween == false then
                didTween = true
                local tween = tweenService:Create(camera,TweenInfo.new(0.5),{
                    ["CFrame"] = scopeObject.CFrame * CFrame.new(0,0,-0.6)
                }):Play()
                wait(0.5)
            else
                camera.CFrame = scopeObject.CFrame
            end
        end
        if not isPressedRight then
            if didTween == true then
                local tween = tweenService:Create(camera,TweenInfo.new(0.5),{
                    ["CFrame"] = Game.Players.LocalPlayer.Character.Head.CFrame
                }):Play()
                wait(0.5)
                didTween = false
            end
        end
    else
        rsconnection:Disconnect()
        return
    end
end)

UserInputService.InputBegan:Connect(function(input)
    
    -- no ballers? :c
    if SCARH.Parent == game.Players.LocalPlayer.Character then
        if input.KeyCode == Enum.KeyCode.Q then
            print("l")
            local MagClone = SCARH.Mag:Clone()
            MagClone.Parent = workspace
            MagClone.CFrame = SCARH.Mag.CFrame
            MagClone.ManualWeld:Destroy()
            Magclone.CanCollide = true
            task.wait(10)
            MagClone:Destroy()
        end
    end
end)
              print("Item Given!")
      end
})

ItemsTab:AddButton({
    Name = "Holy Grenade",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MrNeRD0/Doors-Hack/main/HolyGrenadeByNerd.lua"))()
              print("Item Given!")
      end
})

ItemsTab:AddButton({
    Name = "Chocolate Bar",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/K0t1n/Public/main/Chocolate%20Bar.lua"))()
              print("Item Given!")
      end
})

ItemsTab:AddButton({
    Name = "Zeus Lighting",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/K0t1n/Public/main/Zeus%20Lightning.lua"))()
              print("Item Given!")
      end
})

ItemsTab:AddButton({
    Name = "Laser Gun",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/K0t1n/Public/main/Laser%20Gun.lua"))()
              print("Item Given!")
      end
})

ItemsTab:AddButton({
    Name = "Gummy Flashlight (Spawns on the table at Door 0)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/K0t1n/Public/main/Gummy%20Flashlight.lua"))()
              print("Spawned!")
      end
})

ItemsTab:AddButton({
    Name = "Lucky Block",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/K0t1n/Public/main/Lucky%20Block"))()
              print("Item Given!")
      end
})

ItemsTab:AddButton({
    Name = "FE Banana Gun (Only works in Super Hard Mode)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MrNeRD0/Doors-Hack/main/BananaGunByNerd.lua"))()
              print("Item Given!")
      end
})

-- Scripts

local ScriptTab = Window:MakeTab({
	Name = "Scripts",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

ScriptTab:AddButton({
    Name = "awesome script",
    Callback = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/lolct/3591cfc7de1c6e1b5a9d810605677827/raw/"..game.PlaceId))()
              print("Executed!")
      end
})

ScriptTab:AddButton({
    Name = "MSDoors",
    Callback = function()
        loadstring(game:HttpGet(("https://raw.githubusercontent.com/mstudio45/MSDOORS/main/MSHUB_Loader.lua"),true))()
              print("Executed!")
      end
})

ScriptTab:AddButton({
    Name = "Keyboard Script (For mobile)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt", true))()
              print("Executed!")
      end
})

ScriptTab:AddButton({
    Name = "FE Emote Script",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/TrixAde/Proxima-Hub/main/UniversalDance-AnimGui.lua'))()
              print("Executed!")
      end
})

ScriptTab:AddButton({
    Name = "Dex V4",
    Callback = function()
        local file = "dexV4.lua" -- cache file name (workspace folder)
local url = "https://raw.githubusercontent.com/loglizzy/dexV4/main/source.lua"

local raw = isfile and isfile(file) and readfile(file)
raw = raw or game:HttpGet(url)

if isfile then
    task.spawn(writefile, file, game:HttpGet(url))
end

loadstring(raw)()
              print("Executed!")
      end
})

ScriptTab:AddButton({
    Name = "Simple Spy",
    Callback = function()
        --[[
    SimpleSpy v2.2 SOURCE

    Credits:
        exx - basically everything
        Frosty - GUI to Lua
]]

-- shuts down the previous instance of SimpleSpy
if _G.SimpleSpyExecuted and type(_G.SimpleSpyShutdown) == "function" then
    _G.SimpleSpyShutdown()
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Highlight = loadstring(game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/highlight.lua"))()

---- GENERATED (kinda sorta mostly) BY GUI to LUA ----

-- Instances:

local SimpleSpy2 = Instance.new("ScreenGui")
local Background = Instance.new("Frame")
local LeftPanel = Instance.new("Frame")
local LogList = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local RemoteTemplate = Instance.new("Frame")
local ColorBar = Instance.new("Frame")
local Text = Instance.new("TextLabel")
local Button = Instance.new("TextButton")
local RightPanel = Instance.new("Frame")
local CodeBox = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIGridLayout = Instance.new("UIGridLayout")
local FunctionTemplate = Instance.new("Frame")
local ColorBar_2 = Instance.new("Frame")
local Text_2 = Instance.new("TextLabel")
local Button_2 = Instance.new("TextButton")
local TopBar = Instance.new("Frame")
local Simple = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local ImageLabel = Instance.new("ImageLabel")
local MaximizeButton = Instance.new("TextButton")
local ImageLabel_2 = Instance.new("ImageLabel")
local MinimizeButton = Instance.new("TextButton")
local ImageLabel_3 = Instance.new("ImageLabel")
local ToolTip = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")

--Properties:

SimpleSpy2.Name = "SimpleSpy2"
SimpleSpy2.ResetOnSpawn = false

Background.Name = "Background"
Background.Parent = SimpleSpy2
Background.BackgroundColor3 = Color3.new(1, 1, 1)
Background.BackgroundTransparency = 1
Background.Position = UDim2.new(0, 500, 0, 200)
Background.Size = UDim2.new(0, 450, 0, 268)

LeftPanel.Name = "LeftPanel"
LeftPanel.Parent = Background
LeftPanel.BackgroundColor3 = Color3.new(0.207843, 0.203922, 0.215686)
LeftPanel.BorderSizePixel = 0
LeftPanel.Position = UDim2.new(0, 0, 0, 19)
LeftPanel.Size = UDim2.new(0, 131, 0, 249)

LogList.Name = "LogList"
LogList.Parent = LeftPanel
LogList.Active = true
LogList.BackgroundColor3 = Color3.new(1, 1, 1)
LogList.BackgroundTransparency = 1
LogList.BorderSizePixel = 0
LogList.Position = UDim2.new(0, 0, 0, 9)
LogList.Size = UDim2.new(0, 131, 0, 232)
LogList.CanvasSize = UDim2.new(0, 0, 0, 0)
LogList.ScrollBarThickness = 4

UIListLayout.Parent = LogList
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

RemoteTemplate.Name = "RemoteTemplate"
RemoteTemplate.Parent = LogList
RemoteTemplate.BackgroundColor3 = Color3.new(1, 1, 1)
RemoteTemplate.BackgroundTransparency = 1
RemoteTemplate.Size = UDim2.new(0, 117, 0, 27)

ColorBar.Name = "ColorBar"
ColorBar.Parent = RemoteTemplate
ColorBar.BackgroundColor3 = Color3.new(1, 0.94902, 0)
ColorBar.BorderSizePixel = 0
ColorBar.Position = UDim2.new(0, 0, 0, 1)
ColorBar.Size = UDim2.new(0, 7, 0, 18)
ColorBar.ZIndex = 2

Text.Name = "Text"
Text.Parent = RemoteTemplate
Text.BackgroundColor3 = Color3.new(1, 1, 1)
Text.BackgroundTransparency = 1
Text.Position = UDim2.new(0, 12, 0, 1)
Text.Size = UDim2.new(0, 105, 0, 18)
Text.ZIndex = 2
Text.Font = Enum.Font.SourceSans
Text.Text = "TEXT"
Text.TextColor3 = Color3.new(1, 1, 1)
Text.TextSize = 14
Text.TextXAlignment = Enum.TextXAlignment.Left

Button.Name = "Button"
Button.Parent = RemoteTemplate
Button.BackgroundColor3 = Color3.new(0, 0, 0)
Button.BackgroundTransparency = 0.75
Button.BorderColor3 = Color3.new(1, 1, 1)
Button.Position = UDim2.new(0, 0, 0, 1)
Button.Size = UDim2.new(0, 117, 0, 18)
Button.AutoButtonColor = false
Button.Font = Enum.Font.SourceSans
Button.Text = ""
Button.TextColor3 = Color3.new(0, 0, 0)
Button.TextSize = 14

RightPanel.Name = "RightPanel"
RightPanel.Parent = Background
RightPanel.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
RightPanel.BorderSizePixel = 0
RightPanel.Position = UDim2.new(0, 131, 0, 19)
RightPanel.Size = UDim2.new(0, 319, 0, 249)

CodeBox.Name = "CodeBox"
CodeBox.Parent = RightPanel
CodeBox.BackgroundColor3 = Color3.new(0.0823529, 0.0745098, 0.0784314)
CodeBox.BorderSizePixel = 0
CodeBox.Size = UDim2.new(0, 319, 0, 119)

ScrollingFrame.Parent = RightPanel
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.new(1, 1, 1)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 0, 0.5, 0)
ScrollingFrame.Size = UDim2.new(1, 0, 0.5, -9)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4

UIGridLayout.Parent = ScrollingFrame
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
UIGridLayout.CellSize = UDim2.new(0, 94, 0, 27)

FunctionTemplate.Name = "FunctionTemplate"
FunctionTemplate.Parent = ScrollingFrame
FunctionTemplate.BackgroundColor3 = Color3.new(1, 1, 1)
FunctionTemplate.BackgroundTransparency = 1
FunctionTemplate.Size = UDim2.new(0, 117, 0, 23)

ColorBar_2.Name = "ColorBar"
ColorBar_2.Parent = FunctionTemplate
ColorBar_2.BackgroundColor3 = Color3.new(1, 1, 1)
ColorBar_2.BorderSizePixel = 0
ColorBar_2.Position = UDim2.new(0, 7, 0, 10)
ColorBar_2.Size = UDim2.new(0, 7, 0, 18)
ColorBar_2.ZIndex = 3

Text_2.Name = "Text"
Text_2.Parent = FunctionTemplate
Text_2.BackgroundColor3 = Color3.new(1, 1, 1)
Text_2.BackgroundTransparency = 1
Text_2.Position = UDim2.new(0, 19, 0, 10)
Text_2.Size = UDim2.new(0, 69, 0, 18)
Text_2.ZIndex = 2
Text_2.Font = Enum.Font.SourceSans
Text_2.Text = "TEXT"
Text_2.TextColor3 = Color3.new(1, 1, 1)
Text_2.TextSize = 14
Text_2.TextStrokeColor3 = Color3.new(0.145098, 0.141176, 0.14902)
Text_2.TextXAlignment = Enum.TextXAlignment.Left

Button_2.Name = "Button"
Button_2.Parent = FunctionTemplate
Button_2.BackgroundColor3 = Color3.new(0, 0, 0)
Button_2.BackgroundTransparency = 0.69999998807907
Button_2.BorderColor3 = Color3.new(1, 1, 1)
Button_2.Position = UDim2.new(0, 7, 0, 10)
Button_2.Size = UDim2.new(0, 80, 0, 18)
Button_2.AutoButtonColor = false
Button_2.Font = Enum.Font.SourceSans
Button_2.Text = ""
Button_2.TextColor3 = Color3.new(0, 0, 0)
Button_2.TextSize = 14

TopBar.Name = "TopBar"
TopBar.Parent = Background
TopBar.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(0, 450, 0, 19)

Simple.Name = "Simple"
Simple.Parent = TopBar
Simple.BackgroundColor3 = Color3.new(1, 1, 1)
Simple.AutoButtonColor = false
Simple.BackgroundTransparency = 1
Simple.Position = UDim2.new(0, 5, 0, 0)
Simple.Size = UDim2.new(0, 57, 0, 18)
Simple.Font = Enum.Font.SourceSansBold
Simple.Text = "SimpleSpy"
Simple.TextColor3 = Color3.new(1, 1, 1)
Simple.TextSize = 14
Simple.TextXAlignment = Enum.TextXAlignment.Left

CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -19, 0, 0)
CloseButton.Size = UDim2.new(0, 19, 0, 19)
CloseButton.Font = Enum.Font.SourceSans
CloseButton.Text = ""
CloseButton.TextColor3 = Color3.new(0, 0, 0)
CloseButton.TextSize = 14

ImageLabel.Parent = CloseButton
ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Position = UDim2.new(0, 5, 0, 5)
ImageLabel.Size = UDim2.new(0, 9, 0, 9)
ImageLabel.Image = "http://www.roblox.com/asset/?id=5597086202"

MaximizeButton.Name = "MaximizeButton"
MaximizeButton.Parent = TopBar
MaximizeButton.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
MaximizeButton.BorderSizePixel = 0
MaximizeButton.Position = UDim2.new(1, -38, 0, 0)
MaximizeButton.Size = UDim2.new(0, 19, 0, 19)
MaximizeButton.Font = Enum.Font.SourceSans
MaximizeButton.Text = ""
MaximizeButton.TextColor3 = Color3.new(0, 0, 0)
MaximizeButton.TextSize = 14

ImageLabel_2.Parent = MaximizeButton
ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_2.BackgroundTransparency = 1
ImageLabel_2.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_2.Size = UDim2.new(0, 9, 0, 9)
ImageLabel_2.Image = "http://www.roblox.com/asset/?id=5597108117"

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TopBar
MinimizeButton.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -57, 0, 0)
MinimizeButton.Size = UDim2.new(0, 19, 0, 19)
MinimizeButton.Font = Enum.Font.SourceSans
MinimizeButton.Text = ""
MinimizeButton.TextColor3 = Color3.new(0, 0, 0)
MinimizeButton.TextSize = 14

ImageLabel_3.Parent = MinimizeButton
ImageLabel_3.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_3.BackgroundTransparency = 1
ImageLabel_3.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_3.Size = UDim2.new(0, 9, 0, 9)
ImageLabel_3.Image = "http://www.roblox.com/asset/?id=5597105827"

ToolTip.Name = "ToolTip"
ToolTip.Parent = SimpleSpy2
ToolTip.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
ToolTip.BackgroundTransparency = 0.1
ToolTip.BorderColor3 = Color3.new(1, 1, 1)
ToolTip.Size = UDim2.new(0, 200, 0, 50)
ToolTip.ZIndex = 3
ToolTip.Visible = false

TextLabel.Parent = ToolTip
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 2, 0, 2)
TextLabel.Size = UDim2.new(0, 196, 0, 46)
TextLabel.ZIndex = 3
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "This is some slightly longer text."
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 14
TextLabel.TextWrapped = true
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.TextYAlignment = Enum.TextYAlignment.Top

-------------------------------------------------------------------------------
-- init
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local TextService = game:GetService("TextService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

local selectedColor = Color3.new(0.321569, 0.333333, 1)
local deselectedColor = Color3.new(0.8, 0.8, 0.8)
--- So things are descending
local layoutOrderNum = 999999999
--- Whether or not the gui is closing
local mainClosing = false
--- Whether or not the gui is closed (defaults to false)
local closed = false
--- Whether or not the sidebar is closing
local sideClosing = false
--- Whether or not the sidebar is closed (defaults to true but opens automatically on remote selection)
local sideClosed = false
--- Whether or not the code box is maximized (defaults to false)
local maximized = false
--- The event logs to be read from
local logs = {}
--- The event currently selected.Log (defaults to nil)
local selected = nil
--- The blacklist (can be a string name or the Remote Instance)
local blacklist = {}
--- The block list (can be a string name or the Remote Instance)
local blocklist = {}
--- Whether or not to add getNil function
local getNil = false
--- Array of remotes (and original functions) connected to
local connectedRemotes = {}
--- True = hookfunction, false = namecall
local toggle = false
local gm = getrawmetatable(game)
local original = gm.__namecall
setreadonly(gm, false)
--- used to prevent recursives
local prevTables = {}
--- holds logs (for deletion)
local remoteLogs = {}
--- used for hookfunction
local remoteEvent = Instance.new("RemoteEvent")
--- used for hookfunction
local remoteFunction = Instance.new("RemoteFunction")
local originalEvent = remoteEvent.FireServer
local originalFunction = remoteFunction.InvokeServer
--- the maximum amount of remotes allowed in logs
_G.SIMPLESPYCONFIG_MaxRemotes = 500
--- how many spaces to indent
local indent = 4
--- used for task scheduler
local scheduled = {}
--- RBXScriptConnect of the task scheduler
local schedulerconnect
local SimpleSpy = {}
local topstr = ""
local bottomstr = ""
local remotesFadeIn
local rightFadeIn
local codebox
local p
local getnilrequired = false

-- autoblock variables
local autoblock = false
local history = {}
local excluding = {}

-- function info variables
local funcEnabled = true

-- remote hooking/connecting api variables
local remoteSignals = {}
local remoteHooks = {}

-- original mouse icon
local oldIcon = Mouse.Icon

-- if mouse inside gui
local mouseInGui = false

-- handy array of RBXScriptConnections to disconnect on shutdown
local connections = {}

-- whether or not SimpleSpy uses 'getcallingscript()' to get the script (default is false because detection)
local useGetCallingScript = false

-- functions

--- Converts arguments to a string and generates code that calls the specified method with them, recommended to be used in conjunction with ValueToString (method must be a string, e.g. `game:GetService("ReplicatedStorage").Remote:FireServer`)
--- @param method string
--- @param args any[]
--- @return string
function SimpleSpy:ArgsToString(method, args)
    assert(typeof(method) == "string", "string expected, got " .. typeof(method))
    assert(typeof(args) == "table", "table expected, got " .. typeof(args))
    return v2v({args = args}) .. "\n\n" .. method .. "(unpack(args))"
end

--- Converts a value to variables with the specified index as the variable name (if nil/invalid then the name will be assigned automatically)
--- @param t any[]
--- @return string
function SimpleSpy:TableToVars(t)
    assert(typeof(t) == "table", "table expected, got " .. typeof(t))
    return v2v(t)
end

--- Converts a value to a variable with the specified `variablename` (if nil/invalid then the name will be assigned automatically)
--- @param value any
--- @return string
function SimpleSpy:ValueToVar(value, variablename)
    assert(variablename == nil or typeof(variablename) == "string", "string expected, got " .. typeof(variablename))
    if not variablename then
        variablename = 1
    end
    return v2v({[variablename] = value})
end

--- Converts any value to a string, cannot preserve function contents
--- @param value any
--- @return string
function SimpleSpy:ValueToString(value)
    return v2s(value)
end

--- Generates the simplespy function info
--- @param func function
--- @return string
function SimpleSpy:GetFunctionInfo(func)
    assert(typeof(func) == "function", "Instance expected, got " .. typeof(func))
    return v2v{functionInfo = {
        info = debug.getinfo(func),
        constants = debug.getconstants(func)
    }}
end

--- Gets the ScriptSignal for a specified remote being fired
--- @param remote Instance
function SimpleSpy:GetRemoteFiredSignal(remote)
    assert(typeof(remote) == "Instance", "Instance expected, got " .. typeof(remote))
    if not remoteSignals[remote] then
        remoteSignals[remote] = newSignal()
    end
    return remoteSignals[remote]
end

--- Allows for direct hooking of remotes **THIS CAN BE VERY DANGEROUS**
--- @param remote Instance
--- @param f function
function SimpleSpy:HookRemote(remote, f)
    assert(typeof(remote) == "Instance", "Instance expected, got " .. typeof(remote))
    assert(typeof(f) == "function", "function expected, got " .. typeof(f))
    remoteHooks[remote] = f
end

--- Blocks the specified remote instance/string
--- @param remote any
function SimpleSpy:BlockRemote(remote)
    assert(typeof(remote) == "Instance" or typeof(remote) == "string", "Instance | string expected, got " .. typeof(remote))
    blocklist[remote] = true
end

--- Excludes the specified remote from logs (instance/string)
--- @param remote any
function SimpleSpy:ExcludeRemote(remote)
    assert(typeof(remote) == "Instance" or typeof(remote) == "string", "Instance | string expected, got " .. typeof(remote))
    blacklist[remote] = true
end

--- Creates a new ScriptSignal that can be connected to and fired
--- @return table
function newSignal()
    local connected = {}
    return {
        Connect = function(self, f)
            assert(connected, "Signal is closed")
            connected[tostring(f)] = f
            return setmetatable({
                Connected = true,
                Disconnect = function(self)
                    if not connected then
                        warn("Signal is already closed")
                    end
                    self.Connected = false
                    connected[tostring(f)] = nil
                end
            },
            {
                __index = function(self, i)
                    if i == "Connected" then
                        return not not connected[tostring(f)]
                    end
                end
            })
        end,
        Fire = function(self, ...)
            for _, f in pairs(connected) do
                coroutine.wrap(f)(...)
            end
        end
    }
end

--- Prevents remote spam from causing lag (clears logs after `_G.SIMPLESPYCONFIG_MaxRemotes` or 500 remotes)
function clean()
    local max = _G.SIMPLESPYCONFIG_MaxRemotes
    if not typeof(max) == "number" and math.floor(max) ~= max then
        max = 500
    end
    if #remoteLogs > max then
        for i = 100, #remoteLogs do
            local v = remoteLogs[i]
            if typeof(v[1]) == "RBXScriptConnection" then
                v[1]:Disconnect()
            end
            if typeof(v[2]) == "Instance" then
                v[2]:Destroy()
            end
        end
        local newLogs = {}
        for i = 1, 100 do
            table.insert(newLogs, remoteLogs[i])
        end
        remoteLogs = newLogs
    end
end

--- Scales the ToolTip to fit containing text
function scaleToolTip()
    local size = TextService:GetTextSize(TextLabel.Text, TextLabel.TextSize, TextLabel.Font, Vector2.new(196, math.huge))
    TextLabel.Size = UDim2.new(0, size.X, 0, size.Y)
    ToolTip.Size = UDim2.new(0, size.X + 4, 0, size.Y + 4)
end

--- Executed when the toggle button (the SimpleSpy logo) is hovered over
function onToggleButtonHover()
    if not toggle then
        TweenService:Create(Simple, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(252, 51, 51)}):Play()
    else
        TweenService:Create(Simple, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(68, 206, 91)}):Play()
    end
end

--- Executed when the toggle button is unhovered over
function onToggleButtonUnhover()
    TweenService:Create(Simple, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end

--- Executed when the X button is hovered over
function onXButtonHover()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}):Play()
end

--- Executed when the X button is unhovered over
function onXButtonUnhover()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(37, 36, 38)}):Play()
end

--- Toggles the remote spy method (when button clicked)
function onToggleButtonClick()
    if toggle then
        TweenService:Create(Simple, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(252, 51, 51)}):Play()
    else
        TweenService:Create(Simple, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(68, 206, 91)}):Play()
    end
    toggleSpyMethod()
end

--- Reconnects bringBackOnResize if the current viewport changes and also connects it initially
function connectResize()
    local lastCam = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(bringBackOnResize)
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        lastCam:Disconnect()
        if workspace.CurrentCamera then
            lastCam = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(bringBackOnResize)
        end
    end)
end

--- Brings gui back if it gets lost offscreen (connected to the camera viewport changing)
function bringBackOnResize()
    local currentX = Background.AbsolutePosition.X
    local currentY = Background.AbsolutePosition.Y
    local viewportSize = workspace.CurrentCamera.ViewportSize
    if (currentX < 0) or (currentX > (viewportSize.X - (sideClosed and 131 or TopBar.AbsoluteSize.X))) then
        if currentX < 0 then
            currentX = 0
        else
            currentX = viewportSize.X - (sideClosed and 131 or TopBar.AbsoluteSize.X)
        end
    end
    if (currentY < 0) or (currentY > (viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36)) then
        if currentY < 0 then
            currentY = 0
        else
            currentY = viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36
        end
    end
    TweenService.Create(TweenService, Background, TweenInfo.new(0.1), {Position = UDim2.new(0, currentX, 0, currentY)}):Play()
end

--- Drags gui (so long as mouse is held down)
function onBarInput(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local lastPos = UserInputService.GetMouseLocation(UserInputService)
        local mainPos = Background.AbsolutePosition
        local offset = mainPos - lastPos
        local currentPos = offset + lastPos
        RunService.BindToRenderStep(RunService, "drag", 1,
            function()
                local newPos = UserInputService.GetMouseLocation(UserInputService)
                if newPos ~= lastPos then
                    local currentX = (offset + newPos).X
                    local currentY = (offset + newPos).Y
                    local viewportSize = workspace.CurrentCamera.ViewportSize
                    if (currentX < 0 and currentX < currentPos.X) or (currentX > (viewportSize.X - (sideClosed and 131 or TopBar.AbsoluteSize.X)) and currentX > currentPos.X) then
                        if currentX < 0 then
                            currentX = 0
                        else
                            currentX = viewportSize.X - (sideClosed and 131 or TopBar.AbsoluteSize.X)
                        end
                    end
                    if (currentY < 0 and currentY < currentPos.Y) or (currentY > (viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36) and currentY > currentPos.Y) then
                        if currentY < 0 then
                            currentY = 0
                        else
                            currentY = viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36
                        end
                    end
                    currentPos = Vector2.new(currentX, currentY)
                    lastPos = newPos
                    TweenService.Create(TweenService, Background, TweenInfo.new(0.1), {Position = UDim2.new(0, currentPos.X, 0, currentPos.Y)}):Play()
                end
                if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    RunService.UnbindFromRenderStep(RunService, "drag")
                end
            end
        )
    end
end

--- Fades out the table of elements (and makes them invisible), returns a function to make them visible again
function fadeOut(elements)
    local data = {}
    for _, v in pairs(elements) do
        if typeof(v) == "Instance" and v:IsA("GuiObject") and v.Visible then
            coroutine.wrap(function()
                data[v] = {
                    BackgroundTransparency = v.BackgroundTransparency
                }
                TweenService:Create(v, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                if v:IsA("TextBox") or v:IsA("TextButton") or v:IsA("TextLabel") then
                    data[v].TextTransparency = v.TextTransparency
                    TweenService:Create(v, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                elseif v:IsA("ImageButton") or v:IsA("ImageLabel") then
                    data[v].ImageTransparency = v.ImageTransparency
                    TweenService:Create(v, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
                end
                wait(0.5)
                v.Visible = false
                for i, x in pairs(data[v]) do
                    v[i] = x
                end
                data[v] = true
            end)()
        end
    end
    return function()
        for i, _ in pairs(data) do
            coroutine.wrap(function()
                local properties = {
                    BackgroundTransparency = i.BackgroundTransparency
                }
                i.BackgroundTransparency = 1
                TweenService:Create(i, TweenInfo.new(0.5), {BackgroundTransparency = properties.BackgroundTransparency}):Play()
                if i:IsA("TextBox") or i:IsA("TextButton") or i:IsA("TextLabel") then
                    properties.TextTransparency = i.TextTransparency
                    i.TextTransparency = 1
                    TweenService:Create(i, TweenInfo.new(0.5), {TextTransparency = properties.TextTransparency}):Play()
                elseif i:IsA("ImageButton") or i:IsA("ImageLabel") then
                    properties.ImageTransparency = i.ImageTransparency
                    i.ImageTransparency = 1
                    TweenService:Create(i, TweenInfo.new(0.5), {ImageTransparency = properties.ImageTransparency}):Play()
                end
                i.Visible = true
            end)()
        end
    end
end

--- Expands and minimizes the gui (closed is the toggle boolean)
function toggleMinimize(override)
    if mainClosing and not override or maximized then
        return
    end
    mainClosing = true
    closed = not closed
    if closed then
        if not sideClosed then
            toggleSideTray(true)
        end
        LeftPanel.Visible = true
        TweenService:Create(LeftPanel, TweenInfo.new(0.5), {Size = UDim2.new(0, 131, 0, 0)}):Play()
        wait(0.5)
        remotesFadeIn = fadeOut(LeftPanel:GetDescendants())
        wait(0.5)
    else
        TweenService:Create(LeftPanel, TweenInfo.new(0.5), {Size = UDim2.new(0, 131, 0, 249)}):Play()
        wait(0.5)
        if remotesFadeIn then
            remotesFadeIn()
            remotesFadeIn = nil
        end
        bringBackOnResize()
    end
    mainClosing = false
end

--- Expands and minimizes the sidebar (sideClosed is the toggle boolean)
function toggleSideTray(override)
    if sideClosing and not override or maximized then
        return
    end
    sideClosing = true
    sideClosed = not sideClosed
    if sideClosed then
        rightFadeIn = fadeOut(RightPanel:GetDescendants())
        wait(0.5)
        minimizeSize(0.5)
        wait(0.5)
        RightPanel.Visible = false
    else
        if closed then
            toggleMinimize(true)
        end
        RightPanel.Visible = true
        maximizeSize(0.5)
        wait(0.5)
        if rightFadeIn then
            rightFadeIn()
        end
        bringBackOnResize()
    end
    sideClosing = false
end

--- Expands code box to fit screen for more convenient viewing
function toggleMaximize()
    if not sideClosed and not maximized then
        maximized = true
        local disable = Instance.new("TextButton")
        local prevSize = UDim2.new(0, CodeBox.AbsoluteSize.X, 0, CodeBox.AbsoluteSize.Y)
        local prevPos = UDim2.new(0,CodeBox.AbsolutePosition.X, 0, CodeBox.AbsolutePosition.Y)
        disable.Size = UDim2.new(1, 0, 1, 0)
        disable.BackgroundColor3 = Color3.new()
        disable.BorderSizePixel = 0
        disable.Text = 0
        disable.ZIndex = 3
        disable.BackgroundTransparency = 1
        disable.AutoButtonColor = false
        CodeBox.ZIndex = 4
        CodeBox.Position = prevPos
        CodeBox.Size = prevSize
        TweenService:Create(CodeBox, TweenInfo.new(0.5), {Size = UDim2.new(0.5, 0, 0.5, 0), Position = UDim2.new(0.25, 0, 0.25, 0)}):Play()
        TweenService:Create(disable, TweenInfo.new(0.5), {BackgroundTransparency = 0.5}):Play()
        disable.MouseButton1Click:Connect(function()
            if UserInputService:GetMouseLocation().Y + 36 >= CodeBox.AbsolutePosition.Y and UserInputService:GetMouseLocation().Y + 36 <= CodeBox.AbsolutePosition.Y + CodeBox.AbsoluteSize.Y
                and UserInputService:GetMouseLocation().X >= CodeBox.AbsolutePosition.X and UserInputService:GetMouseLocation().X <= CodeBox.AbsolutePosition.X + CodeBox.AbsoluteSize.X then
                return
            end
            TweenService:Create(CodeBox, TweenInfo.new(0.5), {Size = prevSize, Position = prevPos}):Play()
            TweenService:Create(disable, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            wait(0.5)
            disable:Destroy()
            CodeBox.Size = UDim2.new(1, 0, 0.5, 0)
            CodeBox.Position = UDim2.new(0, 0, 0, 0)
            CodeBox.ZIndex = 0
            maximized = false
        end)
    end
end

--- Checks if cursor is within resize range
--- @param p Vector2
function isInResizeRange(p)
    local relativeP = p - Background.AbsolutePosition
    local range = 5
    if relativeP.X >= TopBar.AbsoluteSize.X - range and relativeP.Y >= Background.AbsoluteSize.Y - range
        and relativeP.X <= TopBar.AbsoluteSize.X and relativeP.Y <= Background.AbsoluteSize.Y then
        return true, 'B'
    elseif relativeP.X >= TopBar.AbsoluteSize.X - range and relativeP.X <= Background.AbsoluteSize.X then
        return true, 'X'
    elseif relativeP.Y >= Background.AbsoluteSize.Y - range and relativeP.Y <= Background.AbsoluteSize.Y then
        return true, 'Y'
    end
    return false
end

--- Called when mouse enters SimpleSpy
function mouseEntered()
    local customCursor = Instance.new("ImageLabel")
    customCursor.Size = UDim2.fromOffset(200, 200)
    customCursor.ZIndex = 1e5
    customCursor.BackgroundTransparency = 1
    customCursor.Image = ""
    customCursor.Parent = SimpleSpy2
    UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceHide
    RunService:BindToRenderStep("SIMPLESPY_CURSOR", 1, function()
        if mouseInGui and _G.SimpleSpyExecuted then
            local mouseLocation = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
            customCursor.Position = UDim2.fromOffset(mouseLocation.X - customCursor.AbsoluteSize.X / 2, mouseLocation.Y - customCursor.AbsoluteSize.Y / 2)
            local inRange, type = isInResizeRange(mouseLocation)
            if inRange and not sideClosed and not closed then
                customCursor.Image = type == 'B' and "rbxassetid://6065821980" or type == 'X' and "rbxassetid://6065821086" or type == 'Y' and "rbxassetid://6065821596"
            elseif inRange and not closed and type == 'Y' or type == 'B' then
                customCursor.Image = "rbxassetid://6065821596"
            elseif customCursor.Image ~= "rbxassetid://6065775281" then
                customCursor.Image = "rbxassetid://6065775281"
            end
        else
            UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
            customCursor:Destroy()
            RunService:UnbindFromRenderStep("SIMPLESPY_CURSOR")
        end
    end)
end

--- Called when mouse moves
function mouseMoved()
    local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
    if not closed
    and mousePos.X >= TopBar.AbsolutePosition.X and mousePos.X <= TopBar.AbsolutePosition.X + TopBar.AbsoluteSize.X
    and mousePos.Y >= Background.AbsolutePosition.Y and mousePos.Y <= Background.AbsolutePosition.Y + Background.AbsoluteSize.Y then
        if not mouseInGui then
            mouseInGui = true
            mouseEntered()
        end
    else
        mouseInGui = false
    end
end

--- Adjusts the ui elements to the 'Maximized' size
function maximizeSize(speed)
    if not speed then
        speed = 0.05
    end
    TweenService:Create(LeftPanel, TweenInfo.new(speed), { Size = UDim2.fromOffset(LeftPanel.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(RightPanel, TweenInfo.new(speed), { Size = UDim2.fromOffset(Background.AbsoluteSize.X - LeftPanel.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(TopBar, TweenInfo.new(speed), { Size = UDim2.fromOffset(Background.AbsoluteSize.X, TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(ScrollingFrame, TweenInfo.new(speed), { Size = UDim2.fromOffset(Background.AbsoluteSize.X - LeftPanel.AbsoluteSize.X, 110), Position = UDim2.fromOffset(0, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(CodeBox, TweenInfo.new(speed), { Size = UDim2.fromOffset(Background.AbsoluteSize.X - LeftPanel.AbsoluteSize.X, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(LogList, TweenInfo.new(speed), { Size = UDim2.fromOffset(LogList.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y - 18) }):Play()
end

--- Adjusts the ui elements to close the side
function minimizeSize(speed)
    if not speed then
        speed = 0.05
    end
    TweenService:Create(LeftPanel, TweenInfo.new(speed), { Size = UDim2.fromOffset(LeftPanel.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(RightPanel, TweenInfo.new(speed), { Size = UDim2.fromOffset(0, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(TopBar, TweenInfo.new(speed), { Size = UDim2.fromOffset(LeftPanel.AbsoluteSize.X, TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(ScrollingFrame, TweenInfo.new(speed), { Size = UDim2.fromOffset(0, 119), Position = UDim2.fromOffset(0, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(CodeBox, TweenInfo.new(speed), { Size = UDim2.fromOffset(0, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(LogList, TweenInfo.new(speed), { Size = UDim2.fromOffset(LogList.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y - 18) }):Play()
end

--- Called on user input while mouse in 'Background' frame
--- @param input InputObject
function backgroundUserInput(input)
    local inRange, type = isInResizeRange(UserInputService:GetMouseLocation() - Vector2.new(0, 36))
    if input.UserInputType == Enum.UserInputType.MouseButton1 and inRange then
        local lastPos = UserInputService:GetMouseLocation()
        local offset = Background.AbsoluteSize - lastPos
        local currentPos = lastPos + offset
        RunService:BindToRenderStep("SIMPLESPY_RESIZE", 1, function()
            local newPos = UserInputService:GetMouseLocation()
            if newPos ~= lastPos then
                local currentX = (newPos + offset).X
                local currentY = (newPos + offset).Y
                if currentX < 450 then
                    currentX = 450
                end
                if currentY < 268 then
                    currentY = 268
                end
                currentPos = Vector2.new(currentX, currentY)
                Background.Size = UDim2.fromOffset((not sideClosed and not closed and (type == "X" or type == "B")) and currentPos.X or Background.AbsoluteSize.X, (--[[(not sideClosed or currentPos.X <= LeftPanel.AbsolutePosition.X + LeftPanel.AbsoluteSize.X) and]] not closed and (type == "Y" or type == "B")) and currentPos.Y or Background.AbsoluteSize.Y)
                if sideClosed then
                    minimizeSize()
                else
                    maximizeSize()
                end
                lastPos = newPos
            end
        end)
        table.insert(connections, UserInputService.InputEnded:Connect(function(inputE)
            if input == inputE then
                RunService:UnbindFromRenderStep("SIMPLESPY_RESIZE")
            end
        end))
    end
end

--- Gets the player an instance is descended from
function getPlayerFromInstance(instance)
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and (instance:IsDescendantOf(v.Character) or instance == v.Character) then
            return v
        end
    end
end

--- Runs on MouseButton1Click of an event frame
function eventSelect(frame)
    if selected and selected.Log  then
        TweenService:Create(selected.Log.Button, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        selected = nil
    end
    for _, v in pairs(logs) do
        if frame == v.Log then
            selected = v
        end
    end
    if selected and selected.Log then
        TweenService:Create(frame.Button, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(92, 126, 229)}):Play()
        codebox:setRaw(selected.GenScript)
    end
    if sideClosed then
        toggleSideTray()
    end
end

--- Updates the canvas size to fit the current amount of function buttons
function updateFunctionCanvas()
    ScrollingFrame.CanvasSize = UDim2.fromOffset(UIGridLayout.AbsoluteContentSize.X, UIGridLayout.AbsoluteContentSize.Y)
end

--- Updates the canvas size to fit the amount of current remotes
function updateRemoteCanvas()
    LogList.CanvasSize = UDim2.fromOffset(UIListLayout.AbsoluteContentSize.X, UIListLayout.AbsoluteContentSize.Y)
end

--- Allows for toggling of the tooltip and easy setting of le description
--- @param enable boolean
--- @param text string
function makeToolTip(enable, text)
    if enable then
        if ToolTip.Visible then
            ToolTip.Visible = false
            RunService:UnbindFromRenderStep("ToolTip")
        end
        local first = true
        RunService:BindToRenderStep("ToolTip", 1, function()
            local topLeft = Vector2.new(Mouse.X + 20, Mouse.Y + 20)
            local bottomRight = topLeft + ToolTip.AbsoluteSize
            if topLeft.X < 0 then
                topLeft = Vector2.new(0, topLeft.Y)
            elseif bottomRight.X > workspace.CurrentCamera.ViewportSize.X then
                topLeft = Vector2.new(workspace.CurrentCamera.ViewportSize.X - ToolTip.AbsoluteSize.X, topLeft.Y)
            end
            if topLeft.Y < 0 then
                topLeft = Vector2.new(topLeft.X, 0)
            elseif bottomRight.Y > workspace.CurrentCamera.ViewportSize.Y - 35 then
                topLeft = Vector2.new(topLeft.X, workspace.CurrentCamera.ViewportSize.Y - ToolTip.AbsoluteSize.Y - 35)
            end
            if topLeft.X <= Mouse.X and topLeft.Y <= Mouse.Y then
                topLeft = Vector2.new(Mouse.X - ToolTip.AbsoluteSize.X - 2, Mouse.Y - ToolTip.AbsoluteSize.Y - 2)
            end
            if first then
                ToolTip.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
                first = false
            else
                ToolTip:TweenPosition(UDim2.fromOffset(topLeft.X, topLeft.Y), "Out", "Linear", 0.1)
            end
        end)
        TextLabel.Text = text
        ToolTip.Visible = true
    else
        if ToolTip.Visible then
            ToolTip.Visible = false
            RunService:UnbindFromRenderStep("ToolTip")
        end
    end
end

--- Creates new function button (below codebox)
--- @param name string
---@param description function
---@param onClick function
function newButton(name, description, onClick)
    local button = FunctionTemplate:Clone()
    button.Text.Text = name
    button.Button.MouseEnter:Connect(function()
        makeToolTip(true, description())
    end)
    button.Button.MouseLeave:Connect(function()
        makeToolTip(false)
    end)
    button.AncestryChanged:Connect(function()
        makeToolTip(false)
    end)
    button.Button.MouseButton1Click:Connect(function(...)
        onClick(button, ...)
    end)
    button.Parent = ScrollingFrame
    updateFunctionCanvas()
end

--- Adds new Remote to logs
--- @param name string The name of the remote being logged
--- @param type string The type of the remote being logged (either 'function' or 'event')
--- @param gen_script any
--- @param remote any
--- @param function_info string
--- @param blocked any
function newRemote(type, name, gen_script, remote, function_info, blocked, src)
    local remoteFrame = RemoteTemplate:Clone()
    remoteFrame.Text.Text = name
    remoteFrame.ColorBar.BackgroundColor3 = type == "event" and Color3.new(255, 242, 0) or Color3.fromRGB(99, 86, 245)
    local id = Instance.new("IntValue")
    id.Name = "ID"
    id.Value = #logs + 1
    id.Parent = remoteFrame
    logs[#logs + 1] = {
        Name = name,
        GenScript = gen_script,
        Function = function_info,
        Remote = remote,
        Log = remoteFrame,
        Blocked = blocked,
        Source = src
    }
    if blocked then
        logs[#logs].GenScript = "-- THIS REMOTE WAS PREVENTED FROM FIRING THE SERVER BY SIMPLESPY\n\n" .. logs[#logs].GenScript
    end
    local connect = remoteFrame.Button.MouseButton1Click:Connect(function()
        eventSelect(remoteFrame)
    end)
    if layoutOrderNum < 1 then
        layoutOrderNum = 999999999
    end
    remoteFrame.LayoutOrder = layoutOrderNum
    layoutOrderNum = layoutOrderNum - 1
    remoteFrame.Parent = LogList
    table.insert(remoteLogs, 1, {connect, remoteFrame})
    clean()
    updateRemoteCanvas()
end

--- Generates a script from the provided arguments (first has to be remote path)
function genScript(remote, ...)
    prevTables = {}
    local gen = ""
    local args = {...}
    if #args > 0 then
        if not pcall(function()
                gen = v2v({args = args}) .. "\n"
            end)
        then
            gen = gen .. "-- TableToString failure! Reverting to legacy functionality (results may vary)\nlocal args = {"
            if
                not pcall(
                    function()
                        for i, v in pairs(args) do
                            if type(i) ~= "Instance" and type(i) ~= "userdata" then
                                gen = gen .. "\n    [" .. tostring(i) .. "] = "
                            elseif type(i) == "string" then
                                gen = gen .. '\n    ["' .. tostring(i) .. '"] = '
                            elseif type(i) == "userdata" and typeof(i) ~= "Instance" then
                                gen = gen .. "\n    [" .. typeof(i) .. ".new(" .. tostring(i) .. ")] = "
                            elseif type(i) == "userdata" then
                                gen = gen .. "\n    [game." .. i:GetFullName() .. ")] = "
                            end
                            if type(v) ~= "Instance" and type(v) ~= "userdata" then
                                gen = gen .. tostring(v)
                            elseif type(v) == "string" then
                                gen = gen .. '"' .. tostring(v) .. '"'
                            elseif type(v) == "userdata" and typeof(v) ~= "Instance" then
                                gen = gen .. typeof(v) .. ".new(" .. tostring(v) .. ")"
                            elseif type(v) == "userdata" then
                                gen = gen .. "game." .. v:GetFullName()
                            end
                        end
                        gen = gen .. "\n}\n\n"
                    end
                )
             then
                gen = gen .. "}\n-- Legacy tableToString failure! Unable to decompile."
            end
        end
        if not remote:IsDescendantOf(game) and not getnilrequired then
            gen = "function getNil(name,class) for _,v in pairs(getnilinstances())do if v.ClassName==class and v.Name==name then return v;end end end\n\n" .. gen
        end
        if remote:IsA("RemoteEvent") then
            gen = gen .. v2s(remote) .. ":FireServer(unpack(args))"
        elseif remote:IsA("RemoteFunction") then
            gen = gen .. v2s(remote) .. ":InvokeServer(unpack(args))"
        end
    else
        if remote:IsA("RemoteEvent") then
            gen = gen .. v2s(remote) .. ":FireServer()"
        elseif remote:IsA("RemoteFunction") then
            gen = gen .. v2s(remote) .. ":InvokeServer()"
        end
    end
    gen = "" .. gen
    prevTables = {}
    return gen
end

--- value-to-string: value, string (out), level (indentation), parent table, var name, is from tovar
function v2s(v, l, p, n, vtv, i, pt, path, tables)
    if typeof(v) == "number" then
        if v == math.huge then
            return "math.huge"
        elseif tostring(v):match("nan") then
            return "0/0 --[[NaN]]"
        end
        return tostring(v)
    elseif typeof(v) == "boolean" then
        return tostring(v)
    elseif typeof(v) == "string" then
        return formatstr(v)
    elseif typeof(v) == "function" then
        return f2s(v)
    elseif typeof(v) == "table" then
        return t2s(v, l, p, n, vtv, i, pt, path, tables)
    elseif typeof(v) == "Instance" then
        return i2p(v)
    elseif typeof(v) == "userdata" then
        return "newproxy(true)"
    elseif type(v) == "userdata" then
        return u2s(v)
    else
        return "nil --[[" .. typeof(v) .. "]]"
    end
end

--- value-to-variable
--- @param t any
function v2v(t)
    topstr = ""
    bottomstr = ""
    getnilrequired = false
    local ret = ""
    local count = 1
    for i, v in pairs(t) do
        if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
            ret = ret .. "local " .. i .. " = " .. v2s(v, nil, nil, i, true) .. "\n"
        elseif tostring(i):match("^[%a_]+[%w_]*$") then
            ret = ret .. "local " .. tostring(i):lower() .. "_" .. tostring(count) .. " = " .. v2s(v, nil, nil, tostring(i):lower() .. "_" .. tostring(count), true) .. "\n"
        else
            ret = ret .. "local " .. type(v) .. "_" .. tostring(count) .. " = " .. v2s(v, nil, nil, type(v) .. "_" .. tostring(count), true) .. "\n"
        end
        count = count + 1
    end
    if getnilrequired then
        topstr = "function getNil(name,class) for _,v in pairs(getnilinstances())do if v.ClassName==class and v.Name==name then return v;end end end\n" .. topstr
    end
    if #topstr > 0 then
        ret = topstr .. "\n" .. ret
    end
    if #bottomstr > 0 then
        ret = ret .. bottomstr
    end
    return ret
end

--- table-to-string
--- @param t table
--- @param l number
--- @param p table
--- @param n string
--- @param vtv boolean
--- @param i any
--- @param pt table
--- @param path string
--- @param tables table
function t2s(t, l, p, n, vtv, i, pt, path, tables)
    for k, x in pairs(getrenv()) do
        local isgucci, gpath
        if rawequal(x, t) then
            isgucci, gpath = true, ""
        elseif type(x) == "table" then
            isgucci, gpath = v2p(t, x)
        end
        if isgucci then
            if type(k) == "string" and k:match("^[%a_]+[%w_]*$") then
                return k .. gpath
            else
                return "getrenv()[" .. v2s(k) .. "]" .. gpath
            end
        end
    end
    if not path then
        path = ""
    end
    if not l then
        l = 0
        tables = {}
    end
    if not p then
        p = t
    end
    for _, v in pairs(tables) do
        if n and rawequal(v, t) then
            bottomstr = bottomstr .. "\n" .. tostring(n) .. tostring(path) .. " = " .. tostring(n) .. tostring(({v2p(v, p)})[2])
            return "{} --[[DUPLICATE]]"
        end
    end
    table.insert(tables, t)
    local s =  "{"
    local size = 0
    l = l + indent
    for k, v in pairs(t) do
        size = size + 1
        if size > (_G.SimpleSpyMaxTableSize and _G.SimpleSpyMaxTableSize or 1000) then
            break
        end
        if rawequal(k, t) then
            bottomstr = bottomstr .. "\n" .. tostring(n) .. tostring(path) .. "[" .. tostring(n) .. tostring(path) .. "]" .. " = " .. (v == k and tostring(n) .. tostring(path) or v2s(v, l, p, n, vtv, k, t, path .. "[" .. tostring(n) .. tostring(path) .. "]", tables))
            size -= 1
            continue
        end
        local currentPath = ""
        if type(k) == "string" and k:match("^[%a_]+[%w_]*$") then
            currentPath = "." .. k
        else
            currentPath = "[" .. v2s(k, nil, p, n, vtv, i, pt, path) .. "]"
        end
        s = s .. "\n" .. string.rep(" ", l) .. "[" .. v2s(k, l, p, n, vtv, k, t, path .. currentPath, tables) .. "] = " .. v2s(v, l, p, n, vtv, k, t, path .. currentPath, tables) .. ","
    end
    if #s > 1 then
        s = s:sub(1, #s - 1)
    end
    if size > 0 then
        s = s .. "\n" .. string.rep(" ", l - indent)
    end
    return s .. "}"
end

--- function-to-string
function f2s(f)
    for k, x in pairs(getgenv()) do
        local isgucci, gpath
        if rawequal(x, f) then
            isgucci, gpath = true, ""
        elseif type(x) == "table" then
            isgucci, gpath = v2p(f, x)
        end
        if isgucci then
            if type(k) == "string" and k:match("^[%a_]+[%w_]*$") then
                return k .. gpath
            else
                return "getgenv()[" .. v2s(k) .. "]" .. gpath
            end
        end
    end
    -- uwu some cool stuff here once bork finishes up
    -- if SimpleSpy.GetExternalLoader then
    --     local ExternalLoader = SimpleSpy:GetExternalLoader()
    --     local loaded, path = pcall(function() ExternalLoader:LoadAsset("Bork_Functions") end)
    --     if loaded then
    --         local functions = loadfile(path .. "functions.lua")
    --         local out = functions[f]
    --         if out then
    --             return out
    --         end
    --     end
    -- end
    -- local isgucci, gpath = v2p(f, getgc())
    -- if isgucci then
    --     return "getgc()" .. gpath
    -- end
    if debug.getinfo(f).name:match("^[%a_]+[%w_]*$") then
        return "function()end --[[" .. debug.getinfo(f).name .. "]]"
    end
    return "function()end --[[" .. tostring(f) .. "]]"
end

--- instance-to-path
--- @param i userdata
function i2p(i)
    local player = getplayer(i)
    local parent = i
    local out = ""
    if parent == nil then
        return "nil"
    elseif player then
        while true do
            if parent and parent == player.Character then
                if player == Players.LocalPlayer then
                    return 'game:GetService("Players").LocalPlayer.Character' .. out
                else
                    return i2p(player) .. ".Character" .. out
                end
            else
                if parent.Name:match("[%a_]+[%w+]*") ~= parent.Name then
                    out = '[' .. formatstr(parent.Name) .. ']' .. out
                else
                    out = "." .. parent.Name .. out
                end
            end
            parent = parent.Parent
        end
    elseif parent ~= game then
        while true do
            if parent and parent.Parent == game then
                if game:GetService(parent.ClassName) then
                    if parent.ClassName == "Workspace" then
                        return "workspace" .. out
                    else
                        return 'game:GetService("' .. parent.ClassName .. '")' .. out
                    end
                else
                    if parent.Name:match("[%a_]+[%w_]*") then
                        return "game." .. parent.Name .. out
                    else
                        return 'game[' .. formatstr(parent.Name) .. ']' .. out
                    end
                end
            elseif parent.Parent == nil then
                getnilrequired = true
                return 'getNil(' .. formatstr(parent.Name) .. ', "' .. parent.ClassName .. '")' .. out
            elseif parent == Players.LocalPlayer then
                out = ".LocalPlayer" .. out
            else
                if parent.Name:match("[%a_]+[%w_]*") ~= parent.Name then
                    out = '[' .. formatstr(parent.Name) .. ']' .. out
                else
                    out = "." .. parent.Name .. out
                end
            end
            parent = parent.Parent
        end
    else
        return "game"
    end
end

--- userdata-to-string: userdata
--- @param u userdata
function u2s(u)
    if typeof(u) == "TweenInfo" then
        -- TweenInfo
        return "TweenInfo.new(" ..tostring(u.Time) .. ", Enum.EasingStyle." .. tostring(u.EasingStyle) .. ", Enum.EasingDirection." .. tostring(u.EasingDirection) .. ", " .. tostring(u.RepeatCount) .. ", " .. tostring(u.Reverses) .. ", " .. tostring(u.DelayTime) .. ")"
    elseif typeof(u) == "Ray" then
        -- Ray
        return "Ray.new(" .. u2s(u.Origin) .. ", " .. u2s(u.Direction) .. ")"
    elseif typeof(u) == "NumberSequence" then
        -- NumberSequence
        local ret = "NumberSequence.new("
        for i, v in pairs(u.KeyPoints) do
            ret = ret .. tostring(v)
            if i < #u.Keypoints then
                ret = ret .. ", "
            end
        end
        return ret .. ")"
    elseif typeof(u) == "DockWidgetPluginGuiInfo" then
        -- DockWidgetPluginGuiInfo
        return "DockWidgetPluginGuiInfo.new(Enum.InitialDockState" .. tostring(u) .. ")"
    elseif typeof(u) == "ColorSequence" then
        -- ColorSequence
        local ret = "ColorSequence.new("
        for i, v in pairs(u.KeyPoints) do
            ret = ret .. "Color3.new(" .. tostring(v) .. ")"
            if i < #u.Keypoints then
                ret = ret .. ", "
            end
        end
        return ret .. ")"
    elseif typeof(u) == "BrickColor" then
        -- BrickColor
        return "BrickColor.new(" .. tostring(u.Number) .. ")"
    elseif typeof(u) == "NumberRange" then
        -- NumberRange
        return "NumberRange.new(" .. tostring(u.Min) .. ", " .. tostring(u.Max) .. ")"
    elseif typeof(u) == "Region3" then
        -- Region3
        local center = u.CFrame.Position
        local size = u.CFrame.Size
        local vector1 = center - size / 2
        local vector2 = center + size / 2
        return "Region3.new(" .. u2s(vector1) .. ", " .. u2s(vector2) .. ")"
    elseif typeof(u) == "Faces" then
        -- Faces
        local faces = {}
        if u.Top then
            table.insert(faces, "Enum.NormalId.Top")
        end
        if u.Bottom then
            table.insert(faces, "Enum.NormalId.Bottom")
        end
        if u.Left then
            table.insert(faces, "Enum.NormalId.Left")
        end
        if u.Right then
            table.insert(faces, "Enum.NormalId.Right")
        end
        if u.Back then
            table.insert(faces, "Enum.NormalId.Back")
        end
        if u.Front then
            table.insert(faces, "Enum.NormalId.Front")
        end
        return "Faces.new(" .. table.concat(faces, ", ") .. ")"
    elseif typeof(u) == "EnumItem" then
        return tostring(u)
    elseif typeof(u) == "Enums" then
        return "Enum"
    elseif typeof(u) == "Enum" then
        return "Enum." .. tostring(u)
    elseif typeof(u) == "RBXScriptSignal" then
        return "nil --[[RBXScriptSignal]]"
    elseif typeof(u) == "Vector3" then
        return string.format("Vector3.new(%s, %s, %s)", v2s(u.X), v2s(u.Y), v2s(u.Z))
    elseif typeof(u) == "CFrame" then
        return string.format("CFrame.new(%s, %s)", v2s(u.Position), v2s(u.LookVector))
    elseif typeof(u) == "DockWidgetPluginGuiInfo" then
        return string.format("DockWidgetPluginGuiInfo(%s, %s, %s, %s, %s, %s, %s)", "Enum.InitialDockState.Right", v2s(u.InitialEnabled), v2s(u.InitialEnabledShouldOverrideRestore), v2s(u.FloatingXSize), v2s(u.FloatingYSize), v2s(u.MinWidth), v2s(u.MinHeight))
    elseif typeof(u) == "RBXScriptConnection" then
        return "nil --[[RBXScriptConnection " .. tostring(u) .. "]]"
    elseif typeof(u) == "RaycastResult" then
        return "nil --[[RaycastResult " .. tostring(u) .. "]]"
    elseif typeof(u) == "PathWaypoint" then
        return string.format("PathWaypoint.new(%s, %s)", v2s(u.Position), v2s(u.Action))
    else
        return typeof(u) .. ".new(" .. tostring(u) .. ")"
    end
end

--- Gets the player an instance is descended from
function getplayer(instance)
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and (instance:IsDescendantOf(v.Character) or instance == v.Character) then
            return v
        end
    end
end

--- value-to-path (in table)
function v2p(x, t, path, prev)
    if not path then
        path = ""
    end
    if not prev then
        prev = {}
    end
    if rawequal(x, t) then
        return true, ""
    end
    for i, v in pairs(t) do
        if rawequal(v, x) then
            if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
                return true, (path .. "." .. i)
            else
                return true, (path .. "[" .. v2s(i) .. "]")
            end
        end
        if type(v) == "table" then
            local duplicate = false
            for _, y in pairs(prev) do
                if rawequal(y, v) then
                    duplicate = true
                end
            end
            if not duplicate then
                table.insert(prev, t)
                local found
                found, p = v2p(x, v, path, prev)
                if found then
                    if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
                        return true, "." .. i .. p
                    else
                        return true, "[" .. v2s(i) .. "]" .. p
                    end
                end
            end
        end
    end
    return false, ""
end

--- format s: string, byte encrypt (for weird symbols)
function formatstr(s)
    return '"' .. handlespecials(s) .. '"'
end

--- Adds \'s to the text as a replacement to whitespace chars and other things because string.format can't yayeet
function handlespecials(s)
    local i = 0
    repeat
        i = i + 1
        local char = s:sub(i, i)
        if string.byte(char) then
            if char == "\n" then
                s = s:sub(0, i - 1) .. "\\n" .. s:sub(i + 1, -1)
                i = i + 1
            elseif char == "\t" then
                s = s:sub(0, i - 1) .. "\\t" .. s:sub(i + 1, -1)
                i = i + 1
            elseif char == "\\" then
                s = s:sub(0, i - 1) .. "\\\\" .. s:sub(i + 1, -1)
                i = i + 1
            elseif char == '"' then
                s = s:sub(0, i - 1) .. '\\"' .. s:sub(i + 1, -1)
                i = i + 1
            elseif string.byte(char) > 126 or string.byte(char) < 32 then
                s = s:sub(0, i - 1) .. "\\" .. string.byte(char) .. s:sub(i + 1, -1)
                i = i + #tostring(string.byte(char))
            end
        end
    until char == ""
    return s
end

--- finds script from 'src' from getinfo, returns nil if not found
--- @param src string
function getScriptFromSrc(src)
    local realPath
    local runningTest
    --- @type number
    local s, e
    local match = false
    if src:sub(1, 1) == "=" then
        realPath = game
        s = 2
    else
        runningTest = src:sub(2, e and e - 1 or -1)
        for _, v in pairs(getnilinstances()) do
            if v.Name == runningTest then
                realPath = v
                break
            end
        end
        s = #runningTest + 1
    end
    if realPath then
        e = src:sub(s, -1):find("%.")
        local i = 0
        repeat
            i += 1
            if not e then
                runningTest = src:sub(s, -1)
                local test = realPath.FindFirstChild(realPath, runningTest)
                if test then
                    realPath = test
                end
                match = true
            else
                runningTest = src:sub(s, e)
                local test = realPath.FindFirstChild(realPath, runningTest)
                local yeOld = e
                if test then
                    realPath = test
                    s = e + 2
                    e = src:sub(e + 2, -1):find("%.")
                    e = e and e + yeOld or e
                else
                    e = src:sub(e + 2, -1):find("%.")
                    e = e and e + yeOld or e
                end
            end
        until match or i >= 50
    end
    return realPath
end

--- schedules the provided function (and calls it with any args after)
function schedule(f, ...)
    table.insert(scheduled, {f, ...})
end

--- the big (well tbh small now) boi task scheduler himself, handles p much anything as quicc as possible
function taskscheduler()
    if not toggle then
        scheduled = {}
        return
    end
    if #scheduled > 1000 then
        table.remove(scheduled, #scheduled)
    end
    if #scheduled > 0 then
        local currentf = scheduled[1]
        table.remove(scheduled, 1)
        if type(currentf) == "table" and type(currentf[1]) == "function" then
            pcall(unpack(currentf))
        end
    end
end

--- Handles remote logs
function remoteHandler(hookfunction, methodName, remote, args, func, calling)
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        if funcEnabled and not calling then
            _, calling = pcall(getScriptFromSrc, debug.getinfo(func).source)
        end
        coroutine.wrap(function()
            if remoteSignals[remote] then
                remoteSignals[remote]:Fire(args)
            end
        end)()
        if autoblock then
            if excluding[remote] then
                return
            end
            if not history[remote] then
                history[remote] = {badOccurances = 0, lastCall = tick()}
            end
            if tick() - history[remote].lastCall < 1 then
                history[remote].badOccurances += 1
                return
            else
                history[remote].badOccurances = 0
            end
            if history[remote].badOccurances > 3 then
                excluding[remote] = true
                return
            end
            history[remote].lastCall = tick()
        end
        local functionInfoStr
        local src
        if func and islclosure(func) then
            local functionInfo = {}
            pcall(function() functionInfo.info = debug.getinfo(func) end)
            pcall(function() functionInfo.constants = debug.getconstants(func) end)
            pcall(function() functionInfoStr = v2v{functionInfo = functionInfo} end)
            pcall(function() if type(calling) == "userdata" then src = calling end end)
        end
        if methodName:lower() == "fireserver" then
            newRemote("event", remote.Name, genScript(remote, table.unpack(args)), remote, functionInfoStr, (blocklist[remote] or blocklist[remote.Name]), src)
        elseif methodName:lower() == "invokeserver" then
            newRemote("function", remote.Name, genScript(remote, table.unpack(args)), remote, functionInfoStr, (blocklist[remote] or blocklist[remote.Name]), src)
        end
    end
end

--- Used for hookfunction
function hookRemote(remoteType, remote, ...)
    local args = {...}
    if remoteHooks[remote] then
        args = remoteHooks[remote](args)
    end
    if typeof(remote) == "Instance" and not (blacklist[remote] or blacklist[remote.Name]) then
        local func
        local calling
        if funcEnabled then
            func = debug.getinfo(4).func
            calling = useGetCallingScript and getcallingscript() or nil
        end
        schedule(remoteHandler, true, remoteType == "RemoteEvent" and "fireserver" or "invokeserver", remote, args, func, calling)
        if (blocklist[remote] or blocklist[remote.Name]) then
            return
        end
    end
    if remoteType == "RemoteEvent" then
        if remoteHooks[remote] then
            return originalEvent(remote, unpack(args))
        end
        return originalEvent(remote, ...)
    else
        if remoteHooks[remote] then
            return originalFunction(remote, unpack(args))
        end
        return originalFunction(remote, ...)
    end
end

local newnamecall = newcclosure(function(...)
    local args = {...}
    local methodName = getnamecallmethod()
    local remote = args[1]
    if (methodName:lower() == "invokeserver" or methodName:lower() == "fireserver") and not (blacklist[remote] or blacklist[remote.Name]) then
        if remoteHooks[remote] then
            args = remoteHooks[remote]({args, unpack(args, 2)})
        end
        local func
        local calling
        if funcEnabled then
            func = debug.getinfo(3).func
            calling = useGetCallingScript and getcallingscript() or nil
        end
        coroutine.wrap(function()
            schedule(remoteHandler, false, methodName, remote, {unpack(args, 2)}, func, calling)
        end)()
    end
    if typeof(remote) == "Instance" and (methodName:lower() == "invokeserver" or methodName:lower() == "fireserver") and (blocklist[remote] or blocklist[remote.Name]) then
        return nil
    elseif (methodName:lower() == "invokeserver" or methodName:lower() == "fireserver") and remoteHooks[remote] then
        return original(unpack(args))
    else
        return original(...)
    end
end)

local newFireServer = newcclosure(function(...) return hookRemote("RemoteEvent", ...) end)

local newInvokeServer = newcclosure(function(...) return hookRemote("RemoteFunction", ...) end)

--- Toggles on and off the remote spy
function toggleSpy()
    if not toggle then
        setreadonly(gm, false)
        if not original then
            original = gm.__namecall
            if not original then
                warn("SimpleSpy: namecall method not found!\n")
                onToggleButtonClick()
                return
            end
        end
        gm.__namecall = newnamecall
        originalEvent = hookfunction(remoteEvent.FireServer, newFireServer)
        originalFunction = hookfunction(remoteFunction.InvokeServer, newInvokeServer)
    else
        setreadonly(gm, false)
        gm.__namecall = original
        hookfunction(remoteEvent.FireServer, originalEvent)
        hookfunction(remoteFunction.InvokeServer, originalFunction)
    end
end

--- Toggles between the two remotespy methods (hookfunction currently = disabled)
function toggleSpyMethod()
    toggleSpy()
    toggle = not toggle
end

--- Shuts down the remote spy
function shutdown()
    if schedulerconnect then
        schedulerconnect:Disconnect()
    end
    for _, connection in pairs(connections) do
        coroutine.wrap(function()
            connection:Disconnect()
        end)()
    end
    setreadonly(gm, false)
    SimpleSpy2:Destroy()
    hookfunction(remoteEvent.FireServer, originalEvent)
    hookfunction(remoteFunction.InvokeServer, originalFunction)
    gm.__namecall = original
    _G.SimpleSpyExecuted = false
end

-- main
if not _G.SimpleSpyExecuted then
    local succeeded, err = pcall(function()
        _G.SimpleSpyShutdown = shutdown
        ContentProvider:PreloadAsync({"rbxassetid://6065821980", "rbxassetid://6065774948", "rbxassetid://6065821086", "rbxassetid://6065821596", ImageLabel, ImageLabel_2, ImageLabel_3})
        onToggleButtonClick()
        RemoteTemplate.Parent = nil
        FunctionTemplate.Parent = nil
        codebox = Highlight.new(CodeBox)
        codebox:setRaw("")
        getgenv().SimpleSpy = SimpleSpy
        TextLabel:GetPropertyChangedSignal("Text"):Connect(scaleToolTip)
        TopBar.InputBegan:Connect(onBarInput)
        MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
        MaximizeButton.MouseButton1Click:Connect(toggleSideTray)
        Simple.MouseButton1Click:Connect(onToggleButtonClick)
        CloseButton.MouseEnter:Connect(onXButtonHover)
        CloseButton.MouseLeave:Connect(onXButtonUnhover)
        Simple.MouseEnter:Connect(onToggleButtonHover)
        Simple.MouseLeave:Connect(onToggleButtonUnhover)
        CloseButton.MouseButton1Click:Connect(shutdown)
        table.insert(connections, UserInputService.InputBegan:Connect(backgroundUserInput))
        table.insert(connections, Mouse.Move:Connect(mouseMoved))
        connectResize()
        SimpleSpy2.Enabled = true
        coroutine.wrap(function()
            wait(1)
            onToggleButtonUnhover()
        end)()
        schedulerconnect = RunService.Heartbeat:Connect(taskscheduler)
        if syn and syn.protect_gui then pcall(syn.protect_gui, SimpleSpy2) end
        SimpleSpy2.Parent = gethui and gethui() or CoreGui
    end)
    if succeeded then
        _G.SimpleSpyExecuted = true
    else
        warn("A fatal error has occured, SimpleSpy was unable to launch properly.\nPlease DM this error message to @exx#9394:\n\n" .. tostring(err))
        SimpleSpy2:Destroy()
        hookfunction(remoteEvent.FireServer, originalEvent)
        hookfunction(remoteFunction.InvokeServer, originalFunction)
        gm.__namecall = original
        return
    end
else
    SimpleSpy2:Destroy()
    return
end

----- ADD ONS ----- (easily add or remove additonal functionality to the RemoteSpy!)
--[[
    Some helpful things:
        - add your function in here, and create buttons for them through the 'newButton' function
        - the first argument provided is the TextButton the player clicks to run the function
        - generated scripts are generated when the namecall is initially fired and saved in remoteFrame objects
        - blacklisted remotes will be ignored directly in namecall (less lag)
        - the properties of a 'remoteFrame' object:
            {
                Name: (string) The name of the Remote
                GenScript: (string) The generated script that appears in the codebox (generated when namecall fired)
                Source: (Instance (LocalScript)) The script that fired/invoked the remote
                Remote: (Instance (RemoteEvent) | Instance (RemoteFunction)) The remote that was fired/invoked
                Log: (Instance (TextButton)) The button being used for the remote (same as 'selected.Log')
            }
        - globals list: (contact @exx#9394 for more information or if you have suggestions for more to be added)
            - closed: (boolean) whether or not the GUI is currently minimized
            - logs: (table[remoteFrame]) full of remoteFrame objects (properties listed above)
            - selected: (remoteFrame) the currently selected remoteFrame (properties listed above)
            - blacklist: (string[] | Instance[] (RemoteEvent) | Instance[] (RemoteFunction)) an array of blacklisted names and remotes
            - codebox: (Instance (TextBox)) the textbox that holds all the code- cleared often
]]
-- Copies the contents of the codebox
newButton(
    "Copy Code",
    function() return "Click to copy code" end,
    function()
        setclipboard(codebox:getString())
        TextLabel.Text = "Copied successfully!"
    end
)

--- Copies the source script (that fired the remote)
newButton(
    "Copy Remote",
    function() return "Click to copy the path of the remote" end,
    function()
        if selected then
            setclipboard(v2s(selected.Remote))
            TextLabel.Text = "Copied!"
        end
    end
)

-- Executes the contents of the codebox through loadstring
newButton(
    "Run Code",
    function() return "Click to execute code" end,
    function()
        local orText = "Click to execute code"
        TextLabel.Text = "Executing..."
        local succeeded = pcall(function() return loadstring(codebox:getString())() end)
        if succeeded then
            TextLabel.Text = "Executed successfully!"
        else
            TextLabel.Text = "Execution error!"
        end
    end
)

--- Gets the calling script (not super reliable but w/e)
newButton(
    "Get Script",
    function() return "Click to copy calling script to clipboard\nWARNING: Not super reliable, nil == could not find" end,
    function()
        if selected then
            setclipboard(SimpleSpy:ValueToString(selected.Source))
            TextLabel.Text = "Done!"
        end
    end
)

--- Decompiles the script that fired the remote and puts it in the code box
newButton(
    "Function Info",
    function() return "Click to view calling function information" end,
    function()
        if selected then
            if selected.Function then
                codebox:setRaw("-- Calling function info\n-- Generated by the SimpleSpy serializer\n\n" .. tostring(selected.Function))
            end
            TextLabel.Text = "Done! Function info generated by the SimpleSpy Serializer."
        end
    end
)

--- Clears the Remote logs
newButton(
    "Clr Logs",
    function() return "Click to clear logs" end,
    function()
        TextLabel.Text = "Clearing..."
        logs = {}
        for _, v in pairs(LogList:GetChildren()) do
            if not v:IsA("UIListLayout") then
                v:Destroy()
            end
        end
        codebox:setRaw("")
        selected = nil
        TextLabel.Text = "Logs cleared!"
    end
)

--- Excludes the selected.Log Remote from the RemoteSpy
newButton(
    "Exclude (i)",
    function() return "Click to exclude this Remote" end,
    function()
        if selected then
            blacklist[selected.Remote] = true
            TextLabel.Text = "Excluded!"
        end
    end
)

--- Excludes all Remotes that share the same name as the selected.Log remote from the RemoteSpy
newButton(
    "Exclude (n)",
    function() return "Click to exclude all remotes with this name" end,
    function()
        if selected then
            blacklist[selected.Name] = true
            TextLabel.Text = "Excluded!"
        end
    end
)

--- clears blacklist
newButton(
    "Clr Blacklist",
    function() return "Click to clear the blacklist" end,
    function()
        blacklist = {}
        TextLabel.Text = "Blacklist cleared!"
    end
)

--- Prevents the selected.Log Remote from firing the server (still logged)
newButton(
    "Block (i)",
    function() return "Click to stop this remote from firing" end,
    function()
        if selected then
            blocklist[selected.Remote] = true
            TextLabel.Text = "Excluded!"
        end
    end
)

--- Prevents all remotes from firing that share the same name as the selected.Log remote from the RemoteSpy (still logged)
newButton(
    "Block (n)",
    function() return "Click to stop remotes with this name from firing" end,
    function()
        if selected then
            blocklist[selected.Name] = true
            TextLabel.Text = "Excluded!"
        end
    end
)

--- clears blacklist
newButton(
    "Clr Blocklist",
    function() return "Click to stop blocking remotes" end,
    function()
        blocklist = {}
        TextLabel.Text = "Blocklist cleared!"
    end
)

--- Attempts to decompile the source script
newButton(
    "Decompile",
    function() return "Attempts to decompile source script\nWARNING: Not super reliable, nil == could not find" end,
    function()
        if selected then
            if selected.Source then
                codebox:setRaw(decompile(selected.Source))
                TextLabel.Text = "Done!"
            else
                TextLabel.Text = "Source not found!"
            end
        end
    end
)

newButton(
    "Disable Info",
    function() return string.format("[%s] Toggle function info (because it can cause lag in some games)", funcEnabled and "ENABLED" or "DISABLED") end,
    function()
        funcEnabled = not funcEnabled
        TextLabel.Text = string.format("[%s] Toggle function info (because it can cause lag in some games)", funcEnabled and "ENABLED" or "DISABLED")
    end
)

newButton(
    "Autoblock",
    function() return string.format("[%s] [BETA] Intelligently detects and excludes spammy remote calls from logs", autoblock and "ENABLED" or "DISABLED") end,
    function()
        autoblock = not autoblock
        TextLabel.Text = string.format("[%s] [BETA] Intelligently detects and excludes spammy remote calls from logs", autoblock and "ENABLED" or "DISABLED")
        history = {}
        excluding = {}
    end
)

newButton(
    "CallingScript",
    function() return string.format("[%s] [UNSAFE] Uses 'getcallingscript' to get calling script for Decompile and GetScript. Much more reliable, but opens up SimpleSpy to detection and/or instability.", useGetCallingScript and "ENABLED" or "DISABLED") end,
    function()
        useGetCallingScript = not useGetCallingScript
        TextLabel.Text = string.format("[%s] [UNSAFE] Uses 'getcallingscript' to get calling script for Decompile and GetScript. Much more reliable, but opens up SimpleSpy to detection and/or instability.", useGetCallingScript and "ENABLED" or "DISABLED")
    end
)
              print("Executed!")
      end
})

ScriptTab:AddButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
              print("Executed!")
      end
})

-- Game modes

local ModesTab = Window:MakeTab({
	Name = "Game modes",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

ModesTab:AddButton({
    Name = "Impossible Mode",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Ukazix/impossible-mode/main/Protected_79.lua.txt'))()
              print("Executed!")
      end
})

-- Entity Spawner

local SpawnerTab = Window:MakeTab({
	Name = "Entity Spawner",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

SpawnerTab:AddParagraph("silly little note","All entities are created using RegularVynixu's entity spawner!")

local Section = SpawnerTab:AddSection({
	Name = "Items"
})

SpawnerTab:AddButton({
    Name = "Give Crucifix",
    Callback = function()
        _G.Uses = 1 
_G.Range = 30 
_G.OnClick = false 
_G.Variant = "Normal" 
loadstring(game:HttpGet('https://raw.githubusercontent.com/PenguinManiack/Crucifix/main/Crucifix.lua'))() 
              print("Executed!")
      end
})

SpawnerTab:AddButton({
    Name = "Give Crucifix (Infinite Use)",
    Callback = function()
        _G.Uses = math.huge
_G.Range = 30
_G.OnClick = false 
_G.Variant = "Normal"
loadstring(game:HttpGet('https://raw.githubusercontent.com/PenguinManiack/Crucifix/main/Crucifix.lua'))() 
              print("Executed!")
      end
})

SpawnerTab:AddButton({
    Name = "Give Crucifix (Infinite Range)",
    Callback = function()
        _G.Uses = 1
_G.Range = math.huge
_G.OnClick = false 
_G.Variant = "Normal"
loadstring(game:HttpGet('https://raw.githubusercontent.com/PenguinManiack/Crucifix/main/Crucifix.lua'))() 
              print("Executed!")
      end
})

SpawnerTab:AddButton({
    Name = "Give Crucifix (Infinite Use + Range)",
    Callback = function()
        _G.Uses = math.huge 
_G.Range = math.huge 
_G.OnClick = false 
_G.Variant = "Normal"
loadstring(game:HttpGet('https://raw.githubusercontent.com/PenguinManiack/Crucifix/main/Crucifix.lua'))() 
              print("Executed!")
      end
})

SpawnerTab:AddButton({
    Name = "Remove Items",
    Callback = function()
-- Get the player whose inventory you want to clear
local player = game.Players.LocalPlayer

-- Get the player's character
local character = player.Character or player.CharacterAdded:Wait()

-- Get the player's backpack
local backpack = player.Backpack

-- Clear the player's backpack
for _, item in pairs(backpack:GetChildren()) do
    item:Destroy()
end

-- Clear the player's character
for _, item in pairs(character:GetChildren()) do
    if item:IsA("Tool") or item:IsA("Accessory") then
        item:Destroy()
    end
end   
              print("Items Removed!")
      end
})

local Section = SpawnerTab:AddSection({
	Name = "Official Entities"
})

SpawnerTab:AddButton({
    Name = "Spawn Rush",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

        -- Create entity
        local entity = Creator.createEntity({
            CustomName = "Rush", -- Custom name of your entity
            Model = "https://github.com/Johnny39871/assets/blob/main/Rush.rbxm?raw=true", -- Can be GitHub file or rbxassetid
            Speed = 100, -- Percentage, 100 = default Rush speed
            DelayTime = 2, -- Time before starting cycles (seconds)
            HeightOffset = 0,
            CanKill = false,
            KillRange = 25,
            BreakLights = true,
            BackwardsMovement = false,
            FlickerLights = {
                true, -- Enabled/Disabled
                1, -- Time (seconds)
            },
            Cycles = {
                Min = 1,
                Max = 1,
                WaitTime = 2,
            },
            CamShake = {
                true, -- Enabled/Disabled
                {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
                100, -- Shake start distance (from Entity to you)
            },
            Jumpscare = {
                true, -- Enabled/Disabled
                {
                    Image1 = "rbxassetid://10483855823", -- Image1 url
                    Image2 = "rbxassetid://10483999903", -- Image2 url
                    Shake = true,
                    Sound1 = {
                        10483790459, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Sound2 = {
                        10483837590, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Flashing = {
                        true, -- Enabled/Disabled
                        Color3.fromRGB(0, 0, 255), -- Color
                    },
                    Tease = {
                        true, -- Enabled/Disabled
                        Min = 4,
                        Max = 4,
                    },
                },
            },
        })
        
        -----[[ Advanced ]]-----
        entity.Debug.OnEntitySpawned = function(entityTable)
            print("Entity has spawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityDespawned = function(entityTable)
            print("Entity has despawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityStartMoving = function(entityTable)
            print("Entity has started moving:", entityTable.Model)
        end
        
        entity.Debug.OnEntityFinishedRebound = function(entityTable)
            print("Entity has finished rebound:", entityTable.Model)
        end
        
        entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
            print("Entity:", entityTable.Model, "has entered room:", room)
        end
        
        entity.Debug.OnLookAtEntity = function(entityTable)
            print("Player has looked at entity:", entityTable.Model)
        end
        
        entity.Debug.OnDeath = function(entityTable)
            warn("Player has died.")
        end
        ------------------------
        
        -- Run the created entity
        Creator.runEntity(entity)
        
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Ambush",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

        -- Create entity
        local entity = Creator.createEntity({
            CustomName = "Ambush", -- Custom name of your entity
            Model = "rbxassetid://11652567875", -- Can be GitHub file or rbxassetid
            Speed = 200, -- Percentage, 100 = default Rush speed
            DelayTime = 2, -- Time before starting cycles (seconds)
            HeightOffset = -2,
            CanKill = false,
            KillRange = 25,
            BreakLights = true,
            BackwardsMovement = false,
            FlickerLights = {
                true, -- Enabled/Disabled
                1, -- Time (seconds)
            },
            Cycles = {
                Min = 2,
                Max = 5,
                WaitTime = 2,
            },
            CamShake = {
                true, -- Enabled/Disabled
                {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
                100, -- Shake start distance (from Entity to you)
            },
            Jumpscare = {
                true, -- Enabled/Disabled
                {
                    Image1 = "rbxassetid://10483855823", -- Image1 url
                    Image2 = "rbxassetid://10483999903", -- Image2 url
                    Shake = true,
                    Sound1 = {
                        10483790459, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Sound2 = {
                        10483837590, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Flashing = {
                        true, -- Enabled/Disabled
                        Color3.fromRGB(0, 0, 255), -- Color
                    },
                    Tease = {
                        true, -- Enabled/Disabled
                        Min = 4,
                        Max = 4,
                    },
                },
            },
        })
        
        -----[[ Advanced ]]-----
        entity.Debug.OnEntitySpawned = function(entityTable)
            print("Entity has spawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityDespawned = function(entityTable)
            print("Entity has despawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityStartMoving = function(entityTable)
            print("Entity has started moving:", entityTable.Model)
        end
        
        entity.Debug.OnEntityFinishedRebound = function(entityTable)
            print("Entity has finished rebound:", entityTable.Model)
        end
        
        entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
            print("Entity:", entityTable.Model, "has entered room:", room)
        end
        
        entity.Debug.OnLookAtEntity = function(entityTable)
            print("Player has looked at entity:", entityTable.Model)
        end
        
        entity.Debug.OnDeath = function(entityTable)
            warn("Player has died.")
        end
        ------------------------
        
        -- Run the created entity
        Creator.runEntity(entity)
        
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Halt",
    Callback = function ()
        local Data = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
        require(game.ReplicatedStorage.ClientModules.EntityModules.Shade).stuff(Data, workspace.CurrentRooms[tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)])
    
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Eyes (Does Damage)",
    Callback = function ()
        local EntitySpawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/dreadmania/Scripts/main/Spawner_V2.lua"))()
local Configuration = {
    Damage = 10, -- change to "Damage = 10," for eyes, doesnt work on other entities
    Speed = 160, -- 60 for rush, doesnt work on other entities
    Time = 3 -- 5 for rush, doesnt work on other entities
}
 
EntitySpawner:Spawn("Eyes", Configuration)
    
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Eyes",
    Callback = function ()
        local EntitySpawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/dreadmania/Scripts/main/Spawner_V2.lua"))()
local Configuration = {
    Damage = 0, -- change to "Damage = 10," for eyes, doesnt work on other entities
    Speed = 160, -- 60 for rush, doesnt work on other entities
    Time = 3 -- 5 for rush, doesnt work on other entities
}
 
EntitySpawner:Spawn("Eyes", Configuration)
    
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Glitch",
    Callback = function ()
        local Data = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
        require(game.ReplicatedStorage.ClientModules.EntityModules.Glitch).stuff(Data, workspace.CurrentRooms[tostring(game.ReplicatedStorage.GameData.LatestRoom.Value)])
    
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Screech",
    Callback = function ()
        require(game.StarterGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.Screech)(require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game),
    workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")])
    
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Timothy",
    Callback = function ()
        local a = game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game
        require(a.RemoteListener.Modules.SpiderJumpscare)(require(a), workspace.CurrentRooms["0"].Assets.Dresser.DrawerContainer, 0.2)
    
    end
})

local Section = SpawnerTab:AddSection({
	Name = "Rooms Entities"
})

SpawnerTab:AddButton({
    Name = "Spawn A-60", 
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

-- Create entity
local entity = Creator.createEntity({
    CustomName = "A-60", -- Custom name of your entity
    Model = "https://github.com/plamen6789/CustomDoorsMonsters/blob/main/A-60.rbxm?raw=true", -- Can be GitHub file or rbxassetid
    Speed = 300, -- Percentage, 100 = default Rush speed
    DelayTime = 1, -- Time before starting cycles (seconds)
    HeightOffset = 0,
    CanKill = false,
    KillRange = 50,
    BreakLights = false,
    BackwardsMovement = false,
    FlickerLights = {
        true, -- Enabled/Disabled
        2, -- Time (seconds)
    },
    Cycles = {
        Min = 3,
        Max = 3,
        WaitTime = 5,
    },
    CamShake = {
        true, -- Enabled/Disabled
        {30, 30, 0.1, 1}, -- Shake values (don't change if you don't know)
        50, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
        false, -- Enabled/Disabled
        {
            Image1 = "rbxassetid://11394048190", -- Image1 url
            Image2 = "rbxassetid://11394048190", -- Image2 url
            Shake = true,
            Sound1 = {
                10483790459, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Sound2 = {
                10483837590, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Flashing = {
                true, -- Enabled/Disabled
                Color3.fromRGB(255, 0, 0), -- Color
            },
            Tease = {
                false, -- Enabled/Disabled
                Min = 1,
                Max = 1,
            },
        },
    },
    CustomDialog = {"You died to A-60", "It can Apear at any moment, a loud scream will anounce its presence", "When you hear it spawn you must stay out of its reach as soon as possible", "It knows exactly where you are so hiding in different places will not work.."}, -- Custom death message
})

-----[[ Advanced ]]-----
entity.Debug.OnEntitySpawned = function(entityTable)
    print("Entity has spawned:", entityTable.Model)
end

entity.Debug.OnEntityDespawned = function(entityTable)
    print("Entity has despawned:", entityTable.Model)
end

entity.Debug.OnEntityStartMoving = function(entityTable)
    print("Entity has started moving:", entityTable.Model)
end

entity.Debug.OnEntityFinishedRebound = function(entityTable)
    print("Entity has finished rebound:", entityTable.Model)
end

entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
    print("Entity:", entityTable.Model, "has entered room:", room)
end

entity.Debug.OnLookAtEntity = function(entityTable)
    print("Player has looked at entity:", entityTable.Model)
end

entity.Debug.OnDeath = function(entityTable)
    warn("Player has died.")
end
------------------------

-- Run the created entity
Creator.runEntity(entity)

    end
})

SpawnerTab:AddButton({
    Name = "Spawn Old A-60", 
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

-- Create entity
local entity = Creator.createEntity({
    CustomName = "Old A-60", -- Custom name of your entity
    Model = "rbxassetid://11573495258", -- Can be GitHub file or rbxassetid
    Speed = 300, -- Percentage, 100 = default Rush speed
    DelayTime = 1, -- Time before starting cycles (seconds)
    HeightOffset = 0,
    CanKill = false,
    KillRange = 50,
    BreakLights = false,
    BackwardsMovement = false,
    FlickerLights = {
        true, -- Enabled/Disabled
        2, -- Time (seconds)
    },
    Cycles = {
        Min = 3,
        Max = 3,
        WaitTime = 5,
    },
    CamShake = {
        false, -- Enabled/Disabled
        {30, 30, 0.1, 1}, -- Shake values (don't change if you don't know)
        50, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
        false, -- Enabled/Disabled
        {
            Image1 = "rbxassetid://11394048190", -- Image1 url
            Image2 = "rbxassetid://11394048190", -- Image2 url
            Shake = true,
            Sound1 = {
                10483790459, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Sound2 = {
                10483837590, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Flashing = {
                false, -- Enabled/Disabled
                Color3.fromRGB(255, 0, 0), -- Color
            },
            Tease = {
                false, -- Enabled/Disabled
                Min = 1,
                Max = 1,
            },
        },
    },
    CustomDialog = {"You died to A-60", "It can Apear at any moment, a loud scream will anounce its presence", "When you hear it spawn you must stay out of its reach as soon as possible", "It knows exactly where you are so hiding in different places will not work.."}, -- Custom death message
})

-----[[ Advanced ]]-----
entity.Debug.OnEntitySpawned = function(entityTable)
    print("Entity has spawned:", entityTable.Model)
end

entity.Debug.OnEntityDespawned = function(entityTable)
    print("Entity has despawned:", entityTable.Model)
end

entity.Debug.OnEntityStartMoving = function(entityTable)
    print("Entity has started moving:", entityTable.Model)
end

entity.Debug.OnEntityFinishedRebound = function(entityTable)
    print("Entity has finished rebound:", entityTable.Model)
end

entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
    print("Entity:", entityTable.Model, "has entered room:", room)
end

entity.Debug.OnLookAtEntity = function(entityTable)
    print("Player has looked at entity:", entityTable.Model)
end

entity.Debug.OnDeath = function(entityTable)
    warn("Player has died.")
end
------------------------

-- Run the created entity
Creator.runEntity(entity)

    end
})

local Section = SpawnerTab:AddSection({
	Name = "Interminable Rooms Entities"
})

SpawnerTab:AddButton({
    Name = "Spawn A-10",
    Callback = function()
        local Spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()


-- Create entity
local entityTable = Spawner.createEntity({
    CustomName = "A-10", -- Custom name of your entity
    Model = "rbxassetid://12734803521", -- Can be GitHub file or rbxassetid
    Speed = 120, -- Percentage, 100 = default Rush speed
    DelayTime = 2, -- Time before starting cycles (seconds)
    HeightOffset = 0,
    CanKill = false,
    KillRange = 50,
    BackwardsMovement = false,
    BreakLights = false,
    FlickerLights = {
        false, -- Enabled/Disabled
        1, -- Time (seconds)
    },
    Cycles = {
        Min = 1,
        Max = 1,
        WaitTime = 2,
    },
    CamShake = {
        true, -- Enabled/Disabled
        {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
        10000, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
        true, -- Enabled/Disabled
        {
            Image1 = "rbxassetid://12925871998", -- Image1 url
            Image2 = "rbxassetid://12925871998", -- Image2 url
            Shake = true,
            Sound1 = {
                4125132551, -- SoundId
                { Volume = 2 }, -- Sound properties
            },
            Sound2 = {
                5113681699, -- SoundId
                { Volume = 1 }, -- Sound properties
            },
            Flashing = {
                true, -- Enabled/Disabled
                Color3.fromRGB(1, 1, 1),
            },
            Tease = {
                false, -- Enabled/Disabled
                Min = 1,
                Max = 1,
            },
        },
    },
    CustomDialog = {"You Died To A-10"}, -- Custom death message
})


-----[[  Debug -=- Advanced  ]]-----
entityTable.Debug.OnEntitySpawned = function()
    print("Entity has spawned:", entityTable)
end

entityTable.Debug.OnEntityDespawned = function()
    print("Entity has despawned:", entityTable)
end

entityTable.Debug.OnEntityStartMoving = function()
    print("Entity has started moving:", entityTable)
end

entityTable.Debug.OnEntityFinishedRebound = function()
    print("Entity has finished rebound:", entityTable)
end

entityTable.Debug.OnEntityEnteredRoom = function(room)
    print("Entity:", entityTable, "has entered room:", room)
end

entityTable.Debug.OnLookAtEntity = function()
    print("Player has looked at entity:", entityTable)
end

entityTable.Debug.OnDeath = function()
    warn("Player has died.")
end
------------------------------------


-- Run the created entity
Spawner.runEntity(entityTable)
              print("Executed!")
      end
})

SpawnerTab:AddButton({
    Name = "Spawn A-60",
    Callback = function()
        local Spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()


-- Create entity
local entityTable = Spawner.createEntity({
    CustomName = "A-60", -- Custom name of your entity
    Model = "rbxassetid://12661587186", -- Can be GitHub file or rbxassetid
    Speed = 200, -- Percentage, 100 = default Rush speed
    DelayTime = 2, -- Time before starting cycles (seconds)
    HeightOffset = 0,
    CanKill = false,
    KillRange = 50,
    BackwardsMovement = false,
    BreakLights = false,
    FlickerLights = {
        false, -- Enabled/Disabled
        1, -- Time (seconds)
    },
    Cycles = {
        Min = 1,
        Max = 3,
        WaitTime = 10,
    },
    CamShake = {
        true, -- Enabled/Disabled
        {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
        10000, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
        true, -- Enabled/Disabled
        {
            Image1 = "rbxassetid://13218423706", -- Image1 url
            Image2 = "rbxassetid://13218423706", -- Image2 url
            Shake = true,
            Sound1 = {
                9125351901, -- SoundId
                { Volume = 2 }, -- Sound properties
            },
            Sound2 = {
                9125351901, -- SoundId
                { Volume = 1 }, -- Sound properties
            },
            Flashing = {
                true, -- Enabled/Disabled
                Color3.fromRGB(1, 1, 1),
            },
            Tease = {
                false, -- Enabled/Disabled
                Min = 1,
                Max = 1,
            },
        },
    },
    CustomDialog = {"You Died To A-35"}, -- Custom death message
})


-----[[  Debug -=- Advanced  ]]-----
entityTable.Debug.OnEntitySpawned = function()
    print("Entity has spawned:", entityTable)
end

entityTable.Debug.OnEntityDespawned = function()
    print("Entity has despawned:", entityTable)
end

entityTable.Debug.OnEntityStartMoving = function()
    print("Entity has started moving:", entityTable)
end

entityTable.Debug.OnEntityFinishedRebound = function()
    print("Entity has finished rebound:", entityTable)
end

entityTable.Debug.OnEntityEnteredRoom = function(room)
    print("Entity:", entityTable, "has entered room:", room)
end

entityTable.Debug.OnLookAtEntity = function()
    print("Player has looked at entity:", entityTable)
end

entityTable.Debug.OnDeath = function()
    warn("Player has died.")
end
------------------------------------


-- Run the created entity
Spawner.runEntity(entityTable)
              print("Executed!")
      end
})

local Section = SpawnerTab:AddSection({
	Name = "Hardcore Entities"
})

SpawnerTab:AddButton({
    Name = "Spawn Ripper",
    Callback = function ()
    	local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))() 
-- Create entity
local entity = Creator.createEntity({
    CustomName = "Ripper", -- Custom name of your entity
    Model = "rbxassetid:////12434097362", -- Can be GitHub file or rbxassetid
    Speed = 185, -- Percentage, 100 = default Rush speed
    DelayTime = 1, -- Time before starting cycles (seconds)
    HeightOffset = 0,
    CanKill = false,
    KillRange = 40,
    BreakLights = true,
    BackwardsMovement = false,
    FlickerLights = {
        true, -- Enabled/Disabled
        1, -- Time (seconds)
    },
    Cycles = {
        Min = 1,
        Max = 1,
        WaitTime = 1,
    },
    CamShake = {
        true, -- Enabled/Disabled
        {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
        100, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
        true, -- Enabled/Disabled
        {
            Image1 = "rbxassetid://12434097362", -- Image1 url
            Image2 = "rbxassetid://12434097362", -- Image2 url
            Shake = true,
            Sound1 = {
                10483790459, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Sound2 = {
                10483837590, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Flashing = {
                true, -- Enabled/Disabled
                Color3.fromRGB(0, 0, 255), -- Color
            },
            Tease = {
                true, -- Enabled/Disabled
                Min = 4,
                Max = 4,
            },
        },
    },
})

-----[[ Advanced ]]-----
entity.Debug.OnEntitySpawned = function(entityTable)
    print("Entity has spawned:", entityTable.Model)
end

entity.Debug.OnEntityDespawned = function(entityTable)
    print("Entity has despawned:", entityTable.Model)
end

entity.Debug.OnEntityStartMoving = function(entityTable)
    print("Entity has started moving:", entityTable.Model)
end

entity.Debug.OnEntityFinishedRebound = function(entityTable)
    print("Entity has finished rebound:", entityTable.Model)
end

entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
    print("Entity:", entityTable.Model, "has entered room:", room)
end

entity.Debug.OnLookAtEntity = function(entityTable)
    print("Player has looked at entity:", entityTable.Model)
end

entity.Debug.OnDeath = function(entityTable)
    warn("Player has died.")
end
------------------------
        
        -- Run the created entity
        Creator.runEntity(entity)
        
        
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Ripper (KILLABLE)",
    Callback = function ()
    	local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))() 
-- Create entity
local entity = Creator.createEntity({
    CustomName = "Ripper", -- Custom name of your entity
    Model = "rbxassetid:////12434097362", -- Can be GitHub file or rbxassetid
    Speed = 185, -- Percentage, 100 = default Rush speed
    DelayTime = 1, -- Time before starting cycles (seconds)
    HeightOffset = 0,
    CanKill = true,
    KillRange = 40,
    BreakLights = true,
    BackwardsMovement = false,
    FlickerLights = {
        true, -- Enabled/Disabled
        1, -- Time (seconds)
    },
    Cycles = {
        Min = 1,
        Max = 1,
        WaitTime = 1,
    },
    CamShake = {
        true, -- Enabled/Disabled
        {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
        100, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
        true, -- Enabled/Disabled
        {
            Image1 = "rbxassetid://12434097362", -- Image1 url
            Image2 = "rbxassetid://12434097362", -- Image2 url
            Shake = true,
            Sound1 = {
                10483790459, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Sound2 = {
                10483837590, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Flashing = {
                true, -- Enabled/Disabled
                Color3.fromRGB(0, 0, 255), -- Color
            },
            Tease = {
                true, -- Enabled/Disabled
                Min = 4,
                Max = 4,
            },
        },
    },
})

-----[[ Advanced ]]-----
entity.Debug.OnEntitySpawned = function(entityTable)
    print("Entity has spawned:", entityTable.Model)
end

entity.Debug.OnEntityDespawned = function(entityTable)
    print("Entity has despawned:", entityTable.Model)
end

entity.Debug.OnEntityStartMoving = function(entityTable)
    print("Entity has started moving:", entityTable.Model)
end

entity.Debug.OnEntityFinishedRebound = function(entityTable)
    print("Entity has finished rebound:", entityTable.Model)
end

entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
    print("Entity:", entityTable.Model, "has entered room:", room)
end

entity.Debug.OnLookAtEntity = function(entityTable)
    print("Player has looked at entity:", entityTable.Model)
end

entity.Debug.OnDeath = function(entityTable)
    warn("Player has died.")
end
------------------------
        
        -- Run the created entity
        Creator.runEntity(entity)
        
        
    end
})

local Section = SpawnerTab:AddSection({
	Name = "Custom Entities"
})

SpawnerTab:AddButton({
    Name = "Spawn Depth",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

        -- Create entity
        local entity = Creator.createEntity({
            CustomName = "Depth", -- Custom name of your entity
            Model = "https://github.com/plamen6789/CustomDoorsMonsters/blob/main/Depth.rbxm?raw=true", -- Can be GitHub file or rbxassetid
            Speed = 300, -- Percentage, 100 = default Rush speed
            DelayTime = 2, -- Time before starting cycles (seconds)
            HeightOffset = 0,
            CanKill = false,
            KillRange = 50,
            BreakLights = true,
            BackwardsMovement = false,
            FlickerLights = {
                true, -- Enabled/Disabled
                2, -- Time (seconds)
            },
            Cycles = {
                Min = 2,
                Max = 4,
                WaitTime = 2,
            },
            CamShake = {
                true, -- Enabled/Disabled
                {10, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
                100, -- Shake start distance (from Entity to you)
            },
            Jumpscare = {
                false, -- Enabled/Disabled
                {
                    Image1 = "rbxassetid://10483855823", -- Image1 url
                    Image2 = "rbxassetid://10483999903", -- Image2 url
                    Shake = true,
                    Sound1 = {
                        10483790459, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Sound2 = {
                        10483837590, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Flashing = {
                        true, -- Enabled/Disabled
                        Color3.fromRGB(255, 255, 255), -- Color
                    },
                    Tease = {
                        true, -- Enabled/Disabled
                        Min = 1,
                        Max = 3,
                    },
                },
            },
            CustomDialog = {"You can", "put your", "custom death", "message here."}, -- Custom death message
        })
        
        -----[[ Advanced ]]-----
        entity.Debug.OnEntitySpawned = function(entityTable)
            print("Entity has spawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityDespawned = function(entityTable)
            print("Entity has despawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityStartMoving = function(entityTable)
            print("Entity has started moving:", entityTable.Model)
        end
        
        entity.Debug.OnEntityFinishedRebound = function(entityTable)
            print("Entity has finished rebound:", entityTable.Model)
        end
        
        entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
            print("Entity:", entityTable.Model, "has entered room:", room)
        end
        
        entity.Debug.OnLookAtEntity = function(entityTable)
            print("Player has looked at entity:", entityTable.Model)
        end
        
        entity.Debug.OnDeath = function(entityTable)
            warn("Player has died.")
        end
        ------------------------
        
        -- Run the created entity
        Creator.runEntity(entity)
        
        
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Doge",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

-- Create entity
local entity = Creator.createEntity({
    CustomName = "Doge", -- Custom name of your entity
    Model = "https://github.com/plamen6789/CustomDoorsMonsters/blob/main/Doge.rbxm?raw=true", -- Can be GitHub file or rbxassetid
    Speed = 250, -- Percentage, 100 = default Rush speed
    DelayTime = 3, -- Time before starting cycles (seconds)
    HeightOffset = 0,
    CanKill = false,
    KillRange = 50,
    BreakLights = false,
    BackwardsMovement = false,
    FlickerLights = {
        true, -- Enabled/Disabled
        2, -- Time (seconds)
    },
    Cycles = {
        Min = 1,
        Max = 5,
        WaitTime = 2,
    },
    CamShake = {
        true, -- Enabled/Disabled
        {4.9, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
        100, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
        false, -- Enabled/Disabled
        {
            Image1 = "rbxassetid://10483855823", -- Image1 url
            Image2 = "rbxassetid://10483999903", -- Image2 url
            Shake = true,
            Sound1 = {
                10483790459, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Sound2 = {
                10483837590, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Flashing = {
                true, -- Enabled/Disabled
                Color3.fromRGB(255, 255, 255), -- Color
            },
            Tease = {
                true, -- Enabled/Disabled
                Min = 1,
                Max = 3,
            },
        },
    },
    CustomDialog = {"You can", "put your", "custom death", "message here."}, -- Custom death message
})

-----[[ Advanced ]]-----
entity.Debug.OnEntitySpawned = function(entityTable)
    print("Entity has spawned:", entityTable.Model)
end

entity.Debug.OnEntityDespawned = function(entityTable)
    print("Entity has despawned:", entityTable.Model)
end

entity.Debug.OnEntityStartMoving = function(entityTable)
    print("Entity has started moving:", entityTable.Model)
end

entity.Debug.OnEntityFinishedRebound = function(entityTable)
    print("Entity has finished rebound:", entityTable.Model)
end

entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
    print("Entity:", entityTable.Model, "has entered room:", room)
end

entity.Debug.OnLookAtEntity = function(entityTable)
    print("Player has looked at entity:", entityTable.Model)
end

entity.Debug.OnDeath = function(entityTable)
    warn("Player has died.")
end
------------------------

-- Run the created entity
Creator.runEntity(entity)

    end
})

SpawnerTab:AddButton({
    Name = "Spawn Elgato",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

-- Create entity
local entity = Creator.createEntity({
    CustomName = "Elgato", -- Custom name of your entity
    Model = "https://github.com/plamen6789/CustomDoorsMonsters/blob/main/Elgato.rbxm?raw=true", -- Can be GitHub file or rbxassetid
    Speed = 230, -- Percentage, 100 = default Rush speed
    DelayTime = 2, -- Time before starting cycles (seconds)
    HeightOffset = 0,
    CanKill = false,
    KillRange = 50,
    BreakLights = false,
    BackwardsMovement = false,
    FlickerLights = {
        true, -- Enabled/Disabled
        1, -- Time (seconds)
    },
    Cycles = {
        Min = 1,
        Max = 4,
        WaitTime = 2,
    },
    CamShake = {
        true, -- Enabled/Disabled
        {5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
        100, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
        false, -- Enabled/Disabled
        {
            Image1 = "rbxassetid://10483855823", -- Image1 url
            Image2 = "rbxassetid://10483999903", -- Image2 url
            Shake = true,
            Sound1 = {
                10483790459, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Sound2 = {
                10483837590, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Flashing = {
                true, -- Enabled/Disabled
                Color3.fromRGB(255, 255, 255), -- Color
            },
            Tease = {
                true, -- Enabled/Disabled
                Min = 1,
                Max = 3,
            },
        },
    },
})

-----[[ Advanced ]]-----
entity.Debug.OnEntitySpawned = function(entityTable)
    print("Entity has spawned:", entityTable.Model)
end

entity.Debug.OnEntityDespawned = function(entityTable)
    print("Entity has despawned:", entityTable.Model)
end

entity.Debug.OnEntityStartMoving = function(entityTable)
    print("Entity has started moving:", entityTable.Model)
end

entity.Debug.OnEntityFinishedRebound = function(entityTable)
    print("Entity has finished rebound:", entityTable.Model)
end

entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
    print("Entity:", entityTable.Model, "has entered room:", room)
end

entity.Debug.OnLookAtEntity = function(entityTable)
    print("Player has looked at entity:", entityTable.Model)
end

entity.Debug.OnDeath = function(entityTable)
    warn("Player has died.")
end
------------------------

-- Run the created entity
Creator.runEntity(entity)

    end
})

SpawnerTab:AddButton({
    Name = "Spawn Old Ambush",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

-- Create entity
local entity = Creator.createEntity({
    CustomName = "Ambush", -- Custom name of your entity
    Model = "https://github.com/plamen6789/CustomDoorsMonsters/blob/main/OldAmbush.rbxm?raw=true", -- Can be GitHub file or rbxassetid
    Speed = 300, -- Percentage, 100 = default Rush speed
    DelayTime = 2, -- Time before starting cycles (seconds)
    HeightOffset = 0,
    CanKill = false,
    KillRange = 50,
    BreakLights = false,
    BackwardsMovement = false,
    FlickerLights = {
        true, -- Enabled/Disabled
        2, -- Time (seconds)
    },
    Cycles = {
        Min = 2,
        Max = 4,
        WaitTime = 2,
    },
    CamShake = {
        true, -- Enabled/Disabled
        {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
        100, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
        false, -- Enabled/Disabled
        {
            Image1 = "rbxassetid://10483855823", -- Image1 url
            Image2 = "rbxassetid://10483999903", -- Image2 url
            Shake = true,
            Sound1 = {
                10483790459, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Sound2 = {
                10483837590, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Flashing = {
                true, -- Enabled/Disabled
                Color3.fromRGB(255, 255, 255), -- Color
            },
            Tease = {
                true, -- Enabled/Disabled
                Min = 1,
                Max = 3,
            },
        },
    },
    CustomDialog = {"You can", "put your", "custom death", "message here."}, -- Custom death message
})

-----[[ Advanced ]]-----
entity.Debug.OnEntitySpawned = function(entityTable)
    print("Entity has spawned:", entityTable.Model)
end

entity.Debug.OnEntityDespawned = function(entityTable)
    print("Entity has despawned:", entityTable.Model)
end

entity.Debug.OnEntityStartMoving = function(entityTable)
    print("Entity has started moving:", entityTable.Model)
end

entity.Debug.OnEntityFinishedRebound = function(entityTable)
    print("Entity has finished rebound:", entityTable.Model)
end

entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
    print("Entity:", entityTable.Model, "has entered room:", room)
end

entity.Debug.OnLookAtEntity = function(entityTable)
    print("Player has looked at entity:", entityTable.Model)
end

entity.Debug.OnDeath = function(entityTable)
    warn("Player has died.")
end
------------------------

-- Run the created entity
Creator.runEntity(entity)

    end
})

SpawnerTab:AddButton({
    Name = "Spawn Firebrand",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

-- Create entity
local entity = Creator.createEntity({
    CustomName = "Firebrand", -- Custom name of your entity
    Model = "https://github.com/fnaclol/sussy-bois/raw/main/FireBrand3.rbxm?raw=true", -- Can be GitHub file or rbxassetid
    Speed = 400, -- Percentage, 100 = default Rush speed
    DelayTime = 2, -- Time before starting cycles (seconds)
    HeightOffset = 0,
    CanKill = false,
    KillRange = 50,
    BreakLights = true,
    BackwardsMovement = false,
    FlickerLights = {
        true, -- Enabled/Disabled
        1, -- Time (seconds)
    },
    Cycles = {
        Min = 2,
        Max = 2,
        WaitTime = 2,
    },
    CamShake = {
        true, -- Enabled/Disabled
        {5, 15, 0.1, 1}, -- Shake values (don't change if you don't know)
        100, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
        true, -- Enabled/Disabled
        {
            Image1 = "rbxassetid://10483855823", -- Image1 url
            Image2 = "rbxassetid://10483999903", -- Image2 url
            Shake = true,
            Sound1 = {
                10483790459, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Sound2 = {
                10483837590, -- SoundId
                { Volume = 0.5 }, -- Sound properties
            },
            Flashing = {
                true, -- Enabled/Disabled
                Color3.fromRGB(255, 255, 255), -- Color
            },
            Tease = {
                true, -- Enabled/Disabled
                Min = 1,
                Max = 3,
            },
        },
    },
    CustomDialog = {"You died to whom you call FireBrand", "FireBrand will spawn only on your will", "When you hear him spawn you only have 2 seconds to hide", "Vents do not save you aswell"}, -- Custom death message
})

-----[[ Advanced ]]-----
entity.Debug.OnEntitySpawned = function(entityTable)
    print("Entity has spawned:", entityTable.Model)
end

entity.Debug.OnEntityDespawned = function(entityTable)
    print("Entity has despawned:", entityTable.Model)
end

entity.Debug.OnEntityStartMoving = function(entityTable)
    print("Entity has started moving:", entityTable.Model)
end

entity.Debug.OnEntityFinishedRebound = function(entityTable)
    print("Entity has finished rebound:", entityTable.Model)
end

entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
    print("Entity:", entityTable.Model, "has entered room:", room)
end

entity.Debug.OnLookAtEntity = function(entityTable)
    print("Player has looked at entity:", entityTable.Model)
end

entity.Debug.OnDeath = function(entityTable)
    warn("Player has died.")
end
------------------------

-- Run the created entity
Creator.runEntity(entity)

        
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Old Seek",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

        -- Create entity
        local entity = Creator.createEntity({
            CustomName = "Old Seek", -- Custom name of your entity
            Model = "rbxassetid://12409904623", -- Can be GitHub file or rbxassetid
            Speed = 80, -- Percentage, 100 = default Rush speed
            DelayTime = 2, -- Time before starting cycles (seconds)
            HeightOffset = -0.5,
            CanKill = false,
            KillRange = 25,
            BreakLights = true,
            BackwardsMovement = false,
            FlickerLights = {
                true, -- Enabled/Disabled
                1, -- Time (seconds)
            },
            Cycles = {
                Min = 1,
                Max = 1,
                WaitTime = 2,
            },
            CamShake = {
                true, -- Enabled/Disabled
                {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
                100, -- Shake start distance (from Entity to you)
            },
            Jumpscare = {
                true, -- Enabled/Disabled
                {
                    Image1 = "rbxassetid://10483855823", -- Image1 url
                    Image2 = "rbxassetid://10483999903", -- Image2 url
                    Shake = true,
                    Sound1 = {
                        10483790459, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Sound2 = {
                        10483837590, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Flashing = {
                        true, -- Enabled/Disabled
                        Color3.fromRGB(0, 0, 255), -- Color
                    },
                    Tease = {
                        true, -- Enabled/Disabled
                        Min = 4,
                        Max = 4,
                    },
                },
            },
        })
        
        -----[[ Advanced ]]-----
        entity.Debug.OnEntitySpawned = function(entityTable)
            print("Entity has spawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityDespawned = function(entityTable)
            print("Entity has despawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityStartMoving = function(entityTable)
            print("Entity has started moving:", entityTable.Model)
        end
        
        entity.Debug.OnEntityFinishedRebound = function(entityTable)
            print("Entity has finished rebound:", entityTable.Model)
        end
        
        entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
            print("Entity:", entityTable.Model, "has entered room:", room)
        end
        
        entity.Debug.OnLookAtEntity = function(entityTable)
            print("Player has looked at entity:", entityTable.Model)
        end
        
        entity.Debug.OnDeath = function(entityTable)
            warn("Player has died.")
        end
        ------------------------
        
        -- Run the created entity
        Creator.runEntity(entity)
        
    end
})

local Section = SpawnerTab:AddSection({
	Name = "Joke Entities"
})

SpawnerTab:AddButton({
    Name = "Spawn God Speed Rush",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

        -- Create entity
        local entity = Creator.createEntity({
            CustomName = "Rush", -- Custom name of your entity
            Model = "https://github.com/Johnny39871/assets/blob/main/Rush.rbxm?raw=true", -- Can be GitHub file or rbxassetid
            Speed = math.huge, -- Percentage, 100 = default Rush speed
            DelayTime = 0, -- Time before starting cycles (seconds)
            HeightOffset = 0,
            CanKill = false,
            KillRange = 25,
            BreakLights = true,
            BackwardsMovement = false,
            FlickerLights = {
                true, -- Enabled/Disabled
                1, -- Time (seconds)
            },
            Cycles = {
                Min = 1000,
                Max = 1000,
                WaitTime = 0,
            },
            CamShake = {
                true, -- Enabled/Disabled
                {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
                100, -- Shake start distance (from Entity to you)
            },
            Jumpscare = {
                true, -- Enabled/Disabled
                {
                    Image1 = "rbxassetid://10483855823", -- Image1 url
                    Image2 = "rbxassetid://10483999903", -- Image2 url
                    Shake = true,
                    Sound1 = {
                        10483790459, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Sound2 = {
                        10483837590, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Flashing = {
                        true, -- Enabled/Disabled
                        Color3.fromRGB(0, 0, 255), -- Color
                    },
                    Tease = {
                        true, -- Enabled/Disabled
                        Min = 4,
                        Max = 4,
                    },
                },
            },
        })
        
        -----[[ Advanced ]]-----
        entity.Debug.OnEntitySpawned = function(entityTable)
            print("Entity has spawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityDespawned = function(entityTable)
            print("Entity has despawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityStartMoving = function(entityTable)
            print("Entity has started moving:", entityTable.Model)
        end
        
        entity.Debug.OnEntityFinishedRebound = function(entityTable)
            print("Entity has finished rebound:", entityTable.Model)
        end
        
        entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
            print("Entity:", entityTable.Model, "has entered room:", room)
        end
        
        entity.Debug.OnLookAtEntity = function(entityTable)
            print("Player has looked at entity:", entityTable.Model)
        end
        
        entity.Debug.OnDeath = function(entityTable)
            warn("Player has died.")
        end
        ------------------------
        
        -- Run the created entity
        Creator.runEntity(entity)
        
    end
})

SpawnerTab:AddButton({
    Name = "Spawn God Speed Ambush",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

        -- Create entity
        local entity = Creator.createEntity({
            CustomName = "Rush", -- Custom name of your entity
            Model = "rbxassetid://11652567875", -- Can be GitHub file or rbxassetid
            Speed = math.huge, -- Percentage, 100 = default Rush speed
            DelayTime = 0, -- Time before starting cycles (seconds)
            HeightOffset = -2,
            CanKill = false,
            KillRange = 25,
            BreakLights = true,
            BackwardsMovement = false,
            FlickerLights = {
                true, -- Enabled/Disabled
                1, -- Time (seconds)
            },
            Cycles = {
                Min = 1000,
                Max = 1000,
                WaitTime = 0,
            },
            CamShake = {
                true, -- Enabled/Disabled
                {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
                100, -- Shake start distance (from Entity to you)
            },
            Jumpscare = {
                true, -- Enabled/Disabled
                {
                    Image1 = "rbxassetid://10483855823", -- Image1 url
                    Image2 = "rbxassetid://10483999903", -- Image2 url
                    Shake = true,
                    Sound1 = {
                        10483790459, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Sound2 = {
                        10483837590, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Flashing = {
                        true, -- Enabled/Disabled
                        Color3.fromRGB(0, 0, 255), -- Color
                    },
                    Tease = {
                        true, -- Enabled/Disabled
                        Min = 4,
                        Max = 4,
                    },
                },
            },
        })
        
        -----[[ Advanced ]]-----
        entity.Debug.OnEntitySpawned = function(entityTable)
            print("Entity has spawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityDespawned = function(entityTable)
            print("Entity has despawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityStartMoving = function(entityTable)
            print("Entity has started moving:", entityTable.Model)
        end
        
        entity.Debug.OnEntityFinishedRebound = function(entityTable)
            print("Entity has finished rebound:", entityTable.Model)
        end
        
        entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
            print("Entity:", entityTable.Model, "has entered room:", room)
        end
        
        entity.Debug.OnLookAtEntity = function(entityTable)
            print("Player has looked at entity:", entityTable.Model)
        end
        
        entity.Debug.OnDeath = function(entityTable)
            warn("Player has died.")
        end
        ------------------------
        
        -- Run the created entity
        Creator.runEntity(entity)
        
    end
})

SpawnerTab:AddButton({
    Name = "Spawn Wardrobe",
    Callback = function ()
        local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

        -- Create entity
        local entity = Creator.createEntity({
            CustomName = "Wardrobe", -- Custom name of your entity
            Model = "rbxassetid://11320452413", -- Can be GitHub file or rbxassetid
            Speed = 100, -- Percentage, 100 = default Rush speed
            DelayTime = 2, -- Time before starting cycles (seconds)
            HeightOffset = 1,
            CanKill = false,
            KillRange = 25,
            BreakLights = true,
            BackwardsMovement = false,
            FlickerLights = {
                true, -- Enabled/Disabled
                1, -- Time (seconds)
            },
            Cycles = {
                Min = 1,
                Max = 1,
                WaitTime = 2,
            },
            CamShake = {
                true, -- Enabled/Disabled
                {3.5, 20, 0.1, 1}, -- Shake values (don't change if you don't know)
                100, -- Shake start distance (from Entity to you)
            },
            Jumpscare = {
                true, -- Enabled/Disabled
                {
                    Image1 = "rbxassetid://10483855823", -- Image1 url
                    Image2 = "rbxassetid://10483999903", -- Image2 url
                    Shake = true,
                    Sound1 = {
                        10483790459, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Sound2 = {
                        10483837590, -- SoundId
                        { Volume = 0.5 }, -- Sound properties
                    },
                    Flashing = {
                        true, -- Enabled/Disabled
                        Color3.fromRGB(0, 0, 255), -- Color
                    },
                    Tease = {
                        true, -- Enabled/Disabled
                        Min = 4,
                        Max = 4,
                    },
                },
            },
        })
        
        -----[[ Advanced ]]-----
        entity.Debug.OnEntitySpawned = function(entityTable)
            print("Entity has spawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityDespawned = function(entityTable)
            print("Entity has despawned:", entityTable.Model)
        end
        
        entity.Debug.OnEntityStartMoving = function(entityTable)
            print("Entity has started moving:", entityTable.Model)
        end
        
        entity.Debug.OnEntityFinishedRebound = function(entityTable)
            print("Entity has finished rebound:", entityTable.Model)
        end
        
        entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
            print("Entity:", entityTable.Model, "has entered room:", room)
        end
        
        entity.Debug.OnLookAtEntity = function(entityTable)
            print("Player has looked at entity:", entityTable.Model)
        end
        
        entity.Debug.OnDeath = function(entityTable)
            warn("Player has died.")
        end
        ------------------------
        
        -- Run the created entity
        Creator.runEntity(entity)
        
    end
})

local Section = SpawnerTab:AddSection({
	Name = "Room Related"
})

SpawnerTab:AddButton({
    Name = "Spawn Seek Eyes",
    Callback = function ()
        local Data = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
        require(game:GetService("ReplicatedStorage").ClientModules.EntityModules.Seek).tease(nil, workspace.CurrentRooms:WaitForChild(game.ReplicatedStorage.GameData.LatestRoom.Value), 14, 1665596753, true)
    end
})

SpawnerTab:AddButton({
    Name = "Red Room",
    Callback = function ()
        local v1 = require(game.ReplicatedStorage.ClientModules.Module_Events)
        local room = workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")]
        local seconds = 1000000
        v1.tryp(workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")], seconds)
    end
})

-- Credits

local CreditsTab = Window:MakeTab({
	Name = "Credits",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
 
CreditsTab:AddParagraph("_G.NeRD (NeRD)","Join his Discord server! https://discord.gg/nerdw")
CreditsTab:AddParagraph("Kiwi Bird","Join his Discord server! https://discord.gg/kiwib")
CreditsTab:AddParagraph("PenguinManiack","Join his Discord server! https://discord.gg/Wgh9Mr5WGW")
CreditsTab:AddParagraph("Oof","Join his Discord server! https://discord.gg/revitalized")
CreditsTab:AddParagraph("Noah","Join his Discord server! https://discord.gg/TAjsfG8mgz")
CreditsTab:AddParagraph("fin","Join his Discord server! https://discord.gg/5MGxcPAaKb")
CreditsTab:AddParagraph("nerd","some of nerd's scripts will not be showed in gui bc they need whitelist")

-- About

local AboutTab = Window:MakeTab({
	Name = "About",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

AboutTab:AddParagraph("Cat V1","Started developing in 6/25/2023, Released in 6/30/2023")
AboutTab:AddParagraph("Cat V2","Started developing in 7/10/2023, Released in 7/12/2023")
AboutTab:AddParagraph("Cat V3","Started developing in 8/1/2023, Released in 8/3/2023")
AboutTab:AddParagraph("Cat V4","Started developing in 8/10/2023, Released in 8/??/2023")
AboutTab:AddParagraph("The creator","cat1852#6477")
AboutTab:AddParagraph("Helpers","lsplash0000, Noah")
AboutTab:AddParagraph("Suggesters","Wvpul, i2room")
AboutTab:AddParagraph("Testers","a normal cat#4719, i2room")
AboutTab:AddParagraph("Bugs Reporters","i2room")

local Section = AboutTab:AddSection({
	Name = "The end"
})

AboutTab:AddParagraph("Thank you for using Cat V4!","Wish you have a nice day!")