# link: http://www.rpgmakercentral.com/topic/41160-dark-cloud-weapon-system-small-edits/

# Added notetag <synth> that makes the item breakable
# Items by default are not breakable
# Added $game_actor[indx].gain_weapon_exp(exp) function to increase weapon's exp
# outside of battle
#
# -------------------
# Script by: vFoggy

module GBP
    module REGEXP
      module ITEM
        SYNTH = /<synth>/i
      end
    end
  end
  
  class RPG::BaseItem
    alias fog_ccdgd create_cache_default_gbp_dcw
    def create_cache_default_gbp_dcw
      fog_ccdgd
      @dcw_basic_params[:is_breakable] = false
    end
    
    alias fog_ccgd create_cache_gbp_dcw
    def create_cache_gbp_dcw
      fog_ccgd
      self.note.split(/[\r\n]+/).each { |line|
        case line
        when GBP::REGEXP::ITEM::SYNTH
          @dcw_basic_params[:is_breakable] = true
        end #case
      } #
    end
  end
  
  class Game_Actor < Game_Battler
    def gain_weapon_exp(exp)
      for weapon in weapons
        next if weapon.nil?
        level = weapon.level
        weapon.gain_exp(exp)
        if weapon.level != level
          text = sprintf(Vocab::DARKCLOUD_WEAPON::BATTLE_WEAPON_LEVELUP, actor.name, weapon.name, weapon.level)
          $game_message.add('\.' + text)
        end
      end
    end
end
