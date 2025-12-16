ParticleEffectsType = {
    Flame = 1,
    Smoke = 2,
    Sparks = 3,
}

StringBuilder = require('StringBuilder')
StorageManager = require('StorageManager')
UIOperations = require('UIOperations')
MathOperations = require('MathOperations')
ExtConfigCodeGenerator = require('ExtConfigCodeGenerator')
ParticleEffectsManager = require('ParticleEffectsManager')

-- local bindings
local ac = ac
local ac_getSim = ac.getSim
local ui = ui
local ui_columns = ui.columns
local ui_setColumnWidth = ui.setColumnWidth
local ui_dwriteText = ui.dwriteText
local ui_sameLine = ui.sameLine
local ui_pushID = ui.pushID
local ui_popID = ui.popID
local ui_text = ui.text
local ui_nextColumn = ui.nextColumn
local ui_button = ui.button
local string_format = string.format
local UIOperations_newLine = UIOperations.newLine


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

local storage = StorageManager.getStorage()

---@type ui.ColorPickerFlags
local colorPickerFlags = bit.bor(
  ui.ColorPickerFlags.PickerHueWheel
)
local colorPickerSize = vec2(DEFAULT_SLIDER_WIDTH, 20)

local flameInstance = ParticleEffectsManager.generateParticleEffect(ParticleEffectsType.Flame, vec3(0,0,0), vec3(0,0,0))
local flame = flameInstance.effect
flame.color = storage.flame_color
flame.size = storage.flame_size
flame.temperatureMultiplier = storage.flame_temperatureMultiplier
flame.flameIntensity = storage.flame_flameIntensity

local sparksInstance = ParticleEffectsManager.generateParticleEffect(ParticleEffectsType.Sparks, vec3(0,0,0), vec3(0,0,0))
local sparks = sparksInstance.effect
sparks.color = storage.sparks_color
sparks.size = storage.sparks_size
sparks.life = storage.sparks_life
sparks.directionSpread = storage.sparks_directionSpread
sparks.positionSpread = storage.sparks_positionSpread

local smokeInstance = ParticleEffectsManager.generateParticleEffect(ParticleEffectsType.Smoke, vec3(0,0,0), vec3(0,0,0))
local smoke = smokeInstance.effect
smoke.color = storage.smoke_color
smoke.colorConsistency = storage.smoke_colorConsistency
smoke.thickness = storage.smoke_thickness
smoke.life = storage.smoke_life
smoke.size = storage.smoke_size
smoke.spreadK = storage.smoke_spreadK
smoke.growK = storage.smoke_growK
smoke.targetYVelocity = storage.smoke_targetYVelocity

local StorageManager__options_label = StorageManager.options_label
local StorageManager__options_tooltip = StorageManager.options_tooltip
local StorageManager__options_default = StorageManager.options_default
local StorageManager__options_min = StorageManager.options_min
local StorageManager__options_max = StorageManager.options_max

---
---@param optionType StorageManager.Options
local renderOptionSlider = function(optionType, currentValue)
    return UIOperations.renderSlider(StorageManager__options_label[optionType], StorageManager__options_tooltip[optionType], currentValue, StorageManager__options_min[optionType], StorageManager__options_max[optionType], DEFAULT_SLIDER_WIDTH, DEFAULT_SLIDER_FORMAT, StorageManager__options_default[optionType])
end

