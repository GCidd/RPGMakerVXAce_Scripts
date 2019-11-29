# ==============================================================================
# Script by: vFoggy
# Loads latest save file on gameover instead of going to title screen.
# If it fails to load the save file it goes to the title screen.
# ==============================================================================
class Scene_Gameover < Scene_Base
    def update
      super
      if Input.trigger?(:C)
        index = DataManager.latest_savefile_index
        if DataManager.load_game(index)
          fadeout_all
          $game_system.on_after_load
          SceneManager.goto(Scene_Map)
        else
          go_to_title
        end
      end
    end
end
