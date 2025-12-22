local ParticlesTesterExtConfigFileHandler = {}

local sectionPrefixes = {
    [ParticleEffectsType.Flame] = 'FLAME',
    [ParticleEffectsType.Sparks] = 'SPARKS',
    [ParticleEffectsType.Smoke] = 'SMOKE',
}

local writers = {
    [ParticleEffectsType.Flame] = function (file, fullSectionName, effect, position, velocity, amount)
        file:set(fullSectionName, 'POSITION', position)
        file:set(fullSectionName, 'VELOCITY', velocity)
        file:set(fullSectionName, 'AMOUNT', amount)
        file:set(fullSectionName, 'TEMPERATURE_MULT', effect.temperatureMultiplier)
        file:set(fullSectionName, 'FLAME_INTENSITY', effect.flameIntensity)
    end,
}

---@param extConfigFileType ExtConfigFileHandler.ExtConfigFileTypes
---@param particleEffectsType ParticleEffectsType
---@param effectInstance FlameEffectWrapper|SparksEffectWrapper|SmokeEffectWrapper
ParticlesTesterExtConfigFileHandler.writeToExtConfig = function(extConfigFileType, particleEffectsType, effectInstance)
    local sectionPrefix = sectionPrefixes[particleEffectsType]
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