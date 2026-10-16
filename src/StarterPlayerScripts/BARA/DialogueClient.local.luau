--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("BARA_Network"):WaitForChild("DialogueEvent") :: RemoteEvent
local gui = player:WaitForChild("PlayerGui"):WaitForChild("BARA_Dialogue") :: ScreenGui
local View = require(ReplicatedStorage.BARA.DialogueView)
local view = View.new(gui, function(id: number) remote:FireServer("Close", id) end)
remote.OnClientEvent:Connect(view.show)
player.CharacterAdded:Connect(view.close)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and gui.Enabled and input.KeyCode == Enum.KeyCode.Return then
        view.advance()
    end
end)
local letter = workspace:WaitForChild("BARA_Phase2").ImportantLetter.Envelope
local prompt = letter.TakeLetter :: ProximityPrompt
local function refreshLetter()
    local available = player:GetAttribute("BARA_LetterState") == "Missing"
    prompt.Enabled = available
    letter.LocalTransparencyModifier = if available then 0 else 1
    letter.Seal.LocalTransparencyModifier = if available then 0 else 1
end
player:GetAttributeChangedSignal("BARA_LetterState"):Connect(refreshLetter)
refreshLetter()
remote:FireServer("Ready")
