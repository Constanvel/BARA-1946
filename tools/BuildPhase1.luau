-- Run once in Studio Edit mode through MCP. Generated geometry stays in the place.
-- This is an illustrative Bandung-inspired layout, not a historical reconstruction.
assert(not workspace:FindFirstChild("BARA_Phase1"), "Phase 1 already exists; do not rebuild over edits")
local scene = Instance.new("Model")
scene.Name = "BARA_Phase1"
scene:SetAttribute("Phase", 1)
scene:SetAttribute("Version", 1)
scene.Parent = workspace

local C = {
    earth = Color3.fromRGB(103, 96, 77), road = Color3.fromRGB(90, 85, 74),
    stone = Color3.fromRGB(133, 127, 108), wall = Color3.fromRGB(173, 160, 131),
    pale = Color3.fromRGB(194, 181, 151), wood = Color3.fromRGB(92, 73, 54),
    roof = Color3.fromRGB(125, 76, 55), roofLine = Color3.fromRGB(98, 61, 47),
    window = Color3.fromRGB(51, 61, 57), leaf = Color3.fromRGB(79, 87, 57),
    darkLeaf = Color3.fromRGB(64, 73, 51), metal = Color3.fromRGB(58, 60, 55),
    warm = Color3.fromRGB(231, 166, 83), cloth = Color3.fromRGB(124, 118, 84),
}
local function model(parent, name)
    local m = Instance.new("Model")
    m.Name = name
    m.WorldPivot = CFrame.identity
    m.Parent = parent
    return m
end
local function part(parent, name, size, frame, color, collide)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame, p.Color = name, size, frame, color
    p.Anchored = true
    p.Material = Enum.Material.SmoothPlastic
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.CanCollide = collide ~= false
    p.CanTouch = false
    p.CanQuery = p.CanCollide
    p.CastShadow = p.CanCollide
    p.Parent = parent
    return p
end
local function block(parent, name, x, y, z, sx, sy, sz, color, collide)
    return part(parent, name, Vector3.new(sx, sy, sz), CFrame.new(x, y, z), color, collide)
end
local function roof(parent, width, depth, height)
    local angle = math.rad(26)
    local span = (width + 3) / 2
    for _, side in {-1, 1} do
        local frame = CFrame.new(side * span / 2, height + 1.2, 0) * CFrame.Angles(0, 0, -side * angle)
        part(parent, "Genteng", Vector3.new(span / math.cos(angle), 0.65, depth + 3), frame, C.roof, false)
        for row = -1, 1 do
            part(parent, "BarisGenteng", Vector3.new(span / math.cos(angle), 0.12, 0.16), frame * CFrame.new(0, 0.37, row * (depth + 3) / 4), C.roofLine, false)
        end
    end
    block(parent, "Bubungan", 0, height + 1.2 + span / 2 * math.tan(angle), 0, 0.8, 0.7, depth + 4, C.roofLine, false)
end
local function house(parent, name, x, z, width, depth, height, yaw, colonial)
    local m = model(parent, name)
    block(m, "Pondasi", 0, 0.6, 0, width + 1, 0.8, depth + 1, C.stone)
    block(m, "Dinding", 0, height / 2 + 0.9, 0, width, height, depth, colonial and C.pale or C.wall)
    block(m, "Pintu", 0, 3.5, -depth / 2 - 0.13, 4, 5.5, 0.2, C.wood, false)
    for _, side in {-1, 1} do
        block(m, "JendelaDepan", side * width * 0.3, 5.8, -depth / 2 - 0.15, 4, 3.8, 0.25, C.window, false)
        block(m, "Ambang", side * width * 0.3, 3.8, -depth / 2 - 0.3, 4.6, 0.35, 0.6, C.wood, false)
        block(m, "JendelaSamping", side * (width / 2 + 0.12), 5.8, 0, 0.25, 3.8, 4, C.window, false)
    end
    block(m, "LisAtap", 0, height + 0.7, 0, width + 1, 0.65, depth + 1, C.wood, false)
    roof(m, width, depth, height + 1.1)
    if colonial then
        block(m, "Teras", 0, 0.65, -depth / 2 - 3.5, width, 0.8, 7, C.stone)
        for _, px in {-width / 2 + 1, -width / 6, width / 6, width / 2 - 1} do
            block(m, "Pilar", px, 5.6, -depth / 2 - 5.5, 1, 9.5, 1, C.pale)
        end
        block(m, "KanopiKolonial", 0, 10.5, -depth / 2 - 3.5, width + 2, 1.1, 8, C.pale, false)
    end
    m:PivotTo(CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(yaw), 0))
    return m
end
local function fence(parent, name, x, z, length, yaw)
    local m = model(parent, name)
    for px = -length / 2, length / 2, 4 do
        block(m, "Papan", px, 2.7, 0, 0.8, 4.5, 0.55, C.wood)
    end
    for _, y in {1.6, 3.7} do block(m, "Palang", 0, y, 0.35, length + 1, 0.45, 0.45, C.wood, false) end
    m:PivotTo(CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(yaw), 0))
