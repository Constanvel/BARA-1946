local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("BARA_Network"):WaitForChild("CombatEvent")
local gui = player:WaitForChild("PlayerGui"):WaitForChild("BARA_Combat")
local lastAction, lastMenu, noticeId = -math.huge, -math.huge, 0
local function refresh()
    local mode = player:GetAttribute("BARA_CombatMode") or "Explore"
    local hp = player:GetAttribute("BARA_HP") or 3
    gui.HUD.HP.Text = string.format("HP: %d / 3", hp)
    gui.GameOver.Visible, gui.MainMenu.Visible = mode == "GameOver", mode == "Menu"
    gui.Shade.Visible = gui.GameOver.Visible or gui.MainMenu.Visible
    gui.HUD.Status.Text = if mode == "Arena" then string.format("J: aksi | Lawan: %d", player:GetAttribute("BARA_EnemiesLeft") or 2)
        elseif mode == "Completed" then "Selesai! Lewati gerbang keluar."
        elseif mode == "GameOver" then "Percobaan berakhir"
        elseif mode == "Menu" then "Pilih kegiatan berikutnya"
        else "Jelajahi map | E: interaksi"
end
for _, attribute in {"BARA_HP", "BARA_CombatMode", "BARA_EnemiesLeft"} do player:GetAttributeChangedSignal(attribute):Connect(refresh) end
local function menu(command)
    if os.clock() - lastMenu < 0.5 then return end
    lastMenu = os.clock()
    remote:FireServer(command)
end
gui.GameOver.Retry.Activated:Connect(function() menu("Retry") end)
gui.GameOver.MainMenu.Activated:Connect(function() menu("MainMenu") end)
gui.MainMenu.Start.Activated:Connect(function() menu("Start") end)
gui.MainMenu.Explore.Activated:Connect(function() menu("Explore") end)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or input.KeyCode ~= Enum.KeyCode.J or player:GetAttribute("BARA_CombatMode") ~= "Arena" then return end
    if os.clock() - lastAction < 0.5 then return end
    lastAction = os.clock()
    remote:FireServer("Action")
end)
remote.OnClientEvent:Connect(function(kind, value)
    if kind == "Swing" and typeof(value) == "CFrame" then
        local pulse = Instance.new("Part")
        pulse.Name, pulse.Size, pulse.CFrame = "BARA_ActionPulse", Vector3.new(4.5, 3, 4), value * CFrame.new(0, 0, -3)
        pulse.Anchored, pulse.CanCollide, pulse.CanTouch, pulse.CanQuery = true, false, false, false
        pulse.Color, pulse.Material, pulse.Transparency = Color3.fromRGB(245, 220, 161), Enum.Material.Neon, 0.78
        pulse.Parent = workspace
        TweenService:Create(pulse, TweenInfo.new(0.18), {Transparency = 1}):Play()
        Debris:AddItem(pulse, 0.2)
    elseif kind == "Damage" then
        gui.Flash.BackgroundTransparency = 0.78
        TweenService:Create(gui.Flash, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
        if player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Adornee, highlight.FillTransparency = player.Character, 1
            highlight.OutlineColor, highlight.DepthMode = Color3.fromRGB(243, 196, 117), Enum.HighlightDepthMode.Occluded
            highlight.Parent = player.Character
            Debris:AddItem(highlight, 1.1)
        end
    elseif kind == "Notice" and typeof(value) == "string" then
        noticeId += 1
        local id = noticeId
        gui.Notice.Text, gui.Notice.Visible = value, true
        task.delay(5, function() if id == noticeId then gui.Notice.Visible = false end end)
    end
end)
refresh()
remote:FireServer("Ready")
