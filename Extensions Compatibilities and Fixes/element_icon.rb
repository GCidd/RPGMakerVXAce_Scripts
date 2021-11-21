# Plug-in script for Yanfly Engine Ace - Battle Engine Add-On: Elemental Popups 
# script by Yanfly.
# Shows an extra icon next to the damage popup.
# ---------------------
# By vFoggy

module YEA
    module ELEMENT_POPUPS
    # icon index to be displayed next to the elemental damage popup
    COLOURS ={
    # ElementID => [ Zoom1, Zoom2, Sz, Bold, Italic, Red, Grn, Blu, Font, Icon Index]
                3 => [   2.0,   1.0, 36, true,  false, 240,  60,  60, DEFAULT, 17],
                4 => [   2.0,   1.0, 36, true,  false, 100, 200, 246, DEFAULT, 18],
                5 => [   2.0,   1.0, 36, true,  false, 255, 255, 160, DEFAULT, 19],
                6 => [   2.0,   1.0, 36, true,  false,   0, 115, 180, DEFAULT, 20],
                7 => [   2.0,   1.0, 36, true,  false, 240, 135,  80, DEFAULT, 21],
                8 => [   2.0,   1.0, 36, true,  false,  60, 180,  75, DEFAULT, 22],
                9 => [   2.0,   1.0, 36, true,  false, 175, 210, 255, DEFAULT, 23],
                10 => [   2.0,   1.0, 36, true,  false, 110,  80, 130, DEFAULT, 24],
    } # Do not remove this.
    end
end


class Sprite_Popup < Sprite_Base
    alias fog_cpb create_popup_bitmap
    def create_popup_bitmap
    fog_cpb
    if @rules.include?("ELEMENT")
        element_id = @rules.split("_")[1].to_i
        icon_index = YEA::ELEMENT_POPUPS::COLOURS[element_id][9]
        iconset = $game_temp.iconset
        rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
        c_width = bitmap.text_size(@value).width
        dx = 0; dy = 0; dw = 0
        dx += 24 if @flags.include?("state")
        dw += 24 if @flags.include?("state")
        bw = Graphics.width
        bw += 48 if @flags.include?("state")
        bh = Font.default_size * 3
        bitmap.blt(dx+(bw-c_width)/2-24, (bh - 24)/2, iconset, rect, 255)
    end
    end
end
