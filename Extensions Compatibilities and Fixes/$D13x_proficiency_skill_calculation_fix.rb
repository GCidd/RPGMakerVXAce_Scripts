# calculation fix
class Game_Battler < Game_BattlerBase
    def apply_weapon_profic(item,user)
      return 1.0 unless user.is_a?(Game_Actor)
      return 1.0 unless item.is_a?(RPG::Skill)
      return 1.0 if item.damage.element_id >= 0
      return 1.0 unless item.damage.type == 1
      prof = 1.0
      user.skills.each do |skill|
        next unless skill != nil
        next unless skill.weap_prof[0] != 0
        user.weapons.each do |wep|
          next unless wep != nil
          next unless skill.weap_prof[0] == wep.wtype_id
          if $D13x[:Skill_Lv]
            mult = Skill_Levels::Exp_Set[skill.exp_set][user.skills_lv(skill.id)][2]
            prof += (skill.weap_prof[1] * mult) 
          else
            prof += skill.weap_prof[1] 
          end
        end
      end
      return prof
    end
end