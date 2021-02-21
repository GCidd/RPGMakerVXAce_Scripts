module FOG_ABS_OPTIONS
  
  TURN_DURATION = 60 #in frames
  IMMOVABLE_STATES = [6,7,8,13]
  
  JUMP_DISTANCE = 2
  JUMP_DELAY    = 30
  
  REC_POP_DUR = 120
  REC_POP_SPEED = 20
  MAX_REC_POPUP = 5
  REC_POPUP_MODE = 2
  
  RESET_ENEM_ON_MAP = false
  RESET_TIMER       = 360
  
  PLAYER_MELEE_RANGE  = 1
  PLAYER_SKILL_RANGE  = 3
  PLAYER_HP_POSX      = 0
  PLAYER_HP_POSY      = 0
  PLAYER_MP_POSX      = 0
  PLAYER_MP_POSY      = 0
  PLAYER_STATES_POSX  = 0
  PLAYER_STATES_POSY  = 0
  PLAYER_NOS          = 0        # max number of states to show
  PLAYER_SIGHT        = 5
  PLAYER_HITS_THRESH  = 5
  PLAYER_INTER_DURATION = 30
  PLAYER_FALL_DURATION = 120
  PLAYER_LVLUP_ANIM_ID  = 40
  PLAYER_MISS_EVADE_RECOVER = 30
  
  ENEMY_HP_POSX           = 0
  ENEMY_HP_POSY           = 0
  ENEMY_NAME_POSX         = 0
  ENEMY_NAME_POSY         = 0
  ENEMY_STATES_POSX       = 0
  ENEMY_STATES_POSY       = 0
  ENEMY_NOS               = 0         #max number of states to show
  ENEMY_INTER_DURATION    = 30
  
end

module RPG
  #----------------------------------------------------------------------------
  #* Skill Class:
  #             * aoe: returns Area of Effect of a skill
  #             * range: returns range of a skill
  #             * targeted: returns if spell initializes targeting sequence
  #             * cooldown: returns if the skill is targeted
  #----------------------------------------------------------------------------
  class Skill < UsableItem
    def aoe
      note =~ /<AOE: (\d+)/ ? $1.to_i : 0
    end
    
    def range
      note =~ /<Range: (\d+)>/ ? $1.to_i : 2
    end
    
    def targeted
      note =~ /<Targeted>/ ? true : false
    end
    
    def cooldown
      note =~ /<Cooldown: (\d+)>/ ? $1.to_i : 5
    end
  end
  #----------------------------------------------------------------------------
  #* Class Class:
  #             * returns maximum number of combo attacks a class can perform
  #             * return the attack speed of a class
  #----------------------------------------------------------------------------
  class Class < BaseItem
    def max_combo
      note =~ /<Combo_Chain: (\d+)>/ ? $1.to_i : 0
    end
    
    def attack_speed
      note =~ /<Attack_Speed: (\d+)>/ ? $1.to_i : 60
    end
  end
  #----------------------------------------------------------------------------
  #* Skill Class:
  #             * returns the range of the weapon
  #----------------------------------------------------------------------------
  class Weapon < EquipItem
    def range
      note =~ /<Range: (\d+)>/ ? $1.to_i : 1
    end
  end
  #----------------------------------------------------------------------------
  #* Skill Class:
  #             * returns the attack speed of the enemy
  #             * return range of the enemy
  #----------------------------------------------------------------------------
  class Enemy < BaseItem
    def attack_speed
      note =~ /<Attack_Speed: (\d+)>/ ? $1.to_i : 80
    end
    
    def level
      note =~ /<Level: (\d+)>/ ?  $1.to_i : 1
    end
    
    def attack_range
      note =~ /<Range: (\d+)>/ ? $1.to_i : 1
    end
    
    def sight_range
      note =~ /<Sight: (\d|)>/ ? $1.to_i : 5
    end
  end
  
end

module Cache
  #--------------------------------------------------------------------------
  # * Get Projectile Graphic
  #--------------------------------------------------------------------------
  def self.projectiles(filename)
    load_bitmap("Graphics/Projectiles/", filename)
  end
  #--------------------------------------------------------------------------
  # * Get Ultimates Graphic
  #--------------------------------------------------------------------------
  def self.ultimate(filename, hue)
    load_bitmap("Graphics/Ultimates/", filename, hue)
  end
end

class Sprite_Character < Sprite_Base
  alias set_character_bitmap_projectile set_character_bitmap
  def set_character_bitmap
    projectile = @character_name =~ /-/ ? true : false
    if projectile 
      self.bitmap = Cache.projectiles(@character_name)
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
      self.ox = @cw / 2
      self.oy = @ch
    else
      set_character_bitmap_projectile
    end
  end
end

#----------------------------------------------------------------------------
#* Messages Class:
# *This class is used to print messages on screen like: damage popups, EXP and
#GOLD popups and attack results.
#     *Initializes the message class
#     *creates the message with message string, at the target position for the
#     spesified duration
#     *after the duration has passed messages made invisible and then 
#     automatically deleted
#----------------------------------------------------------------------------
class Messages < Sprite
  attr_reader :target
  
  def initialize(message,target,duration,offset_x=0,offset_y=0,viewport = nil)
    super(viewport)
    @duration = 0
    @max_duration = 0
    @offset_x = offset_x
    @offset_y = offset_y
    @factor = 0
    @target = target
    self.visible = false
    message(message,target,duration)
  end
  
  def message(message,target,duration)
    @max_duration = duration
    self.bitmap = Bitmap.new((message.length * 24),24)
    self.bitmap.font.size = 20
    self.bitmap.font.italic = true
    self.bitmap.draw_text(0,0,(message.length * 24),24,message)
    self.z = 2
    set_position
    self.opacity = 255
    self.visible = true
  end
  
  def set_position
    self.x = @target.screen_x - 32 - @offset_x
    self.y = @target.screen_y - 32 - @offset_y
  end
  
  def dispose
    return if self.bitmap.nil?
    self.bitmap.dispose
    self.bitmap = nil
  end
  
  def update
    super
    return unless self.visible
    set_position
    
    @duration += 1 
    
    @factor += 1 if @duration % 4 == 0
    self.y -= @factor
    
    if @duration == @max_duration
      self.visible = false
      @duration = 0
      @factor = 0
      dispose
    end
  end
  
end
#----------------------------------------------------------------------------
#*Target_Lock Class:
# *This class creates the locked target sprite that indicates the target of 
#the palyer
#----------------------------------------------------------------------------
class Target_Lock < Sprite
  include FOG_ABS_OPTIONS
  
  def initialize(viewport = nil)
    super(viewport)
    @bitmap_img = Cache.system("Target_lock")
    @target = nil
    rect = Rect.new(0,0,24,24)
    self.bitmap = Bitmap.new(24,24)
    self.bitmap.blt(0,0,@bitmap_img,rect)
    self.z = 201
    self.opacity = 255
    self.visible = false
  end
  
  def dispose
    return if self.bitmap.nil?
    self.bitmap.dispose
    self.bitmap = nil
    self.dispose
  end
  
  def update
    super
    @target = FogBattleManager.target if FogBattleManager.target
    lock_on($game_player.locking_on) if FogBattleManager.target
    self.visible = !FogBattleManager.target.nil?
  end
  
  def lock_on(on)
    self.visible = true
    if on
      rect = Rect.new(24,0,24,24)
      self.bitmap = Bitmap.new(24,24)
      self.bitmap.blt(0,0,@bitmap_img,rect)
    else
      rect = Rect.new(0,0,24,24)
      self.bitmap = Bitmap.new(24,24)
      self.bitmap.blt(0,0,@bitmap_img,rect)
    end
    self.x = @target.screen_x - 12
    self.y = @target.screen_y - 24
  end
end

class Window_NameInput < Window_Selectable
  def process_handling
    return unless open? && active
    process_jump if WolfPad.trigger?(:START)
    process_back if WolfPad.trigger?(:B)
    process_ok   if WolfPad.trigger?(:A)
  end
end  

class Game_Player < Game_Character 
  
  include FOG_ABS_OPTIONS
  alias fog_init initialize
  def initialize
    fog_init
    @current_frame = 0
    @leader_change_speed = 60   #number of frames needed to change leader
    @leader_change_cd = 0       #cooldown to change leader
  end
  
  #--------------------------------------------------------------------------
  # ● Move By Input
  #--------------------------------------------------------------------------    
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    
    case WolfPad.dir8
      when 2,4,6,8
        jump_press? ? pad_jump(WolfPad.dir4) : move_straight(WolfPad.dir4)
      when 1 
        jump_press? ? pad_jump(1) : move_diagonal_straight(4, 2)
      when 3 
        jump_press? ? pad_jump(3) : move_diagonal_straight(6, 2)
      when 5
        pad_jump(5) if jump_press?
      when 7 
        jump_press? ? pad_jump(7) : move_diagonal_straight(4, 8)
      when 9 
        jump_press? ? pad_jump(9) : move_diagonal_straight(6, 8)
    end
  end

  alias fog_jump_up update
  def update
    fog_jump_up
    @leader_change_cd += 1 unless @leader_change_cd >= @leader_change_speed
    change_character if @leader_change_cd == @leader_change_speed 
    @current_frame += 1 if @current_frame != JUMP_DELAY
  end
    
  #--------------------------------------------------------------------------
  # ● Move Diagonal Straight
  #--------------------------------------------------------------------------      
  def move_diagonal_straight(x,y)
    move_diagonal(x, y)
    return if moving?
    move_straight(x) ; move_straight(y)
  end
    
  def pad_jump(direction)
    
    return if choosing_skill?
    return if @current_frame != JUMP_DELAY
    
    case direction
    when 1
      jump(-1,1) 
    when 2
      jump(0,2)
    when 3
      jump(1,1)
    when 4
      jump(-2,0)
    when 6
      jump(2,0)
    when 7
      jump(-1,-1)
    when 8
      jump(0,-2)
    when 9
      jump(1,-1)
    else
      jump(0,0)
    end
    @current_frame = 0
  end
  
  def jump_press?
    WolfPad.press?(:B) && !jumping?
  end
  
  def jump(x_plus, y_plus)
    if x_plus.abs > y_plus.abs
      set_direction(x_plus < 0 ? 4 : 6) if x_plus != 0
    else
      set_direction(y_plus < 0 ? 8 : 2) if y_plus != 0
    end
    return unless can_jump?(@x + x_plus, @y + y_plus, direction)
    @x += x_plus
    @y += y_plus
    distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
    @jump_peak = 10 + distance - @move_speed
    @jump_count = @jump_peak * 2
    @stop_count = 0
    straighten
  end
  
  def can_jump?(x,y,d)
    case d
    when 2,4,6,8
      passable = passable?(x,y,d)
    when 1
      passable = diagonal_passable?(x, y, 4, 2)
    when 3
      passable = diagonal_passable?(x, y, 6, 2)
    when 7
      passable = diagonal_passable?(x, y, 4, 8)
    when 9
      passable = diagonal_passable?(x, y, 6, 8)
    end
    !collide_with_events?(x, y) && passable
  end
  
  alias fog_dash dash?
  def dash?
    super
    xy = WolfPad.left_stick
    return  [xy[0].abs , xy[1].abs].max >= 0.75
  end
  
  def choosing_skill?
    return false if @down
    return WolfPad.press?(:R2) || WolfPad.press?(:L2) 
  end
  
  def change_character
    return if choosing_skill?
    return unless WolfPad.trigger?(:R_LEFT) || WolfPad.trigger?(:R_RIGHT)
    if WolfPad.trigger?(:R_RIGHT)
      FogBattleManager.change_leader
    elsif WolfPad.trigger?(:R_LEFT)
      FogBattleManager.change_leader(true)
    end
    $game_system.refresh_hud = true
  end
  
  def change_target
    #rotates target_list 
    if WolfPad.trigger?(:R1)
      get_next_target(1)
    elsif WolfPad.trigger?(:L1)
      get_next_target(-1)
    end  
  end
  
  def lock_on
    if !$game_system.manual_lockon
      lock_on_target #if manual lockon is false then player locks on nearest target
    else
      change_target if @locking_on
      lock_on_target if @locking_on 
      $game_player.locking_on = false if (WolfPad.repeat?(:R1) && !WolfPad.trigger?(:R1)) || (WolfPad.repeat?(:L1) && !WolfPad.trigger?(:L1)) 
      $game_player.locking_on =  WolfPad.trigger?(:R1) || WolfPad.trigger?(:L1) if WolfPad.repeat?(:R1) || WolfPad.repeat?(:L1)
    end
  end
  
  def get_next_target(val)
    target = FogBattleManager.target
    temp_troop = FogBattleManager.map_troop.alive_members.sort { |x,y| x.distance <=> y.distance }
    temp_troop.select! { |x| x.distance <= 3 }
    ind = temp_troop.index(target).nil? ? 0 : temp_troop.index(target)
    FogBattleManager.target = temp_troop[ind + val] 
    FogBattleManager.target = temp_troop[0] if FogBattleManager.target.nil? 
  end
  
  def lock_on_target
    return unless FogBattleManager.target
    $game_player.turn_toward_character(FogBattleManager.target)
  end
end

class Scene_Map < Scene_Base
  def update_call_menu
    if $game_system.menu_disabled || $game_map.interpreter.running?
      @menu_calling = false
    else
      return if $game_player.choosing_skill?
      @menu_calling ||= WolfPad.trigger?(:Y) && !FogBattleManager.in_battle
      call_menu if @menu_calling && !$game_player.moving?
      RPG::SE.new("Cancel1", 100, 100).play if FogBattleManager.in_battle && WolfPad.trigger?(:Y)
    end
  end
end

class Window_Selectable < Window_Base
  def process_handling
    return unless open? && active
    return if $game_player.choosing_skill?
    return process_ok       if ok_enabled?        && WolfPad.trigger?(:A)
    return process_cancel   if cancel_enabled?    && WolfPad.trigger?(:B)
    return process_pagedown if handle?(:pagedown) && WolfPad.trigger?(:R_LEFT)
    return process_pageup   if handle?(:pageup)   && WolfPad.trigger?(:R_RIGHT)
  end
end


#-------------------------------------------------------------------------------
# * Targeting system with cursor above target
#-------------------------------------------------------------------------------
class Target_cursor < Sprite
  attr_accessor :tile_x, :tile_y, :skill
  
  def initialize(skill,viewport = nil)
    super(viewport)
    bitmap = Cache.system("Cursor")
    @target = nil
    rect = Rect.new(0,0,29,33)
    @up = 1
    @duration = 0
    @tile_x = 0
    @tile_y = 0
    @skill = skill
    self.bitmap = Bitmap.new(29,33)
    self.bitmap.blt(0,0,bitmap,rect)
    self.z = 201
    self.opacity = 255
    self.visible = true
    @aoe_indicator = AOE.new(skill.aoe)
  end
  
  def dispose
    return if self.bitmap.nil?
    self.bitmap.dispose
    self.bitmap = nil
    self.dispose
    @aoe_indicator.dispose
  end
  
  def update
    super
    check_target
    @duration += 1 
    
    self.y -= @up * 1 if @duration % 4 == 0
      
    if @duration % 16 == 0
      @duration = 0
      @up = -@up
    end
  end
  
  def change_target(target)
    self.x = target.screen_x - 16
    self.y = target.screen_y - 55
    @tile_x = target.x
    @tile_y = target.y
    @aoe_indicator.set_position(target)
  end
  
  def check_target
    FogBattleManager.map_troop.alive_members.each do |i|
      if i.x == @tile_x && i.y == @tile_y
        @aoe_indicator.set_position(i)
        @aoe_indicator.visible = true
        return
      end
    end
    @aoe_indicator.visible = false
  end
  
