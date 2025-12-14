
-- local bindings
local ac = ac
local ac_getSim = ac.getSim
local ui = ui
local ui_columns = ui.columns
local ui_setColumnWidth = ui.setColumnWidth
local ui_newLine = ui.newLine
local ui_dwriteText = ui.dwriteText
local ui_pushItemWidth = ui.pushItemWidth
local ui_popItemWidth = ui.popItemWidth
local ui_slider = ui.slider
local ui_itemHovered = ui.itemHovered
local ui_setTooltip = ui.setTooltip
local ui_mouseClicked = ui.mouseClicked
local ui_MouseButton = ui.MouseButton
local ui_sameLine = ui.sameLine
local ui_pushID = ui.pushID
local ui_popID = ui.popID
local ui_text = ui.text
local ui_checkbox = ui.checkbox
local ui_colorButton = ui.colorButton
local string_format = string.format


local UI_HEADER_TEXT_FONT_SIZE = 15
local DEFAULT_SLIDER_WIDTH = 200
local DEFAULT_SLIDER_FORMAT = '%.2f'


local function getWorldPositionFromMouseClick()
    -- Avoid conflicts if you’re using CSP’s gizmo/positioning helper
    if render.isPositioningHelperBusy() then return nil end

    -- Only act on a left-click (and avoid UI clicks)
    if ui.mouseBusy() then return nil end
    if not ui.mouseClicked(ui.MouseButton.Left) then return nil end

    local ray = render.createMouseRay()

    -- Option A: intersect visual track mesh
    local hitDistance = ray:track(1)
    if hitDistance >= 0 then
        return ray.pos + ray.dir * hitDistance
    end

    -- Option B: intersect physics meshes (also gives normal if you pass out params)
    local outPos = vec3()
    local outNormal = vec3()
    local physDistance = ray:physics(outPos, outNormal)
    if physDistance >= 0 then
        -- outPos already contains the contact point
        return outPos, outNormal
    end

    return nil
end

---Color button control. Returns true if color has changed (as usual with Lua, colors are passed)
---by reference so update value would be put in place of old one automatically.
---@param label string
---@param color rgb|rgbm
---@param flags ui.ColorPickerFlags?
---@param size vec2?
---@return boolean
local renderColorPicker = function(label, tooltip, color, flags, size)
    ui_colorButton(label, color, flags, size)

    if ui_itemHovered() then
        -- render the tooltip
        ui_setTooltip(tooltip)
    end
    
    ui_sameLine()
    ui.text(label)
    
    return color
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
local renderSlider = function(label, tooltip, value, minValue, maxValue, sliderWidth, labelFormat, defaultValue)
    -- set the width of the slider
    ui_pushItemWidth(sliderWidth)

    -- render the slider
    -- Andreas: doing the ' ' .. label thing here because when writing a label after the slider manually, there's an extra space so here I'm adding an extra space so they can match
    local newValue = ui_slider(' ' .. label, value, minValue, maxValue, labelFormat)

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

