-- Edit-time builder. Keeps the Phase 1/2 map, prompts, dialogue, and camera.
assert(workspace:FindFirstChild("BARA_Phase2"), "Phase 2 is required")
assert(not workspace:FindFirstChild("BARA_Phase3"), "Preserve the existing arena")
local storage, starterGui = game:GetService("ReplicatedStorage"), game:GetService("StarterGui")
assert(not storage.BARA_Network:FindFirstChild("CombatEvent"), "Combat network already exists")
assert(not starterGui:FindFirstChild("BARA_Combat"), "Combat GUI already exists")
local scene = Instance.new("Model")
scene.Name, scene.Parent = "BARA_Phase3", workspace
local static = Instance.new("Model")
static.Name, static.Parent = "Static", scene
local function part(parent, name, size, frame, color, collide)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame, p.Color = name, size, frame, color
    p.Anchored, p.CanCollide, p.CanTouch = true, collide, false
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Material, p.Parent = Enum.Material.SmoothPlastic, parent
    return p
end
local stone, wood = Color3.fromRGB(125, 116, 94), Color3.fromRGB(87, 70, 51)
part(static, "Approach", Vector3.new(18, 1, 80), CFrame.new(0, -0.3, -255), stone, true)
for _, x in {-9.6, 9.6} do part(static, "ApproachFence", Vector3.new(1, 8, 80), CFrame.new(x, 4.2, -255), wood, true) end
part(static, "ArenaFloor", Vector3.new(78, 1, 92), CFrame.new(0, -0.3, -340), Color3.fromRGB(111, 104, 84), true)
for _, x in {-39, 39} do part(static, "SideWall", Vector3.new(1, 10, 92), CFrame.new(x, 5.2, -340), stone, true) end
for _, z in {-295, -386} do
    for _, x in {-24, 24} do part(static, "EndWall", Vector3.new(31, 10, 1), CFrame.new(x, 5.2, z), stone, true) end
end
part(static, "EntryPanel", Vector3.new(16.8, 9, 1), CFrame.new(0, 4.7, -295), wood, true).Transparency = 0.15
part(static, "ExitPanel", Vector3.new(16.8, 9, 1), CFrame.new(0, 4.7, -386), wood, true)
part(static, "ExitTerrace", Vector3.new(28, 1, 30), CFrame.new(0, -0.3, -401), stone, true)
for _, obstacle in {{-18, -342, 8, 5, 9}, {18, -331, 8, 5, 9}, {0, -363, 8, 4, 3}} do
    part(static, "Cover", Vector3.new(obstacle[3], obstacle[4], obstacle[5]), CFrame.new(obstacle[1], 0.2 + obstacle[4] / 2, obstacle[2]), wood, true)
end
local start = part(scene, "Start", Vector3.new(1, 1, 1), CFrame.new(0, 3.2, -306), stone, false)
start.Transparency, start.CanQuery = 1, false
local sign = part(scene, "EntrySign", Vector3.new(2, 4, 1), CFrame.new(7, 2.2, -282), wood, true)
local prompt = Instance.new("ProximityPrompt")
prompt.Name, prompt.ActionText, prompt.ObjectText = "StartArena", "Mulai latihan", "Arena arcade | J: aksi"
prompt.KeyboardKeyCode, prompt.HoldDuration, prompt.MaxActivationDistance = Enum.KeyCode.E, 0.25, 10
prompt.RequiresLineOfSight, prompt.Parent = false, sign
local enemies = Instance.new("Folder")
enemies.Name, enemies.Parent = "Enemies", scene
for index, position in {Vector3.new(-10, 3.2, -329), Vector3.new(12, 3.2, -350)} do
    local rig = game:GetService("StarterPlayer").StarterCharacter:Clone()
    rig.Name = "Lawan" .. index
    for _, item in rig:GetDescendants() do
        if item:IsA("LuaSourceContainer") or item:IsA("Humanoid") then item:Destroy()
        elseif item:IsA("BasePart") then
            item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, false, false, false
            if item.Name == "Torso" then item.Color = Color3.fromRGB(97, 108, 119) end
        end
    end
    local offset = rig:GetPivot():ToObjectSpace(rig.HumanoidRootPart.CFrame)
    rig:PivotTo(CFrame.new(position) * offset:Inverse())
    rig:SetAttribute("HP", 1)
    rig:SetAttribute("State", "Idle")
    local highlight = Instance.new("Highlight")
    highlight.Name, highlight.Adornee, highlight.Enabled = "Telegraph", rig, false
    highlight.FillColor, highlight.FillTransparency = Color3.fromRGB(235, 184, 93), 0.65
    highlight.OutlineColor, highlight.DepthMode = Color3.fromRGB(246, 220, 167), Enum.HighlightDepthMode.Occluded
    highlight.Parent, rig.Parent = rig, enemies
