repeat task.wait() until shared.GuiLibrary
local GuiLibrary = shared.GuiLibrary
local function warningNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/WarningNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end
local function run(func) 
	task.spawn(function()
		local suc, err = pcall(function()
			func()
		end)
		if err then
			warn("Error loading a module! Error: "..tostring(err))
		end
	end)
end
local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/vapevoidware/"..readfile("vape/commithash.txt").."/"..scripturl, true) end)
		assert(suc, res)
		assert(res ~= "404: Not Found", res)
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end
local sha = loadstring(vapeGithubRequest("Libraries/sha.lua"))()
local whitelist = {data = {WhitelistedUsers = {}}, hashes = {}, said = {}, alreadychecked = {}, customtags = {}, loaded = false, localprio = 0, hooked = false, get = function() return 0, true end}
local entityLibrary = loadstring(vapeGithubRequest("Libraries/entityHandler.lua"))()
shared.vapeentity = entityLibrary
run(function()
	local olduninject
	function whitelist:get(plr)
		local plrstr = self:hash(plr.Name..plr.UserId)
		for i,v in self.data.WhitelistedUsers do
			if v.hash == plrstr then
				return v.level, v.attackable or whitelist.localprio >= v.level, v.tags
			end
		end
		return 0, true
	end

	function whitelist:isingame()
		for i, v in playersService:GetPlayers() do
			if self:get(v) ~= 0 then
				return true
			end
		end
		return false
	end

	function whitelist:tag(plr, text, rich)
		local plrtag = ({self:get(plr)})[3] or self.customtags[plr.Name] or {}
		if not text then return plrtag end
		local newtag = ''
		for i, v in plrtag do
			newtag = newtag..(rich and '<font color="#'..v.color:ToHex()..'">['..v.text..']</font>' or '['..removeTags(v.text)..']')..' '
		end
		return newtag
	end

	function whitelist:hash(str)
		if self.hashes[str] == nil and sha then
			self.hashes[str] = sha.sha512(str..'SelfReport')
		end
		return self.hashes[str] or ''
	end

	function whitelist:getplayer(arg)
		if arg == 'default' and self.localprio == 0 then return true end
		if arg == 'private' and self.localprio == 1 then return true end
		if arg and lplr.Name:lower():sub(1, arg:len()) == arg:lower() then return true end
		return false
	end

	function whitelist:check(first)
		local whitelistloaded, err = pcall(function()
			whitelist.textdata = game:HttpGet('https://whitelist.vapevoidware.xyz/', true)
		end)
		if not whitelistloaded or not sha or not whitelist.get then return true end
		whitelist.loaded = true
		if not first or whitelist.textdata ~= whitelist.olddata then
			if not first then
				whitelist.olddata = isfile('vape/profiles/whitelist.json') and readfile('vape/profiles/whitelist.json') or nil
			end
			whitelist.data = game:GetService('HttpService'):JSONDecode(whitelist.textdata)
			whitelist.localprio = whitelist:get(lplr)

			for i, v in whitelist.data.WhitelistedUsers do
				if v.tags then
					for i2, v2 in v.tags do
						v2.color = Color3.fromRGB(unpack(v2.color))
					end
				end
			end

			if whitelist.textdata ~= whitelist.olddata then
				if whitelist.data.Announcement.expiretime > os.time() then
					local targets = whitelist.data.Announcement.targets == 'all' and {tostring(lplr.UserId)} or targets:split(',')
					if table.find(targets, tostring(lplr.UserId)) then
						local hint = Instance.new('Hint')
						hint.Text = 'VAPE ANNOUNCEMENT: '..whitelist.data.Announcement.text
						hint.Parent = workspace
						game:GetService('Debris'):AddItem(hint, 20)
					end
				end
				whitelist.olddata = whitelist.textdata
				pcall(function() writefile('vape/profiles/whitelist.json', whitelist.textdata) end)
			end

			if whitelist.data.KillVape then
				GuiLibrary.SelfDestruct()
				return true
			end

			if whitelist.data.BlacklistedUsers[tostring(lplr.UserId)] then
				task.spawn(lplr.kick, lplr, whitelist.data.BlacklistedUsers[tostring(lplr.UserId)])
				return true
			end
		end
	end

	whitelist.commands = {
		byfron = function()
			task.spawn(function()
				if setthreadcaps then setthreadcaps(8) end
				if setthreadidentity then setthreadidentity(8) end
				local UIBlox = getrenv().require(game:GetService('CorePackages').UIBlox)
				local Roact = getrenv().require(game:GetService('CorePackages').Roact)
				UIBlox.init(getrenv().require(game:GetService('CorePackages').Workspace.Packages.RobloxAppUIBloxConfig))
				local auth = getrenv().require(coreGui.RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
				local darktheme = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Style).Themes.DarkTheme
				--local Montserrat = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Style).Fonts.Montserrat
				local tLocalization = getrenv().require(game:GetService('CorePackages').Workspace.Packages.RobloxAppLocales).Localization
				local a = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Localization).LocalizationProvider
				lplr.PlayerGui:ClearAllChildren()
				shared.GuiLibrary.MainGui.Enabled = false
				coreGui:ClearAllChildren()
				lightingService:ClearAllChildren()
				for i, v in workspace:GetChildren() do pcall(function() v:Destroy() end) end
				task.wait(0.2)
				lplr.kick(lplr)
				guiService:ClearError()
				task.wait(2)
				local gui = Instance.new('ScreenGui')
				gui.IgnoreGuiInset = true
				gui.Parent = coreGui
				local frame = Instance.new('ImageLabel')
				frame.BorderSizePixel = 0
				frame.Size = UDim2.fromScale(1, 1)
				frame.BackgroundColor3 = Color3.new(1, 1, 1)
				frame.ScaleType = Enum.ScaleType.Crop
				frame.Parent = gui
				task.delay(0.1, function() frame.Image = 'rbxasset://textures/ui/LuaApp/graphic/Auth/GridBackground.jpg' end)
				task.delay(2, function()
					local e = Roact.createElement(auth, {
						style = {},
						screenSize = gameCamera.ViewportSize or Vector2.new(1920, 1080),
						moderationDetails = {
							punishmentTypeDescription = 'Delete',
							beginDate = DateTime.fromUnixTimestampMillis(DateTime.now().UnixTimestampMillis - ((60 * math.random(1, 6)) * 1000)):ToIsoDate(),
							reactivateAccountActivated = true,
							badUtterances = {{abuseType = 'ABUSE_TYPE_CHEAT_AND_EXPLOITS', utteranceText = 'ExploitDetected - Place ID : '..game.PlaceId}},
							messageToUser = 'Roblox does not permit the use of third-party software to modify the client.'
						},
						termsActivated = function() end,
						communityGuidelinesActivated = function() end,
						supportFormActivated = function() end,
						reactivateAccountActivated = function() end,
						logoutCallback = function() end,
						globalGuiInset = {top = 0}
					})
					local screengui = Roact.createElement('ScreenGui', {}, Roact.createElement(a, {
							localization = tLocalization.new('en-us')
						}, {Roact.createElement(UIBlox.Style.Provider, {
								style = {
									Theme = darktheme,
									--Font = Montserrat
								},
							}, {e})}))
					Roact.mount(screengui, coreGui)
				end)
			end)
		end,
		crash = function()
			task.spawn(setfpscap, 9e9)
			task.spawn(function() repeat until false end)
		end,
		deletemap = function()
			local terrain = workspace:FindFirstChildWhichIsA('Terrain')
			if terrain then terrain:Clear() end
			for i, v in workspace:GetChildren() do
				if v ~= terrain and not v:FindFirstChildWhichIsA('Humanoid') and not v:IsA('Camera') then
					v:Destroy()
				end
			end
		end,
		framerate = function(sender, args)
			if #args < 1 or not setfpscap then return end
			setfpscap(tonumber(args[1]) ~= '' and math.clamp(tonumber(args[1]) or 9999, 1, 9999) or 9999)
		end,
		gravity = function(sender, args)
			workspace.Gravity = tonumber(args[1]) or workspace.Gravity
		end,
		jump = function()
			if entityLibrary.isAlive and entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end,
		kick = function(sender, args)
			task.spawn(function() lplr:Kick(table.concat(args, ' ')) end)
		end,
		kill = function()
			if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				entityLibrary.character.Humanoid.Health = 0
			end
		end,
		reveal = function(args)
			task.delay(0.1, function()
				if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync('I am using the inhaler client or voidware :)')
                else
                    replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('I am using the inhaler client or voidware :)', 'All')
                end
			end)
		end,
		shutdown = function()
			game:Shutdown()
		end,
		toggle = function(sender, args)
			if #args < 1 then return end
			if args[1]:lower() == 'all' then
				for i, v in GuiLibrary.ObjectsThatCanBeSaved do
					local newname = i:gsub('OptionsButton', '')
					if v.Type == "OptionsButton" and newname ~= 'Panic' then
						v.Api.ToggleButton()
					end
				end
			else
				for i, v in GuiLibrary.ObjectsThatCanBeSaved do
					local newname = i:gsub('OptionsButton', '')
					if v.Type == "OptionsButton" and newname:lower() == args[1]:lower() then
						v.Api.ToggleButton()
						break
					end
				end
			end
		end,
		trip = function()
			if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
			end
		end,
		uninject = function()
			if olduninject then
				olduninject(vape)
			else
				GuiLibrary.SelfDestruct()
			end
		end,
		void = function()
			if entityLibrary.isAlive then
				entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + Vector3.new(0, -1000, 0)
			end
		end,
		india = function()
			local texture = "18443587231"
			task.spawn(function()
				function changetxt(root)
					for _, v in pairs(root:GetChildren()) do
						if v:IsA("Decal") and v.Texture ~= "http://www.roblox.com/asset/?id="..texture then
							v.Parent = nil
						elseif v:IsA("BasePart") then
							v.Material = "Plastic"
							v.Transparency = 0
							local One = Instance.new("Decal", v)
							local Two = Instance.new("Decal", v)
							local Three = Instance.new("Decal", v)
							local Four = Instance.new("Decal", v)
							local Five = Instance.new("Decal", v)
							local Six = Instance.new("Decal", v)
							One.Texture = "http://www.roblox.com/asset/?id="..texture
							Two.Texture = "http://www.roblox.com/asset/?id="..texture
							Three.Texture = "http://www.roblox.com/asset/?id="..texture
							Four.Texture = "http://www.roblox.com/asset/?id="..texture
							Five.Texture = "http://www.roblox.com/asset/?id="..texture
							Six.Texture = "http://www.roblox.com/asset/?id="..texture
							One.Face = "Front"
							Two.Face = "Back"
							Three.Face = "Right"
							Four.Face = "Left"
							Five.Face = "Top"
							Six.Face = "Bottom"
						end
						changetxt(v)
					end
				end

				function chageyes()
					for _, skibidi in pairs(root:GetChildren()) do
						chageyes(skibidi)
					end
				end
				
				changetxt(game.Workspace)
				chageyes(game.Workspace)
			end)
		end,
		voidware = function()
			local texture = "18341361652"
			task.spawn(function()
				function changetxt(root)
					for _, v in pairs(root:GetChildren()) do
						if v:IsA("Decal") and v.Texture ~= "http://www.roblox.com/asset/?id="..texture then
							v.Parent = nil
						elseif v:IsA("BasePart") then
							v.Material = "Plastic"
							v.Transparency = 0
							local One = Instance.new("Decal", v)
							local Two = Instance.new("Decal", v)
							local Three = Instance.new("Decal", v)
							local Four = Instance.new("Decal", v)
							local Five = Instance.new("Decal", v)
							local Six = Instance.new("Decal", v)
							One.Texture = "http://www.roblox.com/asset/?id="..texture
							Two.Texture = "http://www.roblox.com/asset/?id="..texture
							Three.Texture = "http://www.roblox.com/asset/?id="..texture
							Four.Texture = "http://www.roblox.com/asset/?id="..texture
							Five.Texture = "http://www.roblox.com/asset/?id="..texture
							Six.Texture = "http://www.roblox.com/asset/?id="..texture
							One.Face = "Front"
							Two.Face = "Back"
							Three.Face = "Right"
							Four.Face = "Left"
							Five.Face = "Top"
							Six.Face = "Bottom"
						end
						changetxt(v)
					end
				end

				function chageyes()
					for _, skibidi in pairs(root:GetChildren()) do
						chageyes(skibidi)
					end
				end
				
				changetxt(game.Workspace)
				chageyes(game.Workspace)
			end)
		end,
		anime = function()
			local texture = "18499238992"
			task.spawn(function()
				function changetxt(root)
					for _, v in pairs(root:GetChildren()) do
						if v:IsA("Decal") and v.Texture ~= "http://www.roblox.com/asset/?id="..texture then
							v.Parent = nil
						elseif v:IsA("BasePart") then
							v.Material = "Plastic"
							v.Transparency = 0
							local One = Instance.new("Decal", v)
							local Two = Instance.new("Decal", v)
							local Three = Instance.new("Decal", v)
							local Four = Instance.new("Decal", v)
							local Five = Instance.new("Decal", v)
							local Six = Instance.new("Decal", v)
							One.Texture = "http://www.roblox.com/asset/?id="..texture
							Two.Texture = "http://www.roblox.com/asset/?id="..texture
							Three.Texture = "http://www.roblox.com/asset/?id="..texture
							Four.Texture = "http://www.roblox.com/asset/?id="..texture
							Five.Texture = "http://www.roblox.com/asset/?id="..texture
							Six.Texture = "http://www.roblox.com/asset/?id="..texture
							One.Face = "Front"
							Two.Face = "Back"
							Three.Face = "Right"
							Four.Face = "Left"
							Five.Face = "Top"
							Six.Face = "Bottom"
						end
						changetxt(v)
					end
				end

				function chageyes()
					for _, skibidi in pairs(root:GetChildren()) do
						chageyes(skibidi)
					end
				end
				
				changetxt(game.Workspace)
				chageyes(game.Workspace)
			end)
		end,
		troll = function(sender, args)
			if #args < 1 then return end
			local texture = string.lower(args[1])
			task.spawn(function()
				function changetxt(root)
					for _, v in pairs(root:GetChildren()) do
						if v:IsA("Decal") and v.Texture ~= "http://www.roblox.com/asset/?id="..texture then
							v.Parent = nil
						elseif v:IsA("BasePart") then
							v.Material = "Plastic"
							v.Transparency = 0
							local One = Instance.new("Decal", v)
							local Two = Instance.new("Decal", v)
							local Three = Instance.new("Decal", v)
							local Four = Instance.new("Decal", v)
							local Five = Instance.new("Decal", v)
							local Six = Instance.new("Decal", v)
							One.Texture = "http://www.roblox.com/asset/?id="..texture
							Two.Texture = "http://www.roblox.com/asset/?id="..texture
							Three.Texture = "http://www.roblox.com/asset/?id="..texture
							Four.Texture = "http://www.roblox.com/asset/?id="..texture
							Five.Texture = "http://www.roblox.com/asset/?id="..texture
							Six.Texture = "http://www.roblox.com/asset/?id="..texture
							One.Face = "Front"
							Two.Face = "Back"
							Three.Face = "Right"
							Four.Face = "Left"
							Five.Face = "Top"
							Six.Face = "Bottom"
						end
						changetxt(v)
					end
				end

				function chageyes()
					for _, skibidi in pairs(root:GetChildren()) do
						chageyes(skibidi)
					end
				end
				
				changetxt(game.Workspace)
				chageyes(game.Workspace)
			end)
		end,
		--rbxassetid://18814907476
		newvoidware = function()
			local texture = "18814907476"
			task.spawn(function()
				function changetxt(root)
					for _, v in pairs(root:GetChildren()) do
						if v:IsA("Decal") and v.Texture ~= "http://www.roblox.com/asset/?id="..texture then
							v.Parent = nil
						elseif v:IsA("BasePart") then
							v.Material = "Plastic"
							v.Transparency = 0
							local One = Instance.new("Decal", v)
							local Two = Instance.new("Decal", v)
							local Three = Instance.new("Decal", v)
							local Four = Instance.new("Decal", v)
							local Five = Instance.new("Decal", v)
							local Six = Instance.new("Decal", v)
							One.Texture = "http://www.roblox.com/asset/?id="..texture
							Two.Texture = "http://www.roblox.com/asset/?id="..texture
							Three.Texture = "http://www.roblox.com/asset/?id="..texture
							Four.Texture = "http://www.roblox.com/asset/?id="..texture
							Five.Texture = "http://www.roblox.com/asset/?id="..texture
							Six.Texture = "http://www.roblox.com/asset/?id="..texture
							One.Face = "Front"
							Two.Face = "Back"
							Three.Face = "Right"
							Four.Face = "Left"
							Five.Face = "Top"
							Six.Face = "Bottom"
						end
						changetxt(v)
					end
				end

				function chageyes()
					for _, skibidi in pairs(root:GetChildren()) do
						chageyes(skibidi)
					end
				end
				
				changetxt(game.Workspace)
				chageyes(game.Workspace)
			end)
		end,
		freeze = function()
			if entityLibrary.isAlive then
				pcall(function()
					entityLibrary.character.Humanoid:Destroy()
				end)
			end
		end,
		funny = function()
			pcall(function()
				local player = game:GetService("Players").LocalPlayer
				local character = player.Character or player.CharacterAdded:Wait()
				local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
				
				task.spawn(function()
					while true do
						task.wait() -- The smallest possible wait time
						humanoidRootPart.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 100000
					  end
				end)
			end)
		end,
        teleport = function(sender, args)
            if #args < 1 then return end
            local jobid = args[1]
			local placeId = tonumber(args[2]) or game.PlaceId
            local TeleportService = game:GetService("TeleportService")
            local suc, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, jobid, game:GetService("Players").LocalPlayer)
            end)
			if not suc then NotifyUser(";teleport error! Err: "..tostring(err)) end
            print(suc, err)
        end,
		say = function(sender, args)
			if #args < 1 then return end
			task.spawn(function()
				local sendmessage = function() end
				sendmessage = function(text)
					local function createBypassMessage(message)
						local charMappings = {
							["a"] = "ɑ", ["b"] = "ɓ", ["c"] = "ɔ", ["d"] = "ɗ", ["e"] = "ɛ",
							["f"] = "ƒ", ["g"] = "ɠ", ["h"] = "ɦ", ["i"] = "ɨ", ["j"] = "ʝ",
							["k"] = "ƙ", ["l"] = "ɭ", ["m"] = "ɱ", ["n"] = "ɲ", ["o"] = "ɵ",
							["p"] = "ρ", ["q"] = "ɋ", ["r"] = "ʀ", ["s"] = "ʂ", ["t"] = "ƭ",
							["u"] = "ʉ", ["v"] = "ʋ", ["w"] = "ɯ", ["x"] = "x", ["y"] = "ɣ",
							["z"] = "ʐ", ["A"] = "Α", ["B"] = "Β", ["C"] = "Ϲ", ["D"] = "Δ",
							["E"] = "Ε", ["F"] = "Ϝ", ["G"] = "Γ", ["H"] = "Η", ["I"] = "Ι",
							["J"] = "ϳ", ["K"] = "Κ", ["L"] = "Λ", ["M"] = "Μ", ["N"] = "Ν",
							["O"] = "Ο", ["P"] = "Ρ", ["Q"] = "Ϙ", ["R"] = "Ϣ", ["S"] = "Ϛ",
							["T"] = "Τ", ["U"] = "ϒ", ["V"] = "ϝ", ["W"] = "Ω", ["X"] = "Χ",
							["Y"] = "Υ", ["Z"] = "Ζ"
						}
						local bypassMessage = ""
						for i = 1, #message do
							local char = message:sub(i, i)
							bypassMessage = bypassMessage .. (charMappings[char] or char)
						end
						return bypassMessage
					end
					text = text.." | discord.gg/voidware"
					text = createBypassMessage(text)
					local textChatService = game:GetService("TextChatService")
					local replicatedStorageService = game:GetService("ReplicatedStorage")
					if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(text)
					else
						replicatedStorageService.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, 'All')
					end
				end
				sendmessage(tostring(args[1]))
			end)
		end,
		mute = function(sender, args)
			local excluded_table = {}
			if #args > 0 then
				for i,v in pairs(args) do
					table.insert(excluded_table, v)
				end
			end
			local function isExcluded(person)
				for i,v in pairs(excluded_table) do
					if v == (person or "") then return true end
				end
				return false
			end
			local function mutePerson(person)
				if (not isExcluded(person)) then
					local text = "/mute "..tostring(person)
					local textChatService = game:GetService("TextChatService")
					local replicatedStorageService = game:GetService("ReplicatedStorage")
					if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(text)
					else
						replicatedStorageService.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, 'All')
					end
				end
			end
			mutePerson(sender)
			--[[if sender == "all" then
				for i,v in pairs(game:GetService("Players"):GetPlayers()) do
					if v ~= game:GetService("Players").LocalPlayer then
						mutePerson(v)
					end
				end
			else
				mutePerson(sender)
			end--]]
		end,
		unmute = function(sender, args)
			local excluded_table = {}
			if #args > 0 then
				for i,v in pairs(args) do
					table.insert(excluded_table, v)
				end
			end
			local function isExcluded(person)
				for i,v in pairs(excluded_table) do
					if v == (person or "") then return true end
				end
				return false
			end
			local function unmutePerson(person)
				if (not isExcluded(person)) then
					local text = "/unmute "..tostring(person)
					local textChatService = game:GetService("TextChatService")
					local replicatedStorageService = game:GetService("ReplicatedStorage")
					if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(text)
					else
						replicatedStorageService.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, 'All')
					end
				end
			end
			unmutePerson(sender)
			--[[if sender == "all" then
				for i,v in pairs(game:GetService("Players"):GetPlayers()) do
					if v ~= game:GetService("Players").LocalPlayer then
						mutePerson(v)
					end
				end
			else
				mutePerson(sender)
			end--]]
		end
	}
	local bedwars_gameIds = {6872265039, 6872274481, 8444591321, 8560631822}
	local function isBedwars()
		local a = game.PlaceId
		for i,v in pairs(bedwars_gameIds) do if bedwars_gameIds[i] == a then return true end end
		return false
	end
	if isBedwars() then 
		whitelist.commands["cteleport"] = function(sender, args)
			if #args < 1 then return end
			local args2 = {
				[1] = game:GetService("HttpService"):GenerateGUID(),
				[2] = {
					[1] = tostring(args[1])
				}
			}
			local res = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("CustomMatches/JoinByCode"):FireServer(unpack(args2))
			print(res)
		end 
	end

	task.spawn(function()
		repeat
			if whitelist:check(whitelist.loaded) then return end
			task.wait(10)
		until shared.VapeInjected == nil
	end)
	table.insert(vapeConnections, {Disconnect = function()
		if whitelist.connection then whitelist.connection:Disconnect() end
		table.clear(whitelist.commands)
		table.clear(whitelist.data)
		table.clear(whitelist)
	end})
