# Fixes HP numbers being cut off for HP with many digits for 
# MOG - Boss HP Meter (V1.5).
#
# -------------------
# Script by: vFoggy
class Boss_HP_Meter 
    def create_hp_number
        @hp2 = $game_system.boss_hp_meter[4]
        @hp3 = @hp2
        @hp_old2 = @hp2
        @hp_ref = @hp_old2
        @hp_refresh = false    
        @hp_number_image = $game_temp.cache_boss_hp[2]
        @hp_cw = @hp_number_image.width / 10
        @hp_ch = @hp_number_image.height / 2
        @hp_ch2 = 0
        @hp_ch_range = HP_NUMBER_WAVE_EFFECT == true ? @hp_ch / 3 : 0
        @hp_number_sprite = Sprite.new
        # determine number of digits. each digit has 15 pixels of width
        # add 35 pixels for the HP chars
        width = (Math.log10(@hp2).to_i + 1)*15 + 35
        @hp_number_sprite.bitmap = Bitmap.new(width, @hp_ch * 2)
        @hp_number_sprite.z = @layout.z + 2
        @hp_number_sprite.x = @layout.x + HP_NUMBER_POSITION[0]
        @hp_number_sprite.y = @layout.y + HP_NUMBER_POSITION[1]
        @hp_number_sprite.viewport = @hp_vieport
        @hp_number_sprite.visible = $game_system.boss_hp_meter[9]
        refresh_hp_number
      end
end
