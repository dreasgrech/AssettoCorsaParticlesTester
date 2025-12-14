
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
local string_format = string.format


local UI_HEADER_TEXT_FONT_SIZE = 15
local DEFAULT_SLIDER_WIDTH = 200
local DEFAULT_SLIDER_FORMAT = '%.2f'

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
    local newValue = ui_slider(label, value, minValue, maxValue, labelFormat)

    -- reset the item width
    ui_popItemWidth()

    tooltip = string_format('%s\n\nDefault: %.2f', tooltip, defaultValue)

    if ui_itemHovered() then
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

local flame_color = rgbm(1.0, 0.5, 0.0, 1.0)
local flame_size = 0.5
local flame_temperatureMultiplier = 1.0
local flame_flameIntensity = 1.0
local flame_amount = 5

---@type ui.ColorPickerFlags
local colorPickerFlags = bit.bor(
  ui.ColorPickerFlags.PickerHueWheel
)

local flame = ac.Particles.Flame( {
    color = flame_color,
    size = flame_size,
    temperatureMultiplier = flame_temperatureMultiplier,
    flameIntensity = flame_flameIntensity
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

    ui.colorButton('label', flame_color, colorPickerFlags, 20)
    flame_size = renderSlider('Size', 'The description', flame_size, 0, 200, DEFAULT_SLIDER_WIDTH, DEFAULT_SLIDER_FORMAT, 50)
    flame_temperatureMultiplier = renderSlider('Temperature Multiplier', 'The description', flame_temperatureMultiplier, 0, 10, DEFAULT_SLIDER_WIDTH, DEFAULT_SLIDER_FORMAT, 1)
    flame_flameIntensity = renderSlider('Flame Intensity', 'The description', flame_flameIntensity, 0, 10, DEFAULT_SLIDER_WIDTH, DEFAULT_SLIDER_FORMAT, 1)
    flame_amount = renderSlider('Amount', 'The description', flame_amount, 1, 100, DEFAULT_SLIDER_WIDTH, '%.0f', 5)
    
    -- finish the columns
    ui_columns(1, false)
end

---
-- wiki: called after a whole simulation update
---
function script.MANIFEST__UPDATE(dt)
  local sim = ac_getSim()
  --if sim.isPaused then return end
    ac.log('asd')

    local position = ac.getCar(0).position
    --position.y = position.y + 1.0
    local EFFECT_VELOCITY = vec3(0, 1, 0)
    flame.color = flame_color
    flame.size = flame_size
    flame.temperatureMultiplier = flame_temperatureMultiplier
    flame.flameIntensity = flame_flameIntensity
    flame:emit(position, EFFECT_VELOCITY, flame_amount)
end

---
-- wiki: called when transparent objects are finished rendering
---
function script.MANIFEST__TRANSPARENT(dt)
end