local renderFlamesSection = function()
    ui_pushID("FlamesSection")
    
    ui_dwriteText('Flames', UI_HEADER_TEXT_FONT_SIZE)
    UIOperations_newLine(1)
    
    -- Enabled
    storage.flame_enabled = UIOperations.renderCheckbox(StorageManager__options_label[StorageManager.Options.Flame_Enabled], StorageManager__options_tooltip[StorageManager.Options.Flame_Enabled], storage.flame_enabled, StorageManager__options_default[StorageManager.Options.Flame_Enabled])

    UIOperations_newLine(1)

    if ui_button('Generate ext_config') then
        local extConfigFormat = ExtConfigCodeGenerator.generateCode(ParticleEffectsType.Flame, flame, storage.flame_position + storage.flame_positionOffset, storage.flame_velocity, storage.flame_amount)
        ac.log(extConfigFormat)
    end

    UIOperations_newLine(2)
    
    UIOperations.createDisabledSection(not storage.flame_enabled, function()
        -- Show the position value label
        ui_text(string_format('Position: (%.2f, %.2f, %.2f)', storage.flame_position.x, storage.flame_position.y, storage.flame_position.z))

        ui_sameLine()

        local buttonText = flameInstance.waitingForClickToSetPosition and 'Click in the world' or 'Set Position'

        if ui_button(buttonText) then
            flameInstance.waitingForClickToSetPosition  = true
        end
        
        UIOperations_newLine()

        -- Position Offset
        ui_text(StorageManager__options_label[StorageManager.Options.Flame_PositionOffset])
        storage.flame_positionOffset = UIOperations.renderVec3Sliders(StorageManager__options_label[StorageManager.Options.Flame_PositionOffset], storage.flame_positionOffset, StorageManager__options_min[StorageManager.Options.Flame_PositionOffset], StorageManager__options_max[StorageManager.Options.Flame_PositionOffset])
        
        UIOperations_newLine(1)

        -- Velocity
        ui_text(StorageManager__options_label[StorageManager.Options.Flame_Velocity])
        storage.flame_velocity = UIOperations.renderVec3Sliders(StorageManager__options_label[StorageManager.Options.Flame_Velocity], storage.flame_velocity, StorageManager__options_min[StorageManager.Options.Flame_Velocity], StorageManager__options_max[StorageManager.Options.Flame_Velocity])

        UIOperations_newLine(1)

        storage.flame_color = UIOperations.renderColorPicker(StorageManager__options_label[StorageManager.Options.Flame_Color], StorageManager__options_tooltip[StorageManager.Options.Flame_Color], storage.flame_color, colorPickerFlags, colorPickerSize)
        storage.flame_size = renderOptionSlider(StorageManager.Options.Flame_Size, storage.flame_size)
        storage.flame_amount = renderOptionSlider(StorageManager.Options.Flame_Amount, storage.flame_amount)
        UIOperations_newLine(1)
        storage.flame_temperatureMultiplier = renderOptionSlider(StorageManager.Options.Flame_TemperatureMultiplier, storage.flame_temperatureMultiplier)
        storage.flame_flameIntensity = renderOptionSlider(StorageManager.Options.Flame_FlameIntensity, storage.flame_flameIntensity)
    end)
    
    ui_popID()
end

local renderSparksSection = function()
    ui_pushID("SparksSection")
    
    ui_dwriteText('Sparks', UI_HEADER_TEXT_FONT_SIZE)
    UIOperations_newLine(1)
    
    -- Enabled
    storage.sparks_enabled = UIOperations.renderCheckbox(StorageManager__options_label[StorageManager.Options.Sparks_Enabled], StorageManager__options_tooltip[StorageManager.Options.Sparks_Enabled], storage.sparks_enabled, StorageManager__options_default[StorageManager.Options.Sparks_Enabled])
    
    UIOperations_newLine(1)
    
    if ui_button('Generate ext_config') then
        local extConfigFormat = ExtConfigCodeGenerator.generateCode(ParticleEffectsType.Sparks, sparks, storage.sparks_position + storage.sparks_positionOffset, storage.sparks_velocity, storage.sparks_amount)
        ac.log(extConfigFormat)
    end

    UIOperations_newLine(2)


    UIOperations.createDisabledSection(not storage.sparks_enabled, function()
        -- Show the position value label
        ui_text(string_format('Position: (%.2f, %.2f, %.2f)', storage.sparks_position.x, storage.sparks_position.y, storage.sparks_position.z))
        
        ui_sameLine()
        
        local buttonText = sparksInstance.waitingForClickToSetPosition and 'Click in the world' or 'Set Position'

        if ui_button(buttonText) then
            sparksInstance.waitingForClickToSetPosition = true
        end

        -- Position Offset
        ui_text(StorageManager__options_label[StorageManager.Options.Sparks_PositionOffset])
        storage.sparks_positionOffset = UIOperations.renderVec3Sliders(StorageManager__options_label[StorageManager.Options.Sparks_PositionOffset], storage.sparks_positionOffset, StorageManager__options_min[StorageManager.Options.Sparks_PositionOffset], StorageManager__options_max[StorageManager.Options.Sparks_PositionOffset])

        UIOperations_newLine(1)

        -- Velocity
        ui_text(StorageManager__options_label[StorageManager.Options.Sparks_Velocity])
        storage.sparks_velocity = UIOperations.renderVec3Sliders(StorageManager__options_label[StorageManager.Options.Sparks_Velocity], storage.sparks_velocity, StorageManager__options_min[StorageManager.Options.Sparks_Velocity], StorageManager__options_max[StorageManager.Options.Sparks_Velocity])
        
        UIOperations_newLine(1)

        storage.sparks_color = UIOperations.renderColorPicker(StorageManager__options_label[StorageManager.Options.Sparks_Color], StorageManager__options_tooltip[StorageManager.Options.Sparks_Color], storage.sparks_color, colorPickerFlags, colorPickerSize)
        storage.sparks_size = renderOptionSlider(StorageManager.Options.Sparks_Size, storage.sparks_size)
        storage.sparks_amount = renderOptionSlider(StorageManager.Options.Sparks_Amount, storage.sparks_amount)
        UIOperations_newLine(1)
        storage.sparks_life = renderOptionSlider(StorageManager.Options.Sparks_Life, storage.sparks_life)
        storage.sparks_directionSpread = renderOptionSlider(StorageManager.Options.Sparks_DirectionSpread, storage.sparks_directionSpread)
        storage.sparks_positionSpread = renderOptionSlider(StorageManager.Options.Sparks_PositionSpread, storage.sparks_positionSpread)
    end)
    
    ui_popID()
