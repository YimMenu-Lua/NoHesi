---@diagnostic disable

require("includes/nohesi_utils")
local CFG = require("includes/nohesi_cfg")
local default_config = {
    draw_graphics = false,
    highest_score = 0,
    longest_time = 0,
    uiPosX = 0.89,
    uiPosY = 0.3,
}
local config = CFG:new("tu89geji340t89u2", "NoHesi", default_config)
local highest_score = config:read_item("highest_score") or 0
local longest_time = config:read_item("longest_time") or 0
local draw_graphics = config:read_item("draw_graphics") or false
local uiPosX = config:read_item("uiPosX") or 0.89
local uiPosY = config:read_item("uiPosY") or 0.3
local script_enabled = true
local last_nm_l = 0
local last_nm_r = 0
local gfx_bg_col = { 255, 255, 255, 150 }


local Session = {}
Session.__index = Session
function Session:new()
    local instance = setmetatable({}, self)
    self._started = false
    self.score = 0
    self.time = 0
    self.speed_multiplier = 1.0
    self.proximity_multiplier = 1.0
    self.combo_multiplier = 1.0
    self.multiplier = 1.0
    self.closest_nearmiss = 0.0
    self.pb = highest_score
    return instance
end

function Session:reset()
    self.score = 0
    self.time = 0
    self.speed_multiplier = 1.0
    self.proximity_multiplier = 1.0
    self.combo_multiplier = 1.0
    self.multiplier = 1.0
    self.closest_nearmiss = 0.0
    self._started = false
end

local nohesi_tab = gui.add_tab("NoHesi")
local CurrentSession = Session:new()
nohesi_tab:add_imgui(function()
    ImGui.Spacing()
    script_enabled, _ = ImGui.Checkbox("Enable NoHesi", script_enabled)
    if script_enabled then
        ImGui.SameLine()
        draw_graphics, DgClicked = ImGui.Checkbox("Show NoHesi UI", draw_graphics)
        if ImGui.IsItemHovered() then
            ImGui.SetTooltip("The UI only appears when you're in a vehicle.")
        end
        if DgClicked then
            config:save_item("draw_graphics", draw_graphics)
        end

        if draw_graphics then
            ImGui.SeparatorText("NoHesi UI")
            uiPosX, uiposxChanged = ImGui.SliderFloat("Move Left/Right", uiPosX, 0.0, 1.0)
            if uiposxChanged then
                config:save_item("uiPosX", uiPosX)
            end

            uiPosY, uiposyChanged = ImGui.SliderFloat("Move Up/Down", uiPosY, 0.0, 1.0)
            if uiposyChanged then
                config:save_item("uiPosY", uiPosY)
            end

            if ImGui.Button("Reset") then
                uiPosX, uiPosY = 0.89, 0.3
                config:save_item("uiPosX", uiPosX)
                config:save_item("uiPosY", uiPosY)
            end
        end

        ImGui.Spacing()
        ImGui.SeparatorText("Player Info")
        ImGui.BulletText(("Current Score: %s Points"):format(SeparateInt(CurrentSession.score)))
        ImGui.BulletText(("Player Best: %s Points"):format(SeparateInt(highest_score)))
        ImGui.BulletText(("Current NoHesi Time: %s"):format(Epoch2Time(CurrentSession.time)))
        ImGui.BulletText(("Longest NoHesi Time: %s"):format(Epoch2Time(longest_time)))
    end
end)

script.register_looped("NOHESI_TIMER", function(timer)
    if script_enabled and CurrentSession._started then
        local start_time = os.time()
        repeat
            CurrentSession.time = os.time() - start_time
            timer:sleep(1)
        until not CurrentSession._started
        if CurrentSession.time > longest_time then
            longest_time = CurrentSession.time
            config:save_item("longest_time", CurrentSession.time)
        end
        if CurrentSession.score > config:read_item("highest_score") then
            highest_score = CurrentSession.score
            CurrentSession.pb = CurrentSession.score
            config:save_item("highest_score", CurrentSession.score)
        end
        CurrentSession:reset()
    end
end)

