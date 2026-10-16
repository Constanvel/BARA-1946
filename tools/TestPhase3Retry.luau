-- Run in Server mode immediately after the real Retry button is activated.
local player = game:GetService("Players"):GetPlayers()[1]
local arena = workspace.BARA_Phase3
assert(player:GetAttribute("BARA_CombatMode") == "Arena", "Retry incorrectly returned to map exploration")
assert(player:GetAttribute("BARA_HP") == 3 and player.Character.Humanoid.Health == 3, "Retry did not restore HP")
assert(not player.Character.HumanoidRootPart.Anchored, "Retry left the player frozen")
assert(arena:GetAttribute("OwnerUserId") == player.UserId, "Retry lost arena ownership")
assert(arena.Static.ExitPanel.CanCollide, "Retry did not close the exit gate")
assert(#arena.Enemies:GetChildren() == 2, "Retry duplicated NPCs")
for _, enemy in arena.Enemies:GetChildren() do assert(enemy:GetAttribute("HP") == 1, "Retry did not reset enemies") end
assert((player.Character.HumanoidRootPart.Position - arena.Start.Position).Magnitude < 5, "Retry missed arena spawn")
return {passed = true, hp = 3, enemies = 2, mode = "Arena"}
