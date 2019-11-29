# https://www.rpgmakercentral.com/topic/41438-conflict-between-beastiery-logbook-and-mog-battle-result/
# Compatibility fix for Venka's Bestiary v1.8 and MOG - Battle Result (2.0)
# scripts.
# Fixes incompatibility issue that resulted in kills being counted 3 times each.
#
# -------------------
# Script by: vFoggy

class Game_Troop < Game_Unit
    def on_battle_start
      super
      @added_count = false
    end
    
    alias fog_aec add_encounter_count
    def add_encounter_count
      if not @added_count
        fog_aec 
        @added_count = true
      end
    end
end