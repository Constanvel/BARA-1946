--!strict
local Rules = {}
Rules.COOLDOWN = 0.5
Rules.INVINCIBILITY = 1.1
export type State = {hp: number, lastAction: number, invincibleUntil: number}
function Rules.new(): State
    return {hp = 3, lastAction = -math.huge, invincibleUntil = 0}
end
function Rules.action(state: State, now: number): boolean
    if state.hp <= 0 or now - state.lastAction < Rules.COOLDOWN then return false end
    state.lastAction = now
    return true
end
function Rules.damage(state: State, now: number): boolean
    if state.hp <= 0 or now < state.invincibleUntil then return false end
    state.hp -= 1
    state.invincibleUntil = now + Rules.INVINCIBILITY
    return true
end
function Rules.inFront(frame: CFrame, target: Vector3): boolean
    local delta = target - frame.Position
    if delta.Magnitude > 6 then return false end
    local flat = Vector3.new(delta.X, 0, delta.Z)
    if flat.Magnitude < 0.1 then return true end
    return frame.LookVector:Dot(flat.Unit) >= 0.35
end
function Rules.inside(position: Vector3): boolean
    return math.abs(position.X) < 36 and position.Z > -384 and position.Z < -296 and position.Y > -5 and position.Y < 20
end
return Rules
