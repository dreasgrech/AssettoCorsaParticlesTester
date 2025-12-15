local ExtConfigCodeGenerator = {}

-- ---@param effect ac.Particles.Flame|ac.Particles.Smoke|ac.Particles.Sparks
-- ExtConfigCodeGenerator.generateCode = function(effect)
--     effect.
-- end

--[=====[

[TEMPLATE: _Particles_Bonfire_Fire]
@OUTPUT = FLAME_...
POSITION = $Position
DIRECTION = $Direction
INTENSITY = $_Condition
SIZE = 1
SPEED = 0.5
TEMPERATURE_MULT = 1
FLAME_INTENSITY = 1.1
COLOR = 1, 1, 1, 1

[TEMPLATE: _Particles_Bonfire_Sparks]
@OUTPUT = SPARKS_...
POSITION = $Position
DIRECTION = $Direction
SPEED = 2
LIFE = 0.2
COLOR = '#FE9806'
SPREAD_DIR = 1
SPREAD_POS = 0.2
INTENSITY = 0.05 * $_Condition

[TEMPLATE: _Particles_Bonfire_Smoke]
@OUTPUT = SMOKE_...
POSITION = $Position
DIRECTION = $Direction
SPEED = 2
SIZE = 0.2
COLOR = 0.4, 0.5, 0.6, 0.5
COLOR_CONSISTENCY = 0.3
SPREAD = 0.1
GROW = 0.5
INTENSITY = 0.1 * $_Condition
THICKNESS = 1
LIFE = 30
TARGET_Y_VELOCITY = 0.5

--]=====]

---@param effect ac.Particles.Flame
---@param position vec3
---@param velocity vec3
ExtConfigCodeGenerator.generateCodeForFlames = function(effect, position, velocity)
    local stringBuilder = {}
    table.insert(stringBuilder, "[FLAME_...]")
    table.insert(stringBuilder, string.format("POSITION = %.2f, %.2f, %.2f", position.x, position.y, position.z))
    table.insert(stringBuilder, string.format("DIRECTION = %.2f, %.2f, %.2f", velocity.x, velocity.y, velocity.z))
    -- table.insert(stringBuilder, string.format("INTENSITY = $_Condition"))
    table.insert(stringBuilder, string.format("SIZE = %.2f", effect.size))
    --table.insert(stringBuilder, string.format("SPEED = %.2f", effect:getSpeed()))
    table.insert(stringBuilder, string.format("TEMPERATURE_MULT = %.2f", effect.temperatureMultiplier))
    table.insert(stringBuilder, string.format("FLAME_INTENSITY = %.2f", effect.flameIntensity))
    local color = effect.color
    table.insert(stringBuilder, string.format("COLOR = %.2f, %.2f, %.2f, %.2f", color.r, color.g, color.b, color.mult))
    return table.concat(stringBuilder, "\n")
end

---@param effect ac.Particles.Sparks
---@param position vec3
---@param velocity vec3
ExtConfigCodeGenerator.generateCodeForSparks = function(effect, position, velocity)
    local stringBuilder = {}
    table.insert(stringBuilder, "[SPARKS_...]")
    table.insert(stringBuilder, string.format("POSITION = %.2f, %.2f, %.2f", position.x, position.y, position.z))
    table.insert(stringBuilder, string.format("DIRECTION = %.2f, %.2f, %.2f", velocity.x, velocity.y, velocity.z))
    --table.insert(stringBuilder, string.format("SPEED = %.2f", effect.speed))
    table.insert(stringBuilder, string.format("LIFE = %.2f", effect.life))
    table.insert(stringBuilder, string.format("COLOR = '#%02X%02X%02X'", math.floor(effect.color.r * 255), math.floor(effect.color.g * 255), math.floor(effect.color.b * 255)))
    table.insert(stringBuilder, string.format("SPREAD_DIR = %.2f", effect.directionSpread))
    table.insert(stringBuilder, string.format("SPREAD_POS = %.2f", effect.positionSpread))
    -- table.insert(stringBuilder, string.format("INTENSITY = 0.05 * $_Condition"))
    return table.concat(stringBuilder, "\n")
end

---@param effect ac.Particles.Smoke
---@param position vec3
---@param velocity vec3
ExtConfigCodeGenerator.generateCodeForSmoke = function(effect, position, velocity)
    local stringBuilder = {}
    table.insert(stringBuilder, "[SMOKE_...]")
    table.insert(stringBuilder, string.format("POSITION = %.2f, %.2f, %.2f", position.x, position.y, position.z))
    table.insert(stringBuilder, string.format("DIRECTION = %.2f, %.2f, %.2f", velocity.x, velocity.y, velocity.z))
    --table.insert(stringBuilder, string.format("SPEED = %.2f", effect.speed))
    table.insert(stringBuilder, string.format("SIZE = %.2f", effect.size))
    table.insert(stringBuilder, string.format("COLOR = %.2f, %.2f, %.2f, %.2f", effect.color.r, effect.color.g, effect.color.b, effect.color.mult))
    table.insert(stringBuilder, string.format("COLOR_CONSISTENCY = %.2f", effect.colorConsistency))
    table.insert(stringBuilder, string.format("SPREAD = %.2f", effect.spreadK))
    table.insert(stringBuilder, string.format("GROW = %.2f", effect.growK))
    -- table.insert(stringBuilder, string.format("INTENSITY = 0.1 * $_Condition"))
    table.insert(stringBuilder, string.format("THICKNESS = %.2f", effect.thickness))
    table.insert(stringBuilder, string.format("LIFE = %.2f", effect.life))
    table.insert(stringBuilder, string.format("TARGET_Y_VELOCITY = %.2f", effect.targetYVelocity))
    return table.concat(stringBuilder, "\n")
    
end

return ExtConfigCodeGenerator