script.register_looped("NOHESI_GRAPHICS", function()
    if script_enabled and draw_graphics and IsDriving() then
        DrawNoHesiGraphics(
            uiPosX,
            uiPosY,
            CurrentSession.score,
            CurrentSession.speed_multiplier,
            CurrentSession.proximity_multiplier,
            CurrentSession.combo_multiplier,
            CurrentSession.multiplier,
            Epoch2Time(CurrentSession.time),
            CurrentSession.pb,
            gfx_bg_col
        )
    end
end)

script.register_looped("NOHESI", function(nohesi)
    if script_enabled then
        if IsDriving() and GetVehSpeed() > 1 then
            CurrentSession._started = true
            local shortest_dist = 0
            local nearmiss_l, nearmiss_r, distance_l, distance_r = GetNearMisses()
            if nearmiss_l ~= 0 and nearmiss_l ~= last_nm_l then
                CurrentSession.score = (math.floor(CurrentSession.score + CurrentSession.multiplier + (GetVehSpeed() * math.pi)))
                CurrentSession.score = math.floor(CurrentSession.score + (1000 * CurrentSession.multiplier))
                if distance_l > 0 then
                    CurrentSession.closest_nearmiss = distance_l
                end
                last_nm_l = nearmiss_l
            end
            if nearmiss_r ~= 0 and nearmiss_r ~= last_nm_r then
                CurrentSession.score = math.floor(CurrentSession.score + CurrentSession.multiplier +
                (GetVehSpeed() * math.pi))
                CurrentSession.score = math.floor(CurrentSession.score + 1000 * CurrentSession.multiplier)
                if distance_r > 0 then
                    CurrentSession.closest_nearmiss = distance_r
                end
                last_nm_r = nearmiss_r
            end

            if GetVehSpeed() >= 22 then
                if GetVehSpeed() < 40 then
                    CurrentSession.speed_multiplier = 2.5
                elseif GetVehSpeed() >= 40 and GetVehSpeed() < 50 then
                    CurrentSession.speed_multiplier = 5.0
                elseif GetVehSpeed() >= 50 and GetVehSpeed() < 70 then
                    CurrentSession.speed_multiplier = 10
                elseif GetVehSpeed() > 70 then -- cheater
                    CurrentSession.speed_multiplier = 69
                end
            else
                CurrentSession.speed_multiplier = 1.0
            end

            if CurrentSession.closest_nearmiss > 0 and CurrentSession.closest_nearmiss <= 30 then
                if CurrentSession.closest_nearmiss <= 26 then
                    CurrentSession.proximity_multiplier = 7.5
                elseif CurrentSession.closest_nearmiss > 26 and CurrentSession.closest_nearmiss <= 27 then
                    CurrentSession.proximity_multiplier = 3.5
                elseif CurrentSession.closest_nearmiss > 27 and CurrentSession.closest_nearmiss <= 28 then
                    CurrentSession.proximity_multiplier = 1.5
                end
            else
                CurrentSession.proximity_multiplier = 1.0
            end

            if CurrentSession.score > 0 then
                if CurrentSession.score > 1000 and CurrentSession.score <= 10000 then
                    CurrentSession.combo_multiplier = 2.5
                elseif CurrentSession.score > 10000 and CurrentSession.score <= 100000 then
                    CurrentSession.combo_multiplier = 5.5
                elseif CurrentSession.score > 100000 and CurrentSession.score <= 500000 then
                    CurrentSession.combo_multiplier = 7.5
                elseif CurrentSession.score >= 1000000 then
                    CurrentSession.combo_multiplier = 10
                end
            else
                CurrentSession.combo_multiplier = 1.0
            end

            CurrentSession.multiplier = (
                CurrentSession.speed_multiplier +
                CurrentSession.proximity_multiplier +
                CurrentSession.combo_multiplier
            ) / 3

            if CurrentSession.multiplier < 1.0 then
                CurrentSession.multiplier = 1.0
            end

            if CurrentSession.score > highest_score then
                highest_score = CurrentSession.score
                CurrentSession.pb = CurrentSession.score
            end

            if CheckVehicleCollision() then
                CurrentSession._started = false
                last_nm_l, last_nm_r = 0, 0
                if CurrentSession.score > 0 then
                    gfx_bg_col = { 255, 0, 0, 150 }
                end
                nohesi:sleep(3000)
                gfx_bg_col = { 255, 255, 255, 150 }
            end
        else
            CurrentSession._started = false
        end
    end
end)
