--!strict
local View = {}

function View.new(gui: ScreenGui, onClosed: (number) -> ())
    local panel = gui.Panel
    local activeId: number? = nil
    local lines: {string} = {}
    local page = 1
    local view = {}

    local function render()
        panel.Dialogue.Text = lines[page]
        panel.Continue.Text = if page < #lines then "Lanjut >" else "Selesai"
        panel.Page.Text = string.format("%d / %d", page, #lines)
    end

    function view.close()
        local id = activeId
        activeId = nil
        gui.Enabled = false
        if id then
            onClosed(id)
        end
    end

    function view.advance()
        if not activeId then
            return
        end
        if page < #lines then
            page += 1
            render()
        else
            view.close()
        end
    end

    function view.show(payload)
        if typeof(payload) ~= "table" or typeof(payload.id) ~= "number" or typeof(payload.speaker) ~= "string" or typeof(payload.lines) ~= "table" or #payload.lines == 0 then
            return
        end
        activeId, lines, page = payload.id, payload.lines, 1
        panel.Speaker.Text = payload.speaker
        render()
        gui.Enabled = true
        local id = activeId
        task.delay(40, function()
            if activeId == id then view.close() end
        end)
    end

    panel.Continue.Activated:Connect(view.advance)
    panel.Close.Activated:Connect(view.close)
    return view
end

return View
