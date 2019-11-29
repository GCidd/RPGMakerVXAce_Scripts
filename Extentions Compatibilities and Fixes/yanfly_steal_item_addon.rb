# Forum link: https://forums.rpgmakerweb.com/index.php?threads/yanflys-steal-item-success-check.83710/

# ==============================================================================
# This is an addon script for Yanfly Engine Ace - Steal Items v1.03
# * Extra notetags for skills used by enemies:
#   <required_item: item_id, x>: If item with ID item_id is stolen, the skill's
#     damage will be lowered by x%. If x is 100% then the skill is disabled.
#   <required_armour: armour_id, x>: Same with required_item but for armours.
#   <required_weapon: weapon_id, x>: Same with required_item but for weapons.
#
# * Extra notetags for enemies:
#   <life_item: item_id>: If the item with ID item_id is stolen from the enemy, 
#     the enemy dies.
#
# Multiple required items/armours/weapons and life items can be set for a skill
# and an enemy.
# -------------------
# Script by: vFoggy
# ==============================================================================
class RPG::Skill < RPG::UsableItem
    def required_items
      required_items = []
      self.note.scan(/<required_item: (\d+), (\d+)>/).each do |id, p| 
        required_items << [id.to_i, p.to_i] 
      end
      return required_items
    end
    
    def required_armours
      required_armours = []
      self.note.scan(/<required_armour: (\d+), (\d+)>/).each do |id, p| 
        required_armours << [id.to_i, p.to_i] 
      end
      return required_armours
    end
    
    def required_weapons
      required_weapons = []
      self.note.scan(/<required_weapon: (\d+), (\d+)>/).each do |id, p| 
        required_weapons << [id.to_i, p.to_i] 
      end
      return required_weapons
    end
  end
  
  class RPG::Enemy < RPG::BaseItem
    def life_items
      life_items = []
      self.note.scan(/<life_item: (\d+)>/).each do |id| 
        life_items << id[0].to_i
      end
      return life_items
    end
    
  end
  
  class Game_BattlerBase
    def item_required_stolen?(skill)
      return false if @stealable_items.nil?
      return false unless self.is_a?(Game_Enemy)
      
      required_items = skill.required_items.reject{|id, p| p != 100}
      stelable_items = @stealable_items.reject{|i| i.kind != 1}
      if required_items.empty?
        item_stolen = false
      elsif stelable_items.empty?
        item_stolen = true
      else
        item_stolen = !required_items.any?{|id, p| stelable_items.any?{|i| i.data_id == id}}
      end
      
      required_weapons = skill.required_weapons.reject{|id, p| p != 100}
      stelable_weapons = @stealable_items.reject{|i| i.kind != 2}
      if required_weapons.empty?
        weapon_stolen = false
      elsif stelable_weapons.empty?
        weapon_stolen = true
      else
        weapon_stolen = !required_weapons.any?{|id, p| stelable_weapons.any?{|i| i.data_id == id}}
      end
      
      required_armours = skill.required_armours.reject{|id, p| p != 100}
      stealable_armours = @stealable_items.reject{|i| i.kind != 3}
      if required_armours.empty?
        armour_stolen = false
      elsif stealable_armours.empty?
        armour_stolen = true
      else
        armour_stolen = !required_armours.any?{|id, p| stealable_armours.any?{|i| i.data_id == id}}
      end
      
      return [item_stolen, weapon_stolen, armour_stolen].any?
    end
    
    def skill_conditions_met?(skill)
      usable_item_conditions_met?(skill) &&
      skill_wtype_ok?(skill) && skill_cost_payable?(skill) &&
      !skill_sealed?(skill.id) && !skill_type_sealed?(skill.stype_id) &&
      !item_required_stolen?(skill)
    end
  end
  
  class Game_Battler < Game_BattlerBase
    def life_stolen?
      return false if enemy.life_items.empty?
      return false if @result.stolen_item.nil?
      enemy.life_items.any?{|id| @result.stolen_item.kind == 1 && @result.stolen_item.data_id == id}
    end
    
    #--------------------------------------------------------------------------
    # new method: execute_steal_effect
    #--------------------------------------------------------------------------
    def execute_steal_effect(user, item)
      return if self.actor?
      return if self.actor? == user.actor?
      return if item.steal_type.nil?
      return if stealable_items == []
      apply_steal_effect(user, item) if item.steal_type == :steal
      apply_snatch_effect(user, item) if item.steal_type == :snatch
      apply_life_stolen
      lower_stats_steal_effect
    end
    
    def apply_life_stolen
      if life_stolen?
        die
        refresh
      end
    end
  end
  
  class Game_Battler < Game_BattlerBase
    def apply_stolen(user, item, value)
      req_items = item.required_items.reject{|i| i[1] == 100}
      req_items.each do |id, p|
        if !user.stealable_items.any?{|i| i.kind == 1 && i.data_id == id}
          value *= ((100-p)/100.0)
        end
      end
      
      req_weapons = item.required_weapons.reject{|i| i[1] == 100}
      req_weapons.each do |id, p|
        if !user.stealable_items.any?{|i| i.kind == 2 && i.data_id == id}
          value *= ((100-p)/100.0)
        end
      end
      
      req_armours = item.required_armours.reject{|i| i[1] == 100}
      req_armours.each do |id, p|
        if !user.any?{|i| i.kind == 3 && i.data_id == id}
          value *= ((100-p)/100.0)
        end
      end
      
      return value
    end
    
    def make_damage_value(user, item)
      value = item.damage.eval(user, self, $game_variables)
      value *= item_element_rate(user, item)
      value *= pdr if item.physical?
      value *= mdr if item.magical?
      value *= rec if item.damage.recover?
      value = apply_stolen(user, item, value)
      value = apply_critical(value) if @result.critical
      value = apply_variance(value, item.damage.variance)
      value = apply_guard(value)
      @result.make_damage(value.to_i, item)
    end
  end