end)
shared.vapewhitelist = whitelist
repeat task.wait() until shared.vapewhitelist.loaded
if shared.vapewhitelist:get(game:GetService("Players").LocalPlayer) < 1 then return end
run(function() 
	local Funny = {}
	local PersonChosen = {Value = game:GetService("Players").LocalPlayer.Name}
	Funny = GuiLibrary.ObjectsThatCanBeSaved.FunnyWindow.Api.CreateOptionsButton({
		Name = 'FunnyExploit',
		Function = function(calling)
			if calling then 
				game:GetService("Players").LocalPlayer.Character = workspace:FindFirstChild(PersonChosen.Value)
			else
				game:GetService("Players").LocalPlayer.Character = workspace:FindFirstChild(game:GetService("Players").LocalPlayer.Name)
			end
		end
	}) 
	local list = {}
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do table.insert(list, v.Name) end
	game:GetService("Players").PlayerRemoving:Connect(function(plr)
		for i,v in pairs(list) do
			if v == plr.Name then table.remove(list, i) end
		end
	end)
	game:GetService("Players").PlayerAdded:Connect(function(plr)
		if (not list[plr.Name]) then
			table.insert(list, plr.Name)
		end
	end)
	table.insert(list, "INFINITE_TESTINGG")
	PersonChosen = Funny.CreateDropdown({
		Name = 'Funny Mode',
		List = list,
		Function = function(calling)
			if calling then 
				if PersonChosen.Value ~= "INFINITE_TESTINGG" then
					game:GetService("Players").LocalPlayer.Character = workspace:FindFirstChild(PersonChosen.Value)
				else
					local a = Instance.new("Model")
					a.Parent = workspace
					a.Name = "chasemaser"
					game:GetService("Players").LocalPlayer.Character = a
				end
			end
		end,
		NoSave = true
	})
end)
--[[getgenv().TeleportExploitFunction = function()
	local TeleportService = game:GetService("TeleportService")
	local e2 = TeleportService:GetLocalPlayerTeleportData()
	game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer, e2)
end
shared.TeleportExploitFunction = TeleportExploitFunction
run(function() 
	local TPExploit = {}
	TPExploit = GuiLibrary.ObjectsThatCanBeSaved.FunnyWindow.Api.CreateOptionsButton({
		Name = "FunnyTeleportExploit",
		Function = function(calling)
			if calling then 
				TPExploit.ToggleButton()
				local TeleportService = game:GetService("TeleportService")
				local e2 = TeleportService:GetLocalPlayerTeleportData()
				game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer, e2)
			end
		end
	}) 
end)--]]