end
local function tree(parent, x, z, variant)
    local m = model(parent, "PohonLowPoly")
    block(m, "Batang", 0, 5, 0, 1.8, 10, 1.8, C.wood)
    part(m, "TajukBawah", Vector3.new(10, 6, 9), CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(variant * 17), math.rad(8)), C.leaf, false)
    part(m, "TajukAtas", Vector3.new(7, 5, 7), CFrame.new(1, 14, 0) * CFrame.Angles(0, math.rad(variant * 33), math.rad(-9)), C.darkLeaf, false)
    m:PivotTo(CFrame.new(x, 0, z))
end
local function lamp(parent, x, z)
    local m = model(parent, "TiangLampu")
    block(m, "Dasar", x, 0.9, z, 2, 1.3, 2, C.stone)
    block(m, "Tiang", x, 6.9, z, 0.65, 12, 0.65, C.metal)
    block(m, "AtapLentera", x, 13.5, z, 2.5, 0.5, 2.5, C.metal, false)
    local lightPart = block(m, "Lentera", x, 12.6, z, 1.4, 1.5, 1.4, C.warm, false)
    lightPart.Material = Enum.Material.Neon
    local light = Instance.new("PointLight")
    light.Color, light.Brightness, light.Range, light.Shadows = C.warm, 0.65, 18, false
    light.Parent = lightPart
end
local function crate(parent, x, z, scale)
    local m = model(parent, "PetiKayu")
    local size = 3 * scale
    block(m, "Kotak", x, size / 2 + 0.35, z, size, size, size, C.wood)
    for _, side in {-1, 1} do block(m, "Pengikat", x + side * size * 0.33, size / 2 + 0.35, z, 0.28, size + 0.1, size + 0.1, C.metal, false) end
end
local function sign(parent, text, x, z, width)
    local m = model(parent, "PapanPetunjuk")
    for _, side in {-1, 1} do block(m, "Tiang", x + side * (width / 2 - 0.6), 4, z, 0.7, 8, 0.7, C.wood) end
    local board = block(m, "Papan", x, 7, z, width, 3.1, 0.4, C.wood, false)
    local gui = Instance.new("SurfaceGui")
    gui.Face, gui.CanvasSize, gui.LightInfluence = Enum.NormalId.Back, Vector2.new(640, 130), 0.6
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
    label.Text, label.TextColor3 = text, C.pale
    label.Font, label.TextScaled = Enum.Font.RobotoMono, true
    label.Parent = gui
end

local ground = model(scene, "GroundAndRoads")
block(ground, "Tanah", 0, -0.8, -55, 196, 2, 320, C.earth)
block(ground, "JalanUtama", 0, 0.28, -45, 26, 0.16, 252, C.road)
block(ground, "JalanKampung", 0, 0.28, 2, 154, 0.16, 14, C.road)
block(ground, "JalanKolonial", 0, 0.28, -76, 154, 0.16, 14, C.road)
block(ground, "JalurPengungsian", 0, 0.29, -185, 15, 0.18, 60, C.stone)
for _, x in {-15, 15} do block(ground, "Trotoar", x, 0.42, -45, 3, 0.45, 252, C.stone) end
task.wait()

local kampung = model(scene, "Area01_Kampung")
for _, entry in {{-43, 53, -90}, {43, 53, 90}, {-44, 17, -90}, {44, 17, 90}} do
    house(kampung, "RumahWarga", entry[1], entry[2], 23, 22, 10, entry[3], false)
end
fence(kampung, "PagarHalamanKiri", -27, 35, 26, 90)
fence(kampung, "PagarHalamanKanan", 27, 35, 26, 90)
sign(kampung, "KAMPUNG WARGA", -32, 83, 21)
for i, pos in {{-75, 75}, {74, 75}, {-72, 25}, {75, 25}} do tree(kampung, pos[1], pos[2], i) end
crate(kampung, -24, 64, 1)
crate(kampung, 27, 9, 1.2)
task.wait()

local city = model(scene, "Area02_Kolonial")
house(city, "GedungKolonialBarat", -47, -42, 32, 27, 16, -90, true)
house(city, "GedungKolonialTimur", 47, -42, 32, 27, 16, 90, true)
house(city, "RumahTokoBarat", -48, -99, 27, 24, 12, -90, false)
house(city, "RumahTokoTimur", 48, -99, 27, 24, 12, 90, false)
sign(city, "KAWASAN KOTA", -35, -17, 20)
for i, pos in {{-76, -20}, {76, -20}, {-76, -103}, {76, -103}} do tree(city, pos[1], pos[2], i + 4) end
for _, pos in {{-19, 55}, {19, 12}, {-19, -42}, {19, -96}} do lamp(city, pos[1], pos[2]) end
task.wait()

