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
Sum = function(...)
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

---@param posX float
---@param posY float
---@param text string
---@param color table
---@param scale table
---@param font number
---@param alignment? number
---@param dropShadow? boolean
---@param outline? boolean
DrawText = function(posX, posY, text, color, scale, font, alignment, dropShadow, outline)
    HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("TWOSTRINGS")
    HUD.SET_TEXT_COLOUR(color[1], color[2], color[3], color[4] or 255)
    HUD.SET_TEXT_SCALE(scale[1], scale[2])
    HUD.SET_TEXT_FONT(font)
    if alignment and alignment >= 0 and alignment <= 2 then
        HUD.SET_TEXT_JUSTIFICATION(alignment)
        HUD.SET_TEXT_WRAP(posX, 1.0)
    else
        HUD.SET_TEXT_CENTRE(true)
    end
    if dropShadow then
        HUD.SET_TEXT_DROP_SHADOW()
    end
    if outline then
        HUD.SET_TEXT_OUTLINE()
    end
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text)
    HUD.END_TEXT_COMMAND_DISPLAY_TEXT(posX, posY, 0)
end

function DrawNoHesiGraphics(
    posx,
    posy,
    score,
    speed_multiplier,
    proximity_multiplier,
    combo_multiplier,
    total_multiplier,
    time,
    player_best,
    bgColor
)
    if combo_multiplier < 1000 then
        Combo_ = string.format("%.1fX", combo_multiplier)
    else
        Combo_ = string.format("X%.1fK", combo_multiplier / 1000)
    end

    if total_multiplier < 1000 then
        Total_ = string.format("%.1fX", total_multiplier)
    else
        Total_ = string.format("X%.1fK", total_multiplier / 1000)
    end

    if #tostring(Total_) <= 5 then
        TotalX_Size = { 0.5, 0.59 }
        TotalX_Posx, TotalX_PosY = posx + 0.05, posy - 0.04
    else
        local size_diff = (#Total_ - 5) * 0.1
        local pos_diff = size_diff / 20
        TotalX_Size = { 0.5 - size_diff, 0.59 - size_diff}
        TotalX_Posx, TotalX_PosY = posx + (0.05 - pos_diff), posy - (0.04 - pos_diff)
    end
    -- background
    GRAPHICS.DRAW_RECT(posx, posy + 0.01, 0.2, 0.22, 25, 25, 25, 150, false)
    DrawText(posx, posy - 0.1, "NoHesi", { 0, 0, 0, 200 }, { 3.0, 1.0 }, 1, 0, true, true)

    -- speed
    GRAPHICS.DRAW_RECT(posx - 0.075, posy - 0.02, 0.043, 0.04, 255, 255, 255, 150, false)
    DrawText(posx - 0.075, posy - 0.045, string.format("%.1fX", speed_multiplier), { 0, 0, 0, 200 }, { 1, 0.5 }, 0, 0,
        false)
    DrawText(posx - 0.075, posy - 0.02, "Speed", { 0, 0, 0, 200 }, { 0.3, 0.3 }, 0, 0, false)

    -- distance
    GRAPHICS.DRAW_RECT(posx - 0.027, posy - 0.02, 0.043, 0.04, 255, 255, 255, 150, false)
    DrawText(posx - 0.027, posy - 0.045, string.format("%.1fX", proximity_multiplier), { 0, 0, 0, 200 }, { 1, 0.5 }, 0, 0,
        false)
    DrawText(posx - 0.027, posy - 0.02, "Proximity", { 0, 0, 0, 200 }, { 0.3, 0.3 }, 0, 0, false)

    -- combo
    GRAPHICS.DRAW_RECT(posx + 0.02, posy - 0.02, 0.043, 0.04, 255, 255, 255, 150, false)
    DrawText(posx + 0.02, posy - 0.045, Combo_, { 0, 0, 0, 200 }, { 1, 0.5 }, 0, 0,
        false)
    DrawText(posx + 0.02, posy - 0.02, "Combo", { 0, 0, 0, 200 }, { 0.3, 0.3 }, 0, 0, false)

    -- total multiplier
    GRAPHICS.DRAW_RECT(posx + 0.07, posy - 0.015, 0.056, 0.05, 0, 0, 255, 100, false)
    DrawText(TotalX_Posx, TotalX_PosY, Total_, { 0, 0, 0, 200 }, TotalX_Size, 0, 1,
        false)

    -- score + time
    GRAPHICS.DRAW_RECT(posx - 0.0275, posy + 0.031, 0.137, 0.055, bgColor[1], bgColor[2], bgColor[3], bgColor[4], false)
    DrawText(posx - 0.0275, posy + 0.0155, string.format("%s PTS", SeparateInt(score)), { 0, 0, 0, 200 }, { 1, 0.5 }, 0)
    GRAPHICS.DRAW_RECT(posx + 0.066, posy + 0.036, 0.05, 0.045, 90, 10, 220, 150, false)
    DrawText(posx + 0.066, posy + 0.025, string.format("%s", time), { 0, 0, 0, 200 }, { 0.3, 0.3 }, 0, 0, false)

    GRAPHICS.DRAW_RECT(posx - 0.081, posy + 0.082, 0.03, 0.04, 255, 215, 0, 150, false)
    DrawText(posx - 0.081, posy + 0.062, "PB", { 0, 0, 0, 200 }, { 1, 0.5 }, 0, 0, false)
    GRAPHICS.DRAW_RECT(posx + 0.016, posy + 0.082, 0.16, 0.04, 255, 215, 0, 150, false)
    DrawText(posx + 0.01, posy + 0.062, string.format("%s PTS", SeparateInt(player_best)), { 0, 0, 0, 200 }, { 1, 0.5 },
    0)
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

CheckVehicleCollision = function()
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
