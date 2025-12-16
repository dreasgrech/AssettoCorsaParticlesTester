local ParticleEffectsManager = {}

local generateWrapper = function(effect)
    return {
        enabled = false,
        
        position = vec3(0, 0, 0),
        positionOffset = vec3(0, 0, 0),
        velocity = vec3(0, 0, 0),
        
        waitingForClickToSetPosition = false,
        
        effect = effect
    }
end

local generators = {
    [ParticleEffectsType.Flame] = function()
        local instance = (function()
            local flame = ac.Particles.Flame( {
                color = rgbm(1, 1, 1, 1),
                size = 0,
                
                temperatureMultiplier = 0,
                flameIntensity = 0
            })
            
            local obj = generateWrapper(flame)
            return obj;
        end)()
        
        return instance
    end,
    [ParticleEffectsType.Sparks] = function()
        local instance = (function()
            local sparks = ac.Particles.Sparks({
                color = rgbm(0, 0, 0, 0),
                size = 0,
                
                life = 0,
                directionSpread = 0,
                positionSpread = 0
            })

            local obj = generateWrapper(sparks)
            return obj;
        end)()

        return instance
    end,
    [ParticleEffectsType.Smoke] = function()
        local instance = (function()
            local smoke = ac.Particles.Smoke({
                color = rgbm(0, 0, 0, 0),
                size = 0,

                life = 0,
                colorConsistency = 0,
                thickness = 0,
                spreadK = 0,
                growK = 0,
                targetYVelocity = 0,
            })

            local obj = generateWrapper(smoke)
            return obj;
        end)()

        return instance
    end
}

ParticleEffectsManager.generateParticleEffect = function(effectType)
    return generators[effectType]()
end

return ParticleEffectsManager