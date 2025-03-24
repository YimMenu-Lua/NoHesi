local collision_invalid_models = {
    3008087081,
    415536433,
    874602658,
    693843550,
    4189527861,
    1152297372,
    3907562202,
    2954040756,
    1198649884,
    1067874014,
}

---@param timestamp integer
function Epoch2Time(timestamp)
    return os.date("!%H:%M:%S", timestamp)
end

---@param value integer
function SeparateInt(value)
    return tostring(value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

---@param ... number
---@return number
function Sum(...)
    local args, result = { ... }, 0
    for i = 1, #args do
        if type(args[i]) ~= 'number' then
            error(string.format(
                "Invalid argument '%s' at position (%d) in function sum(). The function only takes numbers as parameters.",
                args[i], i
            ))
        end
        result = result + args[i]
    end
    return result
end

function GetScreenResolution()
    local scr = {x = 0, y = 0}
    local sr_ptr = memory.scan_pattern("66 0F 6E 0D ? ? ? ? 0F B7 3D")
    if sr_ptr:is_valid() then
        scr.x = sr_ptr:sub(0x4):rip():get_word()
        scr.y = sr_ptr:add(0x4):rip():get_word()
    end
    return scr
end

function IsDriving()
    if self.get_veh() ~= 0 then
        local model = ENTITY.GET_ENTITY_MODEL(self.get_veh())
        local isCar = VEHICLE.IS_THIS_MODEL_A_CAR(model)
        local isBike = VEHICLE.IS_THIS_MODEL_A_BIKE(model)
        local isQuad = VEHICLE.IS_THIS_MODEL_A_QUADBIKE(model)
        return (
            (isCar or isBike or isQuad) and
            VEHICLE.GET_PED_IN_VEHICLE_SEAT(self.get_veh(), -1, false) == self.get_ped()
        )
    end
    return false
end

function GetVehSpeed()
    return IsDriving() and ENTITY.GET_ENTITY_SPEED(self.get_veh()) or 0
end

function GetEntityType(entity)
    if ENTITY.DOES_ENTITY_EXIST(entity) then
        local entPtr = memory.handle_to_ptr(entity)
        if entPtr:is_valid() then
            local m_model_info = entPtr:add(0x0020):deref()
            local m_model_type = m_model_info:add(0x009D)
            return m_model_type:get_word()
        end
    end
    return 0
end

function CheckVehicleCollision()
    if ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(self.get_veh()) then
        local entity = ENTITY.GET_LAST_ENTITY_HIT_BY_ENTITY_(self.get_veh())
        if entity ~= nil and entity ~= 0 and ENTITY.DOES_ENTITY_EXIST(entity) then
            local entity_type = GetEntityType(entity)
            if entity_type == 6 then
                return false
            elseif entity_type == 5 or entity_type == 157 then
                return true
            elseif entity_type == 1 or entity_type == 33 or entity_type == 7 then
                if ENTITY.DOES_ENTITY_HAVE_PHYSICS(entity) then
                    local model = ENTITY.GET_ENTITY_MODEL(entity)
                    for _, m in ipairs(collision_invalid_models) do
                        if model == m then
                            return true
                        end
                    end
                    return false
                else
                    return true
                end
            end
        else
            return true
        end
    end
    return false
end

---@param closeTo integer | vec3
---@param range integer
---@param excludeEntity? integer
function GetClosestVehicle(closeTo, range, excludeEntity)
    local thisPos = type(closeTo) == 'number' and ENTITY.GET_ENTITY_COORDS(closeTo, false) or closeTo
    if VEHICLE.IS_ANY_VEHICLE_NEAR_POINT(thisPos.x, thisPos.y, thisPos.z, range) then
        local veh_handles = entities.get_all_vehicles_as_handles()
        for i = 0, #veh_handles do
            if excludeEntity and veh_handles[i] == excludeEntity then
                i = i + 1
            end
            local vehPos = ENTITY.GET_ENTITY_COORDS(veh_handles[i], true)
            local vDist2 = SYSTEM.VDIST2(thisPos.x, thisPos.y, thisPos.z, vehPos.x, vehPos.y, vehPos.z)
            if vDist2 <= range and math.floor(VEHICLE.GET_VEHICLE_BODY_HEALTH(veh_handles[i])) > 0 then
                return veh_handles[i], vDist2
            end
        end
    end
    return 0, 0
end

function GetNearMisses()
    if IsDriving() and GetVehSpeed() > 15 then
        local leftPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(self.get_veh(), -1, 0, 0)
        local rightPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(self.get_veh(), 1, 0, 0)
        local closest_veh_l, dist_l = GetClosestVehicle(leftPos, 30, self.get_veh())
        local closest_veh_r, dist_r = GetClosestVehicle(rightPos, 30, self.get_veh())
        return closest_veh_l, closest_veh_r, dist_l, dist_r
    end
    return 0, 0, 0, 0
end
