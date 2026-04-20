-- ====== Rayfield Movement Hacks - Industriallist (Đã sửa lỗi) ====== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
Rayfield:LoadConfiguration()

local Window = Rayfield:CreateWindow({
    Name = "Movement Hacks - Industriallist",
    LoadingTitle = "Fly | Noclip | Speed | Jump",
    LoadingSubtitle = "bởi ái ny💖💗💓",
    ConfigurationSaving = { Enabled = true, FolderName = "MovementHacks", FileName = "Config" },
})

local MovementTab = Window:CreateTab("Movement", 4483362458)

-- ====== Services ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Variables
local FlyEnabled = false
local NoclipEnabled = false
local FlySpeed = 100
local BodyVelocity = nil
local BodyGyro = nil

-- Update character khi respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- ====== Fly Function (Đã sửa) ======
local function StartFly()
    if BodyVelocity then BodyVelocity:Destroy() end
    if BodyGyro then BodyGyro:Destroy() end

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Name = "FlyVelocity"
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.Velocity = Vector3.new(0,0,0)
    BodyVelocity.Parent = RootPart

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.Name = "FlyGyro"
    BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    BodyGyro.P = 15000
    BodyGyro.Parent = RootPart

    FlyEnabled = true

    local currentVelocity = Vector3.new(0,0,0)
    local acceleration = 0.25

    task.spawn(function()
        while FlyEnabled and RootPart and RootPart.Parent do
            pcall(function()
                local cam = workspace.CurrentCamera
                local moveDirection = Vector3.new(0,0,0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection -= Vector3.new(0,1,0) end

                local targetVelocity = Vector3.new(0,0,0)
                if moveDirection.Magnitude > 0 then
                    targetVelocity = moveDirection.Unit * FlySpeed
                end

                currentVelocity = currentVelocity:Lerp(targetVelocity, acceleration)
                BodyVelocity.Velocity = currentVelocity
                BodyGyro.CFrame = cam.CFrame
            end)
            task.wait()
        end

        if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
        if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    end)
end

local function StopFly()
    FlyEnabled = false
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
end

-- ====== Noclip ======
local NoclipConnection
local function ToggleNoclip(state)
    NoclipEnabled = state
    if state then
        if NoclipConnection then NoclipConnection:Disconnect() end
        NoclipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
    end
end

-- ====== Menu ======
MovementTab:CreateToggle({
    Name = "Bay (Fly)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            StartFly()
        else
            StopFly()
        end
    end
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {50, 500},
    Increment = 10,
    Suffix = "Studs/s",
    CurrentValue = FlySpeed,
    Callback = function(Value)
        FlySpeed = Value
    end
})

MovementTab:CreateToggle({
    Name = "Đi xuyên tường (Noclip)",
    CurrentValue = false,
    Callback = function(Value)
        ToggleNoclip(Value)
    end
})

MovementTab:CreateSlider({
    Name = "Chạy nhanh (WalkSpeed)",
    Range = {16, 300},
    Increment = 5,
    Suffix = "Studs/s",
    CurrentValue = Humanoid.WalkSpeed,
    Callback = function(Value)
        if Humanoid then 
            Humanoid.WalkSpeed = Value 
        end
    end
})

MovementTab:CreateSlider({
    Name = "Sức nhảy (JumpPower)",
    Range = {50, 300},
    Increment = 5,
    Suffix = "",
    CurrentValue = Humanoid.JumpPower,
    Callback = function(Value)
        if Humanoid then 
            Humanoid.JumpPower = Value 
        end
    end
})

local InfiniteJumpEnabled = false
local JumpConnection
MovementTab:CreateToggle({
    Name = "Nhảy vô hạn (Infinite Jump)",
    CurrentValue = false,
    Callback = function(Value)
        InfiniteJumpEnabled = Value
        if Value then
            if JumpConnection then JumpConnection:Disconnect() end
            JumpConnection = UserInputService.JumpRequest:Connect(function()
                if Humanoid and InfiniteJumpEnabled then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if JumpConnection then
                JumpConnection:Disconnect()
                JumpConnection = nil
            end
        end
    end
})

print("✅ Movement Hacks đã load thành công! Mở menu bằng RightShift hoặc F4")