end

class AOE < Sprite
  
  def initialize(area_size, viewport = nil)
    super(viewport)
    @aoe_tile = Cache.system("Tile")
    @rect = Rect.new(0,0,32,32)
    create_aoe_indicator(area_size)
    self.z = 201
    self.opacity = 255
    self.visible = true
  end
  
  def create_aoe_indicator(size)
    @range = (size * 2 + 1) * 32
    self.bitmap = Bitmap.new(@range,@range)
    (size * 2 + 1).times do |i|
      off = size - i > 0 ? i : size * 2 - i
        for j in (size - off)..(size + off)
          self.bitmap.blt(j*32,i*32,@aoe_tile,@rect)
        end
    end
  end
  
  def set_position(target)
    self.x = target.screen_x - @range/2
    self.y = target.screen_y - @range/2 - 16
  end
  
  def dispose
    return if self.bitmap.nil?
    self.bitmap.dispose
    self.bitmap = nil
    self.dispose
  end
end

class Game_Projectile < Game_Event
  attr_reader :starting_x, :starting_y
  
  def initialize(owner)
    projectile_moveroute = RPG::MoveRoute.new
    projectile_movecommand = RPG::MoveCommand.new(12)
    projectile_moveroute.list = [projectile_movecommand, RPG::MoveCommand.new]
    projectile_moveroute.skippable = true
    
    projectile_graphic = RPG::Event::Page::Graphic.new
    projectile_graphic.character_name = "-Arrows"
    projectile_graphic.direction = owner.direction
    
    projectile_page = RPG::Event::Page.new
    
    projectile_page.graphic = projectile_graphic
    projectile_page.move_type = 3
    projectile_page.move_speed = 8
    projectile_page.move_frequency = 8
    projectile_page.move_route = projectile_moveroute
    projectile_page.step_anime = true
    projectile_page.direction_fix = true
    projectile_page.through = true
    projectile_page.priority_type = 0
    projectile_page.trigger = 2
    
    projectile_event = RPG::Event.new(owner.x, owner.y)
    projectile_event.id = 400 + $game_map.projectiles.length
    projectile_event.name = "Projectile"
    projectile_event.pages = [projectile_page]
    
    map_id = $game_map.map_id
    super(map_id, projectile_event)
    @direction = owner.direction
    @owner = owner
    @starting_x = @owner.x
    @starting_y = @owner.y
    @range = @owner.is_a?(Game_Player) ? FogBattleManager.party_leader.equips[0].range : @owner.monster.attack_range
    SceneManager.scene.spriteset.character_sprites.push(Sprite_Character.new(SceneManager.scene.spriteset.viewport1, self))
  end
  
  def update_routine_move
    return unless $game_map.projectiles.include?(self) 
    super
    max_distance
    @owner.is_a?(Game_Player) ? hit_enemy : hit_player
  end
  
  def hit_player
    if $game_player.x == self.x && $game_player.y == self.y
      FogBattleManager.enemy_attack_seq_range(@owner)
      delete_projectile
    end
  end
  
  def hit_enemy
    FogBattleManager.map_troop.alive_members.each do |enemy|
      if enemy.x == self.x && enemy.y == self.y
        enemy.monster.attack_apply(FogBattleManager.party_leader)
        next if FogBattleManager.check_result(enemy) 
        enemy.sprite.dispose_animation unless enemy.monster.hp <= 0
        enemy.animation_id = FogBattleManager.party_leader.atk_animation_id1 
        enemy.jump(0,0)
        result = enemy.monster.result
        FogBattleManager.print_messages(enemy,@owner) 
        delete_projectile
        return
      end
    end
  end
  
  def max_distance
    case @direction
    when 2,8
      delete_projectile if (@starting_y - @y).abs == @range
    when 4,6
      delete_projectile if (@starting_x - @x).abs == @range
    end
  end
  
  def delete_projectile
    $game_map.delete_projectile(self)
    sprite.dispose
    SceneManager.scene.spriteset.character_sprites.delete(self.sprite)
  end
  
end

class Game_Map
  attr_reader :projectiles
  
  alias fog_projectiles_init initialize
  def initialize
    fog_projectiles_init
    @projectiles = []
  end
  
  def delete_projectile(proj)
    @projectiles.delete(proj)
    @need_refresh = true
  end
  
  def add_projectile(owner)
    @projectiles << Game_Projectile.new(owner)
    @need_refresh = true
  end
  
  alias fog_projectiles_up update
  def update(main = false)
    fog_projectiles_up(main)
    update_projectiles
  end
  
  def update_projectiles
    @projectiles.each do |proj|
      proj.update
    end
  end
  
  def refresh
    @events.each_value {|event| event.refresh }
    @common_events.each {|event| event.refresh }
    @projectiles.each { |proj| proj.refresh }
    refresh_tile_events
    @need_refresh = false
  end
  
end

#----------------------------------------------------
#--------------------ENEMY_HUD-----------------------
#----------------------------------------------------
class Enem_HUD
  attr_reader :gauge_sprite
  attr_reader :hp_old, :hp_current, :dmg_old, :dmg_current, :reg_old, :reg_current

  def initialize
    dispose                                   #disposes hud (if already exists)
    @posx = 352
    @posy = 0
    @name = ""
    @target = nil
    
    create_gauge                              #creates black bar     
    create_health_bar                         #creates health bar
    create_damage_bar                         #creates damage bar
    create_regen_bar                          #creates regen bar  
    create_name
    create_states_bar
  end
  
  def set_enemy(enemy)
    @target = enemy
    return if @target.nil?
    @hp_current = @hp_wid * @target.hp / @target.mhp
    @hp_old = @hp_current
    
    @dmg_current = @hp_wid * @target.hp / @target.mhp
    @dmg_old = @dmg_current
    
    @reg_current = @reg_wid * @target.hp / @target.mhp
    @reg_old = @reg_current
  end
  
  def refresh_hud
    dispose
    create_gauge
    create_health_bar
    create_damage_bar
    create_regen_bar
    create_name
    create_states_bar
  end
    
  def create_gauge
    @gauge_sprite = Sprite.new
    @gauge_sprite.bitmap = Cache.system("Gauge.png")
    @gauge_sprite.z = 105
    @gauge_sprite.x = @posx
    @gauge_sprite.y = @posy
    @gauge_sprite.visible = false
  end
  
  def create_health_bar
    @hp_img = Cache.system("Health.png")
    @hp_wid = @hp_img.width 
    @hp_hei = @hp_img.height
    
    @hp_sprite = Sprite.new
    @hp_sprite.bitmap = Bitmap.new(@hp_img.width,@hp_img.height)
    @hp_sprite.z = 104
    @hp_sprite.x = @posx
    @hp_sprite.y = @posy
    @hp_sprite.visible = false
    
    hp_flow if @target
  end
  
  def create_damage_bar
    @dmg_img = Cache.system("Damage.png")
    @dmg_wid = @dmg_img.width 
    @dmg_hei = @dmg_img.height
    
    @dmg_sprite = Sprite.new
    @dmg_sprite.bitmap = Bitmap.new(@hp_img.width,@hp_img.height)
    @dmg_sprite.z = 103
    @dmg_sprite.x = @posx
    @dmg_sprite.y = @posy
    @dmg_sprite.visible = false
    
    dmg_flow if @target
  end
  
  def create_regen_bar
    @reg_img = Cache.system("Regen.png")
    @reg_wid = @reg_img.width
    @reg_hei = @reg_img.height
    
    @reg_sprite = Sprite.new
    @reg_sprite.bitmap = Bitmap.new(@reg_wid,@reg_hei)
    @reg_sprite.z = 102
    @reg_sprite.x = @posx
    @reg_sprite.y = @posy
    @reg_sprite.visible = false
    
    reg_flow if @target
  end
  
  def create_name
    @name_sprite = Sprite.new
    @name_sprite.bitmap = Bitmap.new(200,15)
    @name_sprite.z = 105
    @name_sprite.x = @posx
    @name_sprite.y = @posy + @reg_hei + 2
    @name_sprite.bitmap.font.size = 15
    @name_sprite.visible = false
  end
  
  def create_states_bar
    @states_sprite = Sprite.new
    @states_sprite.bitmap = Bitmap.new(32*2,32)
    @states_sprite.z = 106
    @states_sprite.x = @posx + 140
    @states_sprite.y = @name_sprite.y
    @states_sprite.zoom_x = 0.8
    @states_sprite.zoom_y = 0.8
    up_states  if @target
  end
  
  def dispose
    return if @gauge_sprite.nil?
    @gauge_sprite.bitmap.dispose
    @gauge_sprite.dispose
    
    @dmg_sprite.bitmap.dispose
    @dmg_sprite.dispose
    
    @hp_sprite.bitmap.dispose
    @hp_sprite.dispose
    
    @reg_sprite.bitmap.dispose
    @reg_sprite.dispose
    
    @states_sprite.bitmap.dispose
    @states_sprite.dispose
    
    @name_sprite.bitmap.dispose
    @name_sprite.dispose
  end
  
  def up_visible(show = true)
    return if @gauge_sprite.disposed?
    vis = show && !$game_message.visible
    @hp_sprite.visible = vis
    @dmg_sprite.visible = vis
    @gauge_sprite.visible = vis
    @reg_sprite.visible = vis
    @states_sprite.visible = vis
    @name_sprite.visible = vis
  end
  
  def up_enemy
    return unless FogBattleManager.target
    set_enemy(FogBattleManager.target.monster) if @target != FogBattleManager.target.monster 
  end
  
  def update
    return if @gauge_sprite.disposed? || @target.nil?
    up_enemy
    up_visible
    hp_flow
    dmg_flow
    reg_flow
    set_name
    up_states
  end
  
  def set_name
    return if @target.nil? 
    @name = @target.name + " " + @target.letter
    @name_sprite.bitmap.clear
    @name_sprite.bitmap.draw_text(0,0,@name.length*15,15,@name)
  end
  
  def hp_flow
    @hp_sprite.bitmap.clear
    @hp_current = @hp_img.width * @target.hp / @target.mhp
    step = (@hp_old - @hp_current).abs * 0.1 
    if @hp_current < @hp_old
      @hp_old -= 100 
      if @hp_current+0.5 > @hp_old
        @hp_old = @hp_current 
      end
      
      @hp_rect = Rect.new(0,0,@hp_old,@hp_hei)
      @hp_sprite.bitmap.blt(0,0,@hp_img,@hp_rect)
    elsif @hp_current > @hp_old
      @hp_old += step
      if @hp_current-1 < @hp_old
        @hp_old = @hp_current 
      end
      
      @hp_rect = Rect.new(0,0,@hp_old,@hp_hei)
      @hp_sprite.bitmap.blt(0,0,@hp_img,@hp_rect)
    else
      @hp_rect = Rect.new(0,0,@hp_current,@hp_hei)
      @hp_sprite.bitmap.blt(0,0,@hp_img,@hp_rect)
    end  
  end
  
  def dmg_flow
    @dmg_sprite.bitmap.clear
    @dmg_current = @dmg_wid * @target.hp / @target.mhp
    step = (@dmg_old - @dmg_current).abs * 0.1 
    if @dmg_current < @dmg_old
      @dmg_old -= step/1.5
      if @dmg_current+0.9 > @dmg_old
        @dmg_old = @dmg_current 
      end
      
      @dmg_rect = Rect.new(0,0,@dmg_old,@dmg_hei)
      @dmg_sprite.bitmap.blt(0,0,@dmg_img,@dmg_rect)
    elsif @dmg_current > @dmg_old
      @dmg_old += step*0.9
      if @dmg_current-1 < @dmg_old
        @dmg_old = @dmg_current 
      end
      
      @dmg_rect = Rect.new(0,0,@dmg_old,@dmg_hei)
      @dmg_sprite.bitmap.blt(0,0,@dmg_img,@dmg_rect)
    else
      @dmg_rect = Rect.new(0,0,@dmg_current,@dmg_hei)
      @dmg_sprite.bitmap.blt(0,0,@dmg_img,@dmg_rect)
    end  
  end
  
  def reg_flow
    @reg_sprite.bitmap.clear
    @reg_current = @hp_wid * @target.hp / @target.mhp
    if @reg_current != @reg_old
      valor = 100
      @reg_old -= valor if @reg_old > @reg_current
      if @reg_old < @reg_current
        @reg_old = @reg_current
      end
      @reg_rect = Rect.new(0,0,@reg_old,@reg_hei)
      @reg_sprite.bitmap.blt(0,0,@reg_img,@reg_rect,128)
    end
    @reg_rect = Rect.new(0,0,@reg_current,@reg_hei)
    @reg_sprite.bitmap.blt(0,0,@reg_img,@reg_rect)
  end

  
  def up_states
    num = 0
    @states_sprite.visible = !(@target.states.empty? && @target.buff_icons.empty?)
    
    @target.states.each do |state|
      return if num > 0
      index = state.icon_index
      state_rect = Rect.new(index % 16 * 24, index / 16 * 24, 24, 24)
      bitmap = Cache.system("Iconset")
      @states_sprite.bitmap.blt(num*24 + 1, 1, bitmap, state_rect)
      num += 1
    end
    
    @target.buff_icons.each do |icon|
      break if num > 1
      buff_rect = Rect.new(icon % 16 * 24, icon / 16 * 24, 24, 24)
      bitmap = Cache.system("Iconset")
      @states_sprite.bitmap.blt(num*24 + 1, 1, bitmap, buff_rect)
      num += 1
    end
  end
  
end  

