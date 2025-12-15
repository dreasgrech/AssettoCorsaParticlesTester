UIOperations = require('UIOperations')

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
local ui_nextColumn = ui.nextColumn
local string_format = string.format


local UI_HEADER_TEXT_FONT_SIZE = 15
local DEFAULT_SLIDER_WIDTH = 200
local DEFAULT_SLIDER_FORMAT = '%.2f'

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

local waitingForClick_Flames = false

local renderFlamesSection = function()
    ui_newLine(1)
    ui_dwriteText('Flames', UI_HEADER_TEXT_FONT_SIZE)
    ui_newLine(1)

    if ui_checkbox('Enabled', storage.flame_enabled) then storage.flame_enabled = not storage.flame_enabled end

    ui_newLine(1)
    --ui_newLine(1)
    
    -- ui_text('Position: ')
    -- ui_sameLine()
    ui_text(string_format('Position: (%.2f, %.2f, %.2f)', storage.flame_position.x, storage.flame_position.y, storage.flame_position.z))
    
    --ui_newLine(1)
    ui_sameLine()
    
    local buttonText = waitingForClick_Flames and 'Click anywhere in the world...' or 'Set Position'

    if ui.button(buttonText) then
        waitingForClick_Flames = true
    end
    
    ui_newLine(1)
    

    ui_text('Velocity')
    storage.flame_velocity = UIOperations.uiVec3('Velocity', storage.flame_velocity, -100, 100)

    ui_newLine(1)

    storage.flame_color = UIOperations.renderColorPicker('Color', 'Flame color multiplier\n\nFor red/yellow/blue adjustment use `Temperature Multiplier` instead.', storage.flame_color, colorPickerFlags, colorPickerSize)
    storage.flame_size = UIOperations.renderSlider('Size', 'Particles size', storage.flame_size, 0, 50, DEFAULT_SLIDER_WIDTH, DEFAULT_SLIDER_FORMAT, 50)
    storage.flame_temperatureMultiplier = UIOperations.renderSlider('Temperature Multiplier', 'Temperature multipler to vary base color from red to blue.', storage.flame_temperatureMultiplier, 0, 10, DEFAULT_SLIDER_WIDTH, DEFAULT_SLIDER_FORMAT, 1)
    storage.flame_flameIntensity = UIOperations.renderSlider('Flame Intensity', 'Flame intensity affecting flame look and behaviour.', storage.flame_flameIntensity, 0, 10, DEFAULT_SLIDER_WIDTH, DEFAULT_SLIDER_FORMAT, 1)
    storage.flame_amount = UIOperations.renderSlider('Amount', 'Not sure what this does', storage.flame_amount, 1, 10, DEFAULT_SLIDER_WIDTH, '%.0f', 1)
end

local renderSparksSection = function()
    ui_newLine(1)
    ui_dwriteText('Sparks', UI_HEADER_TEXT_FONT_SIZE)
    ui_newLine(1)
end

local renderSmokeSection = function()
    ui_newLine(1)
    ui_dwriteText('Smoke', UI_HEADER_TEXT_FONT_SIZE)
    ui_newLine(1)
end

-- Function defined in manifest.ini
-- wiki: function to be called each frame to draw window content
---
function script.MANIFEST__FUNCTION_MAIN(dt)
    ui_columns(3, true, "sections")
    ui_setColumnWidth(0, 370)
    ui_setColumnWidth(1, 370)
    ui_setColumnWidth(2, 370)

    renderFlamesSection()
    
    ui_nextColumn()

    renderSparksSection()
    
    ui_nextColumn()
    
    renderSmokeSection()
    
    -- finish the columns
    ui_columns(1, false)
end

---
-- wiki: called after a whole simulation update
---
function script.MANIFEST__UPDATE(dt)
    if waitingForClick_Flames then
        local worldPositionFound, out_worldPosition = UIOperations.tryGetWorldPositionFromMouseClick()
        if worldPositionFound then
            ac.log('Flame position set to: ' .. tostring(out_worldPosition))
            storage.flame_position = out_worldPosition
            waitingForClick_Flames = false
        end
    end
    
    -- local positionFromClick = UIOperations.getWorldPositionFromMouseClick()
    -- if positionFromClick ~= nil then
    --     storage.flame_position = positionFromClick
    -- end
    
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
