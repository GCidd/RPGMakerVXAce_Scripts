# ==============================================================================
# Script by: vFoggy
# Compatibility script for:
#   * Yanfly Engine Ace - Party System v1.08 and
#   * MOG - Scene File A (V1.3)
# The script fixes the extra graphics that are drawn by MOG's Scene File A
# when a party member is removed from the battle party using Yanfly's Party
# System script.
# ==============================================================================

module DataManager
    #--------------------------------------------------------------------------
    # ● Make Save Header
    #--------------------------------------------------------------------------
    def self.make_save_header
      header = {}
      header[:characters] = $game_party.characters_for_savefile
      header[:playtime_s] = $game_system.playtime_s
      header[:playtime] = $game_system.playtime
      header[:map_name] = $game_map.display_name
      header[:members] = $game_party.members
      # Create header for battle_members_array from Yanfly's Party script
      header[:battle_members] = $game_party.battle_members_array
      header
    end
  end
  
  class Window_SaveFile_A < Window_Base
  #--------------------------------------------------------------------------
  # ● load_gamedata
  #--------------------------------------------------------------------------
    def load_gamedata
      @time_stamp = Time.at(0)
      @file_exist = FileTest.exist?(@filename)
      if @file_exist
        header = DataManager.load_header(@file_index)
        if header == nil
          @file_exist = false
          return
        end
        @characters = header[:characters]
        @total_sec = header[:playtime]
        @mapname = header[:map_name]
        @members = header[:members]
        # Load battle_members_array from Yanfly's script
        @battle_members_array = header[:battle_members]
        unless @battle_members_array.nil?
          # Select only members that are not removed from the battle to draw
          @members.select! { |actor| !@battle_members_array.index(actor.id).nil? }
        end
      end
    end
end
