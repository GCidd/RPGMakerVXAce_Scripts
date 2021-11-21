# Forum link: https://forums.rpgmakerweb.com/index.php?threads/requesting-a-little-feature-for-this-script.84293/

# ==============================================================================
# This is an addon script for Storage Boxes v1.8 by IMP1
# Gives the ability to add gold to the boxes and (only) withdraw them.
# Gold is counted as one item in the box (meaning that 900 G will take 1/20 space)
# To add gold to a box use :gold as the item to be added, for example:
#   $game_boxes.box(2)[:gold] = 900   or
#   $game_boxes.add_item(:gold, 5, 3, :all)
# -------------------
# Script by: vFoggy
# ==============================================================================

module IMP1_Storage_Boxes
    # Sound played when gold is withdrawn
    GOLD_WITHDRAW_SOUND = {
      name: "Coin",
      volume: 100,
      pitch: 100
    }
    
    # Icon displayed for gold
    GOLD_ICON = 262
    
    # Help text displayed when on cursor is on gold (in boxes only)
    GOLD_ITEM_DESCRIPTION = "Used to buy items."
  end
  
  class Window_Base < Window
    alias fog_din_game_boxes draw_item_name
    def draw_item_name(item, x, y, enabled = true, width = 172)
      return unless item
      if item != :gold
        fog_din_game_boxes(item, x, y, enabled, width)
      else
        draw_icon(IMP1_Storage_Boxes::GOLD_ICON, x, y, enabled)
        change_color(normal_color, enabled)
        draw_text(x + 24, y, width, line_height, "Gold")
      end
    end
  end
  
  class Window_Help < Window_Base
    alias fog_si set_item
    def set_item(item)
      if item != :gold
        fog_si(item)
        return
      end
      set_text(item ? IMP1_Storage_Boxes::GOLD_ITEM_DESCRIPTION : "")
    end
  end
  
  class IMP1_Game_Boxes
    include IMP1_Storage_Boxes
    
    def fullness(box_id)
      i = 0
      box(box_id).each do |item, amount|
        if item == :gold
          i += 1
        else
          i += amount
        end
      end
      return i
    end
  end
  
  class Scene_ItemStorage < Scene_MenuBase
    alias fog_mi move_item
    def move_item
      item = @box_window.item
      if item != :gold
        fog_mi
        return
      end
      withdrawn = deposited = false
      if @box_window.active && can_move_item_to_inventory?(@box_window.item)
        all_gold = $game_boxes.item_number(:gold, @box_id)
        $game_boxes.remove_item(item, all_gold, @box_id)
        $game_party.gain_gold(all_gold)
        play_withdraw_sound(item)
        withdrawn = true
      end
      if !withdrawn
        Sound.play_buzzer
      end
      refresh
    end
    
    def play_withdraw_sound(item)
      se = IMP1_Storage_Boxes::WITHDRAW_SOUND
      if item == :gold
        se = IMP1_Storage_Boxes::GOLD_WITHDRAW_SOUND.dup
      elsif item.note.include?("<withdraw sound:")
        se = se.dup
        se[:name] = item.note.scan(/<withdraw sound: (.+)>/).flatten[0]
      end
      play_sound(se)
    end
  end
  