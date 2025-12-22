local ParticleEffectsManager = {}

---@class FlameEffectWrapper
---@field enabled boolean
---@field position vec3
---@field positionOffset vec3
---@field velocity vec3
---@field amount number
---@field waitingForClickToSetPosition boolean
---@field getFinalPosition fun():vec3
---@field effect ac.Particles.Flame

---@class SparksEffectWrapper
---@field enabled boolean
---@field position vec3
---@field positionOffset vec3
---@field velocity vec3
---@field amount number
---@field waitingForClickToSetPosition boolean
---@field getFinalPosition fun():vec3
---@field effect ac.Particles.Sparks

---@class SmokeEffectWrapper
---@field enabled boolean
---@field position vec3
---@field positionOffset vec3
---@field velocity vec3
---@field amount number
---@field waitingForClickToSetPosition boolean
---@field getFinalPosition fun():vec3
---@field effect ac.Particles.Smoke

local generateWrapper = function(effect)
    local wrapper = {
        enabled = false,
        
        position = vec3(0, 0, 0),
        positionOffset = vec3(0, 0, 0),
        velocity = vec3(0, 0, 0),
        amount = 0,
        
        waitingForClickToSetPosition = false,
        
        effect = effect
    }

    wrapper.getFinalPosition = function()
        return wrapper.position + wrapper.positionOffset
    end

    return wrapper
end

local generators = {
    ---@return FlameEffectWrapper
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
    ---@return SparksEffectWrapper
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
    ---@return SmokeEffectWrapper
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

---@param effectType ParticleEffectsType
---@return FlameEffectWrapper|SmokeEffectWrapper|SparksEffectWrapper
ParticleEffectsManager.generateParticleEffect = function(effectType)
    return generators[effectType]()
end

return ParticleEffectsManager