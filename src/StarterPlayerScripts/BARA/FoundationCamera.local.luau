--!strict
-- Keep Roblox camera controls, smoothing, and obstacle handling.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function frameCharacter(character: Model)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoid or not humanoid:IsA("Humanoid") or not root or not root:IsA("BasePart") then
        return
    end
    if player.Character ~= character then
        return
    end
    humanoid.CameraOffset = Vector3.new(0, 1.5, 0)
    RunService.RenderStepped:Wait()
    local camera = workspace.CurrentCamera
    if camera and player.Character == character then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = humanoid
        camera.CFrame = CFrame.lookAt(root.Position + Vector3.new(0, 13, 19), root.Position + Vector3.new(0, 1.5, 0))
    end
end

player.CharacterAdded:Connect(frameCharacter)
if player.Character then
    task.spawn(frameCharacter, player.Character)
end
