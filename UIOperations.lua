local ui = ui
local ui_colorButton = ui.colorButton
local ui_itemHovered = ui.itemHovered
local ui_setTooltip = ui.setTooltip
local ui_sameLine = ui.sameLine
local ui_text = ui.text
local ui_pushItemWidth = ui.pushItemWidth
local ui_popItemWidth = ui.popItemWidth
local ui_slider = ui.slider
local ui_mouseClicked = ui.mouseClicked
local ui_MouseButton = ui.MouseButton
local ui_pushID = ui.pushID
local ui_popID = ui.popID
local ui_pushDisabled = ui.pushDisabled
local ui_popDisabled = ui.popDisabled
local ui_checkbox = ui.checkbox
local string_format = string.format
local render = render

local UIOperations = {}

---Color button control. Returns true if color has changed (as usual with Lua, colors are passed)
---by reference so update value would be put in place of old one automatically.
---@param label string
---@param color rgb|rgbm
---@param flags ui.ColorPickerFlags?
---@param size vec2?
---@return boolean
UIOperations.renderColorPicker = function(label, tooltip, color, flags, size)
    ui_colorButton(label, color, flags, size)

    if ui_itemHovered() then
        -- render the tooltip
        ui_setTooltip(tooltip)
    end

    ui_sameLine()
    ui_text(label)

    return color
end

---Tries to get world position from mouse click.
---@return boolean hit @Whether a valid world position was found.
---@return vec3|nil out_worldPosition @The world position if hit is true.
UIOperations.tryGetWorldPositionFromMouseClick = function()
    -- Avoid conflicts if you’re using CSP’s gizmo/positioning helper
    if render.isPositioningHelperBusy() then return false, nil end

    -- Only act on a left-click (and avoid UI clicks)
    if ui.mouseBusy() then return false, nil end
    if not ui.mouseClicked(ui.MouseButton.Left) then return false, nil end

    local ray = render.createMouseRay()

    -- Option A: intersect visual track mesh
    local hitDistance = ray:track(1)
    if hitDistance >= 0 then
        local out_worldPosition = ray.pos + ray.dir * hitDistance
        -- ac.log(string_format('[UIOperations] Track hit at distance %.2f, world position: (%.2f, %.2f, %.2f)', hitDistance, out_worldPosition.x, out_worldPosition.y, out_worldPosition.z))
        return true, out_worldPosition
    end

    -- Option B: intersect physics meshes (also gives normal if you pass out params)
    local outPos = vec3()
    local outNormal = vec3()
    local physDistance = ray:physics(outPos, outNormal)
    if physDistance >= 0 then
        -- outPos already contains the contact point
        local out_worldPosition = outPos
        -- ac.log(string_format('[UIOperations] Physics hit at distance %.2f, world position: (%.2f, %.2f, %.2f)', physDistance, out_worldPosition.x, out_worldPosition.y, out_worldPosition.z))
        return true, out_worldPosition
    end

    return false, nil
end

---Renders a slider with a tooltip
---@param label string @Slider label.
---@param tooltip string
---@param value refnumber|number @Current slider value.
---@param minValue number? @Default value: 0.
---@param maxValue number? @Default value: 1.
---@param sliderWidth number
---@param labelFormat string|'%.3f'|nil @C-style format string. Default value: `'%.3f'`.
---@param defaultValue number @The default value to reset to on right-click and is shown in the tooltip.
---@return number @Possibly updated slider value.
UIOperations.renderSlider = function(label, tooltip, value, minValue, maxValue, sliderWidth, labelFormat, defaultValue)
    -- set the width of the slider
    ui_pushItemWidth(sliderWidth)

    -- render the slider
    -- Andreas: doing the ' ' .. label thing here because when writing a label after the slider manually, there's an extra space so here I'm adding an extra space so they can match
    --local newValue = ui_slider(' ' .. label, value, minValue, maxValue, labelFormat)
    local newValue = ui_slider(label, value, minValue, maxValue, labelFormat)

    -- reset the item width
    ui_popItemWidth()

    if ui_itemHovered() then
        tooltip = string_format('%s\n\nDefault: %.2f', tooltip, defaultValue)

        -- render the tooltip
        ui_setTooltip(tooltip)

        -- reset the slider to default value on right-click
        if ui_mouseClicked(ui_MouseButton.Right) then
            -- Logger.log(string.format('Resetting slider "%s" to default value: %.2f', label, defaultValue))
            newValue = defaultValue
        end
    end

    return newValue
end

UIOperations.renderCheckbox = function(label, tooltip, value, defaultValue)
    if ui_checkbox(label, value) then
        value = not value
    end
    
    if ui_itemHovered() then
        tooltip = string_format('%s\n\nDefault: %s', tooltip, tostring(defaultValue))

        -- render the tooltip
        ui_setTooltip(tooltip)
    end
    
    return value
end

---Renders vec3 sliders
---@param label string @Slider label.
---@param value vec3 @Current vec3 value.
---@param minValue number @Minimum slider value.
---@param maxValue number @Maximum slider value.
---@param format string|'X: %.3f'|'Y: %.3f'|'Z: %.3f'|nil @C-style format string. Default value: `'X: %.3f'`, `'Y: %.3f'`, `'Z: %.3f'
---@return vec3 newValue
---@return boolean changed
UIOperations.renderVec3Sliders = function(label, value, minValue, maxValue, format)
    ui_pushID(label)

    local x = UIOperations.renderSlider('##x', '', value.x, minValue, maxValue, 350, format or 'X: %.3f', 0)
    --ui_sameLine()
    local y = UIOperations.renderSlider('##y', '', value.y, minValue, maxValue, 350, format or 'Y: %.3f', 0)
    --ui_sameLine()
    local z = UIOperations.renderSlider('##z', '', value.z, minValue, maxValue, 350, format or 'Z: %.3f', 0)

    ui_popID()

    return vec3(x, y, z)
end

--- Creates a disabled section in the UI.
---@param createSection boolean @If true, will create a disabled section.
---@param callback function @Function to call to render the contents of the section.
UIOperations.createDisabledSection = function(createSection, callback)
    if createSection then
        ui_pushDisabled()
    end

    callback()

    if createSection then
        ui_popDisabled()
    end
end

return UIOperations