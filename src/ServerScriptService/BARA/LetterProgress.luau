--!strict
local Progress = {}
export type State = {hasLetter: boolean, delivered: boolean}

function Progress.new(): State
    return {hasLetter = false, delivered = false}
end

function Progress.collect(state: State): boolean
    if state.hasLetter or state.delivered then
        return false
    end
    state.hasLetter = true
    return true
end

function Progress.deliver(state: State): boolean
    if not state.hasLetter or state.delivered then
        return false
    end
    state.hasLetter = false
    state.delivered = true
    return true
end

return Progress
