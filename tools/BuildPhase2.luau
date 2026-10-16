-- Run once in Edit mode. Preserves all Phase 1 geometry and scripts.
assert(workspace:FindFirstChild("BARA_Phase1"), "Phase 1 must exist")
assert(not workspace:FindFirstChild("BARA_Phase2"), "Phase 2 exists; do not overwrite edits")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
assert(not ReplicatedStorage:FindFirstChild("BARA_Network"), "Preserve existing network folder")
assert(not StarterGui:FindFirstChild("BARA_Dialogue"), "Preserve existing dialogue UI")
local scene = Instance.new("Model")
scene.Name = "BARA_Phase2"
scene.Parent = workspace
local function part(parent, name, size, frame, color, collide)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame, p.Color = name, size, frame, color
    p.Anchored, p.CanCollide, p.CanTouch = true, collide, false
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Material, p.Parent = Enum.Material.SmoothPlastic, parent
    return p
end
local function prompt(parent, name, action, object)
    local p = Instance.new("ProximityPrompt")
    p.Name, p.ActionText, p.ObjectText = name, action, object
    p.KeyboardKeyCode, p.GamepadKeyCode = Enum.KeyCode.E, Enum.KeyCode.ButtonX
    p.HoldDuration, p.MaxActivationDistance = 0.25, 10
    p.RequiresLineOfSight = false
    p.Parent = parent
    return p
end
local wood = Color3.fromRGB(88, 65, 45)
local cream = Color3.fromRGB(234, 215, 177)
local letter = Instance.new("Model")
letter.Name, letter.Parent = "ImportantLetter", scene
part(letter, "Meja", Vector3.new(4.5, 3, 3), CFrame.new(21, 1.85, 64), wood, true)
local envelope = part(letter, "Envelope", Vector3.new(2.6, 0.16, 1.8), CFrame.new(21, 3.46, 64) * CFrame.Angles(0, math.rad(-12), 0), cream, false)
part(envelope, "Seal", Vector3.new(0.45, 0.08, 0.45), envelope.CFrame * CFrame.new(0, 0.12, 0), Color3.fromRGB(138, 54, 40), false)
prompt(envelope, "TakeLetter", "Ambil surat", "Surat penting")

local post = Instance.new("Model")
post.Name, post.Parent = "ResistancePost", scene
local guard = game:GetService("StarterPlayer").StarterCharacter:Clone()
guard.Name = "Guard"
for _, item in guard:GetDescendants() do
    if item:IsA("LuaSourceContainer") then item:Destroy() end
    if item:IsA("BasePart") then
        item.Anchored, item.CanCollide, item.CanTouch = true, false, false
    end
end
guard.Humanoid.DisplayName = "Penjaga Pos"
guard.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
local rootOffset = guard:GetPivot():ToObjectSpace(guard.HumanoidRootPart.CFrame)
guard:PivotTo(CFrame.new(-20, 3.2, -147) * CFrame.Angles(0, math.rad(-90), 0) * rootOffset:Inverse())
guard.Parent = post
prompt(guard.HumanoidRootPart, "TalkToGuard", "Bicara", "Penjaga pos")

local gate = Instance.new("Model")
gate.Name, gate.Parent = "RefugeeGate", scene
gate:SetAttribute("State", "Closed")
for _, x in {-53, 53} do
    part(gate, "PagarPembatas", Vector3.new(85, 9, 0.8), CFrame.new(x, 4.8, -177), wood, true)
end
for _, x in {-10.2, 10.2} do
    part(gate, "Pilar", Vector3.new(1.5, 12, 1.8), CFrame.new(x, 6.3, -177), wood, true)
end
part(gate, "PalangAtas", Vector3.new(22, 1, 1.8), CFrame.new(0, 12.3, -177), wood, true)
local panel = part(gate, "Panel", Vector3.new(18.8, 8, 1), CFrame.new(0, 4.3, -177), wood, true)
prompt(panel, "CheckGate", "Periksa gerbang", "Jalur terkunci")
local sign = Instance.new("SurfaceGui")
sign.Name, sign.Face, sign.CanvasSize = "GateSign", Enum.NormalId.Back, Vector2.new(600, 180)
sign.LightInfluence, sign.Parent = 0.6, panel
local caption = Instance.new("TextLabel")
caption.Size, caption.BackgroundTransparency = UDim2.fromScale(1, 1), 1
caption.Text, caption.Font, caption.TextSize, caption.TextColor3 = "JALUR TERKUNCI", Enum.Font.RobotoMono, 38, cream
caption.Parent = sign

-- Keep non-script instances outside the Script Sync roots.
local network = Instance.new("Folder")
network.Name, network.Parent = "BARA_Network", ReplicatedStorage
local remote = Instance.new("RemoteEvent")
remote.Name, remote.Parent = "DialogueEvent", network

local gui = Instance.new("ScreenGui")
gui.Name, gui.Enabled, gui.ResetOnSpawn = "BARA_Dialogue", false, false
gui.DisplayOrder, gui.ZIndexBehavior = 50, Enum.ZIndexBehavior.Sibling
local box = Instance.new("Frame")
box.Name, box.AnchorPoint = "Panel", Vector2.new(0.5, 1)
box.Position, box.Size = UDim2.new(0.5, 0, 1, -24), UDim2.new(0.9, 0, 0, 220)
box.BackgroundColor3, box.BorderColor3, box.BorderSizePixel = Color3.fromRGB(45, 32, 24), cream, 2
box.Parent = gui
local constraint = Instance.new("UISizeConstraint")
constraint.MinSize, constraint.MaxSize = Vector2.new(260, 220), Vector2.new(860, 220)
constraint.Parent = box
local function text(name, position, size, value, fontSize)
    local label = Instance.new("TextLabel")
    label.Name, label.Position, label.Size = name, position, size
    label.BackgroundTransparency, label.TextColor3 = 1, cream
    label.Font, label.TextSize, label.Text = Enum.Font.RobotoMono, fontSize, value
    label.TextXAlignment, label.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Top
    label.TextWrapped, label.TextScaled, label.Parent = true, true, box
    local textSize = Instance.new("UITextSizeConstraint")
    textSize.MinTextSize, textSize.MaxTextSize, textSize.Parent = 12, fontSize, label
    return label
end
text("Speaker", UDim2.fromOffset(20, 16), UDim2.new(1, -80, 0, 24), "", 18)
text("Dialogue", UDim2.fromOffset(20, 52), UDim2.new(1, -40, 0, 100), "", 17)
text("Page", UDim2.new(0, 20, 1, -47), UDim2.new(1, -190, 0, 32), "", 12)
local function button(name, position, size, value)
    local b = Instance.new("TextButton")
    b.Name, b.Position, b.Size, b.Text = name, position, size, value
    b.BackgroundColor3, b.BorderColor3, b.TextColor3 = Color3.fromRGB(91, 65, 43), cream, cream
    b.BorderSizePixel, b.TextSize, b.Font = 1, 16, Enum.Font.RobotoMono
    b.Parent = box
    return b
end
button("Continue", UDim2.new(1, -160, 1, -55), UDim2.fromOffset(140, 36), "Lanjut >")
button("Close", UDim2.new(1, -44, 0, 12), UDim2.fromOffset(28, 28), "X")
gui.Parent = StarterGui
return {built = scene:GetFullName(), prompts = 3, dialogueUI = gui:GetFullName(), sharedGate = true}