class Hp_Hud
  
  def initialize
    @leader = $game_party.members[0]
    dispose
    return if @leader == nil
    @pre_leader_id = $game_party.members[0].id
    @posx = 0
    @posy = 0
    
    create_gauge
    create_health_bar
    create_damage_bar
    create_regen_bar
    create_mp_gauge
    create_mp_bar
    create_states_bar
    up_visible($game_system.player_hud_vis)
  end
  
  def refresh_hud
    dispose
    @leader = $game_party.members[0]
    create_gauge
    create_health_bar
    create_damage_bar
    create_regen_bar
    create_mp_gauge
    create_mp_bar
    create_states_bar
  end
    
  def create_gauge
    @gauge_sprite = Sprite.new
    @gauge_sprite.bitmap = Cache.system("Gauge.png")
    @gauge_sprite.z = 5
    @gauge_sprite.x = @posx
    @gauge_sprite.y = @posy
  end
  
  def create_health_bar
    @hp_img = Cache.system("Health.png")
    @hp_wid = @hp_img.width 
    @hp_hei = @hp_img.height
    @hp_current = @hp_wid * @leader.hp / @leader.mhp
    @hp_old = @hp_current
    
    @hp_sprite = Sprite.new
    @hp_sprite.bitmap = Bitmap.new(@hp_img.width,@hp_img.height)
    @hp_sprite.z = 4
    @hp_sprite.x = @posx
    @hp_sprite.y = @posy
    hp_flow
  end
  
  def create_damage_bar
    @dmg_img = Cache.system("Damage.png")
    @dmg_wid = @dmg_img.width 
    @dmg_hei = @dmg_img.height
    @dmg_current = @hp_wid * @leader.hp / @leader.mhp
    @dmg_old = @hp_current
    
    @dmg_sprite = Sprite.new
    @dmg_sprite.bitmap = Bitmap.new(@hp_img.width,@hp_img.height)
    @dmg_sprite.z = 3
    @dmg_sprite.x = @posx
    @dmg_sprite.y = @posy
    dmg_flow
  end
  
  def create_regen_bar
    @reg_img = Cache.system("Regen.png")
    @reg_wid = @reg_img.width
    @reg_hei = @reg_img.height
    @reg_current = @reg_wid * @leader.hp / @leader.mhp
    @reg_old = @reg_current
    
    @reg_sprite = Sprite.new
    @reg_sprite.bitmap = Bitmap.new(@reg_wid,@reg_hei)
    @reg_sprite.z = 2
    @reg_sprite.x = @posx
    @reg_sprite.y = @posy
    reg_flow
  end
  
  def create_mp_gauge
    @mp_gauge_sprite = Sprite.new
    @mp_gauge_sprite.bitmap = Cache.system("Gauge.png")
    @mp_gauge_sprite.z = 5
    @mp_gauge_sprite.x = @posx 
    @mp_gauge_sprite.y = @posy + @gauge_sprite.bitmap.height
  end
  
  def create_mp_bar
    @mp_img = Cache.system("Mana.png")
    @mp_wid = @mp_img.width 
    @mp_hei = @mp_img.height
    @mp_current = @mp_wid * @leader.mp / @leader.mmp
    @mp_old = @mp_current
    
    @mp_sprite = Sprite.new
    @mp_sprite.bitmap = Bitmap.new(@mp_img.width,@mp_img.height)
    @mp_sprite.z = 4
    @mp_sprite.x = @posx
    @mp_sprite.y = @posy + @gauge_sprite.bitmap.height
    mp_flow
  end
  
  def create_states_bar
    @states_sprite = Sprite.new
    @states_sprite.bitmap = Bitmap.new(36*5,36)
    @states_sprite.z = 5
    @states_sprite.x = @posx 
    @states_sprite.y = @posy + @mp_sprite.y + @mp_hei
    @states_sprite.zoom_x = 0.8
    @states_sprite.zoom_y = 0.8
    up_states
  end
  
  def dispose
    return if @gauge_sprite.nil?
    @gauge_sprite.bitmap.dispose
    @gauge_sprite.dispose
    @gauge_sprite = nil
    
    @dmg_sprite.bitmap.dispose
    @dmg_sprite.dispose
    
    @hp_sprite.bitmap.dispose
    @hp_sprite.dispose
    
    @reg_sprite.bitmap.dispose
    @reg_sprite.dispose
    
    @states_sprite.bitmap.dispose
    @states_sprite.dispose
    
    @mp_gauge_sprite.bitmap.dispose
    @mp_gauge_sprite.dispose
    @mp_gauge_sprite = nil
    
    @mp_sprite.bitmap.dispose
    @mp_sprite.dispose
  end
  
  def up_visible(is_visible)
    return if @gauge_sprite.nil?
    @hp_sprite.visible    = !$game_message.visible && is_visible
    @dmg_sprite.visible   = !$game_message.visible && is_visible
    @gauge_sprite.visible = !$game_message.visible && is_visible
    @reg_sprite.visible   = !$game_message.visible && is_visible
    @mp_gauge_sprite.visible      = !$game_message.visible && is_visible
    @mp_sprite.visible            = !$game_message.visible && is_visible
    vis = !$game_message.visible && (!@leader.states.empty? || !@leader.buff_icons.empty?)
    @states_sprite.visible = vis && is_visible
  end
  
  def update
    if @leader == nil || @gauge_sprite.nil?
      #refresh if $game_party.members[0] != nil
      return 
    end  
    
    up_visible($game_system.player_hud_vis)
    hp_flow
    dmg_flow
    reg_flow
    mp_flow
    up_states
    if @leader.hp == 0
      FogBattleManager.check_dead if @dmg_old <= 75
    end
  end
  
  def hp_flow
    @hp_sprite.bitmap.clear
    @hp_current = @hp_img.width * @leader.hp / @leader.mhp
    step = (@hp_old - @hp_current).abs * 0.1 
    if @hp_current < @hp_old
      @hp_old -= 100 
      if @hp_current+0.5 > @hp_old
        @hp_old = @hp_current 
      end
      
      @hp_rect = Rect.new(0,0,@hp_old,@hp_hei)
      @hp_sprite.bitmap.blt(0,0,@hp_img,@hp_rect)
    elsif @hp_current > @hp_old
      @hp_old += step
      if @hp_current-1 < @hp_old
        @hp_old = @hp_current 
      end
      
      @hp_rect = Rect.new(0,0,@hp_old,@hp_hei)
      @hp_sprite.bitmap.blt(0,0,@hp_img,@hp_rect)
    else
      @hp_rect = Rect.new(0,0,@hp_current,@hp_hei)
      @hp_sprite.bitmap.blt(0,0,@hp_img,@hp_rect)
    end  
  end
  
  def dmg_flow
    @dmg_sprite.bitmap.clear
    @dmg_current = @dmg_wid * @leader.hp / @leader.mhp
    step = (@dmg_old - @dmg_current).abs * 0.1 
    if @dmg_current < @dmg_old
      @dmg_old -= step/2.5
      if @dmg_current+0.005 > @dmg_old
        @dmg_old = @dmg_current 
      end
      
      @dmg_rect = Rect.new(0,0,@dmg_old,@dmg_hei)
      @dmg_sprite.bitmap.blt(0,0,@dmg_img,@dmg_rect)
    elsif @dmg_current > @dmg_old
      @dmg_old += step*0.9
      if @dmg_current-1 < @dmg_old
        @dmg_old = @dmg_current 
      end
      
      @dmg_rect = Rect.new(0,0,@dmg_old,@dmg_hei)
      @dmg_sprite.bitmap.blt(0,0,@dmg_img,@dmg_rect)
    else
      @dmg_rect = Rect.new(0,0,@dmg_current,@dmg_hei)
      @dmg_sprite.bitmap.blt(0,0,@dmg_img,@dmg_rect)
    end  
  end
  
  def reg_flow
    @reg_sprite.bitmap.clear
    @reg_current = @hp_wid * @leader.hp / @leader.mhp
    if @reg_current != @reg_old
      valor = 100
      @reg_old -= valor if @reg_old > @reg_current
      if @reg_old < @reg_current
        @reg_old = @reg_current
      end
      @reg_rect = Rect.new(0,0,@reg_old,@reg_hei)
      @reg_sprite.bitmap.blt(0,0,@reg_img,@reg_rect,128)
    end
    @reg_rect = Rect.new(0,0,@reg_current,@reg_hei)
    @reg_sprite.bitmap.blt(0,0,@reg_img,@reg_rect)
  end
  
  def mp_flow
    @mp_sprite.bitmap.clear
    @mp_current = @mp_wid * @leader.mp / @leader.mmp
    step = (@mp_old - @mp_current).abs * 0.1 
    if @mp_current < @mp_old
      @mp_old -= step/2.5
      if @mp_current+0.005 > @mp_old
        @mp_old = @mp_current 
      end
      
      @mp_rect = Rect.new(0,0,@mp_old,@mp_hei)
      @mp_sprite.bitmap.blt(0,0,@mp_img,@mp_rect)
    elsif @mp_current > @mp_old
      @mp_old += step*0.9
      if @mp_current-1 < @mp_old
        @mp_old = @mp_current 
      end
      
      @mp_rect = Rect.new(0,0,@mp_old,@mp_hei)
      @mp_sprite.bitmap.blt(0,0,@mp_img,@mp_rect)
    else
      @mp_rect = Rect.new(0,0,@mp_current,@mp_hei)
      @mp_sprite.bitmap.blt(0,0,@mp_img,@mp_rect)
    end
  end
  
  def up_states
    num = 0
    state_icons = @leader.states.length
    buff_icons = @leader.buff_icons.length
    all_icons = state_icons + buff_icons
    state_num = all_icons == state_icons ? [state_icons,5].min : [(all_icons/2)+1,3].min
    buff_num = all_icons == buff_icons ? [buff_icons,5].min : [(all_icons/2)+1,all_icons-state_icons].min
    bitmap = Cache.system("Iconset")
    @leader.states.each do |state|
      break if num == state_num
      index = state.icon_index
      state_rect = Rect.new(index % 16 * 24, index / 16 * 24, 24, 24)
      @states_sprite.bitmap.blt(num*24 + num+1, 0, bitmap, state_rect)
      num += 1
    end
    
    @leader.buff_icons.each do |icon|
      break if num == buff_num
      buff_rect = Rect.new(icon % 16 * 24, icon / 16 * 24, 24, 24)
      @states_sprite.bitmap.blt(num*24 + num+1, 0, bitmap, buff_rect)
      num += 1
    end
  end
  
end

class Game_System
  attr_accessor :player_hud_vis, :refresh_hud
  
  alias hud_init initialize
  def initialize
    hud_init
    @player_hud_vis = true
    @refresh_hud = false
  end
  
end

class Spriteset_FogABS
  attr_accessor :skill_window, :target_cursor, :enemy_hud, :skill_window
  attr_accessor :target_cursor
  
  include FOG_ABS_OPTIONS
  
  def initialize
    init_members
  end
  
  def init_members
    @damage_popups = []
    @exp_gold_popups = []
    @target_cursor = nil
    @target_lock = Target_Lock.new
    @player_hud = Hp_Hud.new
    @enemy_hud = Enem_HUD.new
    @items_received_popups_q = []
    @items_received_popups = []
    @item_received_show_delay = 0
    init_skill_window
  end
  
  def item_received_queue(string)
    @items_received_popups_q.push(string)
  end
  
  def item_received_add(string)
    @items_received_popups.each { |i| i.move_down } 
    @items_received_popups << Window_ItemsReceived.new(@items_received_popups.length + 1, string)
    @item_received_show_delay = 30
  end
  
  def add_damage(result,target,duration)
    @damage_popups << Messages.new(result,target,duration)
  end
  
  def add_exp_gold(number,target,duration,off_x = 0,off_y = 0)
    @exp_gold_popups << Messages.new(number,target,duration,off_x,off_y)
  end
    
  def init_skill_window
    wx = 0                    #window x position
    wy = 416 - 5*24           #window y position
    ww =  Graphics.width / 3  #window width
    wh = 5 * 24               #window height
    @skill_window = Window_AssignedSkills.new(wx,wy,ww,wh,true) #creates window
    @skill_window.hide  
    @skill_window.actor = FogBattleManager.party_leader 
  end
  
  def refresh_hud(both = 0) #0 for both, 1 for player, 2 for enemy hud
    case both
    when 0
      @player_hud.refresh_hud
      @enemy_hud.refresh_hud
    when 1
      @player_hud.refresh_hud
    when 2
      @enemy_hud.refresh_hud
    end
    $game_system.refresh_hud = false
  end
  
  def update
    return if FogBattleManager.selecting_target
    update_items_received
    update_damage_popups
    update_exp_gold_popups
    update_huds
    update_target_lock
    update_skill_window
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
  
  def update_damage_popups
    @damage_popups.each do |pop|
      if !pop.visible
        pop.dispose
        @damage_popups.delete(pop)
        next
      end
      if @damage_popups.length > 5
        @damage_popups[-1].dispose
        @damage_popups.delete_at(-1)
      end
      pop.update
    end
  end
  
  def update_exp_gold_popups
    @exp_gold_popups.each do |pop|
      if !pop.visible
        pop.dispose
        @exp_gold_popups.delete(pop)
        next
      end
      if @exp_gold_popups.length > 5
        @exp_gold_popups[-1].dispose
        @exp_gold_popups.delete_at(-1)
      end
      pop.update
    end
  end
  
  def update_huds
    refresh_hud if $game_system.refresh_hud
    @player_hud.update
    @enemy_hud.update
  end
  
  def update_target_lock
    @target_lock.update
  end
  
  def update_target_cursor
    @target_cursor.update
  end
  
  def update_skill_window
    unless WolfPad.press?(:R2) || WolfPad.press?(:L2) 
      @skill_window.hide
      return
    end
    @skill_window.unselect
    if WolfPad.press?(:R2) #if R2 is pressed then window is showed on right side
      @skill_window.x = 544 - Graphics.width / 3
      @skill_window.side = :right2   
    elsif WolfPad.press?(:L2) #if L2 is pressed then window is showed on left side
      @skill_window.x = 0
      @skill_window.side = :left2 
    end
    @skill_window.refresh
    @skill_window.show   
    FogBattleManager.selected_skill
  end
  
  def setup_cursor(skill)
    @target_cursor = Target_cursor.new(skill)
    @target_cursor.change_target(FogBattleManager.cursor_target)
    @skill_window.hide
  end  
    
  def moving_cursor
    if WolfPad.trigger?(:Y)
      FogBattleManager.selecting_target = false
      @target_cursor.dispose
    end
    
    if WolfPad.trigger?(:RIGHT)
      return if cursor_outrange?(6)
      @target_cursor.x += 32
      @target_cursor.tile_x += 1
    elsif WolfPad.trigger?(:LEFT)
      return if cursor_outrange?(4)
      @target_cursor.x -= 32
      @target_cursor.tile_x -= 1
    end
    
    if WolfPad.trigger?(:UP)
      return if cursor_outrange?(8)
      @target_cursor.y -= 32
      @target_cursor.tile_y -= 1
    elsif WolfPad.trigger?(:DOWN)
      return if cursor_outrange?(2)
      @target_cursor.y += 32
      @target_cursor.tile_y += 1
    end
  end

  def cursor_outrange?(direction)
    case direction
    when 2
      distance_from($game_player,@target_cursor.tile_x,@target_cursor.tile_y+1) > @target_cursor.skill.range
    when 4
      distance_from($game_player,@target_cursor.tile_x-1,@target_cursor.tile_y) > @target_cursor.skill.range
    when 6
      distance_from($game_player,@target_cursor.tile_x+1,@target_cursor.tile_y) > @target_cursor.skill.range
    when 8
      distance_from($game_player,@target_cursor.tile_x,@target_cursor.tile_y-1) > @target_cursor.skill.range
    end
  end
  
  def distance_from(center,x,y)
    (center.x - x).abs + (center.y - y).abs
  end
  
  def dispose_all
    dispose_damage_popups
    dispose_exp_gold_popups
    dispose_huds
    dispose_target_lock
  end
  
  def dispose_damage_popups
    @damage_popups.each do |pop|
      pop.dispose
    end
  end
  
  def dispose_exp_gold_popups
    @exp_gold_popups.each do |pop|
      pop.dispose
    end
  end
  
  def dispose_huds(both = 0)
    case both
    when 0
      @player_hud.dispose
      @enemy_hud.dispose
    when 1
      @player_hud.dispose
    when 2
      @enemy_hud.dispose
    end
  end
  
  def dispose_target_lock
    @target_lock.dispose
  end
  
  def dispose_target_popups(target)
    @damage_popups.each do |pop|
      if pop.target == target
        pop.dispose
        @damage_popups.delete(pop)
      end
    end
  end
  
