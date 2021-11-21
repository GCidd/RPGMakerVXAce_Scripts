# https://www.rpgmakercentral.com/topic/41419-on-tsukihimes-corpse-retrieval-script/
# Drops only gold and if player dies before retrieving the corpse a new one is 
# created, replacing the old one and losing the gold dropped
#
# -------------------
# Script by: vFoggy

module TH
  module Corpse_Retrieval
    # if you want, for example, only a percentage of the gold to be lost then 
    # set the GOLD_LOST_CONSTANT to 0
    GOLD_LOST_PERCENTAGE = 0.5
    GOLD_LOST_CONSTANT = 1000
    #-----------------------------------------------------------------------------
    # Changed setup_event_commands to only add the command to increase Gold
    #-----------------------------------------------------------------------------
    def self.setup_event_commands(corpse_items, list)
      list << RPG::EventCommand.new(101, 0, ["", 0, 0, 2])
      list << RPG::EventCommand.new(401, 0, ["Corpse retrieved"])
      list << RPG::EventCommand.new(125, 0, [0, 0, corpse_items[:gold], false])
      list << RPG::EventCommand.new("delete_corpse_event")
      list << RPG::EventCommand.new
    end
  end
end

class Game_Interpreter
  #-----------------------------------------------------------------------------
  # Checks if there is a corpse in the map and removes it (keeps the number of 
  # corpses to 1
  #-----------------------------------------------------------------------------
  alias fog_cpc create_party_corpse
  def create_party_corpse(map_id=$game_map.map_id, x=$game_player.x, y=$game_player.y)
    if $game_system.get_corpse_events($game_map.map_id).length > 0
      corpse = $game_system.get_corpse_events($game_map.map_id)[-1]
      $game_system.remove_corpse_event($game_map.map_id, corpse)
      $game_map.remove_corpse_event(corpse.id)
    end
    fog_cpc($game_map.map_id, $game_player.x, $game_player.y)
  end
end

class Game_Party < Game_Unit
  #-----------------------------------------------------------------------------
  # Firsly removes a percetange of the gold and then a constant value.
  # If using only one way to remove gold is needed, set the other to 0.
  #-----------------------------------------------------------------------------
  def create_party_corpse
    corpse_items = {:gold => 0}
    corpse_items[:gold] += (@gold*TH::Corpse_Retrieval::GOLD_LOST_PERCENTAGE).to_i
    @gold -= [corpse_items[:gold], @gold].min
    corpse_items[:gold] += [@gold, TH::Corpse_Retrieval::GOLD_LOST_CONSTANT].min
    @gold -= [corpse_items[:gold], @gold].min
    return corpse_items
  end
end