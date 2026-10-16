--!strict
local Rules = {}

function Rules.canInteract(player: Player, prompt: ProximityPrompt): boolean
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local target = prompt.Parent
    if not prompt.Enabled or not prompt:IsDescendantOf(workspace) or not target or not target:IsA("BasePart") then
        return false
    end
    if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
        return false
    end
    return (root.Position - target.Position).Magnitude <= prompt.MaxActivationDistance
end

return Rules
