-- Run in Studio Edit mode through MCP; does not modify the scene.
local scene = workspace:FindFirstChild("BARA_Phase1")
assert(scene, "Phase 1 environment has not been built")
for _, name in {"GroundAndRoads", "Area01_Kampung", "Area02_Kolonial", "Area03_PosPejuang"} do
    assert(scene:FindFirstChild(name), "Missing area: " .. name)
end
local count = 0
for _, item in scene:GetDescendants() do
    if item:IsA("BasePart") then
        count += 1
        assert(item.Anchored, "Unanchored environment: " .. item:GetFullName())
    end
    assert(not item:IsA("LuaSourceContainer"), "Environment must not contain runtime builders")
end
assert(count <= 850, "Phase 1 exceeded its part budget")
local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Include
overlap.FilterDescendantsInstances = {scene}
local samples = 0
for z = 70, -200, -5 do
    local obstacles = workspace:GetPartBoundsInBox(CFrame.new(0, 4, z), Vector3.new(8, 5, 3), overlap)
    for _, item in obstacles do
        assert(not item.CanCollide, "Blocked main route: " .. item:GetFullName())
    end
    local ray = workspace:Raycast(Vector3.new(0, 12, z), Vector3.new(0, -20, 0))
    assert(ray and ray.Instance.CanCollide, "No walkable ground at z=" .. z)
    samples += 1
end
local starter = game:GetService("StarterPlayer")
assert(starter.CameraMode == Enum.CameraMode.Classic, "Expected built-in classic camera")
assert(starter.CameraMinZoomDistance >= 8, "First-person zoom is still allowed")
assert(starter.CameraMaxZoomDistance <= 32, "Camera can leave the intended map view")
assert(starter.StarterPlayerScripts.BARA:FindFirstChild("FoundationCamera"), "Missing camera setup")
assert(game:GetService("Lighting"):FindFirstChild("BARA_Retro"), "Missing retro color grade")
local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
assert(spawn and spawn.Enabled and spawn.Anchored and spawn.CanCollide, "Spawn is not ready")
return {passed = true, anchoredParts = count, clearRouteSamples = samples, areas = 3}
