#===============================================================================
# Script for Galv's Group Manager ver. 1.3
# Requested by: RpG LoVeR
# Script by: vFoggy
# What was added:
#   * If the party has 4 actors, any new actor that joins the party will be
#   moved to the first group (and removed from the party)
#   * Variable 6 stores the number of actors in the party (without the ones in
#   a group)
#   * Dead actors can not be moved to the group (indicated with a state icon)
#   * When actors are moved in a group, they are removed from the party and vice
#   versa
#   * If the party is full (4 actors) the player can't remove any actors from
#   the group
# Changed:
#   * remove_member function now takes the member that is going to be removed as
#   an argument.
#   * All actors are drawn in the party list window (those that are in the party
#   and those that are in the first group), so that the user can select an actor
#   and remove him from the group (as they will not be in the party anymore)
#===============================================================================
module FOG_OPTIONS
    VARIABLE_INDX = 6
  end
  
  class Game_Party < Game_Unit
    alias fog_init initialize
    def initialize
      fog_init
    end
   
    def add_actor(actor_id)
      @actors.push(actor_id) unless @actors.include?(actor_id) or @group[0].include?(actor_id)
      $game_player.refresh
      $game_map.need_refresh = true
      
      $game_variables[FOG_OPTIONS::VARIABLE_INDX] = members.length if members.count <= 4
      if members.count >= 5
        $game_party.group[0] << actor_id unless $game_party.group[0].include?(actor_id)
        remove_actor(actor_id)
      end
    end
   
    alias fog_ra remove_actor
    def remove_actor(actor_id)
      fog_ra(actor_id)
      $game_variables[FOG_OPTIONS::VARIABLE_INDX] = members.length if members.count <= 4
    end
  end
  
  class Scene_GroupManager < Scene_MenuBase
    def on_party_cancel
      check_members_in_groups
      check_min_group_members
      
      if @check_arrays.sort != @party_array.sort && Galv_Split::REQUIRE_GROUPED
        # Check all members have been distributed
        $game_temp.group_error = "All members must be in a group."
        show_error
      elsif @min_number_check == false
        # Check if all groups have minimum requirement of members filled
        $game_temp.group_error = "A group requires members."
        show_error
      elsif $game_party.all_dead?
        $game_temp.group_error = "At least one member in party must be alive."
        show_error
      elsif Galv_Split::REQUIRE_UNASSIGNED && !Galv_Split::REQUIRE_GROUPED
        # Check if at least 1 unassigned party member remains
        if @check_arrays.sort == @party_array.sort
          $game_temp.group_error = "One member must be unassigned."
          show_error
        else
          $game_party.saved_group[0] = @party_array.sort - @group_array.sort
          SceneManager.return
        end
      else
        $game_party.saved_group[0] = @party_array.sort - @group_array.sort
        SceneManager.return
      end
    end
    
    def on_party_ok
      check_if_locked
      indx = @party_window.index
      if indx >= $game_party.members.count
        g_indx = indx-$game_party.members.count
        g_id = $game_party.group[0][g_indx]
        member = $game_actors[g_id]
      else
        member = $game_party.members[indx]
      end
      if !member.alive?
        $game_temp.group_error = "Member is dead."
        show_error
        @party_window.deactivate
        return
      end
      
      check_if_locked
      if @locked_members.include?(member.id)
        $game_temp.group_error = "Member in locked group."
        show_error
        @party_window.deactivate
      else
        @party_index = @party_window.index
        @group_index = 0 if @group_index.nil?
        @party_window.deactivate
        @group_window.activate
        @group_window.select(@group_index)
      end
    end
   
    def member_action
      @g = @group_window.index
      @p = @party_window.index
      if @p >= $game_party.members.count
        @p -= $game_party.members.count
        member = $game_actors[$game_party.group[0][@p]]
      else
        member = $game_party.members[@p]
      end
      
      # Check if group locked
      if !$game_party.group_info[@g][2].nil?
        return Sound.play_buzzer if $game_party.group_info[@g][2] == true
      end
      
      if $game_party.group[@g].include?(member.id)
        if $game_party.members.count == 4
          $game_temp.group_error = "Party is full."
          show_error
          @group_window.deactivate
          return Sound.play_buzzer
        end
        remove_member(member)
        @party_index = $game_party.members.count-1
      else
        return Sound.play_buzzer if $game_party.group[@g].count >= max_members
        remove_from_all_groups if Galv_Split::ONLY_ONE_GROUP
        add_member
        @party_index = $game_party.members.count + $game_party.group[0].count-1
      end
      on_group_cancel
    end
   
    alias fog_am add_member
    def add_member
      fog_am
      $game_party.remove_actor($game_party.members[@p].id)
    end
   
    def remove_member(member)
      RPG::SE.new(Galv_Split::REM_SE[0], Galv_Split::REM_SE[1], Galv_Split::REM_SE[2]).play
      $game_party.group[@g] -= [member.id]
      $game_party.add_actor(member.id)
    end
  end
  
  class Window_Party_List < Window_Selectable
    alias fog_init initialize
    def initialize(data)
      super(party_x, (Graphics.height - 410) / 2, 96 + standard_padding * 2, 410)
      self.opacity = 255
      @index = 0
      @set = true
      @item_max = $game_party.members.count + $game_party.group[0].count
      refresh(data)
      select(0)
      activate
    end
   
    alias fog_r refresh
    def refresh(data)
      self.contents.clear
      self.contents = Bitmap.new(96, @item_max * 96)
      for i in 0...$game_party.members.count
         draw_item(i) unless i == nil
      end
      $game_party.group[0].each do |id|
        draw_group_item(id)
      end
    end
   
    def draw_item(index)
      x = 0
      y = (index) / col_max * 96
      check_item_max
      @mem = $game_party.members
      check_if_set(@mem[index].id)
      draw_party_face(@mem[index].face_name, @mem[index].face_index, x, y, @set, !@mem[index].alive?)
    end
   
    def draw_group_item(id)
      x = 0
      index = $game_party.group[0].index(id) + $game_party.members.count
      y = (index) / col_max * 96
      draw_face($game_actors[id].face_name, $game_actors[id].face_index, x, y, false)
    end
   
    def draw_party_face(face_name, face_index, x, y, enabled = true, dead = false)
      bitmap = Cache.face(face_name)
      b_x = face_index % 4 * 96 + 96
      b_y = face_index / 4 * 96 + 96
      txt_w = 12
      txt_h = 24
      party_index = y/96 + 1
      bitmap.draw_text(b_x-txt_w, b_y-txt_h, txt_w, txt_h, party_index.to_s)
      if dead
        icon_bitmap = Cache.system("Iconset")
        icon_index = 17 # death state index
        icon_rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
        bitmap.blt(b_x-96, b_y-24, icon_bitmap, icon_rect, 255)
        icon_bitmap.dispose
      end
      rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
      contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
      bitmap.dispose
    end
   
    def check_item_max
      @data_max = $game_party.members.count + $game_party.group[0].count
    end
   
    def item_max
      return @item_max == nil ? 0 : @item_max
    end
   
    alias fog_cis check_if_set
    def check_if_set(check)
      mem = $game_party.members.select{|mem| mem.id == check}[0]
      if !mem.alive?
        @set = false
        return
      end
      fog_cis(check)
    end
  end
  