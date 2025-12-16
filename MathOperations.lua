local MathOperations = {}

--- Splits a velocity vector into its speed (magnitude) and direction (normalized vector).
---@param velocity vec3 @The velocity vector to split.
---@param outDirection vec3 @Output parameter to store the direction vector.
---@return number speed @The magnitude of the velocity vector.
---@return vec3 direction @The normalized direction vector.
MathOperations.splitVelocity = function(velocity, outDirection)
    local speed = velocity:length()
    -- local direction = vec3(0, 0, 0)

    if speed > 0 then
        -- direction = velocity / speed
        velocity:normalize(outDirection)
    else
        outDirection:set(0, 0, 0)
    end

    return speed, outDirection
end

return MathOperations