#===============================================================================
# *Notetag options:
#   -<Stacked_Weight>: Treats stacks of item as one item weight
#   -<Weight: x>: Weight of item/equipment
# *Refrences:
#   -$game_party.max_weight: Maximum weight of party
#   -$game_party.current_weight: Current weight of party
#
#===============================================================================
# Created by vFoggy
#===============================================================================
module ITEM_WEIGHT_SETTINGS
    #=============================================================================
    # #DEFAULT ITEM WEIGHT (Used ONLY when no notetag is found)
    #   *DEF_ITEM_WEIGHT    = [Regular item, Key item];
    #   *DEF_EQUIP_WEIGHTS  = [Weapon, Shield, Head, Body, Accessory];
    #
    #   *DEFAULT_STACK      = If true calculates weight for each item individually 
    # when stacked, 
    # e.g. one stack of 56 potions(each weighs 1):
    # -when true 1 weight will be added to current inventory weight.
    # -when false 56 weight will be added to current inventory weight.
    #=============================================================================
    DEF_ITEM_WEIGHT   = [1,1]
    DEF_EQUIP_WEIGHTS = [1,1,1,1,1]
    DEF_STACK = false
    
    #=============================================================================
    # STARTING_WEIGHT = Starting maximum weight of party.
    # MAX_WEIGHT_VAR  = Game variable number of maximum weight.
    # EQUIP_WEIGHT    = If true adds weight from equipments of actors to current weight
    #=============================================================================
    STARTING_WEIGHT = 50
    MAX_WEIGHT_VAR  = 20
    EQUIP_WEIGHT    = false
  end
  
  class Game_Variables
    alias initialize_weight_var initialize
    def initialize
      initialize_weight_var
      @data[ITEM_WEIGHT_SETTINGS::MAX_WEIGHT_VAR] = ITEM_WEIGHT_SETTINGS::STARTING_WEIGHT
    end
    
    alias on_change_weights on_change
    def on_change
      on_change_weights
      $game_party.refresh_item_weights
    end
  end
  
  module RPG
    class BaseItem
      def stacked_weight
        note =~ /<Stacked_Weight>/ ? true : ITEM_WEIGHT_SETTINGS::DEF_STACK
      end
    end
    
    class Item < UsableItem 
      def weight
        note =~ /<Weight: (\d+)>/ ? $1.to_i : ITEM_WEIGHT_SETTINGS::DEF_ITEM_WEIGHT[@itype_id-1]
      end
    end
    
    class EquipItem < BaseItem
      def weight
        weight = note =~ /<Weight: (\d+)>/ ? $1.to_i : ITEM_WEIGHT_SETTINGS::DEF_EQUIP_WEIGHTS[@etype_id]
      end
    end
  end
  
  class Game_Party < Game_Unit
    attr_reader :max_weight, :current_weight
    
    include ITEM_WEIGHT_SETTINGS
    
    alias initialize_item_weight initialize
    def initialize
      @max_weight = $game_variables[MAX_WEIGHT_VAR]
      @current_weight = 0
      initialize_item_weight
    end
    
    alias setup_starting_weights setup_starting_members
    def setup_starting_members
      setup_starting_weights
      @actors.each { |member| add_actor_weight(member)} if EQUIP_WEIGHT
    end
    
    alias add_actor_item_weight add_actor
    def add_actor(actor_id)
      add_actor_weight(actor_id) if !@actors.include?(actor_id) && EQUIP_WEIGHT
      add_actor_item_weight(actor_id)
    end
    
    alias remove_actor_item_weight remove_actor
    def remove_actor(actor_id)
      remove_actor_weight(actor_id) if @actors.include?(actor_id) && EQUIP_WEIGHT
      remove_actor_item_weight(actor_id)
    end
    
    def add_actor_weight(actor_id)
      $game_actors[actor_id].equips.each do |equip|
        next unless equip
        @current_weight += equip.weight
      end
    end
    def remove_actor_weight(actor_id)
      $game_actors[actor_id].equips.each do |equip|
        next unless equip
        @current_weight -= equip.weight
      end
    end
    
    alias gain_item_weight gain_item
    def gain_item(item, amount, include_equip = false)
      gain_item_weight(item, amount, include_equip)
      return unless item_container(item.class)
      refresh_item_weights
    end
    
    def refresh_item_weights
      @max_weight = $game_variables[MAX_WEIGHT_VAR]
      @current_weight = 0
      items.each { |item| @current_weight += item.weight * (item.stacked_weight ?  1 : @items[item.id]) } 
      weapons.each { |weapon| @current_weight += weapon.weight * (weapon.stacked_weight ? 1 : @weapons[weapon.id]) } 
      armors.each { |armor| @current_weight += armor.weight * (armor.stacked_weight ?  1 : @armors[armor.id]) } 
      if EQUIP_WEIGHT
        all_members.each { |member| add_actor_weight(member.id) }
      end
    end
  end
  
  class Scene_Map < Scene_Base
    alias start_weight_refresh start
    def start
      start_weight_refresh
      $game_party.refresh_item_weights
    end
  end