end

class Spriteset_Map
  alias fog_abs_init initialize
  def initialize
    FogBattleManager.setup($game_map)
    fog_abs_init
  end
  
  alias fog_abs_up update
  def update
    fog_abs_up
    FogBattleManager.setup($game_map) if $game_map.map_id != FogBattleManager.map_id
    FogBattleManager.update
  end
end
class Scene_MenuBase < Scene_Base
  alias fog_abs_term terminate
  def terminate
    fog_abs_term
    $game_system.refresh_hud = true
  end
end

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module manages battle progress.
#==============================================================================
module FogBattleManager
  include FOG_ABS_OPTIONS
  #attr_accessor :selecting_target, :cursor_targer
  
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def self.setup(map)
    init_members
    @spriteset_abs = Spriteset_FogABS.new
    @map_troop = Map_Troop.new
    @map_id = map.map_id
    @map_troop.setup(map)
  end
  #--------------------------------------------------------------------------
  # * Initialize Member Variables
  #--------------------------------------------------------------------------
  def self.init_members
    @can_escape = false         # Can Escape Flag
    @can_lose = false           # Can Lose Flag
    @surprise = false           # Surprise Flag
    @map_bgm = nil              # For Memorizing Pre-Battle BGM
    @map_bgs = nil              # For Memorizing Pre-Battle BGS
    @party_leader = $game_actors[$game_party.members[0].id]
    @party_leader_class = $data_classes[@party_leader.class_id]
    @action_battlers = []       # Action Order List
    @selecting_target = false
    @cursor_target = nil
    @target = nil
    @turn_duration = TURN_DURATION
    @c_frame = 0
  end
  
  def self.cursor_target=(target)
    @cursor_target = target
  end
  def self.cursor_target
    @cursor_target
  end
  def self.init_cursor_target
    @cursor_target = @map_troop.alive_members.min{ |x,y| x.distance<=>y.distance}
    @selecting_target = true
  end
  def self.selecting_target
    @selecting_target
  end
  def self.selecting_target=(selecting)
    @selecting_target = selecting
  end
  
  def self.map_id
    @map_id
  end

  def self.target
    @target
  end
  def self.target=(target)
    @target = target
  end
  
  def self.party_leader
    @party_leader
  end
  def self.party_leader_class
    @party_leader_class
  end
  
  def self.spriteset_abs
    @spriteset_abs
  end
  
  def self.map_troop
    @map_troop
  end
  #--------------------------------------------------------------------------
  # * Returns if player can escape battle/map
  #--------------------------------------------------------------------------
  def can_escape=(can_escape)
    @can_escape = can_escape
  end
  #--------------------------------------------------------------------------
  # * Returns if player will get game over screen after loss
  #--------------------------------------------------------------------------
  def can_lose=(can_lose)
    @can_lose = can_lose
  end
  #--------------------------------------------------------------------------
  # * Updates everything
  #--------------------------------------------------------------------------
  def self.update
    return unless SceneManager.scene.spriteset
    if @selecting_target
      @spriteset_abs.target_cursor.update
      @cursor_target = @map_troop.alive_members.find do |i| 
        i.x == @spriteset_abs.target_cursor.tile_x && i.y == @spriteset_abs.target_cursor.tile_y 
      end
      targeting_seq
      return
    end
    @spriteset_abs.update
    update_turn
    update_distances
    update_troop
    update_leader
  end
  #--------------------------------------------------------------------------
  # * Updates states and buffs every second
  #--------------------------------------------------------------------------
  def self.update_turn
    @c_frame += 1 if @c_frame < @turn_duration
    return unless @c_frame == @turn_duration
    
    $game_party.members.each do |i|
      i.on_turn_end
      i.update_skills_cd
    end
    
    @map_troop.alive_members.each do |enemy|
      next if enemy.dead?  
      enemy.monster.on_turn_end
      enemy.monster.remove_buffs_auto
      enemy.monster.skills_cd.each_key do |key|
        enemy.monster.skills_cd[key] += 1 if enemy.monster.skills_cd[key] < $data_skills[key].cooldown
      end
    end
    
    @c_frame = 0
  end
  #--------------------------------------------------------------------------
  # * Updates distances between player and enemies and sets current target
  #--------------------------------------------------------------------------
  def self.update_distances
    if @map_troop.alive_members.empty?
      target_hud_update
      return 
    end
    @map_troop.alive_members.each do |i|
      i.update_distance
    end
    #puts "#{@map_troop.enemies[0].monster.name} #{@map_troop.enemies[0].id}"
    
    closest_enemy = @map_troop.alive_members.min {|x,y| x.distance <=> y.distance }
    
    @target = nil if closest_enemy.distance > PLAYER_SIGHT
    target_hud_update(closest_enemy)  
  end
  #--------------------------------------------------------------------------
  # * Updates alive and dead troop members
  #--------------------------------------------------------------------------
  def self.update_troop
    @map_troop.alive_members.each do |member|
      if member.monster.hp == 0
        death_sequence(member) 
        next
      end
      b_mode = (member.distance <= member.sight_range)
      last_enable = $game_self_switches[member.battle_key]
      if b_mode != last_enable
        $game_self_switches[member.battle_key] = b_mode
        member.battling = b_mode
        member.refresh
      end
    end
    
    @map_troop.dead_members.each do |member|
      member.check_if_picked unless member.erased?
    end  
    make_action_orders
    @action_battlers.each_index do |i|
      break if i > atk_list_length
      @action_battlers[i].attack_cd += 1
      @action_battlers[i].update_action
    end
  end
  
  def self.atk_list_length
    return 0 if @map_troop.enemies == 0
    average_level = 0
    @map_troop.alive_members.each do |i|
      average_level += i.level
    end
    average_level /= @map_troop.alive_members.length * 15
    average_level.to_i + 1 + $game_system.difficulty
  end
  #--------------------------------------------------------------------------
  # * Updates leader's parameters
  #--------------------------------------------------------------------------
  def self.update_leader
    check_dead
    @party_leader.atk_cd +=1 if  @party_leader.atk_cd < 2*@party_leader_class.attack_speed
    @party_leader.delay -= 1 if @party_leader.delay > 0
    @party_leader.combo_num = 0 if @party_leader.atk_cd >= 2*@party_leader_class.attack_speed
    attack_seq
    $game_player.lock_on
    update_graphic
  end
  def self.update_graphic
    begin
      Cache.character("$#{@party_leader.name}") 
    rescue 
      puts "No sprite found for character. Using default."
      return
    end
    if $game_player.down
      @party_leader.change_graphic("$#{@party_leader.name}_Hit")
    elsif $game_player.jumping?
      @party_leader.change_graphic("$#{@party_leader.name}_Jump") 
    elsif $game_player.dash?
      @party_leader.change_graphic("$#{@party_leader.name}_Dash")
    else
      @party_leader.change_graphic("$#{@party_leader.name}")
    end
    $game_player.frame_attacking
  end
  def self.attack_seq
    return unless $game_player.attacking?
    if @party_leader.equips[0].range == 1
      @party_leader.combo_num += 1 if @party_leader.combo_num < @party_leader_class.max_combo
      dmg_inrange_targets
      if @party_leader.combo_num == @party_leader_class.max_combo
        @party_leader.combo_num = 0 
        finish_hit #events for finishing hit
      end
    elsif @party_leader.equips[0].range > 1
      $game_map.add_projectile($game_player)
    end
    @party_leader.atk_cd = 0
  end
  def self.play_attack_sound
    Audio.se_stop 
    max_combo = $data_classes[@party_leader.class_id].max_combo
    case @party_leader.combo_num
    when max_combo
      Audio.se_play("Audio\\SE\\V_Attack5")
    when 1..2
      Audio.se_play("Audio\\SE\\V_Attack1")
    when 3..(max_combo - 1)
      Audio.se_play("Audio\\SE\\V_Attack2")
    end
  end
  def self.finish_hit
    $game_player.jump(0,0)
  end
  #--------------------------------------------------------------------------
  # * Events when an enemy dies
  #--------------------------------------------------------------------------
  def self.death_sequence(event)
    event.can_attack = false
    event.interrupted = true
    hud = @spriteset_abs.enemy_hud
    enemy = event.monster
    hud.update
    a =  hud.hp_old == hud.hp_current 
    b =  hud.dmg_old == hud.dmg_current
    c =  hud.reg_old == hud.reg_current
    if a && b && c
      return unless event.play_death_anim
      dispose_messages(event)
      enemy.add_state(enemy.death_state_id)
      @action_battlers.delete(enemy)
      $game_self_switches[event.battle_key] = false
      $game_dead_enemies[event.death_key] = true
      hud.up_visible(false)
      dispose_messages(event)
      self.killed_enemy(event)
      if event == @target
        @target = nil
        @spriteset_abs.enemy_hud.set_enemy(@target)
        $game_player.locking_on = false
      end
      event.make_drop
    end
  end
  
  def self.dispose_messages(target)
    @spriteset_abs.dispose_target_popups(target)
    #@spriteset_abs.dispose_user_projectiles(target)
  end
  
  #--------------------------------------------------------------------------
  # * Updates hud of target
  #--------------------------------------------------------------------------
  def self.target_hud_update(closest_enemy = nil)
    if closest_enemy.nil? || closest_enemy.distance > PLAYER_SIGHT
      @spriteset_abs.enemy_hud.up_visible(false)
      return
    end
    if closest_enemy.distance <= PLAYER_SIGHT
      if @target != closest_enemy && !$game_player.locking_on
        @target = closest_enemy
        @spriteset_abs.enemy_hud.set_enemy(@target.monster)
        $game_system.refresh_hud = true
      end
      @spriteset_abs.enemy_hud.update
    end
  end
  #--------------------------------------------------------------------------
  # * Changes Party Leader
  #--------------------------------------------------------------------------
  def self.change_leader(reverse = false)
    $game_party.rotate_order(reverse)
    @party_leader = $game_actors[$game_party.members[0].id] 
    @party_leader_class = $data_classes[@party_leader.class_id]
  end
  #--------------------------------------------------------------------------
  # * Damages targets that are inrange of attack
  #--------------------------------------------------------------------------
  def self.dmg_inrange_targets
    result = nil
    @map_troop.alive_members.each do |event|
      front_line = get_front_line($game_player)
      next unless front_line.include?([event.x,event.y]) 
      $game_player.start_attack_animation
      event.monster.attack_apply(@party_leader, result)
      if result.nil?
        result = event.monster.result
        if result.missed || result.evaded
          @party_leader.delay += PLAYER_MISS_EVADE_RECOVER
        end
      end
      print_messages(event,$game_player)
      if result.missed || result.evaded
        event.attack_cd += 20
        next
      end
      if @party_leader.combo_num == @party_leader_class.max_combo
        push_target_back($game_player,event) 
        push_target_back($game_player,event) 
      end
      event.interrupted = true
      event.sprite.dispose_animation unless event.monster.hp <= 0
      event.animation_id = @party_leader.atk_animation_id1 
      event.jump(0,0)
    end
  end
  def self.check_result(result)
      if result.missed
        Audio.se_play("Audio\\SE\\Miss")
        return true
      elsif result.evaded
        Audio.se_play("Audio\\SE\\Evasion1")
        return true
      end
      return false
  end
  def self.get_front_line(user, range = 1, aoe = 1)
    cent_front_x = $game_map.x_with_direction(user.x, user.direction)
    cent_front_y = $game_map.y_with_direction(user.y, user.direction)
    case user.direction
    when 2, 8
      front_line = [[cent_front_x-1,cent_front_y],[cent_front_x+1,cent_front_y]]
    when 4, 6
      front_line = [[cent_front_x,cent_front_y-1],[cent_front_x,cent_front_y+1]]
    end
    if $game_player.dash? || range > 1
      range.times do |i|
        case user.direction
        when 2
          aoe.times do |j|
            front_line << [cent_front_x-j,cent_front_y+(i+1)]
            front_line << [cent_front_x+j,cent_front_y+(i+1)]
            #front_line << [cent_front_x+1,cent_front_y+(i+1)]
            #front_line << [cent_front_x,cent_front_y+(i+1)]
          end
        when 8
          aoe.times do |j|
            front_line << [cent_front_x-j,cent_front_y-(i+1)]
            front_line << [cent_front_x+j,cent_front_y-(i+1)]
            #front_line << [cent_front_x+1,cent_front_y-(i+1)]
            #front_line << [cent_front_x,cent_front_y-(i+1)]
          end
        when 4
          aoe.times do |j|
            front_line << [cent_front_x-(i+1),cent_front_y-j]
            front_line << [cent_front_x-(i+1),cent_front_y+j]
            #front_line << [cent_front_x-(i+1),cent_front_y+1]
            #front_line << [cent_front_x-(i+1),cent_front_y]
          end
        when 6
          aoe.times do |j|
            front_line << [cent_front_x+i+1,cent_front_y-j]
            front_line << [cent_front_x+i+1,cent_front_y+j]
            #front_line << [cent_front_x+i+1,cent_front_y+1]
            #front_line << [cent_front_x+i+1,cent_front_y]
          end
        end
      end
    end
    front_line << [cent_front_x,cent_front_y]
    return front_line
  end
  #--------------------------------------------------------------------------
  # * Executes Skill
  #--------------------------------------------------------------------------
  def self.selected_skill
    #which key is pressed
    actor = @party_leader
    if WolfPad.trigger?(:X)
      #@skillz.select(0)
      skill = @spriteset_abs.skill_window.side == :left2 ? actor.left[0] : actor.right[0]
      execute_skill_seq(skill)
    elsif WolfPad.trigger?(:Y)
      #@skillz.select(1)
      skill = @spriteset_abs.skill_window.side == :left2 ? actor.left[1] : actor.right[1]
      execute_skill_seq(skill)
    elsif WolfPad.trigger?(:A)
      #@skillz.select(2)
      skill = @spriteset_abs.skill_window.side == :left2 ? actor.left[2] : actor.right[2]
      execute_skill_seq(skill)
    elsif WolfPad.trigger?(:B)
      #@skillz.select(3)
      skill = @spriteset_abs.skill_window.side == :left2 ? actor.left[3] : actor.right[3]
      execute_skill_seq(skill)
    end
  end
  
  def self.targeting_seq
    selected_target
    @spriteset_abs.moving_cursor
  end
  
  def self.selected_target
    if WolfPad.trigger?(:A)
      if @cursor_target.nil?
        RPG::SE.new("Bow3", 100, 100).play
        return
      end
      execute_skill(@spriteset_abs.target_cursor.skill,@cursor_target)
      @selecting_target = false
      @spriteset_abs.target_cursor.dispose
    end
  end
  
  def self.execute_skill_seq(skill)
    return if skill.id == 127
    if skill.is_a?(RPG::Item)
      use_item(skill) 
      return
    end
    return unless @party_leader.skill_cost_payable?(skill)
    if @party_leader.skills_cd[skill.id] < skill.cooldown
      @spriteset_abs.add_damage("No cooldown!",$game_player,30)
      return
    end
    if skill.targeted
      return if map_troop.alive_members.empty?
      init_cursor_target
      @spriteset_abs.setup_cursor(skill)
    else
      execute_skill(skill)
    end
  end
  
  def self.use_item(item)
    return unless $game_party.all_items.include?(item)
    @party_leader.item_apply(@party_leader,item)
    $game_player.sprite.dispose_animation
    $game_player.animation_id = item.animation_id
    @party_leader.use_item(item)
  end
  
  def self.execute_skill(skill, target = nil)
    #gets target list
    return if @target.nil?
    #gets curent actor and L2 or R2 skill and range of  skill
    player = $game_player
    
    
    #selects only targets that are in-range of skill and sorts them
    @party_leader.pay_skill_cost(skill) #deplents mp or tp and checks scope of skill and
    animation = skill.animation_id
    @target = target if target
    case skill.scope
    when 0 #none
      user.item_apply(@party_leader,skill)
    when 1,2,3,4,5,6 #one enemy
      if skill.targeted
        @map_troop.alive_members.each do |enemy|
          next if @target.distance_from(enemy) > skill.aoe
          enemy.monster.item_apply(@party_leader,skill)
          print_messages(enemy,@party_leader)
          enemy.sprite.dispose_animation
          enemy.animation_id = animation 
        end
      else
        front_line = get_front_line($game_player, skill.range, skill.aoe)
        @map_troop.close_members(skill.range).each do |enemy|
          next unless front_line.include?([enemy.x,enemy.y])
          enemy.monster.item_apply(@party_leader,skill)
          print_messages(enemy,@party_leader)
          enemy.sprite.dispose_animation
          enemy.animation_id = animation == -1 ? @party_leader.atk_animation_id1 : animation
        end
      end
    when 7,8,11 #one ally, all allies, the user
      @party_leader.item_apply(@party_leader, skill)
      player.sprite.dispose_animation
      player.animation_id = animation
    end
    
    @party_leader.skills_cd[skill.id] = 0
  end
  #--------------------------------------------------------------------------
  # * Enemy Attack
  #--------------------------------------------------------------------------
  def self.find_target(user, skill)
    enemy = user.monster
    
    allies = Array.new(@map_troop.enemies)
    allies.reject! { |i| user.distance_from(i) > skill.range }
    #allies.reject! { |i| !enemy.target_history.include?(i) }
    
    if skill.damage.recover?
      if skill.scope == 9
        allies.reject! { |i| !i.dead? } 
        return allies[rand(allies.length)]
        #enemy.target_history << allies[rand(allies.length)]
      else
        allies.reject! {|i| i.dead? }
        allies.sort! { |i,j| i.monster.hp <=> j.monster.hp } 
        #enemy.target_history << allies[0]
        return allies[0]
      end
    elsif skill.damage.none? && !skill.for_opponent?
      #target = allies[rand(allies.length)]
      #enemy.target_history << target
      return allies[rand(allies.length)]
    end
    
  end
  
  def self.temp_damage_val(user, item)
    value = item.damage.eval(user, @party_leader, $game_variables)
    value *= user.item_element_rate(user, item)
    value *= user.pdr if item.physical?
    value *= user.mdr if item.magical?
    value *= user.rec if item.damage.recover?
    value = user.apply_critical(value) 
    value = user.apply_variance(value, item.damage.variance)
    return value
  end
  
  def self.execute_enemy_skill(user,skill)
    return if skill.nil?
    return if user.interrupted || !user.monster.skill_cost_payable?(skill)
    return unless user.monster.skills_cd[skill.id] == $data_skills[skill.id].cooldown
    if skill.scope.between?(1,6) && user.distance > skill.range
      user.attack_cd = 0
      user.monster.action_history[skill] = true
      return
    end
    
    actor = @party_leader
    
    allies = Array.new(@map_troop.enemies)
    allies.delete(user)
    
    allies.reject!{ |i| user.distance_from(i) > skill.range } 
    
    allies.sort! { |i,j| user.distance_from(i) <=> user.distance_from(j)} if allies.length > 1
    
    closest_ally_distance = allies[0] ? user.distance_from(allies[0]) : 0
    user.monster.skills_cd[skill.id] = 0
    return if skill.scope.between?(7,10) && (allies.empty?) || closest_ally_distance > skill.range
    user.monster.action_history[skill] = true
    user.attack_cd = 0
    @action_battlers.rotate!
    
    case skill.scope
    when 1,2,3,4,5,6 #one enemy
      actor.item_apply(user.monster,skill)
      $game_player.sprite.dispose_animation
      $game_player.animation_id = skill.animation_id
      $game_player.increment_hits
      result = actor.result
      print_messages($game_player,user) 
      user.monster.pay_skill_cost(skill)
      #push_player_back(user) 
      #push_player_back(user) 
    when 7 #one ally
      target = find_target(user,skill)
      return unless target
      target.monster.item_apply(user.monster, skill)
      target.sprite.dispose_animation
      target.animation_id = skill.animation_id
      user.monster.pay_skill_cost(skill)
    when 8 #all allies
      allies.each do |ally|
        ally.monster.item_apply(user.monster,skill)
        ally.sprite.dispose_animation
        ally.animation_id = skill.animation_id
      end
      user.monster.pay_skill_cost(skill)
    when 9 #one ally(dead)
      #NEEDS FIXING
      target = find_target(user, skill)
      return unless target
      target.monster.item_apply(user.monster,skill)
      target.sprite.dispose_animation
      target.animation_id = skill.animation_id
      target.revive
      user.monster.pay_skill_cost(skill)
    when 10 #all allies(dead)
      allies.select! { |i| i.dead? }
      allies.each do |ally|
        ally.monster.item_apply(@monster,skill)
        ally.sprite.dispose_animation
        ally.animation_id = skill.animation_id
        ally.revive
      end
      user.monster.pay_skill_cost(skill)
    when 11 #the user
      user.monster.item_apply(user.monster,skill)
      user.sprite.dispose_animation
      user.animation_id = skill.animation_id
      user.monster.pay_skill_cost(skill)
    end
    user.monster.skills_cd[skill.id]= 0
  end
  
  def self.enemy_attack_seq(user)
    return unless inrange?(user)
    return if user.interrupted || $game_player.down
    return unless user.attack_cd >= user.monster.attack_speed
    
    user.monster.action_history[$data_skills[1]] = true
    
    @action_battlers.rotate!
    @party_leader.attack_apply(user.monster)
    result = @party_leader.result
    if $game_player.jumping?
      result.evaded = true
      print_messages($game_player,user) 
      user.attack_cd = 0
      return
    end
    if result.missed
      print_messages($game_player,user)
      user.attack_cd = 0
      return
    end
    
    if result.critical
      print_messages($game_player,user)  
    end
    
    print_messages($game_player,user)  
    
    #user.move_toward_player
    #push_player_back(user) 
    if $game_player.animation_id != PLAYER_LVLUP_ANIM_ID
      $game_player.sprite.dispose_animation 
      $game_player.animation_id = user.attack_animation
    end
    $game_player.increment_hits
    Audio.se_play("Audio\\SE\\V_Damage2") if @party_leader.hp != 0
    user.attack_cd = 0
  end
  
  def self.enemy_attack_seq_range(user)
    @action_battlers.rotate!
    if $game_player.jumping?
      print_messages($game_player,user) 
      return
    end
    
    @party_leader.attack_apply(user.monster)
    result = @party_leader.result
    if result.missed
      print_messages($game_player,user)
      return
    end
    
    if result.critical
      print_messages($game_player,user)  
    end
    
    print_messages($game_player,user)  
    
    $game_player.sprite.dispose_animation
    $game_player.animation_id = user.attack_animation
    Audio.se_play("Audio\\SE\\V_Damage2") if @party_leader.hp != 0
  end
  
  def self.inrange?(user)
    front_line = get_front_line(user)
    player = $game_player
    return front_line.include?([player.x,player.y])
  end
  
  def self.push_target_back(user,target)
    target.set_direction_fix(true)
    dir = target.direction
    target.move_straight(user.direction,false)
    target.set_direction_fix
  end
  #--------------------------------------------------------------------------
  # * Damages targets that are inrange of attack
  #--------------------------------------------------------------------------
  def self.check_dead
    return if @party_leader.hp > 0
    return if $game_player.animation_id > 0
    Audio.se_play("Audio\\SE\\V_Defeat2") if !@party_leader.death_state?
    $game_system.refresh_hud = true
    @party_leader.add_state(@party_leader.death_state_id)
    $game_player.sprite.dispose_animation
    $game_player.animation_id = 110
    process_defeat
    change_leader
    $game_party.rotate_order
    #$game_player.sprite.set_animation_rate
  end
  
  def self.print_messages(target,user)
    target_result = target.is_a?(Game_Event) ? target.monster.result : @party_leader.result
    @spriteset_abs.add_damage("Miss!",user,60) if target_result.missed
    @spriteset_abs.add_damage("Evade!",target,60) if target_result.evaded
    @spriteset_abs.add_damage("-#{target_result.hp_damage}",target,60) unless target_result.missed || target_result.evaded
    @spriteset_abs.add_damage("Critical!",user,60) if target_result.critical
  end
  #--------------------------------------------------------------------------
  # * Processing at Encounter Time
  #--------------------------------------------------------------------------
  def self.on_encounter
    @surprise = (rand < rate_surprise && !@preemptive)
  end
  #--------------------------------------------------------------------------
  # * Get Probability of Surprise
  #--------------------------------------------------------------------------
  def self.rate_surprise
    $game_party.rate_surprise($game_troop.agi)
  end
  #--------------------------------------------------------------------------
  # * Save BGM and BGS
  #--------------------------------------------------------------------------
  def self.save_bgm_and_bgs
    @map_bgm = RPG::BGM.last
    @map_bgs = RPG::BGS.last
  end
  #--------------------------------------------------------------------------
  # * Play Battle BGM
  #--------------------------------------------------------------------------
  def self.play_battle_bgm
    $game_system.battle_bgm.play
    RPG::BGS.stop
  end
  #--------------------------------------------------------------------------
  # * Play Battle End ME
  #--------------------------------------------------------------------------
  def self.play_battle_end_me
    $game_system.battle_end_me.play
  end
  #--------------------------------------------------------------------------
  # * Resume BGM and BGS
  #--------------------------------------------------------------------------
  def self.replay_bgm_and_bgs
    @map_bgm.replay unless $BTEST
    @map_bgs.replay unless $BTEST
  end
  #--------------------------------------------------------------------------
  # * Determine if Turn Is Executing
  #--------------------------------------------------------------------------
  def self.in_turn?
    @phase == :turn
  end
  #--------------------------------------------------------------------------
  # * Determine if Turn Is Ending
  #--------------------------------------------------------------------------
  def self.turn_end?
    @phase == :turn_end
  end
  #--------------------------------------------------------------------------
  # * Determine if Battle Is Aborting
  #--------------------------------------------------------------------------
  def self.aborting?
    @phase == :aborting
  end
  #--------------------------------------------------------------------------
  # * Get Whether Escape Is Possible
  #--------------------------------------------------------------------------
  def self.can_escape?
    @can_escape
  end
  #--------------------------------------------------------------------------
  # * Set Wait Method
  #--------------------------------------------------------------------------
  def self.method_wait_for_message=(method)
    @method_wait_for_message = method
  end
  #--------------------------------------------------------------------------
  # * Wait Until Message Display has Finished
  #--------------------------------------------------------------------------
  def self.wait_for_message
    @method_wait_for_message.call if @method_wait_for_message
  end
  #--------------------------------------------------------------------------
  # * An Enemy is Killed 
  #--------------------------------------------------------------------------
  def self.killed_enemy(enemy)
    display_exp(enemy)
    gain_gold(enemy)
  end
  
  def self.display_exp(enemy)
    display_time = 120
    gain_exp(enemy.monster.exp)
    if enemy.monster.exp > 0
      @spriteset_abs.add_exp_gold(enemy.monster.exp.to_s + "EXP" ,enemy,display_time,0,20)
    end
  end
  
  def self.gain_gold(enemy)
    display_time = 120
    if enemy.monster.gold > 0
      @spriteset_abs.add_exp_gold(enemy.monster.gold.to_s + "G" ,enemy,display_time)
      $game_party.gain_gold(enemy.monster.gold)
    end
  end
  #--------------------------------------------------------------------------
  # * Battle Start
  #--------------------------------------------------------------------------
  def self.battle_start
    $game_system.battle_count += 1
    $game_party.on_battle_start
    $game_troop.on_battle_start
    $game_troop.enemy_names.each do |name|
      $game_message.add(sprintf(Vocab::Emerge, name))
    end
    if @preemptive
      $game_message.add(sprintf(Vocab::Preemptive, $game_party.name))
    elsif @surprise
      $game_message.add(sprintf(Vocab::Surprise, $game_party.name))
    end
  end
  #--------------------------------------------------------------------------
  # * Defeat Processing 
  #--------------------------------------------------------------------------
  def self.process_defeat
    return unless all_dead? || @cant_lose
    #$game_message.add(sprintf(Vocab::Defeat, $game_party.name))
    #wait_for_message
    @spriteset_abs.dispose_all
    SceneManager.goto(Scene_Gameover)
    return true
  end
  #--------------------------------------------------------------------------
  # * Revive Battle Members (When Defeated)
  #--------------------------------------------------------------------------
  def self.revive_battle_members
    $game_party.battle_members.each do |actor|
      actor.hp = 1 if actor.dead?
    end
  end
  
  def self.in_battle
    return false if !@map_troop || @map_troop.alive_members.empty?
    return @map_troop.alive_members.min{|x,y| x.distance<=>y.distance }.distance <= PLAYER_SIGHT
  end
  #--------------------------------------------------------------------------
  # * Start Turn
  #--------------------------------------------------------------------------
  def self.turn_start
    @phase = :turn
    make_action_orders
  end
  #--------------------------------------------------------------------------
  # * End Turn
  #--------------------------------------------------------------------------
  def self.turn_end
    @phase = :turn_end
    @preemptive = false
    @surprise = false
  end
  #--------------------------------------------------------------------------
  # * Dropped Item Acquisition and Display
  #--------------------------------------------------------------------------
  def self.gain_drop_items
    $game_troop.make_drop_items.each do |item|
      $game_party.gain_item(item, 1)
      $game_message.add(sprintf(Vocab::ObtainItem, item.name))
    end
  end
  #--------------------------------------------------------------------------
  # * EXP Acquisition and Level Up Display 
  #--------------------------------------------------------------------------
  def self.gain_exp(exp_points)
    @party_leader.gain_exp(exp_points)
    $game_system.refresh_hud = true
  end
  #--------------------------------------------------------------------------
  # * Create Action Order
  #--------------------------------------------------------------------------
  def self.make_action_orders
    @action_battlers = []
    @action_battlers += @map_troop.alive_members
    @action_battlers.select!{ |battler| battler.battling }
    @action_battlers.select!{ |battler| battler.distance <= battler.monster.attack_range } 
    @action_battlers.each {|battler| battler.monster.make_speed }
    @action_battlers.sort! {|a,b| b.monster.speed - a.monster.speed }
  end
  #--------------------------------------------------------------------------
  # * Force Action
  #--------------------------------------------------------------------------
  def self.force_action(battler)
    @action_forced = battler
    @action_battlers.delete(battler)
  end
  #--------------------------------------------------------------------------
  # * Clear Forcing of Battle Action
  #--------------------------------------------------------------------------
  def self.clear_action_force
    @action_forced = nil
  end
  #--------------------------------------------------------------------------
  # * Checks if All Actors are dead 
  #--------------------------------------------------------------------------
  def self.all_dead?
    $game_party.members.each do |i|
      return false if i.hp > 0
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Get Next Action Subject
  #    Get the battler from the beginning of the action order list.
  #    If an actor not currently in the party is obtained (occurs when index
  #    is nil, immediately after escaping in battle events etc.), skip them.
  #--------------------------------------------------------------------------
  def self.next_subject
    loop do
      battler = @action_battlers.shift
      return nil unless battler
      next unless battler.index && battler.alive?
      return battler
    end
  end
