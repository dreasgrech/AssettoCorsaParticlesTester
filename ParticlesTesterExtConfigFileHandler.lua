local ParticlesTesterExtConfigFileHandler = {}

local MathOperations_splitVelocity = MathOperations.splitVelocity

local SectionPrefixes = ExtConfigDefinitions.SectionPrefixes
local ExtConfigKeyType = ExtConfigDefinitions.ExtConfigKeyType

--- Temporary vector for direction calculation
local outDirection = vec3(0, 0, 0)

local writers = {
    [ParticleEffectsType.Flame] = function (file, fullSectionName, effect, position, velocity, amount)
        local speed, direction = MathOperations_splitVelocity(velocity, outDirection)
        local color = effect.color

        file:set(fullSectionName, ExtConfigCodeGenerator.getExtConfigKeyName(ExtConfigKeyType.Position), position)
        file:set(fullSectionName, ExtConfigCodeGenerator.getExtConfigKeyName(ExtConfigKeyType.Direction), direction)
        file:set(fullSectionName, ExtConfigCodeGenerator.getExtConfigKeyName(ExtConfigKeyType.Speed), speed)
        file:set(fullSectionName, ExtConfigCodeGenerator.getExtConfigKeyName(ExtConfigKeyType.Intensity), amount)
        file:set(fullSectionName, ExtConfigCodeGenerator.getExtConfigKeyName(ExtConfigKeyType.Color), color)
        file:set(fullSectionName, ExtConfigCodeGenerator.getExtConfigKeyName(ExtConfigKeyType.Size), effect.size)
        file:set(fullSectionName, ExtConfigCodeGenerator.getExtConfigKeyName(ExtConfigKeyType.TemperatureMult), effect.temperatureMultiplier)
        file:set(fullSectionName, ExtConfigCodeGenerator.getExtConfigKeyName(ExtConfigKeyType.FlameIntensity), effect.flameIntensity)
    end,
}

---@param extConfigFileType ExtConfigFileHandler.ExtConfigFileTypes
---@param particleEffectsType ParticleEffectsType
---@param effectInstance FlameEffectWrapper|SparksEffectWrapper|SmokeEffectWrapper
ParticlesTesterExtConfigFileHandler.writeToExtConfig = function(extConfigFileType, particleEffectsType, effectInstance)
    local sectionPrefix = SectionPrefixes[particleEffectsType]
    if not sectionPrefix then
        ac.log('Unknown particle effects type: ' .. tostring(particleEffectsType))
        return
    end

    ExtConfigFileHandler.writeNewSectionToExtConfigFile(
        extConfigFileType,
        sectionPrefix,
        function (file, fullSectionName)
            local effectWrapper = effectInstance
            local effect = effectWrapper.effect
            local position = effectWrapper.position
            local velocity = effectWrapper.velocity
            local amount = effectWrapper.amount

            writers[particleEffectsType](file, fullSectionName, effect, position, velocity, amount)
        end
    )

end

return ParticlesTesterExtConfigFileHandler