local post = model(scene, "Area03_PosPejuang")
house(post, "PosPejuang", -40, -147, 24, 22, 9, -90, false)
sign(post, "POS PEJUANG", -30, -124, 20)
sign(post, "JALUR PENGUNGSIAN", 29, -177, 26)
for _, z in {-130, -145, -160, -175, -190} do
    fence(post, "PagarJalurKiri", -12, z, 12, 90)
    fence(post, "PagarJalurKanan", 12, z, 12, 90)
end
for _, pos in {{-24, -134}, {-24, -139}, {-27, -144}, {33, -148}, {38, -148}} do crate(post, pos[1], pos[2], 1.1) end
for i = 1, 4 do block(post, "KarungPerlindungan", 21 + i * 3, 1.3, -132, 3, 2, 2.4, C.cloth) end
block(post, "TiangBendera", -24, 9.3, -156, 0.45, 18, 0.45, C.wood)
block(post, "Merah", -21, 16.3, -156, 6, 2, 0.12, Color3.fromRGB(157, 55, 44), false)
block(post, "Putih", -21, 14.3, -156, 6, 2, 0.12, C.pale, false)
for i, pos in {{-69, -164}, {68, -163}, {-65, -195}, {61, -197}} do tree(post, pos[1], pos[2], i + 8) end
task.wait()

local edges = model(scene, "PerimeterAndBackdrop")
for _, x in {-95, 95} do
    block(edges, "DindingBatas", x, 3.6, -55, 2, 7, 318, C.stone)
end
block(edges, "DindingSelatan", 0, 3.6, 104, 192, 7, 2, C.stone)
for _, x in {-55, 55} do block(edges, "DindingUtara", x, 3.6, -214, 80, 7, 2, C.stone) end
for _, pos in {{-70, -240}, {-38, -248}, {36, -246}, {70, -238}} do
    local shell = block(edges, "SiluetKota", pos[1], 13, pos[2], 23, 26, 20, Color3.fromRGB(76, 66, 57))
    local glow = block(edges, "PendarJauh", pos[1], 6, pos[2] + 10.2, 6, 4, 0.3, Color3.fromRGB(210, 112, 51), false)
    glow.Material = Enum.Material.Neon
    shell.CastShadow = false
end

local lighting = game:GetService("Lighting")
lighting.ClockTime, lighting.Brightness, lighting.ExposureCompensation = 17.5, 2.5, 0.4
lighting.Ambient = Color3.fromRGB(155, 140, 120)
lighting.OutdoorAmbient = Color3.fromRGB(160, 144, 122)
lighting.ColorShift_Top = Color3.fromRGB(30, 17, 4)
lighting.GlobalShadows = true
lighting.FogColor = Color3.fromRGB(160, 140, 115)
lighting.FogStart, lighting.FogEnd = 100, 350
local atmosphere = lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", lighting)
atmosphere.Density, atmosphere.Offset, atmosphere.Haze, atmosphere.Glare = 0.23, 0.1, 1, 0.08
atmosphere.Color, atmosphere.Decay = Color3.fromRGB(191, 167, 137), Color3.fromRGB(104, 88, 71)
assert(not lighting:FindFirstChild("BARA_Retro"), "Retro effect already exists")
local grade = Instance.new("ColorCorrectionEffect")
grade.Name, grade.Saturation, grade.Contrast, grade.Brightness = "BARA_Retro", -0.28, 0.035, 0.015
grade.TintColor, grade.Parent = Color3.fromRGB(255, 234, 207), lighting
local bloom = lighting:FindFirstChildOfClass("BloomEffect")
if bloom then bloom.Intensity, bloom.Size, bloom.Threshold = 0.12, 24, 1.4 end
local rays = lighting:FindFirstChildOfClass("SunRaysEffect")
if rays then rays.Intensity, rays.Spread = 0.025, 0.5 end

workspace.Baseplate.Color, workspace.Baseplate.Material = C.earth, Enum.Material.SmoothPlastic
local texture = workspace.Baseplate:FindFirstChildOfClass("Texture")
if texture then texture.Transparency = 1 end
local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
assert(spawn, "Keep the existing spawn; none found")
spawn.Position, spawn.Size = Vector3.new(0, 0.7, 72), Vector3.new(6, 1, 6)
spawn.Anchored, spawn.CanCollide, spawn.Enabled, spawn.Neutral = true, true, true, true
spawn.Transparency, spawn.Duration = 1, 0
local decal = spawn:FindFirstChildOfClass("Decal")
if decal then decal.Transparency = 1 end
local starter = game:GetService("StarterPlayer")
starter.CameraMode = Enum.CameraMode.Classic
starter.CameraMinZoomDistance, starter.CameraMaxZoomDistance = 10, 26
starter.DevComputerCameraMovementMode = Enum.DevComputerCameraMovementMode.Classic
starter.CharacterWalkSpeed, starter.CharacterJumpPower = 16, 50

local count = 0
for _, item in scene:GetDescendants() do if item:IsA("BasePart") then count += 1 end end
assert(count <= 850, "Part budget exceeded")
return {built = scene:GetFullName(), parts = count, areas = 3}
