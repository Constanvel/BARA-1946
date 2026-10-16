-- Read-only structural checks in Edit mode.
local scene = workspace:FindFirstChild("BARA_Phase2")
assert(scene, "Missing Phase 2 scene")
local prompts = 0
for _, item in scene:GetDescendants() do
    if item:IsA("ProximityPrompt") then
        prompts += 1
        assert(item.KeyboardKeyCode == Enum.KeyCode.E, "Interaction must use E")
        assert(item.MaxActivationDistance == 10, "Unexpected interaction distance")
    end
    if item:IsA("BasePart") then assert(item.Anchored, "Unanchored Phase 2 part") end
    assert(not item:IsA("LuaSourceContainer"), "Static NPC must not contain copied scripts")
end
assert(prompts == 3, "Expected letter, guard, and gate prompts")
local leg = scene.ResistancePost.Guard["Left Leg"]
assert(math.abs(leg.Position.Y - leg.Size.Y / 2 - 0.2) < 0.1, "Guard feet are not on the ground")
assert(scene.RefugeeGate.Panel.CanCollide, "Gate must initially be locked")
assert(scene.RefugeeGate:GetAttribute("State") == "Closed", "Initial gate state is wrong")
local rays = RaycastParams.new()
rays.FilterType = Enum.RaycastFilterType.Include
rays.FilterDescendantsInstances = {scene.RefugeeGate}
for _, x in {-30, 30} do
    local hit = workspace:Raycast(Vector3.new(x, 4, -170), Vector3.new(0, 0, -14), rays)
    assert(hit and hit.Instance.CanCollide, "Gate can be bypassed through the side yard")
end
local gui = game:GetService("StarterGui").BARA_Dialogue
assert(not gui.Enabled and not gui.ResetOnSpawn, "Dialogue should start closed and survive respawn")
assert(gui.Panel:FindFirstChild("Continue") and gui.Panel:FindFirstChild("Close"), "Dialogue exit controls missing")
assert(game:GetService("ReplicatedStorage").BARA_Network.DialogueEvent:IsA("RemoteEvent"), "Missing dialogue network")
local server = game:GetService("ServerScriptService").BARA
assert(server.InteractionServer.RunContext == Enum.RunContext.Server, "Gameplay must run on server")
assert(server:FindFirstChild("LetterProgress") and server:FindFirstChild("InteractionRules"), "Missing reusable server modules")
assert(game:GetService("StarterPlayer").StarterPlayerScripts.BARA.DialogueClient:IsA("LocalScript"), "Missing dialogue client")
return {passed = true, prompts = prompts, gate = "Closed", phase1Preserved = workspace:FindFirstChild("BARA_Phase1") ~= nil}
