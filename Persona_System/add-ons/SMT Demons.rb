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

end

class Window_PersonaStatus < Window_Command
    # Patch to work with Scene_Status that expects an actor= method
    def actor=(actor)
        return if @actor == actor
        @persona = actor
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

class Window_MenuActor < Window_MenuStatus
end

class Scene_Battle < Scene_Base
    # Remove persona commands to actor command window
    def add_persona_commands_to_actor_command_window
    end  
end


class Scene_Menu < Scene_MenuBase
    # Remove persona command from menu
    def add_persona_commands_to_command_window
    end
end