end

local renderSmokeSection = function()
    ui_pushID("SmokeSection")
    
    ui_dwriteText('Smoke', UI_HEADER_TEXT_FONT_SIZE)
    UIOperations_newLine(1)
    
    -- Enabled
    storage.smoke_enabled = UIOperations.renderCheckbox(StorageManager__options_label[StorageManager.Options.Smoke_Enabled], StorageManager__options_tooltip[StorageManager.Options.Smoke_Enabled], storage.smoke_enabled, StorageManager__options_default[StorageManager.Options.Smoke_Enabled])
    
    UIOperations_newLine(1)

    if ui_button('Generate ext_config') then
        local extConfigFormat = ExtConfigCodeGenerator.generateCode(ParticleEffectsType.Smoke, smoke, storage.smoke_position + storage.smoke_positionOffset, storage.smoke_velocity, storage.smoke_amount)
        ac.log(extConfigFormat)
    end

    UIOperations_newLine(2)

    UIOperations.createDisabledSection(not storage.smoke_enabled, function()
        -- Show the position value label
        ui_text(string_format('Position: (%.2f, %.2f, %.2f)', storage.smoke_position.x, storage.smoke_position.y, storage.smoke_position.z))
        
        ui_sameLine()
        
        local buttonText = smokeInstance.waitingForClickToSetPosition and 'Click in the world' or 'Set Position'

        if ui_button(buttonText) then
            smokeInstance.waitingForClickToSetPosition = true
        end

        -- Position Offset
        ui_text(StorageManager__options_label[StorageManager.Options.Smoke_PositionOffset])
        storage.smoke_positionOffset = UIOperations.renderVec3Sliders(StorageManager__options_label[StorageManager.Options.Smoke_PositionOffset], storage.smoke_positionOffset, StorageManager__options_min[StorageManager.Options.Smoke_PositionOffset], StorageManager__options_max[StorageManager.Options.Smoke_PositionOffset])

        UIOperations_newLine(1)

        -- Velocity
        ui_text(StorageManager__options_label[StorageManager.Options.Smoke_Velocity])
        storage.smoke_velocity = UIOperations.renderVec3Sliders(StorageManager__options_label[StorageManager.Options.Smoke_Velocity], storage.smoke_velocity, StorageManager__options_min[StorageManager.Options.Smoke_Velocity], StorageManager__options_max[StorageManager.Options.Smoke_Velocity])
        
        UIOperations_newLine(1)

        storage.smoke_color = UIOperations.renderColorPicker(StorageManager__options_label[StorageManager.Options.Smoke_Color], StorageManager__options_tooltip[StorageManager.Options.Smoke_Color], storage.smoke_color, colorPickerFlags, colorPickerSize)
        storage.smoke_size = renderOptionSlider(StorageManager.Options.Smoke_Size, storage.smoke_size)
        storage.smoke_amount = renderOptionSlider(StorageManager.Options.Smoke_Amount, storage.smoke_amount)
        UIOperations_newLine(1)
        storage.smoke_colorConsistency = renderOptionSlider(StorageManager.Options.Smoke_ColorConsistency, storage.smoke_colorConsistency)
        storage.smoke_thickness = renderOptionSlider(StorageManager.Options.Smoke_Thickness, storage.smoke_thickness)
        storage.smoke_life = renderOptionSlider(StorageManager.Options.Smoke_Life, storage.smoke_life)
        storage.smoke_spreadK = renderOptionSlider(StorageManager.Options.Smoke_SpreadK, storage.smoke_spreadK)
        storage.smoke_growK = renderOptionSlider(StorageManager.Options.Smoke_GrowK, storage.smoke_growK)
        storage.smoke_targetYVelocity = renderOptionSlider(StorageManager.Options.Smoke_TargetYVelocity, storage.smoke_targetYVelocity)
        UIOperations_newLine(1)
        storage.smoke_disableCollisions = UIOperations.renderCheckbox(StorageManager__options_label[StorageManager.Options.Smoke_DisableCollisions], StorageManager__options_tooltip[StorageManager.Options.Smoke_DisableCollisions], storage.smoke_disableCollisions, StorageManager__options_default[StorageManager.Options.Smoke_DisableCollisions])
        storage.smoke_fadeIn = UIOperations.renderCheckbox(StorageManager__options_label[StorageManager.Options.Smoke_FadeIn], StorageManager__options_tooltip[StorageManager.Options.Smoke_FadeIn], storage.smoke_fadeIn, StorageManager__options_default[StorageManager.Options.Smoke_FadeIn])
    end)
    
    ui_popID()
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

