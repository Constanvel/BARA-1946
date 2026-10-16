local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Rules = require(script.Parent.CombatRules)
local Enemy = require(script.Parent.ArcadeEnemy)
local scene = workspace:WaitForChild("BARA_Phase3")
local remote = ReplicatedStorage.BARA_Network:WaitForChild("CombatEvent")
local gate, entry = scene.Static.ExitPanel, scene.Static.EntryPanel
local gateClosed = gate.CFrame
local enemies = {}
for _, model in scene.Enemies:GetChildren() do table.insert(enemies, Enemy.new(model)) end
table.sort(enemies, function(a, b) return a.model.Name < b.model.Name end)
assert(#enemies == 2, "Arena must have exactly two enemies")
local sessions, owner, gateTween, round = {}, nil, nil, 0
local obstacles = RaycastParams.new()
obstacles.FilterType, obstacles.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {scene.Static}
local function remaining()
    local count = 0
    for _, enemy in enemies do if enemy.hp > 0 then count += 1 end end
    return count
end
local function publish(player)
    local session = sessions[player]
    if not session then return end
    player:SetAttribute("BARA_HP", session.stats.hp)
    player:SetAttribute("BARA_CombatMode", session.mode)
    player:SetAttribute("BARA_EnemiesLeft", remaining())
end
local function notice(player, message) remote:FireClient(player, "Notice", message) end
local function resetArena()
    round += 1
    if gateTween then gateTween:Cancel(); gateTween = nil end
    gate.CFrame, gate.CanCollide, gate.CanQuery = gateClosed, true, true
    entry.CanCollide, entry.Transparency = true, 0.15
    for _, enemy in enemies do Enemy.reset(enemy) end
    scene:SetAttribute("State", "Idle")
    scene:SetAttribute("OwnerUserId", 0)
    scene:SetAttribute("EnemiesLeft", 2)
end
local function release()
    owner = nil
    resetArena()
end
local function alive(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and humanoid.Health > 0 and root then return character, humanoid, root end
end
local function gameOver(player)
    local session = sessions[player]
    if not session or owner ~= player or session.mode ~= "Arena" then return end
    session.stats.hp, session.mode = 0, "GameOver"
    scene:SetAttribute("State", "GameOver")
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then root.Anchored = true end
    publish(player)
end
local function configureCharacter(player, character, expectedLoad)
    local session = sessions[player]
    if not session then return end
    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoid or not root or player.Character ~= character then return end
    if owner == player and not expectedLoad then
        release()
        session.mode = "Explore"
    end
    session.stats = Rules.new()
    session.stats.invincibleUntil = os.clock() + Rules.INVINCIBILITY
    humanoid.MaxHealth, humanoid.Health, humanoid.BreakJointsOnDeath = 3, 3, false
    root.Anchored = false
    humanoid.Died:Connect(function()
        if owner == player and session.mode == "Arena" then
            gameOver(player)
        else
            session.stats.hp = 0
            if owner == player then release(); session.mode = "Explore" end
            publish(player)
            task.delay(Players.RespawnTime, function()
                if player.Parent == Players and player.Character == character and humanoid.Health <= 0 then
                    local ok, reason = pcall(function() player:LoadCharacterAsync() end)
                    if not ok then warn("BARA map respawn failed: " .. tostring(reason)) end
                end
            end)
        end
    end)
    if session.mode == "Arena" then character:PivotTo(scene.Start.CFrame) end
    if expectedLoad then session.busy = false end
    publish(player)
end
local function loadCharacter(player)
    local session = sessions[player]
    session.busy, session.pendingLoad = true, true
    local ok, reason = pcall(function() player:LoadCharacterAsync() end)
    if sessions[player] ~= session then return end
    if not ok then
        session.busy, session.pendingLoad = false, false
        warn("BARA character load failed: " .. tostring(reason))
        if owner == player then session.mode = "Arena"; gameOver(player) end
        notice(player, "Karakter belum dapat dimuat. Coba kembali ke menu.")
    end
end
local function beginArena(player, reload)
    local session = sessions[player]
    if owner and owner ~= player then notice(player, "Arena sedang digunakan pemain lain."); return end
    owner = player
    resetArena()
    session.stats, session.mode = Rules.new(), "Arena"
    session.stats.invincibleUntil = os.clock() + Rules.INVINCIBILITY
    scene:SetAttribute("State", "Active")
    scene:SetAttribute("OwnerUserId", player.UserId)
    entry.CanCollide, entry.Transparency = false, 0.8
    publish(player)
    if reload then
        loadCharacter(player)
    else
        local character, humanoid = alive(player)
        if character then humanoid.Health = 3; character:PivotTo(scene.Start.CFrame) end
    end
end
local function complete(player)
    local session = sessions[player]
    session.mode = "Completed"
    scene:SetAttribute("State", "Completed")
    scene:SetAttribute("EnemiesLeft", 0)
    local generation = round
    gateTween = TweenService:Create(gate, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = gateClosed + Vector3.new(0, 11, 0)})
    gateTween.Completed:Once(function(status)
        if generation == round and status == Enum.PlaybackState.Completed then gate.CanCollide, gate.CanQuery = false, false end
    end)
    gateTween:Play()
    publish(player)
    notice(player, "Arena selesai. Lewati gerbang keluar untuk melanjutkan.")
end
local function action(player)
    local session = sessions[player]
    local _, _, root = alive(player)
    if not session or session.busy or owner ~= player or session.mode ~= "Arena" or not root or not Rules.inside(root.Position) or player:GetAttribute("BARA_DialogueOpen") then return end
    if not Rules.action(session.stats, os.clock()) then return end
    remote:FireAllClients("Swing", root.CFrame)
    for _, enemy in enemies do
        if enemy.hp > 0 and Rules.inFront(root.CFrame, enemy.root.Position) and not workspace:Raycast(root.Position, enemy.root.Position - root.Position, obstacles) then
            Enemy.defeat(enemy)
        end
    end
    scene:SetAttribute("EnemiesLeft", remaining())
    publish(player)
    if remaining() == 0 then complete(player) end
end
-- Manual respawn preserves a KO screen until Retry; exploration still respawns normally.
Players.CharacterAutoLoads = false
local function setup(player)
    if sessions[player] then return end
    sessions[player] = {stats = Rules.new(), mode = "Explore", busy = false, pendingLoad = false, ready = false, lastMenu = -math.huge}
    player.CharacterAdded:Connect(function(character)
        local session = sessions[player]
        if not session then return end
        local expected = session.pendingLoad
        session.pendingLoad = false
        configureCharacter(player, character, expected)
    end)
    publish(player)
    if player.Character then task.spawn(configureCharacter, player, player.Character)
    else task.spawn(loadCharacter, player) end
end
scene.EntrySign.StartArena.Triggered:Connect(function(player)
    local session = sessions[player]
    if not session or not session.ready or session.busy or session.mode ~= "Explore" or player:GetAttribute("BARA_DialogueOpen") then return end
    local _, _, root = alive(player)
    if root and (root.Position - scene.EntrySign.Position).Magnitude <= 10 then beginArena(player, false) end
end)
remote.OnServerEvent:Connect(function(player, command, extra)
    local session = sessions[player]
    if not session or extra ~= nil then return end
    if command == "Ready" then session.ready = true; return end
    if command == "Action" then action(player); return end
    if not session.ready or session.busy or os.clock() - session.lastMenu < 0.5 then return end
    if command == "Retry" and session.mode == "GameOver" and owner == player then
        session.lastMenu = os.clock(); beginArena(player, true)
    elseif command == "MainMenu" and (session.mode == "GameOver" or session.mode == "Completed") then
        session.lastMenu = os.clock()
        if owner == player then release() end
        session.mode, session.stats = "Menu", Rules.new()
        publish(player); loadCharacter(player)
    elseif command == "Explore" and session.mode == "Menu" then
        session.lastMenu, session.mode = os.clock(), "Explore"; publish(player)
    elseif command == "Start" and session.mode == "Menu" and alive(player) then
        session.lastMenu = os.clock(); beginArena(player, false)
    end
end)
local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 0.1 then return end
    local step = math.min(elapsed, 0.2); elapsed = 0
    local session = owner and sessions[owner]
    local character, humanoid, root
    if session then character, humanoid, root = alive(owner) end
    local active = session and not session.busy and session.mode == "Arena" and root and not owner:GetAttribute("BARA_DialogueOpen")
    if active and not Rules.inside(root.Position) then
        character:PivotTo(scene.Start.CFrame)
        session.stats.invincibleUntil = math.max(session.stats.invincibleUntil, os.clock() + 0.5)
    end
    for _, enemy in enemies do
        local strike = Enemy.step(enemy, active and root or nil, os.clock(), step, obstacles)
        if strike and active and (enemy.root.Position - root.Position).Magnitude <= 4.8 and not workspace:Raycast(enemy.root.Position, root.Position - enemy.root.Position, obstacles) then
            if Rules.damage(session.stats, os.clock()) then
                publish(owner)
                remote:FireClient(owner, "Damage")
                humanoid.Health = session.stats.hp
            end
        end
    end
    if session and session.mode == "Completed" and root and root.Position.Z < -391 then
        local player = owner
        release(); session.mode = "Explore"; publish(player)
    end
end)
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player) if owner == player then release() end; sessions[player] = nil end)
resetArena()
for _, player in Players:GetPlayers() do setup(player) end