run(function() 
	local Funny = {}
	local PersonChosen = {Value = game:GetService("Players").LocalPlayer.Name}
	Funny = GuiLibrary.ObjectsThatCanBeSaved.FunnyWindow.Api.CreateOptionsButton({
		Name = 'FunnyExploit',
		Function = function(calling)
			if calling then 
				game:GetService("Players").LocalPlayer.Character = workspace:FindFirstChild(PersonChosen.Value)
			else
				game:GetService("Players").LocalPlayer.Character = workspace:FindFirstChild(game:GetService("Players").LocalPlayer.Name)
			end
		end
	}) 
	local list = {}
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do table.insert(list, v.Name) end
	game:GetService("Players").PlayerRemoving:Connect(function(plr)
		for i,v in pairs(list) do
			if v == plr.Name then table.remove(list, i) end
		end
	end)
	game:GetService("Players").PlayerAdded:Connect(function(plr)
		if (not list[plr.Name]) then
			table.insert(list, plr.Name)
		end
	end)
	table.insert(list, "INFINITE_TESTINGG")
	PersonChosen = Funny.CreateDropdown({
		Name = 'BetterSpectatorMode',
		List = list,
		Function = function(calling)
			if calling then 
				if PersonChosen.Value ~= "INFINITE_TESTINGG" then
					game:GetService("Players").LocalPlayer.Character = workspace:FindFirstChild(PersonChosen.Value)
				else
					local a = Instance.new("Model")
					a.Parent = workspace
					a.Name = "chasemaser"
					game:GetService("Players").LocalPlayer.Character = a
				end
			end
		end,
		NoSave = true
	})
end)
getgenv().TeleportExploitFunction = function()
	local TeleportService = game:GetService("TeleportService")
	local e2 = TeleportService:GetLocalPlayerTeleportData()
	game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer, e2)
