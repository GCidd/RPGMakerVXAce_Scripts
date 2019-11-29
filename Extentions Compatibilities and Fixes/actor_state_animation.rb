#===============================================================================
#
# Extention script for AMoonlessNight's AMN Actor Animations
# Author: vFoggy
# Description: 
#   Now items and skills can have a different animation if a specific actor is 
#   using it while under a specific state.
#   
#   Notetag:
#   <actor ani: actor_id animation_id state_id>
#   Using the above tag, when the actor with id actor_id uses the item/skill
#   and has a state with id state_id, the animation with id animation_id will 
#   play instead.
#
#===============================================================================
class RPG::UsableItem
    attr_reader :actor_state_ani
  
    def load_notetags_state_ani
      @actor_state_ani = {}
      note.split(/[\r\n]+/).each do |line|
        case line
        when /<actor[ -_]+ani:*\s+(\d+)\s+(\d+)(?:\s+(\d+))?>/i
          @actor_state_ani[$1.to_i] = [$2.to_i, $3.to_i]
        end
      end
    end
    
    alias fog_lnaa load_notetags_actor_ani
    def load_notetags_actor_ani
      fog_lnaa
      load_notetags_state_ani
    end
  end
  
  
  class Scene_Battle < Scene_Base
    alias fog_sna show_normal_animation
    def show_normal_animation(targets, animation_id, mirror = false)
      if @subject && @subject.is_a?(Game_Actor) && @subject.current_action && @subject.current_action.item
        item = @subject.current_action.item
        # if item/skill has a state animation for the user and
        # the required state is applied on the user
        if item.actor_state_ani.key?(@subject.id) &&
          !@subject.states.find{|s| s.id == item.actor_state_ani[@subject.id][1] }.nil?
            animation_id = item.actor_state_ani[@subject.id][0]
        elsif item.actor_ani.key?(@subject.id)
          # check for just actor animation (script's default behaviour)
          animation_id = @subject.current_action.item.actor_ani[@subject.id]
        end
      end
      amn_ani_scenebattle_shownormalanimation(targets, animation_id, mirror)
    end
end 