-- ac.Particles.SmokeFlags = { FadeIn = 1, DisableCollisions = 256 }
-- smoke.flags = bit.bor(smoke.flags, ac.Particles.SmokeFlags.DisableCollisions)
-- smoke.flags = bit.bor(smoke.flags, ac.Particles.SmokeFlags.FadeIn)
-- ac.log('Smoke flags: ' .. tostring(smoke.flags))

---
-- wiki: called after a whole simulation update
---
function script.MANIFEST__UPDATE(dt)
    if flameInstance.waitingForClickToSetPosition   then
        local worldPositionFound, out_worldPosition = UIOperations.tryGetWorldPositionFromMouseClick()
        if worldPositionFound then
            ac.log('Flame position set to: ' .. tostring(out_worldPosition))
            storage.flame_position = out_worldPosition
            flameInstance.waitingForClickToSetPosition    = false
        end
    end
    
    if sparksInstance.waitingForClickToSetPosition then
        local worldPositionFound, out_worldPosition = UIOperations.tryGetWorldPositionFromMouseClick()
        if worldPositionFound then
            ac.log('Sparks position set to: ' .. tostring(out_worldPosition))
            storage.sparks_position = out_worldPosition
            sparksInstance.waitingForClickToSetPosition = false
        end
    end
    
    if smokeInstance.waitingForClickToSetPosition then
        local worldPositionFound, out_worldPosition = UIOperations.tryGetWorldPositionFromMouseClick()
        if worldPositionFound then
            ac.log('Smoke position set to: ' .. tostring(out_worldPosition))
            storage.smoke_position = out_worldPosition
            smokeInstance.waitingForClickToSetPosition = false
        end
    end
    
    if storage.flame_enabled then
        flame.color = storage.flame_color
        flame.size = storage.flame_size
        flame.temperatureMultiplier = storage.flame_temperatureMultiplier
        flame.flameIntensity = storage.flame_flameIntensity
        local position = storage.flame_position + storage.flame_positionOffset
        flame:emit(position, storage.flame_velocity, storage.flame_amount)
    end
    
    if storage.sparks_enabled then
        sparks.color = storage.sparks_color
        sparks.life = storage.sparks_life
        sparks.size = storage.sparks_size
        sparks.directionSpread = storage.sparks_directionSpread
        sparks.positionSpread = storage.sparks_positionSpread
        local position = storage.sparks_position + storage.sparks_positionOffset
        sparks:emit(position, storage.sparks_velocity, storage.sparks_amount)
    end
    
    if storage.smoke_enabled then
        smoke.color = storage.smoke_color
        smoke.colorConsistency = storage.smoke_colorConsistency
        smoke.thickness = storage.smoke_thickness
        smoke.life = storage.smoke_life
        smoke.size = storage.smoke_size
        smoke.spreadK = storage.smoke_spreadK
        smoke.growK = storage.smoke_growK
        smoke.targetYVelocity = storage.smoke_targetYVelocity
        
        local flags = 0
        if storage.smoke_disableCollisions then
            flags = bit.bor(flags, ac.Particles.SmokeFlags.DisableCollisions)
        end
        if storage.smoke_fadeIn then
            flags = bit.bor(flags, ac.Particles.SmokeFlags.FadeIn)
        end
        smoke.flags = flags

        local position = storage.smoke_position + storage.smoke_positionOffset
        smoke:emit(position, storage.smoke_velocity, storage.smoke_amount)
    end
end

---
-- wiki: called when transparent objects are finished rendering
---
function script.MANIFEST__TRANSPARENT(dt)
end