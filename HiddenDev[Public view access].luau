---------------x-----------------x------------------x-----------------x-----------------x-----------------x--------------x-----------------x-----------------x------------------x-----------------x-----------------x-----------------x
--[[ Read Only License 1.0

The ROL is an open source license for closed source projects to share thoughts on internet.

As simple as dos and don'ts.

YOU CAN:

Clone or download the project
Read the code using your eyeballs
Build or run the project
Try or test the project
Understanding or learning the implementations of the project

YOU CAN'T:

Make changes or modify the project
Re-upload the project on the internet
Re-submit the project to any market place
Take screenshots from the project
Copy & paste the files or code to any other project
Print the code as a physical paper ]]
---------------x-----------------x------------------x-----------------x-----------------x-----------------x--------------x-----------------x-----------------x------------------x-----------------x-----------------x-----------------x


---------------x-----------------x------------------x-----------------x-----------------x-----------------x--------------x-----------------x-----------------x------------------x-----------------x-----------------x-----------------x
-- Spring Module [View them in differnt file's seperatly if you find any errors]
---------------x-----------------x------------------x-----------------x-----------------x-----------------x--------------x-----------------x-----------------x------------------x-----------------x-----------------x-----------------x


-- Constants
local ITERATIONS = 8      -- number of iterations

-- Module
local SPRING = {}

-- Functions 
function SPRING.new(self, mass, force, damping, speed)

	local spring = {
		Target = Vector3.new();                                 -- position for the spring
		Position = Vector3.new();                               --  current position of spring
		Velocity = Vector3.new();                               -- ceurrent velocity of spring

		Mass = mass or 5;            -- mass of the spring
		Force = force or 50;         -- force applied to the spring
		Damping = damping or 4;      -- damping
		Speed = speed or 4;          -- speed of the spring
	}

	function spring.getstats(self)
		return self.Mass, self.Force, self.Damping, self.Speed
	end

	function spring.changestats(self, mass, force, damping, speed)
		self.Mass = mass or self.Mass                               -- update mass if provided
		self.Force = force or self.Force                            -- same thing but for force
		self.Damping = damping or self.Damping                      -- again same thing but for damping
		self.Speed = speed or self.Speed                            -- and for speed
	end

	function spring.shove(self, force)
		local x, y, z = force.X, force.Y, force.Z
		if x ~= x or x == math.huge or x == -math.huge then
			x = 0                                           -- x if it's NaN or inf
		end
		if y ~= y or y == math.huge or y == -math.huge then
			y = 0                                           -- y if it's NaN or inf
		end
		if z ~= z or z == math.huge or z == -math.huge then
			z = 0                                           -- z if it's NaN or inf (basically same thing we done for x coordinates applys for y and z)
		end
		self.Velocity = self.Velocity + Vector3.new(x, y, z) -- update velocity with the applied force
	end

	function spring.update(self, dt)
		local scaledDeltaTime = dt * self.Speed / ITERATIONS
		for i = 1, ITERATIONS do
			local iterationForce = self.Target - self.Position
			local acceleration = (iterationForce * self.Force) / self.Mass -- calculate acceleration

			acceleration = acceleration - self.Velocity * self.Damping     -- damping to acceleration

			self.Velocity = self.Velocity + acceleration * scaledDeltaTime
			self.Position = self.Position + self.Velocity * scaledDeltaTime
		end

		return self.Position
	end

	return spring
end

    return SPRING

---------------x-----------------x------------------x-----------------x-----------------x-----------------x--------------x-----------------x-----------------x------------------x-----------------x-----------------x-----------------x
-- Movement Module
---------------x-----------------x------------------x-----------------x-----------------x-----------------x--------------x-----------------x-----------------x------------------x-----------------x-----------------x-----------------x


local UserInputService = game:GetService("UserInputService") 
local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer
local PlayerHUD = Player.PlayerGui:WaitForChild("PlayerHUD")

local Bar = PlayerHUD.BottomLeft.PlayerStats.StaminaHusk.StaminaBar -- reference to the stamina UI

local Character : Model 
local Humanoid : Humanoid

local Sprinting = false 

local MaxStamina = 250                    -- max stamina value
local Stamina = MaxStamina                -- current stamina to maximum

local Handler = {}

-- Toggling Sprint
local function ToggleSprint(Bool)
    if not Humanoid then return end
    if Stamina >= 10 and Bool then                             -- if there is enough stamina to sprint
        Sprinting = true
        Humanoid.WalkSpeed = 24                                -- walk speed for sprinting
    else
        Sprinting = false
        Humanoid.WalkSpeed = 16                                -- reset walk speed to normal
    end
end

-- The Main Loop of the stamina logic, managing regeneration and depletion
local function StaminaLoop()
    while true do
        if Sprinting then
                                   -- Checking Stamina
            if Stamina <= 0 then
                ToggleSprint(false)
            else
                Stamina -= 1       -- decrease stamina while sprinting
            end
        else
            if Stamina <= MaxStamina then
                Stamina += 1        -- regenerate stamina
            end
        end

        task.wait(0.05)
    end
end

local function InputBegan(input, GPE)
    if input.KeyCode == Enum.KeyCode.LeftShift then -- if LeftShift is pressed
        ToggleSprint(true)
    elseif input.KeyCode == Enum.KeyCode.LeftAlt then -- if LeftAlt is pressed
        ToggleSprint(false)
        Humanoid.WalkSpeed = 8
    end
end

local function InputEnded(input, GPE)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        ToggleSprint(false)
    elseif input.KeyCode == Enum.KeyCode.LeftAlt then -- same thing but vice versa aka released
        ToggleSprint(false)
        Humanoid.WalkSpeed = 16
    end
end

-- Init - Setup
function Handler:Init()
    Character = Player.Character or Player.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid") 

    
    Player.CharacterAdded:Connect(function(character) 
        Character = character 
        Humanoid = Character:WaitForChild("Humanoid") 
        task.wait()
    end)

    -- Connections
    UserInputService.InputBegan:Connect(InputBegan)
    UserInputService.InputEnded:Connect(InputEnded)
    RunService.RenderStepped:Connect(function(deltaTime)
        Bar.Size = UDim2.fromScale((Stamina / MaxStamina), 1)
    end)

    -- Functions
    StaminaLoop()
end

return Handler


---------------x-----------------x------------------x-----------------x-----------------x-----------------x--------------x-----------------x-----------------x------------------x-----------------x-----------------x-----------------x
-- Camera Module
---------------x-----------------x------------------x-----------------x-----------------x-----------------x--------------x-----------------x-----------------x------------------x-----------------x-----------------x-----------------x


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Lerp = require(ReplicatedStorage.Shared.Util.Lerp) -- return function(a, b, t) return a + (b - a) * t end(lerp thing will be fixed by this)
local Mouse = Player:GetMouse()
local Camera = game.Workspace.CurrentCamera

local TouchEnabled = UserInputService.TouchEnabled

local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

local Turn = 0
local AngleX, x, y, Tilt, vX, vY, sX, sY = 0, 0, 0, 0, 0, 0, 10, 10
local randomX, randomY = nil, nil

local CameraSystem = {}

local function RenderStepped(deltaTime)
    -- Camera Sway

    local mouseDelta = UserInputService:GetMouseDelta()

    Turn = Lerp(Turn, math.clamp(mouseDelta.X, -6, 6), (15 * deltaTime)) -- smoothly adjust the turn based on mouse movement

    Camera.CFrame *= CFrame.Angles(0, 0, math.rad(Turn))

    -- Camera Bob :D
    local velocity = Root.AssemblyLinearVelocity.Magnitude
    
    if velocity > 0.02 then deltaTime *= 60 randomX = math.random(1, 2) randomY = math.random(1, 2) --x(10,15), y(5,10)
     -- Calculate camera bobbing effects based on velocity and time
        vX = deltaTime <= 2 and Lerp(vX, math.cos(tick() * 0.5 * randomX) * (math.random(5, 20) / 200) * deltaTime, 0.05 * deltaTime) or 0
        vY = deltaTime <= 2 and Lerp(vY, math.cos(tick() * 0.5 * randomY) * (math.random(2, 10) / 200) * deltaTime, 0.05 * deltaTime) or 0
    -- apply camera angles based on various calculated values
        Camera.CFrame *= CFrame.Angles(0, 0, math.rad(AngleX))
            * CFrame.Angles(math.rad(math.clamp(x * deltaTime, -0.15, 0.15)), math.rad(math.clamp(y * deltaTime, -0.5, 0.5)), Tilt)
            * CFrame.Angles(math.rad(vX), math.rad(vY), math.rad(vY * 10))

            Tilt = math.clamp(Lerp(Tilt, -Camera.CFrame:VectorToObjectSpace((Root and Root.Velocity or 
            Vector3.new()) / math.max(Player.Character.Humanoid.WalkSpeed, 0.01)).X * 0.05, 0.1 * deltaTime), -0.05, 0.05)

        if not TouchEnabled and deltaTime < 2 then
            AngleX = Lerp(AngleX, math.clamp(UserInputService:GetMouseDelta().X / deltaTime * 0.15, -2.5, 2.5), 0.25 * deltaTime)
        end 
        -- Calculate x and y for camera bobbing
        x = Lerp(x, math.sin(tick() * sX) / 5 * math.min(1, sY / 10), 0.25 * deltaTime)
        y = velocity > 1 and Lerp(y, math.cos(tick() * 0.5 * math.floor(sX)) * (sX / 200), 0.25 * deltaTime) or Lerp(y, 0, 0.05 * deltaTime)
        sX, sY = velocity > 12 and 20 or (velocity > 0.1 and 12 or 0), velocity > 0.1 and 18 or (velocity > 0.1 and 14 or 0)
    end   
end

CameraSystem.Init = function()
    -- Connections
    RunService.RenderStepped:Connect(RenderStepped)
end

return CameraSystem
