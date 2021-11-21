# ==============================================================================
# Edit by: vFoggy
# Adds item usage functionality to the KsiMenu script. Also added some sounds on
# closing windows.
# ==============================================================================
class Scene_Menu < Scene_MenuBase
    def update
      super
      if Input.trigger?(:B)
        SceneManager.return
        # Edit: Added sound on going to the previous menu
        Sound.play_cancel
      end
    end
  end
  
  class Scene_Items < Scene_ItemBase
    # Edit: Added create_item method
    def create_item
      @item_window = Window_KsiItem.new
      @item_window.help_window = @help_window
      @item_window.update_help
      @item_window.set_handler(:ok, method(:on_item_ok))
    end
    
    # Edit: Added on_item_ok method
    def on_item_ok
      $game_party.last_item.object = item
      determine_item
    end
    
    # Edit: Added show_sub_window method. 
    def show_sub_window(window)
      width_remain = Graphics.width - window.width
      
      # Edit: Changed the position of the actor menu window
      offset = ((@item_window.width - @actor_window.width).abs/2).to_i
      window.x = @item_window.x - offset
      window.y = 0
      window.z = 1000
      
      @viewport.rect.x = @viewport.ox = cursor_left? ? 0 : window.width
      @viewport.rect.width = width_remain
      window.show.activate
    end
    
    def update
      super
      if Input.trigger?(:B)
        SceneManager.return
        # Edit: Added sound on going to the previous menu
        Sound.play_cancel
      end
    end
    
    # Edit: play_se_for_item
    def play_se_for_item
      Sound.play_use_item
    end
    
    # Edit: Added use_item method
    def use_item
      super
      @item_window.redraw_current_item
    end
end
