#===============================================================================
# Script Name: Popup message windows
# Author: vFoggy
# Description: 
#   This script allows the user to show popup windows with messages. By adding
# a \pop in the beginning of a message (in the events) the message will be shown 
# as a pop up window in the top right corner.
# 
#===============================================================================
module POPUP_OPTIONS
  # duration popup is shown (in frames)
  REC_POP_DUR = 120
  # speed of pop up
  REC_POP_SPEED = 20
  # max number of popups shown at the same time
  MAX_REC_POPUP = 5
  # for 1 the popups fade in and out, for 2 the popups open and close
  REC_POPUP_MODE = 2
  # sound name, volume, pitch
  POPUP_SOUND = ["Chime2", 100, 150]
end

class Game_Message
  def add(text)
    if text.start_with?("\\pop")
      txt = text.gsub("\\pop") { "" }
      SceneManager.scene.item_received_queue(txt)
    else
      @texts.push(text)
    end
  end
end

class Scene_Base
  include POPUP_OPTIONS
  
  alias foggy_popup_s start
  def start
    foggy_popup_s
    @items_received_popups_q = []
    @items_received_popups = []
    @item_received_show_delay = 0
  end
  
  def item_received_queue(string)
    @items_received_popups_q.push(string)
  end
  
  def item_received_add(string)
    @items_received_popups.each { |i| i.move_down } 
    @items_received_popups << Window_ItemsReceived.new(@items_received_popups.length + 1, string)
    @item_received_show_delay = 30
  end
  
  alias foggy_popup_update update
  def update
    foggy_popup_update
    update_items_received
  end
  
  def update_items_received
    if @item_received_show_delay == 0 && !@items_received_popups_q.empty?
      item_received_add(@items_received_popups_q.shift)
    elsif @item_received_show_delay > 0
      @item_received_show_delay -= 1
    end
    
    if @items_received_popups.length > MAX_REC_POPUP
      (@items_received_popups.length - MAX_REC_POPUP).times do
        @items_received_popups[0].visible_duration = 0
      end
    end
    
    @items_received_popups.each do |i| 
      i.update
      if i.dispose_await
        i.dispose 
        @items_received_popups.delete(i)
      end
    end
  end
end

class Window_ItemsReceived < Window_Base
  attr_reader :dispose_await
  attr_accessor :visible_duration
  include POPUP_OPTIONS
  
  def initialize(num, item_received)
    width = 200
    height = line_height + standard_padding * 2
    x = 0
    y = standard_padding + line_height
    super(x,y,width,height)
    @item_received = convert_escape_characters(item_received)
    @self_number = num
    @last_self_num = num
    @appear_speed = REC_POP_SPEED
    @visible_duration = REC_POP_DUR
    @offset_y = line_height + standard_padding
    @move_speed = @offset_y/5
    @font_size = 18
    @dispose_await = false
    case REC_POPUP_MODE
    when 1
      self.x = Graphics.width + width
      self.opacity = 0
    when 2
      self.x = Graphics.width - width
      self.openness = 0
    end
    create_item_content
    draw_item_received
    RPG::SE.new(*POPUP_SOUND).play
  end
  
  def line_height
    return 20
  end
  
  def standard_padding
    return 6
  end
  
  def move_down
    @self_number += 1
  end
  
  def create_item_content
    contents.dispose
    self.contents = Bitmap.new(contents_width, contents_height)
  end
  
  def update
    super
    update_visibility
    update_position 
  end 
  
  def update_visibility
    @visible_duration -= 1 if @visible_duration > 0
    case REC_POPUP_MODE
    when 1
      if @visible_duration == 0
        self.x += @appear_speed
        self.opacity -= @appear_speed 
        @dispose_await = true if self.opacity == 0 
      end
    when 2
      if @visible_duration == 0
        @closing = true 
        @dispose_await = true if close?
      end
    end
  end
  
  def update_position
    update_appear unless @visible_duration == 0
    update_move_down if @self_number != @last_self_num
  end
  
  def update_appear
    case REC_POPUP_MODE
    when 1
      if self.x > Graphics.width - self.width 
        self.x -= @appear_speed
      elsif self.opacity <= 255
        self.opacity += @appear_speed
      end
    when 2
      @opening = true 
    end
  end
  
  def update_move_down
    self.y += @move_speed
    @offset_y -= @move_speed
    if @offset_y <= 0
      @offset_y = line_height + standard_padding
      @last_self_num = @self_number
    end
  end
  
  def reset_font_settings
    change_color(normal_color)
    contents.font.size = @font_size
    contents.font.bold = Font.default_bold
    contents.font.italic = Font.default_italic
  end
  
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    src_rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    dest_rect = Rect.new(x, y, 18, 18)
    contents.stretch_blt(dest_rect, bitmap, src_rect, 255)
  end
  
  def draw_item_received
    draw_text_ex(0, 0, @item_received)
  end
end