---Renders a vec3 slider (3 sliders in one line).
---@param label string @Slider label.
---@param value vec3 @Current vec3 value.
---@param minValue number @Minimum slider value.
---@param maxValue number @Maximum slider value.
---@param format string|'X: %.3f'|'Y: %.3f'|'Z: %.3f'|nil @C-style format string. Default value: `'X: %.3f'`, `'Y: %.3f'`, `'Z: %.3f'
---@return vec3 newValue
---@return boolean changed
local function uiVec3(label, value, minValue, maxValue, format)
    ui_pushID(label)

    local x = renderSlider('##x', '', value.x, minValue, maxValue, 350, format or 'X: %.3f', 0)
    --ui_sameLine()
    local y = renderSlider('##y', '', value.y, minValue, maxValue, 350, format or 'Y: %.3f', 0)
    --ui_sameLine()
    local z = renderSlider('##z', '', value.z, minValue, maxValue, 350, format or 'Z: %.3f', 0)

    ui_popID()

    return vec3(x, y, z)
end

--[======[
---Flame emitter holding specialized settings. Set settings in a table when creating an emitter and/or change them later.
---Use `:emit(position, velocity, amount)` to actually emit flames.
---@param params {color: rgbm, size: number, temperatureMultiplier: number, flameIntensity: number}|`{color = rgbm(0.5, 0.5, 0.5, 0.5), size = 0.2, temperatureMultiplier = 1, flameIntensity = 0}` "Table with properties:\n- `color` (`rgbm`): Flame color multiplier (for red/yellow/blue adjustment use `temperatureMultiplier` instead).\n- `size` (`number`): Particles size. Default value: 0.2.\n- `temperatureMultiplier` (`number`): Temperature multipler to vary base color from red to blue. Default value: 1.\n- `flameIntensity` (`number`): Flame intensity affecting flame look and behaviour. Default value: 0."
---@return ac.Particles.Flame
function ac.Particles.Flame(params) end



---Sparks emitter holding specialized settings. Set settings in a table when creating an emitter and/or change them later.
---Use `:emit(position, velocity, amount)` to actually emit sparks.
---@param params {color: rgbm, life: number, size: number, directionSpread: number, positionSpread: number}|`{color = rgbm(0.5, 0.5, 0.5, 0.5), life = 4, size = 0.2, directionSpread = 1, positionSpread = 0.2}` "Table with properties:\n- `color` (`rgbm`): Sparks color.\n- `life` (`number`): Base lifetime. Default value: 4.\n- `size` (`number`): Base size. Default value: 0.2.\n- `directionSpread` (`number`): How much sparks directions vary. Default value: 1.\n- `positionSpread` (`number`): How much sparks position vary. Default value: 0.2."
---@return ac.Particles.Sparks
function ac.Particles.Sparks(params) end



---Smoke flags for emitters.
ac.Particles.SmokeFlags = { FadeIn = 1, DisableCollisions = 256 }

---Smoke emitter holding specialized settings. Set settings in a table when creating an emitter and/or change them later.
---Use `:emit(position, velocity, amount)` to actually emit smoke.
---@param params {color: rgbm, colorConsistency: number, thickness: number, life: number, size: number, spreadK: number, growK: number, targetYVelocity: number}|`{color = rgbm(0.5, 0.5, 0.5, 0.5), colorConsistency = 0.5, thickness = 1, life = 4, size = 0.2, spreadK = 1, growK = 1, targetYVelocity = 0}` "Table with properties:\n- `color` (`rgbm`): Smoke color with values from 0 to 1. Alpha can be used to adjust thickness. Default alpha value: 0.5.\n- `colorConsistency` (`number`): Defines how much color dissipates when smoke expands, from 0 to 1. Default value: 0.5.\n- `thickness` (`number`): How thick is smoke, from 0 to 1. Default value: 1.\n- `life` (`number`): Smoke base lifespan in seconds. Default value: 4.\n- `size` (`number`): Starting particle size in meters. Default value: 0.2.\n- `spreadK` (`number`): How randomized is smoke spawn (mostly, speed and direction). Default value: 1.\n- `growK` (`number`): How fast smoke expands. Default value: 1.\n- `targetYVelocity` (`number`): Neutral vertical velocity. Set above zero for hot gasses and below zero for cold, to collect at the bottom. Default value: 0."
---@return ac.Particles.Smoke
function ac.Particles.Smoke(params) end
--]======]

---@class StorageTable
---@field flame_enabled boolean
---@field flame_position vec3
---@field flame_velocity vec3
---@field flame_color rgbm
---@field flame_size number
---@field flame_temperatureMultiplier number
---@field flame_flameIntensity number
---@field flame_amount number

---@type StorageTable
local storageTable = {
    flame_enabled = true,
    flame_position = vec3(0, 0, 0),
    flame_velocity = vec3(0, 1, 0),
    flame_color = rgbm(0.5, 0.5, 0.5, 0.5), -- value from lib.lua
    flame_size = 0.2, -- value from lib.lua
    flame_temperatureMultiplier = 1.0, -- value from lib.lua
    flame_flameIntensity = 0.0, -- value from lib.lua
    flame_amount = 1
}

---@type StorageTable
local storage = ac.storage(storageTable, "global")

---@type ui.ColorPickerFlags
local colorPickerFlags = bit.bor(
  ui.ColorPickerFlags.PickerHueWheel
)
local colorPickerSize = vec2(DEFAULT_SLIDER_WIDTH, 20)

local flame = ac.Particles.Flame( {
    color = storage.flame_color,
    size = storage.flame_size,
    temperatureMultiplier = storage.flame_temperatureMultiplier,
    flameIntensity = storage.flame_flameIntensity
})

-- Function defined in manifest.ini
-- wiki: function to be called each frame to draw window content
---
function script.MANIFEST__FUNCTION_MAIN(dt)
    ui_columns(2, true, "sections")
    ui_setColumnWidth(0, 560)

    ui_newLine(1)
    ui_dwriteText('Flames', UI_HEADER_TEXT_FONT_SIZE)
    ui_newLine(1)

    if ui_checkbox('Enabled', storage.flame_enabled) then storage.flame_enabled = not storage.flame_enabled end
    
    ui_newLine(1)
    ui_newLine(1)
    
    ui_text('Velocity')
    storage.flame_velocity = uiVec3('Velocity', storage.flame_velocity, -100, 100)
    
    ui_newLine(1)

    storage.flame_color = renderColorPicker('Color', 'Flame color multiplier\n\nFor red/yellow/blue adjustment use `Temperature Multiplier` instead.', storage.flame_color, colorPickerFlags, colorPickerSize)
    storage.flame_size = renderSlider('Size', 'Particles size', storage.flame_size, 0, 50, DEFAULT_SLIDER_WIDTH, DEFAULT_SLIDER_FORMAT, 50)
    storage.flame_temperatureMultiplier = renderSlider('Temperature Multiplier', 'Temperature multipler to vary base color from red to blue.', storage.flame_temperatureMultiplier, 0, 10, DEFAULT_SLIDER_WIDTH, DEFAULT_SLIDER_FORMAT, 1)
    storage.flame_flameIntensity = renderSlider('Flame Intensity', 'Flame intensity affecting flame look and behaviour.', storage.flame_flameIntensity, 0, 10, DEFAULT_SLIDER_WIDTH, DEFAULT_SLIDER_FORMAT, 1)
    storage.flame_amount = renderSlider('Amount', 'The description', storage.flame_amount, 1, 10, DEFAULT_SLIDER_WIDTH, '%.0f', 1)
    
    -- finish the columns
    ui_columns(1, false)
end

---
-- wiki: called after a whole simulation update
---
function script.MANIFEST__UPDATE(dt)
    local positionFromClick = getWorldPositionFromMouseClick()
    if positionFromClick ~= nil then
        storage.flame_position = positionFromClick
    end
    
    if storage.flame_enabled then
        flame.color = storage.flame_color
        flame.size = storage.flame_size
        flame.temperatureMultiplier = storage.flame_temperatureMultiplier
        flame.flameIntensity = storage.flame_flameIntensity
        flame:emit(storage.flame_position, storage.flame_velocity, storage.flame_amount)
    end
end

---
-- wiki: called when transparent objects are finished rendering
---
function script.MANIFEST__TRANSPARENT(dt)
end
