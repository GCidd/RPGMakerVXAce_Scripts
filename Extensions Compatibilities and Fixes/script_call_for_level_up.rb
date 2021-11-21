# Requested by: Crescent
# link: http://www.rpgmakercentral.com/topic/41074-controlling-explevel-ups-vx-ace/

# This script removes the auto level up from the game and restricts the exp to 
# 100% (no exp is earned)
#
# -------------------
# Script by: vFoggy

class Game_Actor < Game_Battler
    def change_exp(exp, show)
      @exp[@class_id] = [[exp, 0].max, next_level_exp].min
      level_down while self.exp < current_level_exp
      refresh
    end
    
    def level_up_on_upgrade
      if self.exp == next_level_exp
        level_up
        last_level = @level
        last_skills = skills
        display_level_up(skills - last_skills) if show && @level > last_level
        refresh
      end
    end
end
