---@diagnostic disable

require("includes.nohesi_utils")
require("includes.nohesi_ui")
local Toast = require("YimToast")
local CFG = require("includes/nohesi_cfg")
local SCREEN_RES <const> = GetScreenResolution()
local ImGui_win_w = 440
local ImGui_win_h = 360
local default_config = {
    draw_graphics = false,
    ui_type = 0,
    highest_score = 0,
    longest_time = 0,
    nativeUiPosX = 0.89,
    nativeUiPosY = 0.3,
    ImGuiPosX = SCREEN_RES.x - (ImGui_win_w + 10),
    ImGuiPosY = (SCREEN_RES.y / 2) - (ImGui_win_h / 2),
    ImGuiWindowAlpha = 0.0
}

local config = CFG:new("tu89geji340t89u2", "NoHesi", default_config)
local highest_score = config:read_item("highest_score") or 0
local longest_time = config:read_item("longest_time") or 0
local nativeUiPosX = config:read_item("nativeUiPosX") or 0.89
local nativeUiPosY = config:read_item("nativeUiPosY") or 0.3
local ImGuiPosX = config:read_item("ImGuiPosX") or SCREEN_RES.x - (ImGui_win_w + 10)
local ImGuiPosY = config:read_item("ImGuiPosY") or (SCREEN_RES.y / 2) - (ImGui_win_h / 2)
local ImGuiWindowAlpha = config:read_item("ImGuiWindowAlpha") or 0.0
local last_nm_l = 0
local last_nm_r = 0
local gfx_bg_col = { 255, 255, 255, 150 }
script_enabled = false
draw_graphics = config:read_item("draw_graphics") or false
ui_type = config:read_item("ui_type") or 0


local Session = {}
Session.__index = Session
function Session:New()
    local instance = setmetatable({}, self)
    self._started = false
    self.score = 0
    self.time = 0
    self.speed_multiplier = 1.0
    self.proximity_multiplier = 1.0
    self.combo_multiplier = 1.0
    self.multiplier = 1.0
    self.nearmiss_interval = 3
    self.closest_nearmiss = 0.0
    self.last_nearmiss_time = 0.0
    self.pb = highest_score
    return instance
end

function Session:Reset()
    self.score = 0
    self.time = 0
    self.speed_multiplier = 1.0
    self.proximity_multiplier = 1.0
    self.combo_multiplier = 1.0
    self.multiplier = 1.0
    self.closest_nearmiss = 0.0
    self.last_nearmiss_time = 0.0
    self._started = false
end

function Session:Timer()
    if script_enabled and self._started then
        local start_time = os.time()
        repeat
            self.time = os.time() - start_time
            coroutine.yield()
        until not self._started
        if self.time > longest_time then
            longest_time = self.time
            config:save_item("longest_time", self.time)
        end
        if self.score > config:read_item("highest_score") then
            Toast:ShowSuccess("NoHesi", "New Best Score!")
            highest_score = self.score
            self.pb = self.score
            config:save_item("highest_score", self.score)
        end
        self:Reset()
    end
end

function Session:ComboTimer()
    if script_enabled and self._started then
        local elapsed = os.clock() - self.last_nearmiss_time
        if elapsed >= self.nearmiss_interval and self.combo_multiplier > 1 then
            self.combo_multiplier = self.combo_multiplier - 1
            self.last_nearmiss_time = os.clock()
        end
        coroutine.yield()
    end
end

function Session:DrawGfx()
    if script_enabled and draw_graphics and IsDriving() then
        if ui_type == 1 then
            DrawNativeUI(
                nativeUiPosX,
                nativeUiPosY,
                self.score,
                self.speed_multiplier,
                self.proximity_multiplier,
                self.combo_multiplier,
                self.multiplier,
                Epoch2Time(self.time),
                self.pb,
                gfx_bg_col
            )
        end
    end
end


