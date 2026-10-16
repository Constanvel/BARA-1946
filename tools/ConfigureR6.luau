-- Run in Edit mode. Uses Roblox's rig generator, not a Toolbox asset.
local starter = game:GetService("StarterPlayer")
assert(not starter:FindFirstChild("StarterCharacter"), "Preserve the existing custom character")
local description = Instance.new("HumanoidDescription")
description.HeadColor = Color3.fromRGB(191, 158, 128)
description.LeftArmColor, description.RightArmColor = description.HeadColor, description.HeadColor
description.TorsoColor = Color3.fromRGB(113, 105, 78)
description.LeftLegColor, description.RightLegColor = Color3.fromRGB(63, 66, 54), Color3.fromRGB(63, 66, 54)
local character = game:GetService("Players"):CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R6)
description:Destroy()
character.Name = "StarterCharacter"
assert(character.Humanoid.RigType == Enum.HumanoidRigType.R6, "Expected R6")
starter.LoadCharacterAppearance = false
character.Parent = starter
return {rig = character.Humanoid.RigType.Name, template = character:GetFullName()}