end
shared.TeleportExploitFunction = TeleportExploitFunction
local function tp(a)
	local TeleportService = game:GetService("TeleportService")
	local e2 = TeleportService:GetLocalPlayerTeleportData()
	local id = game.PlaceId
	if a then id = tonumber(a) end
	game:GetService("TeleportService"):Teleport(id, game.Players.LocalPlayer, e2)
end
local GuiLibrary = shared.GuiLibrary
local entityLibrary = shared.vapeentity
local store = shared.GlobalStore
local bedwars = shared.GlobalBedwars
run(function() 
	local TPExploit = {}
	local AutowinMode = {Enabled = false}
	local AntiFailure = {Enabled = false}
	local CustomGame = {Enabled = false}
	local GameChoice = {Value = "Duels"}

	local GameModes = {
		["30v30"] = 8444591321,
		["Doubles"] = 6872274481,
		["Solos"] = 8560631822,
		["5v5"] = 6872274481,
		["Squads"] = 6872274481,
		["Duels"] = 8560631822
	}
	local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
	local function a()
		local queue = shared.GlobalStore.queueType
		if shared.HasTeleported then return InfoNotification("EmptyGameTP" ,"Failure loading into next game! Please wait to queue into a valid game!", 7) end
		queueonteleport([[shared.HasTeleported = true]])
		if CustomGame.Enabled and GameChoice.Value ~= "" then
			tp(GameModes[GameChoice.Value])
		else
			tp()
		end
	end
	TPExploit = GuiLibrary.ObjectsThatCanBeSaved.FunnyWindow.Api.CreateOptionsButton({
		Name = "EmptyGameTP-Private",
		Function = function(calling)
			if calling then 
				if AutowinMode.Enabled then
					if AntiFailure.Enabled then
						shared.TeleportExploitAutowinEnabled = true
					end
					task.spawn(function()
						repeat task.wait() until store.matchState
						if store.matchState < 1 then
							InfoNotification("EmptyGameTP - AutowinMode", "Waiting for the game to start...", 3)
						end
						repeat task.wait() until store.matchState > 0
						if store.matchState == 1 then
							InfoNotification("EmptyGameTP - AutowinMode", "Using Autowin to win the match...", 3)
							repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.AutowinOptionsButton
							if (not GuiLibrary.ObjectsThatCanBeSaved.AutowinOptionsButton.Api.Enabled) then
								GuiLibrary.ObjectsThatCanBeSaved.AutowinOptionsButton.Api.ToggleButton(false)
							end
							repeat task.wait() until store.matchState == 2
							InfoNotification("EmptyGameTP - AutowinMode", "Teleporting to the next match...", 3)
							a()
						elseif store.matchState == 2 then
							InfoNotification("EmptyGameTP - AutowinMode", "Teleporting to the next match...", 3)
							a()
						end
					end)
				else
					TPExploit.ToggleButton()
					a()
				end
			end
		end
	}) 
	AutowinMode = TPExploit.CreateToggle({
		Name = "AutowinMode",
		Function = function() end,
		Default = true,
		HoverText = "Auto wins the games and gets you in a new one"
	})
	AntiFailure = TPExploit.CreateToggle({
		Name = "AntiFailure",
		Function = function() end,
		Default = true,
		HoverText = "Makes you auto-queue in lobby in case of error"
	})
	CustomGame = TPExploit.CreateToggle({
		Name = "CustomGame",
		Function = function() end,
		Default = false,
		HoverText = "Uses the game placeid you chose in the dropdown \n to teleport in"
	})
	local real_list = {}
	for i,v in pairs(GameModes) do table.insert(real_list, i) end
	GameChoice = TPExploit.CreateDropdown({
		Name = "PlaceId Choice",
		List = real_list,
		Function = function() 
			pcall(function()
				if CustomGame.Enabled then
					InfoNotification("EmptyGameTP - PlaceID Choice", "Successfully set the teleport placeid to "..tostring(GameModes[GameChoice.Value]).."!", 3)
				end
			end)
		end
	})
end)