local CurrentSession = Session:New()
local NoHesi_tab = gui.add_tab("NoHesi")
NoHesi_tab:add_imgui(function()
    ImGui.Spacing()
    script_enabled, _ = ImGui.Checkbox("Enable NoHesi", script_enabled)
    if script_enabled then
        ImGui.SameLine()
        draw_graphics, DgClicked = ImGui.Checkbox("Show UI", draw_graphics)
        if ImGui.IsItemHovered() then
            ImGui.SetTooltip("The UI only appears when you're in a vehicle.")
        end
        if DgClicked then
            config:save_item("draw_graphics", draw_graphics)
        end

        if draw_graphics then
            ImGui.Dummy(1, 10)
            ImGui.SeparatorText("UI Settings")
            ui_type, imgui = ImGui.RadioButton("ImGui", ui_type, 0)
            if imgui then
                config:save_item("ui_type", 0)
            end

            ImGui.SameLine()
            ImGui.Spacing()
            ImGui.SameLine()
            ui_type, nativeui = ImGui.RadioButton("NativeUI", ui_type, 1)
            if nativeui then
                config:save_item("ui_type", 1)
            end

            if ui_type == 0 then
                ImGuiWindowAlpha, ImGuiAlphaChanged = ImGui.SliderFloat("Transparency", ImGuiWindowAlpha, 0.0, 1.0)
                if ImGuiAlphaChanged then
                    config:save_item("ImGuiWindowAlpha", ImGuiWindowAlpha)
                end

                ImGuiPosX, ImGuiPosXChanged = ImGui.SliderFloat("Move Left/Right", ImGuiPosX, 0.0, (SCREEN_RES.x - ImGui_win_w))
                if ImGuiPosXChanged then
                    config:save_item("ImGuiPosX", ImGuiPosX)
                end

                ImGuiPosY, ImGuiPosYChanged = ImGui.SliderFloat("Move Up/Down", ImGuiPosY, 0.0, (SCREEN_RES.y - ImGui_win_h))
                if ImGuiPosYChanged then
                    config:save_item("ImGuiPosY", ImGuiPosY)
                end

                if ImGui.Button("Reset") then
                    ImGuiPosX = SCREEN_RES.x - (ImGui_win_w + 10)
                    ImGuiPosY = (SCREEN_RES.y / 2) - (ImGui_win_h / 2)
                    config:save_item("ImGuiPosX", ImGuiPosX)
                    config:save_item("uiPosY", ImGuiPosY)
                end
            else
                nativeUiPosX, nativeUiPosXChanged = ImGui.SliderFloat("Move Left/Right", nativeUiPosX, 0.0, 1.0)
                if nativeUiPosXChanged then
                    config:save_item("nativeUiPosX", nativeUiPosX)
                end

                nativeUiPosY, nativeUiPosChanged = ImGui.SliderFloat("Move Up/Down", nativeUiPosY, 0.0, 1.0)
                if nativeUiPosChanged then
                    config:save_item("nativeUiPosY", nativeUiPosY)
                end

                if ImGui.Button("Reset") then
                    nativeUiPosX, nativeUiPosY = 0.89, 0.3
                    config:save_item("nativeUiPosX", nativeUiPosX)
                    config:save_item("nativeUiPosY", nativeUiPosY)
                end
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

gui.add_always_draw_imgui(function()
    DrawImGui(
        ImGuiPosX,
        ImGuiPosY,
        ImGui_win_w,
        ImGui_win_h,
        ImGuiWindowAlpha,
        CurrentSession.score,
        CurrentSession.speed_multiplier,
        CurrentSession.proximity_multiplier,
        CurrentSession.combo_multiplier,
        CurrentSession.multiplier,
        Epoch2Time(CurrentSession.time),
        CurrentSession.pb
    )
end)

script.register_looped("NOHESI_TIMER", function()
    CurrentSession:Timer()
end)

script.register_looped("NOHESI_COMBO_TIMER", function()
    CurrentSession:ComboTimer()
end)

script.register_looped("NOHESI_GFX", function()
    CurrentSession:DrawGfx()
end)

script.register_looped("NOHESI", function(nohesi)
    if script_enabled then
        if IsDriving() and GetVehSpeed() > 1 then
            CurrentSession._started = true
            local shortest_dist = 0
            local nearmiss_l, nearmiss_r, distance_l, distance_r = GetNearMisses()
            if nearmiss_l ~= 0 and nearmiss_l ~= last_nm_l then
                CurrentSession.combo_multiplier = CurrentSession.combo_multiplier + 1
                CurrentSession.last_nearmiss_time = os.clock()
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

            CurrentSession.multiplier = (
                CurrentSession.speed_multiplier +
                CurrentSession.proximity_multiplier +
                CurrentSession.combo_multiplier
            ) / 3

            if CurrentSession.multiplier < 1.0 then
                CurrentSession.multiplier = 1.0
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
