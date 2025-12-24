#===============================================================================
#
# Script Name: Shin Megami Tensei Demons Add-on for Persona System
# Author: vFoggy
# Description: 
#   WIP - This script modifies the Persona System to remove Persona-specific
#   commands and adapt it for how personas, or demons, in SMT work.
#
#   This script is intended to be used with the Persona System script.
#
# Notes:
#   - This script assumes that demons are treated as actors in the party,
#     similar to how personas are handled in the Persona System.
#   - Demons are treated as actors
#   - Every functionality of the original Persona System remains intact,
#     meaning that you could still use $game_party.add_persona_by_id(id)
#     to add personas, but this would break the game. Only use functionalities
#     that you actually need.
#   - The status window of the Persona System is applied to the actors now.
#   - What is disabled in this script:
#       - Persona commands in battle
#       - Persona command in menu
#       - Social Links command in menu
#       - Arcana command in menu
#       - Persona skills command in battle
#
#
# Instructions:
#   Place this script below the Persona System script in the script editor.
#
#===============================================================================

class Window_ActorCommand < Window_Command
  # Remove commands from actor command window
  def add_persona_command
  end

  def add_persona_skills_command
  end
end

class Window_MenuCommand < Window_Command
  # Remove persona command from menu command window
  def add_persona_command
  end
end

class Game_Party < Game_Unit
  def add_persona_by_id(persona_id, equip=false)
    if $game_personas[persona_id].nil? || !$game_personas[persona_id].is_persona?
      msgbox("There was an attempt to add a persona with an invalid ID (#{persona_id}) or one that is not a persona")
      return
    end
    # Basically the same, without the auto equip
    persona = $game_personas[persona_id]
    return if persona.nil?
    return if @personas.include?(persona)
    
    @personas.push(persona)

    $game_player.refresh
    $game_map.need_refresh = true
  end
  
  alias smt_add_actor add_actor
  def add_actor(actor_id)
    smt_add_actor(actor_id)
    add_persona_by_id(actor_id) if $data_actors[actor_id].is_persona?
  end

  alias smt_remove_actor remove_actor
  def remove_actor(actor_id)
    smt_remove_actor(actor_id)
    remove_persona_by_id(actor_id) if $data_actors[actor_id].is_persona?
  end
end

class Game_Personas
  # Redirect to Game_Actors
  def [](actor_id)
    $game_actors[actor_id]
  end
end

class Window_PersonaStatus < Window_Command
  # Patch to work with Scene_Status that expects an actor= method
  def actor=(actor)
    @persona = actor
    clear_command_list
    make_command_list
    refresh
  end
end

class Scene_Status < Scene_MenuBase
  alias smt_start start
  def start
    smt_start
    create_persona_status_window
  end

  def create_persona_status_window
    # Replace default status window with persona status window
    @status_window = Window_PersonaStatus.new(@actor)
    @status_window.set_handler(:cancel,   method(:return_scene))
    @status_window.set_handler(:pagedown, method(:next_actor))
    @status_window.set_handler(:pageup,   method(:prev_actor))
    @status_window.show
    @status_window.activate
  end
end

class Scene_Battle < Scene_Base
  # Remove persona commands to actor command window
  def add_persona_commands_to_actor_command_window
  end  
end

class Game_Actor < Game_Battler  
  def index
    # Revert to original index method
    $game_party.members.index(self)
  end
end

class Scene_Menu < Scene_MenuBase
  # Remove persona command from menu
  def add_persona_commands_to_command_window
  end
end

class Window_MenuCommand < Window_Command
  # Remove arcana command from menu command window
  def add_arcana_command
  end
end

class Scene_Menu < Scene_MenuBase
  # Remove social links command from menu
  def add_social_links_command
  end
end

class Window_FusionParents < Window_Personas
  def personas
    # Return all personas in party
    $game_party.personas
  end
  
  def command_enabled?(index)
    # skip checking for options from the original system
    return fusion_selection_valid?(index)
  end
end

class Scene_Fusion < Scene_Base
  def on_fuse_confirm
    # Remove fused persona re-equipping
    parents = @fuse_window.selected_personas
    parents_str = parents.collect{|p| p.name }.join(" + ")
    fusion_data = @fuse_window.result_data

    $game_message.add("Fused #{parents_str} into\n#{@status_window.persona.name}!")
    wait_for_message
    
    for persona in parents
      # Remove from party's personas
      $game_party.remove_persona_by_id(persona.id)
      # Remove as an actor from party
      $game_party.remove_actor(persona.id)
    end
    
    $game_party.add_actor(@status_window.persona.id)
    if Persona::REMOVE_CONDITION_ITEM_ON_FUSE
      item_id = fusion_data[:conditions][:item_id]
      $game_party.lose_item($data_items[item_id], 1) if !item_id.nil?
    end
    
    @extra_exp_window.close
    @status_window.close.deactivate.unselect
    @results_window.fusion_results_data = []
    @fuse_window.selected_personas.clear
    @exit_on_next_cancel = true
    @fuse_window.reset
    @choice = -1
    
    run_skill_forget_if_needed(@status_window.persona)
  end
end

