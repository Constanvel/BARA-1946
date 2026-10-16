--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Progress = require(script.Parent.LetterProgress)
local Rules = require(script.Parent.InteractionRules)
local Catalog = require(ReplicatedStorage.BARA.DialogueCatalog)
local remote = ReplicatedStorage:WaitForChild("BARA_Network"):WaitForChild("DialogueEvent") :: RemoteEvent
local scene = workspace:WaitForChild("BARA_Phase2")
local letterPrompt = scene.ImportantLetter.Envelope.TakeLetter :: ProximityPrompt
local guardPrompt = scene.ResistancePost.Guard.HumanoidRootPart.TalkToGuard :: ProximityPrompt
local gate = scene.RefugeeGate.Panel :: BasePart
local gatePrompt = gate.CheckGate :: ProximityPrompt
type Session = {progress: Progress.State, ready: boolean, nextId: number, activeId: number?, deadline: number, lastAction: number}
-- shortcut: progress lasts for this server session, add persistence only if cross-session saves are requested.
local sessions: {[Player]: Session} = {}
local gateOpening = false

local function publish(player: Player, session: Session)
    player:SetAttribute("BARA_LetterState", if session.progress.delivered then "Delivered" elseif session.progress.hasLetter then "Carrying" else "Missing")
    player:SetAttribute("BARA_DialogueOpen", session.activeId ~= nil)
end

local function setup(player: Player)
    local session: Session = {progress = Progress.new(), ready = false, nextId = 0, activeId = nil, deadline = 0, lastAction = -math.huge}
    sessions[player] = session
    publish(player, session)
    player.CharacterAdded:Connect(function()
        session.activeId = nil
        publish(player, session)
    end)
end

local function openGate()
    if gateOpening then
        return
    end
    gateOpening = true
    scene.RefugeeGate:SetAttribute("State", "Opening")
    gatePrompt.Enabled = false
    gate.GateSign.TextLabel.Text = "MEMBUKA JALUR"
    local tween = TweenService:Create(gate, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = gate.CFrame + Vector3.new(0, 11, 0)})
    tween.Completed:Once(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            gate.CanCollide = false
            gate.CanQuery = false
            gate.GateSign.TextLabel.Text = "JALUR TERBUKA"
            scene.RefugeeGate:SetAttribute("State", "Open")
        end
    end)
    tween:Play()
end

local function show(player: Player, session: Session, key: string)
    session.nextId += 1
    session.activeId = session.nextId
    session.deadline = os.clock() + 45
    publish(player, session)
    local entry = Catalog[key]
    remote:FireClient(player, {id = session.activeId, speaker = entry.speaker, lines = entry.lines})
end

local function interact(player: Player, prompt: ProximityPrompt, action: string)
    local session = sessions[player]
    if not session or not session.ready or not Rules.canInteract(player, prompt) then
        return
    end
    local now = os.clock()
    if (session.activeId ~= nil and now < session.deadline) or now - session.lastAction < 0.35 then
        return
    end
    session.lastAction = now
    if action == "Letter" then
        if Progress.collect(session.progress) then
            show(player, session, "LetterFound")
        end
    elseif action == "Guard" then
        if Progress.deliver(session.progress) then
            openGate()
            show(player, session, "LetterDelivered")
        else
            show(player, session, if session.progress.delivered then "AlreadyDelivered" else "NoLetter")
        end
    elseif action == "Gate" and not gateOpening then
        show(player, session, "GateLocked")
    end
end

remote.OnServerEvent:Connect(function(player: Player, command: unknown, id: unknown)
    local session = sessions[player]
    if not session then
        return
    end
    if command == "Ready" then
        session.ready = true
    elseif command == "Close" and typeof(id) == "number" and id == session.activeId then
        session.activeId = nil
        publish(player, session)
    end
end)
letterPrompt.Triggered:Connect(function(player) interact(player, letterPrompt, "Letter") end)
guardPrompt.Triggered:Connect(function(player) interact(player, guardPrompt, "Guard") end)
gatePrompt.Triggered:Connect(function(player) interact(player, gatePrompt, "Gate") end)
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player) sessions[player] = nil end)
for _, player in Players:GetPlayers() do setup(player) end