end
local overrides = game:GetService("StarterPlayer").StarterCharacterScripts
assert(not overrides:FindFirstChild("Health"), "Do not overwrite an existing health script")
local health = Instance.new("Script")
health.Name, health.Source = "Health", "-- Default regeneration disabled; CombatServer owns the three HP.\n"
health.Parent = overrides
local remote = Instance.new("RemoteEvent")
remote.Name, remote.Parent = "CombatEvent", storage.BARA_Network

local cream, brown = Color3.fromRGB(234, 215, 177), Color3.fromRGB(45, 32, 24)
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "BARA_Combat", false, 60
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local function label(parent, name, pos, size, value, fontSize)
    local text = Instance.new("TextLabel")
    text.Name, text.Position, text.Size, text.Text = name, pos, size, value
    text.BackgroundTransparency, text.TextColor3, text.Font = 1, cream, Enum.Font.RobotoMono
    text.TextSize, text.TextWrapped, text.TextScaled, text.Parent = fontSize, true, true, parent
    local limit = Instance.new("UITextSizeConstraint")
    limit.MinTextSize, limit.MaxTextSize, limit.Parent = 12, fontSize, text
    return text
end
local function frame(name, pos, size, parent)
    local box = Instance.new("Frame")
    box.Name, box.Position, box.Size = name, pos, size
    box.BackgroundColor3, box.BorderColor3, box.BorderSizePixel, box.Parent = brown, cream, 1, parent
    return box
end
local hud = frame("HUD", UDim2.fromOffset(20, 16), UDim2.new(0.85, 0, 0, 82), gui)
local size = Instance.new("UISizeConstraint")
size.MinSize, size.MaxSize, size.Parent = Vector2.new(240, 82), Vector2.new(340, 82), hud
label(hud, "HP", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 26), "HP: 3 / 3", 21)
label(hud, "Status", UDim2.fromOffset(12, 40), UDim2.new(1, -24, 0, 30), "Jelajahi map", 14)
local notice = label(gui, "Notice", UDim2.new(0.15, 0, 0, 110), UDim2.new(0.7, 0, 0, 50), "", 17)
notice.BackgroundColor3, notice.BackgroundTransparency = brown, 0.15
notice.Visible = false
local flash = frame("Flash", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), gui)
flash.BackgroundColor3, flash.BackgroundTransparency, flash.BorderSizePixel, flash.ZIndex = Color3.fromRGB(210, 157, 78), 1, 0, 2
local shade = frame("Shade", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), gui)
shade.BackgroundTransparency, shade.BorderSizePixel, shade.ZIndex, shade.Visible = 0.3, 0, 9, false
local function menuPanel(name, title, subtitle)
    local panel = frame(name, UDim2.fromScale(0.5, 0.5), UDim2.new(0.88, 0, 0, 260), gui)
    panel.AnchorPoint, panel.Visible, panel.ZIndex = Vector2.new(0.5, 0.5), false, 10
    local constraint = Instance.new("UISizeConstraint")
    constraint.MinSize, constraint.MaxSize, constraint.Parent = Vector2.new(260, 260), Vector2.new(420, 260), panel
    label(panel, "Title", UDim2.new(0.08, 0, 0, 18), UDim2.new(0.84, 0, 0, 38), title, 26)
    label(panel, "Description", UDim2.new(0.08, 0, 0, 65), UDim2.new(0.84, 0, 0, 45), subtitle, 15)
    return panel
end
local function button(parent, name, y, text)
    local b = Instance.new("TextButton")
    b.Name, b.Text, b.Position, b.Size = name, text, UDim2.new(0.1, 0, 0, y), UDim2.new(0.8, 0, 0, 42)
    b.BackgroundColor3, b.BorderColor3, b.TextColor3 = Color3.fromRGB(91, 65, 43), cream, cream
    b.Font, b.TextSize, b.ZIndex, b.Parent = Enum.Font.RobotoMono, 18, 11, parent
end
local ko = menuPanel("GameOver", "GAME OVER", "Latihan belum selesai. Coba lagi dengan waktu aksi yang tepat.")
button(ko, "Retry", 130, "Retry")
button(ko, "MainMenu", 190, "Main Menu")
local menu = menuPanel("MainMenu", "BARA 1946", "MENU UTAMA | Latihan Arcade")
button(menu, "Start", 130, "Mulai arena")
button(menu, "Explore", 190, "Jelajahi map")
gui.Parent = starterGui
return {arena = scene:GetFullName(), enemies = #enemies:GetChildren(), exitZ = -386}