local function errorNotification(title, text, delay)
    if (not text) then return end
    local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/InfoNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(220, 0, 0)
		return frame
	end)
    warn(title..": "..text)
    return (suc and res)
end

local function InfoNotification(title, text, delay)
    local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title or "Voidware", text or "Successfully called function", delay or 7, "assets/InfoNotification.png")
		return frame
	end)
	warn(title..": "..text)
	return (suc and res)
end

local function run(func)
    local success, err = pcall(func)
    if not success then
        warn("Error loading a module: " .. tostring(err))
    end
end

local VWindows = {
    ["hot"] = GuiLibrary.ObjectsThatCanBeSaved.HotWindow,
	["funny"] = GuiLibrary.ObjectsThatCanBeSaved.FunnyWindow
}

shared.next_level = shared.next_level or 1
shared.level_points = shared.level_points or 0
shared.LevelUpgradeData = shared.LevelUpgradeData or {
    ["Damage"] = 1,
    ["Speed"] = 1,
    ["Armor"] = 1,
    ["Destruction"] = 1
}

run(function()
    local AutoBuyDiamondUpgrades = {Enabled = false}
    local AutoBuyRange = {Value = 20}
    local PreferredUpgrade = {Value = "Damage"}
    local fully_upgraded_normal_diamond_upgrades = false

    local UpgradeTable = {
        ["NormalUpgrade"] = function()
            local args = {shared.next_level}
            local res = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include")
                :WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net")
                :WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestPurchaseTeamLevel")
                :InvokeServer(unpack(args))
            shared.next_level = shared.next_level + 1
            if shared.next_level > 20 then
                fully_upgraded_normal_diamond_upgrades = true
            end
            return res
        end,
        ["Damage"] = function()
            local args = {"DAMAGE", shared.LevelUpgradeData.Damage}
            local res = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include")
                :WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net")
                :WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestUpgradeStat")
                :InvokeServer(unpack(args))
            shared.LevelUpgradeData.Damage = shared.LevelUpgradeData.Damage + 1
            return res
        end,
        ["Speed"] = function()
            local args = {"SPEED", shared.LevelUpgradeData.Speed}
            local res = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include")
                :WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net")
                :WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestUpgradeStat")
                :InvokeServer(unpack(args))
            shared.LevelUpgradeData.Speed = shared.LevelUpgradeData.Speed + 1
            return res
        end,
        ["Armor"] = function()
            local args = {"ARMOR", shared.LevelUpgradeData.Armor}
            local res = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include")
                :WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net")
                :WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestUpgradeStat")
                :InvokeServer(unpack(args))
            shared.LevelUpgradeData.Armor = shared.LevelUpgradeData.Armor + 1
            return res
        end,
        ["Destruction"] = function()
            local args = {"DESTRUCTION", shared.LevelUpgradeData.Destruction}
            local res = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include")
                :WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net")
                :WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestUpgradeStat")
                :InvokeServer(unpack(args))
            shared.LevelUpgradeData.Destruction = shared.LevelUpgradeData.Destruction + 1
            return res
        end
    }

    local LevelTable = {
        [1] = {["Cost"] = 1, ["Points"] = 0},
        [2] = {["Cost"] = 1, ["Points"] = 1},
        [3] = {["Cost"] = 1, ["Points"] = 0},
        [4] = {["Cost"] = 1, ["Points"] = 0},
        [5] = {["Cost"] = 2, ["Points"] = 1},
        [6] = {["Cost"] = 2, ["Points"] = 0},
        [7] = {["Cost"] = 2, ["Points"] = 0},
        [8] = {["Cost"] = 2, ["Points"] = 0},
        [9] = {["Cost"] = 4, ["Points"] = 0},
        [10] = {["Cost"] = 4, ["Points"] = 1},
        [11] = {["Cost"] = 4, ["Points"] = 0},
        [12] = {["Cost"] = 4, ["Points"] = 0},
        [13] = {["Cost"] = 4, ["Points"] = 0},
        [14] = {["Cost"] = 4, ["Points"] = 0},
        [15] = {["Cost"] = 6, ["Points"] = 1},
        [16] = {["Cost"] = 6, ["Points"] = 0},
        [17] = {["Cost"] = 6, ["Points"] = 0},
        [18] = {["Cost"] = 8, ["Points"] = 0},
        [19] = {["Cost"] = 8, ["Points"] = 0},
        [20] = {["Cost"] = 10, ["Points"] = 1}
    }

    AutoBuyDiamondUpgrades = VWindows.funny.Api.CreateOptionsButton({
        Name = 'AutoBuyDiamondUpgrades',
        Function = function(calling)
            if calling then
				if shared.GlobalStore.queueType == "skywars_to2" then 
					errorNotification("AutoBuyDiamondUpgrades", "Skywars not supported", 5)
					AutoBuyDiamondUpgrades.ToggleButton(false)
					return
				end
                local function getNPC()
                    repeat task.wait() until store.matchState == 1
                    local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam.id
                    local npc = workspace:FindFirstChild(tostring(myTeam) .. "_upgrade_shop_" .. tostring(tonumber(myTeam) - 1))
                    if npc then
                        local real_npc = npc:FindFirstChild("florist")
                        return real_npc ~= nil, real_npc
                    else
                        return false, nil
                    end
                end

                local function nearNPC(range)
                    local success, npc = getNPC()
                    if success then
                        local player = game:GetService("Players").LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local playerPosition = character.HumanoidRootPart.Position
                        local npcPosition = npc.PrimaryPart.Position
                        local distance = (playerPosition - npcPosition).Magnitude
                        return true, distance <= range, nil
                    else
                        return false, nil, "NPC Issue"
                    end
                end

                local function getDiamonds()
                    for _, item in pairs(store.localInventory.inventory.items) do
                        if item.itemType:find("diamond") then
                            return true, item.amount
                        end
                    end
                    return false, nil
                end

                local function buyUpgrade(upgrade)
                    if UpgradeTable[upgrade] then
                        return true, UpgradeTable[upgrade](), nil
                    else
                        return false, nil, "Unknown upgrade type"
                    end
                end
                local fully_bought_everything = false
                task.spawn(function()
                    repeat
                        task.wait(0.1)
                        if shared.level_points == 0 and fully_upgraded_normal_diamond_upgrades then full_bought_everything = true end
                        local success, inRange, err = nearNPC(AutoBuyRange.Value)
                        if success and inRange then
                            local successDiamonds, diamonds = getDiamonds()
                            if successDiamonds then
                                if (not fully_upgraded_normal_diamond_upgrades) and LevelTable[shared.next_level]["Cost"] <= diamonds then
                                    local pointsReward = LevelTable[shared.next_level]["Points"]
                                    local successUpgrade, resultUpgrade, errUpgrade = buyUpgrade("NormalUpgrade")
                                    if successUpgrade and resultUpgrade then
                                        InfoNotification("AutoBuyDiamondUpgrades", "Successfully upgraded to Level "..tostring(tonumber(shared.next_level) - 1), 5)
                                    end
                                    if successUpgrade and resultUpgrade then
                                        shared.level_points = shared.level_points + pointsReward
                                    else
                                        errorNotification("AutoBuyDiamondUpgrades", tostring(errUpgrade), 10)
                                    end
                                end

                                task.spawn(function()
                                    pcall(function()
                                        if shared.level_points > 0 then
                                            local current_upgrade = PreferredUpgrade.Value
                                            local function getRandomUpgrade()
                                                for i,v in pairs(shared.LevelUpgradeData) do
                                                    if i ~= current_upgrade then return i end
                                                end
                                            end
                                            if shared.LevelUpgradeData[current_upgrade] == 3 then
                                                current_upgrade = getRandomUpgrade()
                                            end
                                            if shared.LevelUpgradeData[current_upgrade] ~= 3 then
                                                local suc4, res3, err3 = buyUpgrade(current_upgrade)
                                                if suc4 and res3 then
                                                    InfoNotification("AutoBuyDiamondUpgrades", "Successfully upgraded "..tostring(current_upgrade).." to level "..tostring(shared.LevelUpgradeData[current_upgrade]), 5)
                                                end
                                                if suc4 then
                                                    if res3 then
                                                        shared.level_points = shared.level_points - 1
                                                    end
                                                else
                                                    errorNotification("AutoBuyDiamondUpgrades", tostring(err3), 10)
                                                end
                                            end
                                        end
                                    end)
                                end)
                            end
                        else
                            if (not success) then errorNotification("AutoBuyDiamondUpgrades", tostring(err), 5) end
                        end
                    until ((not AutoBuyDiamondUpgrades.Enabled) or fully_bought_everything)
                end)
            end
        end
    })

    AutoBuyRange = AutoBuyDiamondUpgrades.CreateSlider({
        Name = "AutoBuyRange",
        Min = 5,
        Max = 20,
        Function = function() end,
        Default = 20
    })

    PreferredUpgrade = AutoBuyDiamondUpgrades.CreateDropdown({
        Name = "PreferredUpgrade",
        List = {"Damage", "Speed", "Armor", "Destruction"},
        Function = function() end
    })

    shared.AutoBuyDiamondUpgrades = AutoBuyDiamondUpgrades
end)
