---@diagnostic disable
require("nohesi_utils")

---@param posX float
---@param posY float
---@param text string
---@param color table
---@param scale table
---@param font number
---@param alignment? number
---@param dropShadow? boolean
---@param outline? boolean
function DrawText(
    posX,
    posY,
    text,
    color,
    scale,
    font,
    alignment,
    dropShadow,
    outline
)
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

function DrawNativeUI(
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

---@param should_draw boolean
---@param window_posx number
---@param window_posy number
---@param win_w number
---@param win_h number
---@param win_alpha number
---@param score number
---@param speed_multiplier number
---@param proximity_multiplier number
---@param combo_multiplier number
---@param total_multiplier number
---@param time string
---@param player_best number
function DrawImGui(
    window_posx,
    window_posy,
    win_w,
    win_h,
    win_alpha,
    score,
    speed_multiplier,
    proximity_multiplier,
    combo_multiplier,
    total_multiplier,
    time,
    player_best
)
    if script_enabled and
        draw_graphics and
        IsDriving() and
        (ui_type == 0)
    then
        if combo_multiplier < 1000 then
            Combo_ = string.format("x%.1f", combo_multiplier)
        else
            Combo_ = string.format("x%.1fK", combo_multiplier / 1000)
        end

        if total_multiplier < 1000 then
            Total_ = string.format("x%.1f", total_multiplier)
        else
            Total_ = string.format("x%.1fK", total_multiplier / 1000)
        end

        ImGui.SetNextWindowBgAlpha(win_alpha)
        ImGui.SetNextWindowSize(win_w, win_h)
        ImGui.SetNextWindowPos(window_posx, window_posy)
        if ImGui.Begin(
            "NoHesiGui",
            ImGuiWindowFlags.NoMove |
            ImGuiWindowFlags.NoResize |
            ImGuiWindowFlags.NoScrollbar |
            ImGuiWindowFlags.NoTitleBar
        ) then
            ImGui.Dummy(105, 1)
            ImGui.SameLine()
            ImGui.SetWindowFontScale(3)
            ImGui.PushStyleColor(ImGuiCol.Text, 0.0, 0.0, 0.0, 1.0)
            ImGui.Text("NoHesi")
            ImGui.Separator()
            ImGui.PopStyleColor()
            ImGui.SetWindowFontScale(1.12)

            if ImGui.BeginChild(
                "xSpeed",
                win_w / 5, 69,
                true,
                ImGuiWindowFlags.NoScrollbar
            ) then
                ImGui.SetWindowFontScale(1.12)
                ImGui.Text(string.format(" x%.1f", speed_multiplier))
                ImGui.SetWindowFontScale(0.8)
                ImGui.Text(" Speed")
                -- ImGui.SetWindowFontScale(1.12)
                ImGui.EndChild()
                ImGui.SameLine()
            end

            if ImGui.BeginChild(
            "xProximity",
            win_w / 5, 69,
            true,
            ImGuiWindowFlags.NoScrollbar
            ) then
                ImGui.SetWindowFontScale(1.12)
                ImGui.Text(string.format("  x%.1f", proximity_multiplier))
                ImGui.SetWindowFontScale(0.8)
                ImGui.Text("Proximity")
                ImGui.EndChild()
                ImGui.SameLine()
            end

            if ImGui.BeginChild(
            "xCombo",
            win_w / 5, 69,
            true,
            ImGuiWindowFlags.NoScrollbar
            ) then
                ImGui.SetWindowFontScale(1.12)
                ImGui.Text(Combo_)
                ImGui.SetWindowFontScale(0.8)
                ImGui.Text("Combo")
                ImGui.EndChild()
                ImGui.SameLine()
            end

            if ImGui.BeginChild(
                "Total",
                win_w / 3, 80,
                true,
                ImGuiWindowFlags.NoScrollbar
            ) then
                ImGui.SetWindowFontScale(1.7)
                ImGui.Text(Total_)
                ImGui.SetWindowFontScale(1)
                ImGui.EndChild()
            end

            if score > 0 then
                ImGui.PushStyleColor(ImGuiCol.ChildBg, 0.01, score / 1e9, 0.01, 0.6)
            end
            if ImGui.BeginChild(
                "Score",
                win_w - (win_w / 4), 55,
                false,
                ImGuiWindowFlags.NoScrollbar
            ) then
                ImGui.Spacing()
                ImGui.SetWindowFontScale(1.8)
                ImGui.Text(string.format(" %s PTS", SeparateInt(score)))
                ImGui.EndChild()
                ImGui.SameLine()
            end
            if score > 0 then
                ImGui.PopStyleColor()
            end

            ImGui.PushStyleVar(ImGuiStyleVar.ChildRounding, 60)
            ImGui.PushStyleColor(ImGuiCol.ChildBg, 0.17, 0.33, 1, 1.0)
            ImGui.SetNextWindowBgAlpha(0.7)
            if ImGui.BeginChild(
                "Time",
                win_w / 4, 55,
                false,
                ImGuiWindowFlags.NoScrollbar
            ) then
                ImGui.Spacing()
                ImGui.SetWindowFontScale(0.8)
                ImGui.Spacing()
                ImGui.Text(string.format("  %s", time))
                ImGui.EndChild()
            end
            ImGui.PopStyleColor()
            ImGui.PopStyleVar()

            ImGui.Dummy(1, 15)
            ImGui.SeparatorText("Player Best")
            ImGui.PushStyleColor(ImGuiCol.ChildBg, 0.8, 0.675, 0.0, 0.8)
            if ImGui.BeginChild(
                "PB Label",
                win_w / 7, 40,
                false,
                ImGuiWindowFlags.NoScrollbar
            ) then
                ImGui.Spacing()
                ImGui.SetWindowFontScale(1.1)
                ImGui.Text("   PB")
                ImGui.EndChild()
                ImGui.SameLine()
            end

            if ImGui.BeginChild(
                "PB",
                win_w - (win_w / 7), 40,
                false,
                ImGuiWindowFlags.NoScrollbar
            ) then
                ImGui.Spacing()
                ImGui.SetWindowFontScale(1.1)
                ImGui.Text(string.format("  %s PTS", SeparateInt(player_best)))
                ImGui.EndChild()
            end
            ImGui.PopStyleColor()
            ImGui.End()
        end
    end
end
