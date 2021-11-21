class Window_BankGive < Window_ItemList
    # Change: Only checks for items of category item
    def include?(item)
      case @category
      when :item
        item.is_a?(RPG::Item) && !item.key_item?
      else
        false
      end
    end
  end
  
  class Scene_ItemBank < Scene_MenuBase
    # Change: Makes the height of the window used to choose item category to 0
    alias fog_ccw create_category_window
    def create_category_window
      fog_ccw
      @category_window.height = 0
    end
    
    # Change: Does not activate the category_window window and immidiately 
    # activates give_window window
    def command_give
      @dummy_window.hide
      @give_window.show
      @give_window.unselect
      @give_window.refresh
      activate_give_window
      @give_window.select(0) 
    end
    
    # Change: Does not activate the category_window and immidiately activates 
    # command_window window
    def on_give_cancel
      @give_window.unselect
      @category_window.hide
      @command_window.activate
      @dummy_window.show
      @give_window.hide
      @status_window.item = nil
      @help_window.clear
    end
end
