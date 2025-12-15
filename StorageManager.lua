local StorageManager = {}

local fillInDoDTables = function(collection_beforeDoD, options_default, options_min, options_max, options_label, options_tooltip)
    options_default = {}
    options_min = {}
    options_max = {}
    options_label = {}
    options_tooltip = {}

    for i, option in ipairs(collection_beforeDoD) do
        local optionName = option.name
        options_default[optionName] = option.default
        options_min[optionName] = option.min
        options_max[optionName] = option.max
        options_label[optionName] = option.label
        options_tooltip[optionName] = option.tooltip
    end

    return options_default, options_min, options_max, options_label, options_tooltip
end

---@enum StorageManager.Options
StorageManager.Options = {
    Flame_Enabled = 1,
    Flame_Position = 2,
    Flame_Velocity = 3,
    Flame_Color = 4,
    Flame_Size = 5,
    Flame_TemperatureMultiplier = 6,
    Flame_FlameIntensity = 7,
    Flame_Amount = 8
}

-- only used to fill in DoD tables, memory freed right after
local optionsCollection_beforeDoD = {
    { name = StorageManager.Options.Flame_Enabled, default=true, min=nil, max=nil, label='Enabled', tooltip='Enable Flames' },
    { name = StorageManager.Options.Flame_Position, default=vec3(0,0,0), min=nil, max=nil, label='Position', tooltip='Flame position in world coordinates' },
    { name = StorageManager.Options.Flame_Velocity, default=vec3(0,1,0), min=-100, max=100, label='Velocity', tooltip='Flame initial velocity' },
    { name = StorageManager.Options.Flame_Color, default=rgbm(0.5, 0.5, 0.5, 0.5), min=nil, max=nil, label='Color', tooltip='Flame color multiplier\n\nFor red/yellow/blue adjustment use `Temperature Multiplier` instead.' },
    { name = StorageManager.Options.Flame_Size, default=0.2, min=0, max=50, label='Size', tooltip='Particles size' },
    { name = StorageManager.Options.Flame_TemperatureMultiplier, default=1.0, min=0, max=10, label='Temperature Multiplier', tooltip='Temperature multipler to vary base color from red to blue.' },
    { name = StorageManager.Options.Flame_FlameIntensity, default=0.0, min=0, max=10, label='Flame Intensity', tooltip='Flame intensity affecting flame look and behaviour.' },
    { name = StorageManager.Options.Flame_Amount, default=1, min=1, max=10, label='Amount', tooltip='Not sure what this does' }
}

StorageManager.options_default,
StorageManager.options_min,
StorageManager.options_max,
StorageManager.options_label,
StorageManager.options_tooltip = fillInDoDTables(
        optionsCollection_beforeDoD,
        StorageManager.options_default,
        StorageManager.options_min,
        StorageManager.options_max
)
optionsCollection_beforeDoD = nil  -- free memory

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
    flame_enabled = StorageManager.options_default[StorageManager.Options.Flame_Enabled],
    flame_position = StorageManager.options_default[StorageManager.Options.Flame_Position],
    flame_velocity = StorageManager.options_default[StorageManager.Options.Flame_Velocity],
    flame_color = StorageManager.options_default[StorageManager.Options.Flame_Color],
    flame_size = StorageManager.options_default[StorageManager.Options.Flame_Size],
    flame_temperatureMultiplier = StorageManager.options_default[StorageManager.Options.Flame_TemperatureMultiplier],
    flame_flameIntensity = StorageManager.options_default[StorageManager.Options.Flame_FlameIntensity],
    flame_amount = StorageManager.options_default[StorageManager.Options.Flame_Amount],
}

---@type StorageTable
local storage = ac.storage(storageTable, "global")

StorageManager.getStorage = function()
    return storage
end

return StorageManager