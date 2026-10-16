-- Read-only Edit-mode checks. Live combat is tested separately.
local scene = workspace:FindFirstChild("BARA_Phase3")
assert(scene, "Phase 3 arena is missing")
assert(#scene.Enemies:GetChildren() == 2, "Arena must contain exactly two opponents")
for _, enemy in scene.Enemies:GetChildren() do
    assert(enemy:GetAttribute("HP") == 1 and enemy:GetAttribute("State") == "Idle", "Initial enemy state is incorrect")
    for _, item in enemy:GetDescendants() do
        assert(not item:IsA("LuaSourceContainer"), "Enemies must not have duplicated AI scripts")
        if item:IsA("BasePart") then assert(item.Anchored and not item.CanCollide, "Enemy physics should be server-owned") end
    end
end
assert(scene.Static.ExitPanel.CanCollide and scene.Static.EntryPanel.CanCollide, "Arena gates must begin closed")
assert(scene.EntrySign.StartArena.KeyboardKeyCode == Enum.KeyCode.E, "Entry must use interaction E")
local network = game:GetService("ReplicatedStorage").BARA_Network
local count = 0
for _, event in network:GetChildren() do if event.Name == "CombatEvent" then count += 1 end end
assert(count == 1 and network.CombatEvent:IsA("RemoteEvent"), "Combat event was duplicated")
local gui = game:GetService("StarterGui").BARA_Combat
assert(not gui.ResetOnSpawn and not gui.GameOver.Visible and not gui.MainMenu.Visible, "Combat UI initial state is incorrect")
assert(gui.GameOver:FindFirstChild("Retry") and gui.GameOver:FindFirstChild("MainMenu"), "Missing Game Over controls")
assert(game:GetService("StarterPlayer").StarterCharacterScripts:FindFirstChild("Health"), "Health override must be in StarterCharacterScripts to disable regeneration")
assert(workspace:FindFirstChild("BARA_Phase1") and workspace:FindFirstChild("BARA_Phase2"), "Previous scenes were replaced")
return {passed = true, enemies = 2, combatEvents = count, previousPhasesPresent = true}