end

#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==============================================================================
class Map_Troop < Game_Troop
  #--------------------------------------------------------------------------
  # * Characters to be added to the end of enemy names
  #--------------------------------------------------------------------------
  LETTER_TABLE_HALF = [' A',' B',' C',' D',' E',' F',' G',' H',' I',' J',
                       ' K',' L',' M',' N',' O',' P',' Q',' R',' S',' T',
                       ' U',' V',' W',' X',' Y',' Z']
  LETTER_TABLE_FULL = ['Ａ','Ｂ','Ｃ','Ｄ','Ｅ','Ｆ','Ｇ','Ｈ','Ｉ','Ｊ',
                       'Ｋ','Ｌ','Ｍ','Ｎ','Ｏ','Ｐ','Ｑ','Ｒ','Ｓ','Ｔ',
                       'Ｕ','Ｖ','Ｗ','Ｘ','Ｙ','Ｚ']
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :screen                   # battle screen state
  attr_reader   :interpreter              # battle event interpreter
  attr_reader   :event_flags              # battle event executed flag
  attr_reader   :name_counts              # hash for enemy name appearance
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    clear
  end
  #--------------------------------------------------------------------------
  # * Get Members
  #--------------------------------------------------------------------------
  def close_members(range, dead = false)
    dead ? enemies.select{ |enemy| enemy.distance <= range } :
    alive_members.select{ |enemy| enemy.distance <= range }
  end
  
  def alive_members
    @enemies.select { |enemy| !enemy.dead? }
  end
  
  def dead_members
    @enemies.select { |enemy| enemy.dead? }
  end
  
  def enemies
    @enemies
  end
  #--------------------------------------------------------------------------
  # * Clear
  #--------------------------------------------------------------------------
  def clear
    @enemies = []
    @names_count = {}
  end
  #--------------------------------------------------------------------------
  # * Get Troop Objects
  #--------------------------------------------------------------------------
  def troop
    $data_troops[@troop_id]
  end
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(map)
    clear
    map.events.each do |i, event|
      next unless map.events[i].is_enemy?
      map.events[i].setup_enemy
      #map.events[i].reset_switches
      @enemies << map.events[i]
    end
    make_unique_names
  end
  #--------------------------------------------------------------------------
  # * Add letters (ABC, etc) to enemy characters with the same name
  #--------------------------------------------------------------------------
  def make_unique_names
    enemies.each do |enemy|
      next if enemy.dead?
      next unless enemy.monster.letter.empty?
      n = @names_count[enemy.monster.original_name] || 0
      enemy.monster.letter = letter_table[n % letter_table.size]
      @names_count[enemy.monster.original_name] = n + 1
    end
  end
  #--------------------------------------------------------------------------
  # * Get Text Table to Place Behind Enemy Name
  #--------------------------------------------------------------------------
  def letter_table
    LETTER_TABLE_FULL
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Name Array
  #    For display at start of battle. Overlapping names are removed.
  #--------------------------------------------------------------------------
  def enemy_names
    names = []
    members.each do |enemy|
      next if enemy.dead?
      next if names.include?(enemy.monster.original_name)
      names.push(enemy.original_name)
    end
    names
  end
