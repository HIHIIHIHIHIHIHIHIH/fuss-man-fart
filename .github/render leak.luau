    --[[

    $$$$$$$\                            $$\                           $$$$$$\            $$\                          $$\               
    $$  __$$\                           $$ |                          \_$$  _|           $$ |                         $$ |              
    $$ |  $$ | $$$$$$\  $$$$$$$\   $$$$$$$ | $$$$$$\   $$$$$$\          $$ |  $$$$$$$\ $$$$$$\    $$$$$$\  $$$$$$$\ $$$$$$\    $$$$$$$\ 
    $$$$$$$  |$$  __$$\ $$  __$$\ $$  __$$ |$$  __$$\ $$  __$$\         $$ |  $$  __$$\\_$$  _|  $$  __$$\ $$  __$$\\_$$  _|  $$  _____|
    $$  __$$< $$$$$$$$ |$$ |  $$ |$$ /  $$ |$$$$$$$$ |$$ |  \__|        $$ |  $$ |  $$ | $$ |    $$$$$$$$ |$$ |  $$ | $$ |    \$$$$$$\  
    $$ |  $$ |$$   ____|$$ |  $$ |$$ |  $$ |$$   ____|$$ |              $$ |  $$ |  $$ | $$ |$$\ $$   ____|$$ |  $$ | $$ |$$\  \____$$\ 
    $$ |  $$ |\$$$$$$$\ $$ |  $$ |\$$$$$$$ |\$$$$$$$\ $$ |            $$$$$$\ $$ |  $$ | \$$$$  |\$$$$$$$\ $$ |  $$ | \$$$$  |$$$$$$$  |
    \__|  \__| \_______|\__|  \__| \_______| \_______|\__|            \______|\__|  \__|  \____/  \_______|\__|  \__|  \____/ \_______/ 

    Bedwarz Client Side Anticheat Paste
    
    --> Reasons: 
        Bedwarz is a shitty bedwars ripoff owned by < 13 fags and pasters!

    -- Contributors:
        GodClutcher

    --> Leaks: 
        https://renderintents.xyz
        https://discord.gg/renderintents
]]

local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local chances = 10
local currentChance = 0
local anticheat = true

local teleporting = false
local flying = false
local speeding = false

local minMagnitude = 1
local minSpeed = 50
local minTeleportDist = 10

local previousVelocity = HumanoidRootPart.AssemblyLinearVelocity
local previousPosition = HumanoidRootPart.Position

local connection = nil
local teleportConnection = nil

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {character}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function Fix()
	task.delay(3, function()
		teleporting = false
		flying = false
		speeding = false

		anticheat = true
	end)
end

local function Anticheat()
	if anticheat then
		anticheat = false

		Fix()
	end
end

local function IsTeleporting()
	local currentPosition = HumanoidRootPart.Position
	local distance = math.abs((currentPosition - previousPosition).Magnitude)

	if distance >= minTeleportDist then
		teleporting = true
		currentChance += 1

		if currentChance >= chances then
			currentChance = 0
			Anticheat()
		end

	elseif distance < minTeleportDist and currentChance > 0 and teleporting and not speeding and not flying and not teleportConnection then
		teleportConnection = task.delay(0.5, function()
			if not teleporting then
				currentChance = 0
				teleportConnection = nil
			end
		end)
	end

	previousPosition = currentPosition
end

local function IsFlying()
	local origin = HumanoidRootPart.Position
	local direction = Vector3.new(0, -25, 0)
	local raycast = workspace:Raycast(origin, direction, raycastParams)

	local velocity = HumanoidRootPart.AssemblyLinearVelocity

	if not raycast and not speeding and not teleporting then
		local magnitude = math.abs(previousVelocity.Y - velocity.Y)

		if magnitude <= minMagnitude then
			flying = true
			currentChance += 1

			if currentChance >= chances then
				currentChance = 0
				Anticheat()
			end

		elseif magnitude > minMagnitude and currentChance > 0 then
			currentChance -= 1
		end

	elseif raycast and not speeding and not teleporting and flying and currentChance > 0 then
		currentChance -= 1
	end

	previousVelocity = velocity
end

local function IsSpeeding()
	local velocity = HumanoidRootPart.AssemblyLinearVelocity
	local speed = math.abs(velocity.X) + math.abs(velocity.Z)

	if speed >= minSpeed and not flying and not teleporting then
		speeding = true
		currentChance += 1

		if currentChance >= chances then
			currentChance = 0
			Anticheat()
		end

	elseif speed < minSpeed and speeding and not flying and not teleporting and currentChance > 0 then
		currentChance -= 1
	end
end

connection = RunService.Heartbeat:Connect(function()
	if anticheat then
		IsTeleporting()
		IsFlying()
		IsSpeeding()
	end
end)

humanoid.Died:Once(function()
	if connection then
		connection:Disconnect()
	end
end)
