# Forum link: https://forums.rpgmakerweb.com/index.php?threads/menu-problem.85398/

#===============================================================================
# This script fixes visual issues with larger than 544x416 resolution in 
# eugene222's Tales of Vesperia CMS.
#
# -------------------
# Script by: vFoggy
#===============================================================================

class Window_Base
    def zoom_x
      Graphics.width.to_f / 544
    end
    def zoom_y
      Graphics.height.to_f / 416
    end
  end
  
  class Window_Menu < Window_Help
    def create_bg
      @bg = Sprite.new
      @bg.bitmap = Cache.menu("") rescue nil
      @bg.zoom_x = zoom_x(@bg.width)
      @bg.zoom_y = zoom_y(@bg.height)
      @bg1 = Sprite.new
      @bg1.bitmap = Cache.menu("menu_layout") rescue nil
      @bg1.zoom_x = zoom_x(@bg1.width)
      @bg1.zoom_y = zoom_y(@bg1.height)
    end
  end
  
  class Window_MenuCommand < Window_Command
    include Eugene222::MConfig
    def initialize(x,y)
      init_commands
      x *= zoom_x
      y *= zoom_y
      super(x,y)
      w = (24 + item_max * (48+spacing))*zoom_x
      h = 72 * zoom_y 
      self.width = w
      self.height = h
      self.opacity = 0
      select_last
      update
    end
    def contents_width
      ((item_width + spacing) * item_max - spacing)*zoom_x
    end
    def item_width;48*zoom_x;end
    def item_height;48*zoom_y;end
    def spacing;4*zoom_x;end
    
    def draw_all_items
      @sprite_items = []
       @commands.each_with_index do |command,index|
        icon = Cache.menu(command.to_s) rescue Cache.menu("none")
        sprite = Sprite.new
        sprite.bitmap = icon
        sprite.x = index * (48*zoom_x + spacing) + self.x + self.padding
        sprite.y = self.y + self.padding
        sprite.zoom_x = zoom_x
        sprite.zoom_y = zoom_y
        sprite.z = self.z + 1
        sprite.opacity = 155
        @sprite_items << sprite
      end
    end
    
    def item_rect(index)
      rect = super
      rect.x = index * (48*zoom_x + spacing)
      rect.y = 0
      rect.width = 48 * zoom_x
      rect.height = 48 * zoom_y
      rect
    end
  end
  
  
  class Window_NewMenuStatus < Window_MenuStatus
    def initialize(x, y)
      @layout = []
      @face = []
      @y = y
      super(x, y)
      self.opacity = 0
      self.ox = 0
      self.oy = 0
      @pending_index = -1
    end
    def item_height
      (line_height + 20)*3 + 48 + 24
    end
    def window_height
      (Graphics.height - @y - 48*zoom_y)
    end
  end
  
  class Window_Information < Window_Base
    include Eugene222::MConfig
    def initialize
      w = Graphics.width
      h = 72 * zoom_y
      y = Graphics.height-h
      super(0, y, w, h)
      self.opacity = 0
      draw_all
      update
    end
  end
  
  class Scene_Menu < Scene_MenuBase
    def create_status_window
      y =  (@command_window.height*2 - 24)*(Graphics.height/416)
      @status_window = Window_NewMenuStatus.new(0, y)
    end
  end