end

class Game_CharacterBase
  attr_accessor :through
end

class Sprite_Character < Sprite_Base
  def start_balloon
    dispose_balloon
    @balloon_duration = 8 * balloon_speed + balloon_wait
    @balloon_sprite = ::Sprite.new(viewport)
    @balloon_sprite.bitmap = Cache.system("Balloon")
    @balloon_sprite.ox = 16
    offset_y = @character.is_a?(Game_Player) ? 58 : 0
    @balloon_sprite.oy = 32 - offset_y
    update_balloon
  end
end

class Sprite_Base 
  #--------------------------------------------------------------------------
  # * Changes the size of the animation frames
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    cell_data = frame.cell_data
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.bitmap = pattern < 100 ? @ani_bitmap1 : @ani_bitmap2
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @ani_mirror
        sprite.x = @ani_ox - cell_data[i, 1]
        sprite.y = @ani_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @ani_ox + cell_data[i, 1]
        sprite.y = @ani_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 300.0
      sprite.zoom_y = cell_data[i, 3] / 300.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
end
#-------------------------------------------------------------------------------
# * Game_Battler
#   *attack_apply and item_apply edit
#     *if player hits more than one enemy with a single hit, the result of the
#    first enemy hits will be stored and used for the rest enemies. 
#       If the result of the first enemy is miss/evade means that the hit 
#    that was missed/evaded will be a missed/evaded for the rest enemies.
#-------------------------------------------------------------------------------
class Game_Battler < Game_BattlerBase
  def attack_apply(attacker, result = nil)
    item_apply(attacker, $data_skills[attacker.attack_skill_id], result)
  end
  
  alias item_apply_result item_apply
  def item_apply(user, item, result = nil)
    if result.nil?
      item_apply_result(user,item)
    else
      @result = result
      if @result.hit?
        unless item.damage.none?
          execute_damage(user)
        end
        item.effects.each {|effect| item_effect_apply(user, item, effect) }
        item_user_effect(user, item)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Processing at End of Turn
  #--------------------------------------------------------------------------
  def on_turn_end
    @result.clear
    regenerate_all
    update_state_turns
    update_buff_turns
    remove_states_auto(2)
    remove_buffs_auto
  end
end
#-------------------------------------------------------------------------------
# * Game_Character
#   *Edit to dispose animation of the sprite.
#-------------------------------------------------------------------------------
class Scene_Map < Scene_Base
  attr_accessor :spriteset
end

class Spriteset_Map
  attr_accessor :character_sprites
  attr_reader   :viewport1
end

class Game_Character < Game_CharacterBase
  def sprite
    return if SceneManager.scene.is_a?(Scene_Gameover)
    SceneManager.scene.spriteset.character_sprites.find{ |i| i.character == self }
  end
end

#-------------------------------------------------------------------------------
# * Game_BattlerBase
#     *removed @hp == 0 ? add_state(death_state_id) : remove_state(death_state_id)
#   so that it does not apply the death state before fully updating hp bar etc
#   when enemy is dead
#-------------------------------------------------------------------------------

class Game_BattlerBase
  def refresh
    state_resist_set.each {|state_id| erase_state(state_id) }
    @hp = [[@hp, mhp].min, 0].max
    @mp = [[@mp, mmp].min, 0].max
  end
end
#-------------------------------------------------------------------------------
# *Game_Party
#   *rotates the order of the party. If next party member to be the leader is 
#   dead then rotates once more untill it finds a non dead party member.
#     *rotation is done for a temporary array contaning the order so that the 
#     whole roatition between the members is not shown
#-------------------------------------------------------------------------------
class Game_Party < Game_Unit
  def rotate_order(reverse = false)
    return if $game_party.members.length == 1
    num = 1
    actors_temp = @actors
    for i in 1...actors_temp.length
      i = -i if reverse
      num += 1 if $game_actors[actors_temp[i]].death_state?
      break if !$game_actors[actors_temp[i]].death_state?
    end
    num = @actors.length - num if reverse
    actors_temp.rotate!(num)
    @actors = actors_temp
    $game_player.refresh
  end
end
#-------------------------------------------------------------------------------
# *Game_System
#   *Option to toggle between manual and automatic target lock on
#-------------------------------------------------------------------------------
class Game_System
  attr_accessor :manual_lockon
  
  alias fog_target_init initialize
  def initialize
    fog_target_init
    @manual_lockon = true
  end
end
#-------------------------------------------------------------------------------
# *Game_Player
#   *Variable that shows if the player is locking on
#-------------------------------------------------------------------------------
class Game_Player < Game_Character #lock on target
  attr_accessor   :locking_on

  alias fog_target_init initialize
  def initialize
    @locking_on = false         #if player is currently loccking on a target
    fog_target_init
  end
end
#-------------------------------------------------------------------------------
# *Game_Actor
#   *Changes the character_name(graphic_name) of the actor
#-------------------------------------------------------------------------------
class Game_Actor < Game_Battler
  def change_graphic(name)
    return if @character_name == name
    begin 
      Cache.character(name)
    rescue
      puts "Character graphic not found."
      return
    end
    @character_name = name
    @character_index = 0
    refresh
    $game_player.refresh
  end
end
#-------------------------------------------------------------------------------
# *Game_Player
#   *attacking_frame_duration: duration of the attack animation. Depends on the 
#     attack speed of the actor class
#   *attacking_current_frame: acts like a flag and a counter. If it is -1 attack
#     animation is not played. When higher starts playing attack animation. Each
#     frame lasts attack_speed/3 frames
#   *attacking_graphic_frame: current attack animation frame
#   *When the attack animation is finished attacking_current_frame is set to -1
#     and the sprite of the player in the Spriteset is reset.
#-------------------------------------------------------------------------------
class Game_Player < Game_Character #lock on target
  attr_accessor :attacking_current_frame
  alias attack_duration_init initialize
  def initialize
    @attacking_frame_duration = 0
    @attacking_current_frame  = -1
    @attacking_graphic_frame  = 0
    attack_duration_init
  end
  
  def attacking?
    return false unless FogBattleManager.party_leader.atk_cd >= FogBattleManager.party_leader_class.attack_speed + FogBattleManager.party_leader.delay
    return false if $game_message.visible || $game_player.choosing_skill?
    return false if @down || @interrupted || @cannot_move
    return WolfPad.trigger?(:A)
  end
  
  def start_attack_animation
    if @attacking_current_frame < 0
      @attacking_current_frame += 1 
      FogBattleManager.play_attack_sound
    end
  end
  
  def frame_attacking
    return if @attacking_current_frame == -1
    @attacking_frame_duration = $data_classes[FogBattleManager.party_leader.class_id].attack_speed / 3
    @attacking_current_frame += 1
    if @attacking_current_frame == @attacking_frame_duration
      @attacking_graphic_frame += 1
      @attacking_current_frame = 0
    end
    if @attacking_graphic_frame > 2
      @attacking_current_frame = -1
      @attacking_graphic_frame = 0
      
      $game_player.sprite.set_character_bitmap
      $game_player.sprite.update
      
      refresh
      return
    end
    dir = @direction 
    dir = dir == 2 ? 0 : dir == 4 ? 1 : dir == 6 ? 2 : 3
    weapon = FogBattleManager.party_leader.equips[0].wtype_id
    case weapon
    when 1
      weapon = "Axe"
    when 3
      weapon = "Spear"
    else
      weapon = "Atk"
    end
    char = Cache.character("$#{FogBattleManager.party_leader.name}_#{weapon}")
    bitmap = Bitmap.new(char.width / 3, char.height / 4)
    rect = Rect.new(@attacking_graphic_frame * bitmap.width,dir * bitmap.height,bitmap.width, bitmap.height)
    bitmap.blt(0,0,char,rect)
    sprite.bitmap = bitmap
  end
end
#-------------------------------------------------------------------------------
# *Game_Enemy
#   *Gets attack_speed and range of the RPG::Enemy from the database
#-------------------------------------------------------------------------------
class Game_Enemy < Game_Battler
  attr_reader :attack_speed
  alias fog_abs_init initialize
  def initialize(index, enemy_id)
    fog_abs_init(index, enemy_id)
    @attack_speed = enemy.attack_speed
  end
  
end
#-------------------------------------------------------------------------------
# *Game_Event
#   *Contains the Game_Enemy. Initializes all parameters required for battle 
#     sequence. Updates distance from the player. When dead changes graphic
#     to drop item and checks if picked.
#-------------------------------------------------------------------------------
class Game_Event < Game_Character
  attr_reader :level, :sight_range, :attack_animation, :battle_key, :distance
  attr_reader :death_key
  attr_accessor :battling, :can_attack, :monster, :attack_cd
  
  def setup_enemy
    @death_key = [$game_map.map_id, self.id]
    if $game_dead_enemies[@death_key]
      erase
      return
    end
    enemy_id = @event.name =~ /<Enemy(\d+)>/ ? $1.to_i : 0
    @monster = Game_Enemy.new(0,enemy_id)
    @battle_key = [$game_map.map_id, self.id, "A"] 
    @drop_key = [$game_map.map_id, self.id, "B"]
    @level = $data_enemies[enemy_id].level
    @sight_range = $data_enemies[enemy_id].sight_range
    @items_dropped = []        
    @battling = false
    @can_attack = true
    @attack_delay = $data_enemies[enemy_id].attack_speed
    @attack_cd = 0
    @attack_animation = $data_enemies[enemy_id].note =~ /<Attack Animation: (\d+)>/ ?  $1.to_i : 36
    @death_animation = $data_enemies[enemy_id].note =~ /<Death Animation: (\d+)>/ ?  $1.to_i : 69
    update_distance
  end
  
  def dead?
    $game_dead_enemies[@death_key]
  end
  
  def update_distance
    @distance = ($game_player.x - self.x).abs + ($game_player.y - self.y).abs
  end
  
  def is_enemy?
    @event.name =~ /<Enemy(\d+)>/ ? true : false
  end
  
  def erased?
    @erased
  end
  
  def reset_switches
    $game_self_switches[@battle_key] = false
    $game_self_switches[@drop_key] = false
    $game_dead_enemies[@death_key] = false
    self.refresh
  end
  
  def make_drop
    $game_self_switches[@drop_key] = true
    @items_dropped = @monster.make_drop_items
    refresh
    if @items_dropped.empty?
      erase
      refresh
      return
    else
      @icon_name = 260
    end
  end       
  
  def check_if_picked
    return if @items_dropped.empty?
    if $game_player.pos?(self.x,self.y)
      @items_dropped.each do |item|
        $game_party.gain_item(item, 1)
        FogBattleManager.spriteset_abs.item_received_queue("#{item.name} was found!")
      end
      RPG::SE.new("Key",100,100).play
      erase
      refresh
    end
  end
  
  def play_death_anim
    #sprite.dispose_animation
    if @animation_id > 0
      return false
    else
      @animation_id = @death_animation
      return true
    end
  end
  
