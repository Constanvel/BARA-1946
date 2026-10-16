-- Server-owned, anchored rigs: no pathfinding, client physics, or NPC scripts.
local Enemy = {}
local function state(enemy, value)
    if enemy.state ~= value then
        enemy.state = value
        enemy.model:SetAttribute("State", value)
        enemy.model.Telegraph.Enabled = value == "Action"
    end
end
function Enemy.new(model)
    local enemy = {model = model, root = model.HumanoidRootPart, state = "", colors = {}}
    enemy.spawn = enemy.root.CFrame
    enemy.offset = model:GetPivot():ToObjectSpace(enemy.root.CFrame)
    for _, item in model:GetDescendants() do
        if item:IsA("BasePart") then enemy.colors[item] = {item.Color, item.Transparency} end
    end
    Enemy.reset(enemy)
    return enemy
end
function Enemy.reset(enemy)
    enemy.hp, enemy.nextAction, enemy.untilTime = 1, 0, 0
    enemy.model:PivotTo(enemy.spawn * enemy.offset:Inverse())
    for part, original in enemy.colors do part.Color, part.Transparency = original[1], original[2] end
    enemy.model:SetAttribute("HP", 1)
    state(enemy, "Idle")
end
function Enemy.defeat(enemy)
    if enemy.hp == 0 then return false end
    enemy.hp = 0
    enemy.model:SetAttribute("HP", 0)
    state(enemy, "Defeated")
    for part, original in enemy.colors do
        part.Color = Color3.fromRGB(119, 114, 102)
        part.Transparency = math.max(original[2], 0.55)
    end
    return true
end
function Enemy.step(enemy, target, now, dt, obstacles)
    if enemy.hp == 0 then return false end
    if not target then state(enemy, "Idle"); return false end
    local difference = target.Position - enemy.root.Position
    local flat = Vector3.new(difference.X, 0, difference.Z)
    local distance = flat.Magnitude
    if distance > 30 then state(enemy, "Idle"); return false end
    if enemy.state == "Idle" then
        if distance <= 26 then state(enemy, "Detect"); enemy.untilTime = now + 0.4 end
        return false
    elseif enemy.state == "Detect" then
        if now >= enemy.untilTime then state(enemy, "Chase") end
        return false
    elseif enemy.state == "Action" then
        if now >= enemy.untilTime then
            state(enemy, "Chase")
            return distance <= 4.6 and enemy.root.CFrame.LookVector:Dot(flat.Magnitude > 0.1 and flat.Unit or enemy.root.CFrame.LookVector) > 0.1
        end
        return false
    end
    if distance <= 4.2 and now >= enemy.nextAction then
        state(enemy, "Action")
        enemy.untilTime, enemy.nextAction = now + 0.45, now + 1.5
        return false
    end
    if distance > 3.4 then
        local step = flat.Unit * math.min(8 * dt, distance - 3.4)
        local function clear(direction)
            return not workspace:Blockcast(CFrame.new(enemy.root.Position), Vector3.new(2.6, 5, 2.6), direction, obstacles)
        end
        if not clear(step) then
            local horizontal, vertical = Vector3.new(step.X, 0, 0), Vector3.new(0, 0, step.Z)
            if horizontal.Magnitude > 0.01 and clear(horizontal) then step = horizontal
            elseif vertical.Magnitude > 0.01 and clear(vertical) then step = vertical
            else step = Vector3.zero end
        end
        local position = enemy.root.Position + step
        if math.abs(position.X) < 35 and position.Z > -383 and position.Z < -297 then
            enemy.model:PivotTo(CFrame.lookAt(position, Vector3.new(target.Position.X, position.Y, target.Position.Z)) * enemy.offset:Inverse())
        end
    end
    return false
end
return Enemy