end
#-------------------------------------------------------------------------------
# * Game_Map
#   *Revives enemy
#-------------------------------------------------------------------------------
class Game_Event < Game_Character
  def distance_from(event)
    return (@x - event.x).abs + (@y - event.y).abs
  end
  
  def revive
    @erased = false
    reset_switches
    setup_enemy
    @icon_name = nil
    refresh
  end
end
#-------------------------------------------------------------------------------
# *Game_System
#   *Difficulty of the game.
#-------------------------------------------------------------------------------
class Game_System
  attr_accessor :difficulty
  alias fog_difficulty_init initialize
  def initialize
    fog_difficulty_init
    @difficulty = 1         #0 = easy, 1 = normal, 2 = hard
  end
  
end
#-------------------------------------------------------------------------------
# *Game_BattlerBase
#   *changed usage of item and occasion
#-------------------------------------------------------------------------------
class Game_BattlerBase 
  def usable_item_conditions_met?(item)
    true && occasion_ok?(item)
  end
  
  def occasion_ok?(item)
    FogBattleManager.in_battle ? true : item.menu_ok?
  end
end
#-------------------------------------------------------------------------------
# *Game_Enemy
#   *initializes action_history and target_history of the enemy.
#     *action_history: an array containing the history of the actions done by 
#       the enemy
#     *target_history: array containing the history of the targets chose by enemy
#-------------------------------------------------------------------------------
class Game_Enemy < Game_Battler
  attr_accessor :action_history, :target_history, :skills_cd, :attack_range
  
  alias game_enemy_init initialize
  def initialize(index, enemy_id)
    @skills_cd = {}
    game_enemy_init(index, enemy_id)
    setup_skills_cd
    @action_history = {}
    @attack_range = $data_enemies[enemy_id].attack_range
  end
  
  def setup_skills_cd
    $data_enemies[@enemy_id].actions.each do |action|
      next if action.skill_id == 1
      @skills_cd[action.skill_id] = $data_skills[action.skill_id].cooldown
    end
  end
end
#-------------------------------------------------------------------------------
# *Game_Event
#   *empties action and target history if needed
#   *sets the next actions of the enemy and calls the method needed to perform it
#-------------------------------------------------------------------------------
class Game_Enemy < Game_Battler
  def make_actions
    super
    return if @actions.empty?
    action_list = enemy.actions.select {|a| action_valid?(a) }
    return if action_list.empty?
    rating_max = action_list.collect {|a| a.rating }.max
    rating_zero = rating_max - 3
    action_list.reject! {|a| a.rating <= rating_zero }
    @actions.each do |action|
      action.set_enemy_action(select_enemy_action(action_list, rating_zero))
      @action_history[action.item] = false
    end
  end
end

class Game_Event < Game_Character
  attr_accessor :attacker_list, :messages, :attack_cd
  include FOG_ABS_OPTIONS
  
  def update_action
    @monster.action_history = {} if @monster.action_history.length == $data_enemies[@monster.enemy_id].actions.length
    
    
    #FogBattleManager.decide_action(self) 

    @monster.make_actions
    
    #if @monster.action_history[@monster.action_history.keys[-1]] || @monster.action_history.empty?
    #  action = $data_skills[1]
    #else
      action = @monster.action_history.keys[-1] 
    #end
    
    if action == $data_skills[1]
      if @monster.attack_range == 1 
        FogBattleManager.enemy_attack_seq(self) 
      else
        if @attack_cd == @monster.attack_speed
          @monster.action_history[$data_skills[1]] = true
          $game_map.add_projectile(self)
          @attack_cd = 0
        end
      end
    else
      FogBattleManager.execute_enemy_skill(self,action)
    end
  end
  
end
#-------------------------------------------------------------------------------
# *Game_Character
#   *Sets direction fix
#-------------------------------------------------------------------------------
class Game_Character < Game_CharacterBase
  def set_direction_fix(fix = false)
    @direction_fix = fix
  end
end
#-------------------------------------------------------------------------------
# *Removes cost of TP needed and depletion
#-------------------------------------------------------------------------------
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Determine if Cost of Using Skill Can Be Paid ONLY MP USAGE
  #--------------------------------------------------------------------------
  def skill_cost_payable?(skill)
    mp >= skill_tp_cost(skill) && mp >= skill_mp_cost(skill)
  end
  #--------------------------------------------------------------------------
  # * Pay Cost of Using Skill
  #--------------------------------------------------------------------------
  def pay_skill_cost(skill)
    self.mp -= skill_mp_cost(skill)
    self.mp -= skill_tp_cost(skill)
  end
end
#-------------------------------------------------------------------------------
# *Game_Player
#   *Disables movement if player has one of the IMMOVABLE_STATES and pops a 
#     balloon
#-------------------------------------------------------------------------------
class Game_Player < Game_Character
  include FOG_ABS_OPTIONS
  alias states_immov initialize
  def initialize
    states_immov
    @cannot_move = false
    @bal_id = 0
  end
  
  alias disable_movement move_by_input
  def move_by_input
    if FogBattleManager.party_leader
      set_balloon
      has_immovale_state
    end
    return if @cannot_move
    disable_movement
  end
  
  def set_balloon
    return unless FogBattleManager.party_leader
    return if FogBattleManager.party_leader.states.empty?
    @bal_id = FogBattleManager.party_leader.states[0].note =~ /<Balloon_id: (\d+)>/ ? $1.to_i : 1
    $game_player.balloon_id = @bal_id
  end
  
  def has_immovale_state
    return unless FogBattleManager.party_leader
    FogBattleManager.party_leader.states.each do |i|
      if IMMOVABLE_STATES.include?(i.id)
        @cannot_move = true 
        return
      end
    end
    @cannot_move = false
  end
  
end

class Game_Character < Game_CharacterBase
  attr_accessor :icon_name
end

class Sprite_Character < Sprite_Base
  alias fog_drop_item_init initialize
  def initialize(viewport, character = nil)
    @up = 1
    @duration = 0
    @float_height = 0
    fog_drop_item_init(viewport, character)
  end
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------             
  alias fog_drop_item update
  def update
      fog_drop_item
      if @character.icon_name != nil && !@character.erased?
        bitmap = Cache.system("Drop_Items")
        rect = Rect.new(0, 0, 24, 24)
        self.bitmap.clear
        self.bitmap = Bitmap.new(24,24)
        self.bitmap.blt(0,0,bitmap,rect)
        self.ox = 12
        self.oy = 24
        
        @duration += 1 
        
        @float_height -= @up * 1 if @duration % 4 == 0
        self.y -= @float_height
        
        if @duration % 16 == 0
          @duration = 0
          @up = -@up
        end
      end
  end
  #--------------------------------------------------------------------------
  # * Move Animation
  #--------------------------------------------------------------------------
  def move_animation(dx, dy)
    if @animation && @animation.position != 3
      @ani_sprites.each do |sprite|
        sprite.x = @character.screen_x 
        sprite.y = @character.screen_y - 24
      end
    end
  end
end

class Game_Character < Game_CharacterBase
  def moving_pattern
    if $game_player.down
      move_away_from_player
    else
      move_toward_player
    end
  end
end

class Game_Player < Game_Character
  attr_reader :down
  include FOG_ABS_OPTIONS
  
  alias fall_down_init initialize
  def initialize
    fall_down_init  
    @hits_fall = PLAYER_HITS_THRESH
    @down = false
    @down_duration = PLAYER_FALL_DURATION
    @down_frame = 0
    @refresh_length = 60
  end
  
  def increment_hits
    @hits_fall -= 1
    @refresh_length = 60 
    @interrupted = true
    if @hits_fall == 0
      @direction_fix = true
      @down = true
      @hits_fall = PLAYER_HITS_THRESH
    end
  end
  
  alias fall_down_update update
  def update
    fall_down_update
    if @down 
      @down_duration -= 1
      if @down_duration == 0
        @down = false
        @direction_fix = false
        @hits_fall = PLAYER_HITS_THRESH
        @down_duration = PLAYER_FALL_DURATION
      end
    else 
      @refresh_length -= 1 if @refresh_length > 0
      if @refresh_length == 0 && @hits_fall < PLAYER_HITS_THRESH
        @refresh_length = 60
        @hits_fall += 1
      end
    end
  end
  
  alias fall_down_move move_by_input
  def move_by_input
    return if @down
    fall_down_move
  end
  
end

class Game_Actor < Game_Battler
  attr_accessor :atk_cd, :combo_num, :max_combo, :skills_cd, :delay
  
  alias fog_params_init initialize
  def initialize(actor_id)
    @skills_cd = {}
    fog_params_init(actor_id)
    @combo_num = 0              #number of combo hit
    @max_combo = 0
    @atk_cd = 0                 #cooldown for next attack in frames
    @delay = 0
  end
  
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
      @skills.push(skill_id)
      @skills.sort!
      @skills_cd[skill_id] = $data_skills[skill_id].cooldown
    end
  end
  
  alias forget_skill_cd forget_skill
  def forget_skill(skill_id)
    forget_skill_cd(skill_id)
    @skills_cd.delete(skill_id)
  end
  
  def update_skills_cd
    @skills_cd.each_key do |key|
      @skills_cd[key] += 1 if @skills_cd[key] < $data_skills[key].cooldown
    end
  end
  #--------------------------------------------------------------------------
  # * Change Experience
  #     show : Level up display flag
  #--------------------------------------------------------------------------
  def change_exp(exp, show)
    @exp[@class_id] = [exp, 0].max
    last_level = @level
    last_skills = skills
    level_up while !max_level? && self.exp >= next_level_exp
    $game_player.animation_id = FOG_ABS_OPTIONS::PLAYER_LVLUP_ANIM_ID  if @level > last_level
    $game_system.refresh_hud = true if @level > last_level
    level_down while self.exp < current_level_exp
    display_level_up(skills - last_skills) if true && @level > last_level
    refresh
  end
  
  #--------------------------------------------------------------------------
  # * Level Up
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level == @level
    end
  end
  
  #--------------------------------------------------------------------------
  # * Show Level Up Message
  #     new_skills : Array of newly learned skills
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
    $game_message.new_page
    FogBattleManager.spriteset_abs.item_received_queue(sprintf(Vocab::LevelUp, @name, Vocab::level, @level))
    new_skills.each do |skill|
      FogBattleManager.spriteset_abs.item_received_queue(sprintf(Vocab::ObtainSkill, skill.name))
    end
  end
  
end

class Game_CharacterBase 
  alias fog_target_skill_up update
  def update
    return if FogBattleManager.selecting_target
    fog_target_skill_up
  end
end

class Game_Character < Game_CharacterBase
end

class Game_Event < Game_Character
  attr_reader :interrupted
  
  alias setup_interruption setup_enemy
  def setup_enemy
    setup_interruption
    return if dead?
    @interrupt_duration = ENEMY_INTER_DURATION
    @interrupted = false
  end
  
  def interrupted=(v)
    @interrupted = v
    @interrupt_duration = 30
  end
  
  alias interrupt_update update
  def update
    interrupt_update
    interrupt_proc if @interrupted
  end
  
  def interrupt_proc
    @interrupt_duration -= 1
    @attack_cd = 0
    if @interrupt_duration == 0
      @interrupted = false
      @interrupt_duration = ENEMY_INTER_DURATION
    end
  end
end

class Game_Player < Game_Character
  attr_reader :interrupted
  
  alias interrupt_init initialize
  def initialize
    interrupt_init
    @interrupt_duration = PLAYER_INTER_DURATION
    @interrupted = false
  end
  
  def interrupted=(v)
    @interrupted = v
    @interrupt_duration = 30
    sprite.end_balloon if @balloon_id > 0
  end
  
  alias interrupt_update update
  def update
    interrupt_update
    interrupt_proc if @interrupted
  end
  
  def interrupt_proc
    @balloon_id = 5
    @interrupt_duration -= 1
    @attack_cd = 0
    if @interrupt_duration == 0
      @interrupted = false
      sprite.end_balloon 
      @interrupt_duration = PLAYER_INTER_DURATION
    end
  end
end

class Sprite_Character < Sprite_Base
  alias end_balloon_debug end_balloon
  def end_balloon
    end_balloon_debug
    @balloon_duration = 0
  end
end

class Game_CharacterBase
  attr_accessor :through
end

class Game_Event < Game_Character
  def name
    @event.name
  end
end

class Game_CharacterBase
  
  alias init_pub init_public_members
  def init_public_members
    init_pub
    @animation_q = []
  end
  
  def animation_q_add(id)
    @animation_q << id
    #@animation_q.each{ |i| puts i }
  end
  
  alias up_ani update_animation
  def update_animation
    if !@animation_q.empty? && @animation_id == 0
      @animation_id = @animation_q.shift
    end
    up_ani
    #update_anime_count
    #if @anime_count > 18 - real_move_speed * 2
    #  update_anime_pattern
    #  @anime_count = 0
    #end
  end
  
  #--------------------------------------------------------------------------
  # * Detect Collision with Event
  #--------------------------------------------------------------------------
  def collide_with_events?(x, y)
    $game_map.events_xy_nt(x, y).any? do |event|
      (event.name == "Barrier" && self.is_a?(Game_Event)) || 
      event.normal_priority? || self.is_a?(Game_Event)
    end
  end
end

class Game_Player < Game_Character
  
  def animation_qq_add(id)
    temp = Temp_Event.new(self,id)
  end
  
end

module DataManager
  class <<self
    alias create_deadenemies create_game_objects
    def create_game_objects
      create_deadenemies
      $game_dead_enemies = Game_DeadEnemies.new
    end
    #--------------------------------------------------------------------------
    # * Create Save Contents
    #--------------------------------------------------------------------------
    def make_save_contents
      contents = {}
      contents[:system]        = $game_system
      contents[:timer]         = $game_timer
      contents[:message]       = $game_message
      contents[:switches]      = $game_switches
      contents[:variables]     = $game_variables
      contents[:self_switches] = $game_self_switches
      contents[:actors]        = $game_actors
      contents[:party]         = $game_party
      contents[:troop]         = $game_troop
      contents[:map]           = $game_map
      contents[:player]        = $game_player
      contents[:dead_enemies]  = $game_dead_enemies
      contents
    end
    #--------------------------------------------------------------------------
    # * Extract Save Contents
    #--------------------------------------------------------------------------
    def extract_save_contents(contents)
      $game_system        = contents[:system]
      $game_timer         = contents[:timer]
      $game_message       = contents[:message]
      $game_switches      = contents[:switches]
      $game_variables     = contents[:variables]
      $game_self_switches = contents[:self_switches]
      $game_actors        = contents[:actors]
      $game_party         = contents[:party]
      $game_troop         = contents[:troop]
      $game_map           = contents[:map]
      $game_player        = contents[:player]
      $game_dead_enemies  = contents[:dead_enemies]
    end
  end
end


#==============================================================================
# ** Game_SelfSwitches
#------------------------------------------------------------------------------
#  This class handles self switches. It's a wrapper for the built-in class
# "Hash." The instance of this class is referenced by $game_self_switches.
#==============================================================================

class Game_DeadEnemies
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @data = {}
  end
  #--------------------------------------------------------------------------
  # * Get Self Switch 
  #--------------------------------------------------------------------------
  def [](key)
    @data[key] == true
  end
  #--------------------------------------------------------------------------
  # * Set Self Switch
  #     value : ON (true) / OFF (false)
  #--------------------------------------------------------------------------
  def []=(key, value)
    @data[key] = value
    on_change
  end
  #--------------------------------------------------------------------------
  # * Processing When Setting Self Switches
  #--------------------------------------------------------------------------
  def on_change
    $game_map.need_refresh = true
  end
end

#----------------------------------------------------
#--------------------GAME_EVENT----------------------
#-------------------Skill Assign---------------------
class Game_Actor < Game_Battler
  alias fog_skill_assign_init initialize
  def initialize(actor_id)
    fog_skill_assign_init(actor_id)
    @left2_skills = Array.new(4,$data_skills[127])
    @right2_skills = Array.new(4,$data_skills[127])
  end
  
  def left
    @left2_skills
  end
  
  def right
    @right2_skills
  end
  
  def change_skills(slot_num, skill, slot_side)
    case slot_side
    when :left2
      if @left2_skills.include?(skill)
        if skill == $data_skills[127]
          @left2_skills[slot_num] = $data_skills[127]
        else
          @left2_skills[@left2_skills.index(skill)], @left2_skills[slot_num] = @left2_skills[slot_num], @left2_skills[@left2_skills.index(skill)]
        end
      else
        @left2_skills[slot_num] = skill
      end
    when :right2
      if @right2_skills.include?(skill)
        if skill == $data_skills[127]
          @right2_skills[slot_num] = $data_skills[127]
        else
          @right2_skills[@right2_skills.index(skill)], @right2_skills[slot_num] = @right2_skills[slot_num], @right2_skills[@right2_skills.index(skill)]
        end
      else
        @right2_skills[slot_num] = skill
      end
    end
  end
  
end

class Window_MenuCommand < Window_Command
  #adds a new command to window skill command called "Assign Skills"
  def add_main_commands
    add_command(Vocab::item,   :item,   main_commands_enabled)
    add_command(Vocab::skill,  :skill,  main_commands_enabled)
    add_command("Quick Actions", :assign_skill, true)  
    add_command(Vocab::equip,  :equip,  main_commands_enabled)
    add_command(Vocab::status, :status, main_commands_enabled)
  end
  
end

class Scene_Menu < Scene_MenuBase
  #sets handler for assign skill command. Calls method command_assign_skill
  #when assign_skill is selected
  alias create_quick_window create_command_window
  def create_command_window
    create_quick_window
    @command_window.set_handler(:assign_skill,     method(:command_personal))
  end
  
  def on_personal_ok
    case @command_window.current_symbol
    when :skill
      SceneManager.call(Scene_Skill)
    when :assign_skill
      SceneManager.call(Scene_AssignSkills)
    when :equip
      SceneManager.call(Scene_Equip)
    when :status
      SceneManager.call(Scene_Status)
    end
  end
end

#==============================================================================
# ** Scene_Equip
#------------------------------------------------------------------------------
#  This class performs the equipment screen processing.
#==============================================================================

class Scene_AssignSkills < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_status_window
    create_side_window
    create_button_slots_window
    create_item_skills_window
    #create_items_window
  end
  #--------------------------------------------------------------------------
  # * Create Status Window
  #--------------------------------------------------------------------------
  def create_status_window
    #creates selected actor's status window. shows graphic hp mp class name etc.
    @status_window = Window_AssignSkillStatus.new(0, @help_window.height)
    @status_window.viewport = @viewport
    @status_window.actor = @actor
  end
  #--------------------------------------------------------------------------
  # * Create Side Command Window
  #--------------------------------------------------------------------------
  def create_side_window
    #creates command window. includes L2 and R2 options each showing
    #assigned skills
    wx = @status_window.width
    wy = @help_window.height
    ww = Graphics.width - @status_window.width
    @command_window = Window_AssignSkillsCommand.new(wx, wy, ww)
    @command_window.viewport = @viewport
    @command_window.help_window = @help_window
    @command_window.set_handler(:left2,    method(:command_left2))
    @command_window.set_handler(:right2, method(:command_right2))
    @command_window.set_handler(:cancel,   method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * Create Assignes Slot Window
  #--------------------------------------------------------------------------
  def create_button_slots_window
    #creates window that shows the assigned skills for each side (L2 R2)
    wx = @status_window.width
    wy = @command_window.y + @command_window.height
    ww = Graphics.width - @status_window.width
    wh = 5 * 24
    @slot_window = Window_AssignedSkills.new(wx, wy, ww, wh)
    @slot_window.viewport = @viewport
    @slot_window.help_window = @help_window
    @slot_window.actor = @actor
    @slot_window.set_handler(:ok,       method(:on_slot_ok))
    @slot_window.set_handler(:cancel,   method(:on_slot_cancel))
    @command_window.slot_window = @slot_window
  end
  
  def create_item_skills_window
    wx = @status_window.x
    wy = @status_window.y + @status_window.height
    ww = @status_window.width
    @item_skills_select = Window_Items_SkillsCommand.new(wx, wy, ww)
    @item_skills_select.viewport = @viewport
    @item_skills_select.help_window = @help_window
    @item_skills_select.set_handler(:items,   method(:command_items))
    @item_skills_select.set_handler(:skills,  method(:command_skills))
    @item_skills_select.set_handler(:cancel,  method(:on_item_skill_cancel))
    @item_skills_select.unselect
    @item_skills_select.deactivate
  end
  #--------------------------------------------------------------------------
  # * Create Skills Window
  #--------------------------------------------------------------------------
  def create_items_window(items)
    #creates window that includes all actor's skills
    @items_window.dispose if @items_window
    wx = 0
    wy = @item_skills_select.y + @item_skills_select.height
    ww = Graphics.width
    wh = Graphics.height - wy
    if items
      @items_window = Window_AllItems.new(wx, wy, ww, wh)
    else
      @items_window = Window_AllSkills.new(wx, wy, ww, wh)
      @items_window.actor = @actor
    end
    @items_window.viewport = @viewport
    @items_window.help_window = @help_window
    @items_window.set_handler(:ok,     method(:on_item_ok))
    @items_window.set_handler(:cancel, method(:on_item_cancel))
    @items_window.refresh
  end
  #--------------------------------------------------------------------------
  # * [Change Equipment] Command
  #--------------------------------------------------------------------------
  def command_left2
    @slot_window.activate
    @slot_window.select(0)
  end
  #--------------------------------------------------------------------------
  # * [Change Equipment] Command
  #--------------------------------------------------------------------------
  def command_right2
    @slot_window.activate
    @slot_window.select(0)
  end
  #--------------------------------------------------------------------------
  # * Slot [OK]
  #--------------------------------------------------------------------------
  def on_slot_ok
    @item_skills_select.activate
    @item_skills_select.select(0)
  end
  #--------------------------------------------------------------------------
  # * Slot [Cancel]
  #--------------------------------------------------------------------------
  def on_slot_cancel
    @slot_window.unselect
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # * Item [OK]
  #--------------------------------------------------------------------------
  def on_item_ok
    Sound.play_equip
    @actor.change_skills(@slot_window.index, @items_window.item, @slot_window.side)
    @items_window.deactivate
    @items_window.unselect
    @items_window.refresh
    @item_skills_select.unselect
    @slot_window.activate
    @slot_window.refresh
  end
  #--------------------------------------------------------------------------
  # * Item [Cancel]
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_skills_select.activate
    @items_window.unselect
    @items_window.deactivate
  end
  
  def command_skills
    create_items_window(false)
    @items_window.activate
    @items_window.select(0)
  end
  def command_items
    create_items_window(true) 
    @items_window.activate
    @items_window.select(0)
  end
  def on_item_skill_cancel
    @slot_window.activate
    @item_skills_select.unselect
    @items_window.unselect if @items_window
    @items_window.deactivate if @items_window
  end
end

#==============================================================================
# ** Window_EquipStatus
#------------------------------------------------------------------------------
#  This window displays actor parameter changes on the equipment screen.
#==============================================================================

class Window_AssignSkillStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @actor = nil
    @temp_actor = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 208
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    return 4
  end
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @actor
    draw_actor_face(@actor, 0, 0)
    fog_draw_actor_status(@actor)
  end
  #--------------------------------------------------------------------------
  # * Draw Simple Status
  #--------------------------------------------------------------------------
  def fog_draw_actor_status(actor)
    draw_actor_name(actor, 100, 0)
    draw_actor_class(actor, 100, line_height * 1)
    draw_actor_level(actor, 100, line_height * 2)
    draw_actor_icons(actor, 100, line_height * 3)
    #draw_actor_hp(actor, 0, 92 + line_height * 1 )
    #draw_actor_mp(actor, 0, 92 + line_height * 2 )
  end
end

#==============================================================================
# ** Window_EquipCommand
#------------------------------------------------------------------------------
#  This window is for selecting commands (change equipment/ultimate equipment
# etc.) on the skill screen.
#==============================================================================

class Window_Items_SkillsCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    @window_width = width
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Items", :items)
    add_command("Skills", :skills)
  end
  #--------------------------------------------------------------------------
  # * Set Current Side
  #--------------------------------------------------------------------------
  def update
    super
    #@slot_window.side = current_symbol if @slot_window
  end
end

#==============================================================================
# ** Window_EquipCommand
#------------------------------------------------------------------------------
#  This window is for selecting commands (change equipment/ultimate equipment
# etc.) on the skill screen.
#==============================================================================

class Window_AssignSkillsCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width)
    @window_width = width
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("L2", :left2)
    add_command("R2", :right2)
  end
  #--------------------------------------------------------------------------
  # * Set Current Side
  #--------------------------------------------------------------------------
  def update
    super
    @slot_window.side = current_symbol if @slot_window
  end
  #--------------------------------------------------------------------------
  # * Set Item Window
  #--------------------------------------------------------------------------
  def slot_window=(slot_window)
    @slot_window = slot_window
    update
  end
end

#==============================================================================
# ** Window_ItemList
#------------------------------------------------------------------------------
#  This window displays a list of party items on the item screen.
#==============================================================================

class Window_AssignedSkills < Window_Selectable
  attr_reader :side
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, font = false)
    super(x,y,width,height)
    @actor = nil
    @side = :none
    @data = []
    @font = font
  end
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Set Category
  #--------------------------------------------------------------------------
  def side=(side)
    return if @side == side
    @side = side
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    4
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    true
  end
  #--------------------------------------------------------------------------
  # * Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    case @side
    when :left2
      @actor.left.include?(item)
    when :right2
      @actor.right.include?(item)
    else
      false
    end
  end
  #--------------------------------------------------------------------------
  # * Create Item List
  #--------------------------------------------------------------------------
  def make_item_list
    @data = @side == :left2 ? @actor.left : @actor.right
    @data.push(nil) if include?(nil)
  end
  
  def update
    super
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index($game_party.last_item.object) || 0)
  end
  #--------------------------------------------------------------------------
  # * Draw Buttons Corresponding to each Skill
  #--------------------------------------------------------------------------
  def draw_all_skill_button
    item_max.times do |i|
      bitmap = Cache.system("Assign_Buttons")
      rect = Rect.new(i * 24, 0, 24, 24)
      contents.blt(0, i * 24, bitmap, rect)
    end
  end
  #--------------------------------------------------------------------------
  # * Display Skill in Active State?
  #--------------------------------------------------------------------------
  def enable?(item)
    if @actor
      if item.is_a?(RPG::Skill)
        @actor.usable?(item) || @actor.skill_cost_payable?(item) &&
        @actor.skills_cd[item.id] == item.cooldown
      else
        $game_party.item_number(item) > 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item Name
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    draw_icon(item.icon_index, x + 24, y, enabled) if !@font
    change_color(normal_color, enabled)
    contents.font.size = 16 if @font
    text_x = @font ? x - 24 : x
    draw_text(text_x + 48, y, width, line_height, item.name)
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      enable = @font ? enable?(item) : true
      draw_item_name(item, rect.x, rect.y,enable)
      draw_skill_cost(rect, item)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Skill Use Cost
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    draw_text(rect, sprintf(":%2d", $game_party.item_number(item)), 2)
  end
  
  def draw_skill_cost(rect, skill)
    if skill.is_a?(RPG::Item)
      draw_item_number(rect,skill)
      return
    end
    contents.font.size = 18 if @font
    if @actor.skill_tp_cost(skill) > 0
      change_color(tp_cost_color)
      draw_text(rect, @actor.skill_tp_cost(skill), 2)
    elsif @actor.skill_mp_cost(skill) > 0
      change_color(mp_cost_color)
      draw_text(rect, @actor.skill_mp_cost(skill), 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
    draw_all_skill_button
  end
end

#==============================================================================
# ** Window_SkillList
#------------------------------------------------------------------------------
#  This window is for displaying a list of available skills on the skill window.
#==============================================================================

class Window_AllSkills < Window_SkillList
  #attr_reader :items
  #--------------------------------------------------------------------------
  # * Create Skill List
  #--------------------------------------------------------------------------
  def make_item_list
    @data = @actor ? @actor.skills.select {|skill| include?(skill) } : []
    @data << $data_skills[127]
  end
  def items=(v)
    @items = v
    refresh
  end
  #--------------------------------------------------------------------------
  # * Include in Skill List? 
  #--------------------------------------------------------------------------
  def include?(item)
    true
  end
  #--------------------------------------------------------------------------
  # * Display Skill in Active State?
  #--------------------------------------------------------------------------
  def enable?(item)
    @actor 
  end
end

#==============================================================================
# ** Window_ItemList
#------------------------------------------------------------------------------
#  This window displays a list of party items on the item screen.
#==============================================================================

class Window_AllItems < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @category = :item
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # * Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    item.is_a?(RPG::Item) && !item.key_item?
  end
  #--------------------------------------------------------------------------
  # * Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    true
  end
  #--------------------------------------------------------------------------
  # * Create Item List
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $game_party.all_items.select {|item| include?(item) }
    @data.push($data_skills[127])
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index($game_party.last_item.object) || 0)
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
      draw_item_number(rect, item) if item.is_a?(RPG::Item)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Number of Items
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    draw_text(rect, sprintf(":%2d", $game_party.item_number(item)), 2)
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
end

class Game_Message
  def add(text)
    if text.start_with?("\\pop")
      text.gsub!("\\pop") { "" }
        FogBattleManager.spriteset_abs.item_received_queue(text)
    else
      @texts.push(text)
    end
  end
end

class Window_ItemsReceived < Window_Base
  attr_reader :dispose_await
  attr_accessor :visible_duration
  include FOG_ABS_OPTIONS
  
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
    RPG::SE.new("Chime2",100,150).play
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
    self.contents.font.size = 18
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
  
  def draw_item_received
    contents.draw_text(0,0,width,line_height,@item_received)
  end
end

