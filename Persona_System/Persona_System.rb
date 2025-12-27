#-------------------------------------------------------------------------------
#  ____                                   __  __           _       _      
# |  _ \ ___ _ __ ___  ___  _ __   __ _  |  \/  | ___   __| |_   _| | ___ 
# | |_) / _ \ '__/ __|/ _ \| '_ \ / _` | | |\/| |/ _ \ / _` | | | | |/ _ \
# |  __/  __/ |  \__ \ (_) | | | | (_| | | |  | | (_) | (_| | |_| | |  __/
# |_|   \___|_|  |___/\___/|_| |_|\__,_| |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                                                         
# Persona Module
#-------------------------------------------------------------------------------
class RPG::Actor < RPG::BaseItem
  def is_persona?
    note =~ /<Persona>/ ? true : false
  end
  
  def users
    # list of actors that can use specific persona
    matches = /<User: (\d+(,\s*\d+)*)?>/.match(note)
    return Persona::DEFAULT_PERSONA_USERS if matches.nil?
    user_str = matches[1]
    user_str.split(",").collect{ |i| i.to_i }
  end
  
  def exlusive_persona_id
    note =~ /<Persona: (\d+)>/ ? $1.to_i : nil
  end
  
  def min_player_level
    # minimum player level requirement to fuse persona
    note =~ /<Player level: (\d+)>/ ? $1.to_i : 0
  end
  
  def battletest_persona_id
    # get persona to use for battletest
    note =~ /<Battletest persona: (\d+)>/ ? $1.to_i : -1
  end
  
  def hide_status_nickname
    note =~ /<Hide status nickname>/ ? true : false
  end
end

module Cache
  def self.persona_file(filename)
    load_bitmap(Persona::GRAPHICS_DIRECTORY, filename)
  end
end

module DataManager
  class <<self
    
    alias persona_cgo create_game_objects
    def create_game_objects
      persona_cgo
      $game_personas = Game_Personas.new
      $game_arcanas = Game_Arcanas.new
      load_fusions_from_file
      load_all_arcanas_mapping
    end 
    
    alias persona_msc make_save_contents
    def make_save_contents
      contents = persona_msc
      contents[:personas] = $game_personas
      contents[:arcanas] = $game_arcanas
      contents
    end
    
    alias persona_esc extract_save_contents
    def extract_save_contents(contents)
      persona_esc(contents)
      $game_personas = contents[:personas]
      $game_arcanas = contents[:arcanas]
    end

    def load_fusions_from_file
      begin
        File.open(Persona::FUSIONS_CSV_FILEPATH, "r") do |file|
          file.readline
          file.each_line.each_with_index do |line|
            line_fields = line.strip.split(",")
            persona_names = line_fields[0..3]
            persona_ids = persona_names.map{|p| $game_personas.get_actor_id_by_name(p)}
            arcana_ranks = line_fields[4..6].map do |a|
                a.to_i
            end
            user_level = line_fields[7].to_i
            item_id = line_fields[8].to_i
            user_condition_formula = line_fields[9]
            parents = persona_ids[0...3]
            conditions = {
              :arcana_ranks => arcana_ranks,
              :user_level => user_level,
              :item_id => item_id,
              :user_condition_formula => user_condition_formula
            }
            $game_personas.register_fusion(parents, persona_ids[3], conditions)
          end
        end
      rescue Errno::ENOENT
        puts "Error: File '#{filename}' not found."
      rescue Errno::EACCES
        puts "Error: Permission denied reading '#{filename}'."
      rescue => e
        puts "Error reading file: #{e.message}"
      end
    end

    def load_all_arcanas_mapping
      mappings_table = load_arcanas_mapping_from_file(Persona::ARCANAS_MAPPING_FILEPATH)
      $game_personas.arcanas_mapping = mappings_table
      mappings_table = load_arcanas_mapping_from_file(Persona::SPECIAL_FUSIONS_ARCANAS_MAPPING_FILEPATH)
      $game_personas.special_arcanas_mapping = mappings_table
    end

    def load_arcanas_mapping_from_file(filepath)
      begin
        mappings_table = {}
        File.open(filepath, "r") do |file|
          # Skip fist empty cell
          arcanas = file.readline.strip.split(",")[1..-1]
          arcanas.each do |a|
            mappings_table[a] = {}
          end
          file.each_line.each_with_index do |line, i|
            results = line.strip.split(",")
            second_arcana = results[0]
            results = results[1..-1]
            
            mappings_table.each_key.each_with_index do |k, i|
              mappings_table[k][second_arcana] = results[i]
            end
          end
        end
        return mappings_table
      rescue Errno::ENOENT
        puts "Error: File '#{filename}' not found."
      rescue Errno::EACCES
        puts "Error: Permission denied reading '#{filename}'."
      rescue => e
        puts "Error reading file: #{e.message}"
      end
      return nil
    end

  end
end

class Game_Actor < Game_Battler
  include Persona
  
  attr_reader :users, :exlusive_persona_id, :min_player_level, :current_user
  alias persona_su setup
  def setup(actor_id)
    persona_su(actor_id)
    @persona = nil
    @current_user = nil
    @changed_persona_in_battle = false
    @exlusive_persona_id = actor.exlusive_persona_id
    setup_persona
  end

  def current_user=(user)
    @current_user = user
  end
  
  def setup_persona
    @is_persona = actor.is_persona?
    @users = actor.users
    @min_player_level = actor.min_player_level
  end

  def is_persona?
    @is_persona
  end
  
  def persona
    @persona
  end
  
  def can_change_persona
    !@changed_persona_in_battle
  end 
  
  def persona_change_ok?(persona)
    return false if @changed_persona_in_battle
    return false if @persona == persona
    return false if !can_equip_persona(persona)
    return true
  end
  
  def post_persona_change(target_hp_ratio, target_mp_ratio)
    @hp = (mhp * target_hp_ratio).to_i
    @mp = (mmp * target_mp_ratio).to_i
  end

  def change_persona(persona)
    return if !persona_change_ok?(persona)
    return if !$game_party.persona_in_party(nil, persona.id)
    
    prev_hp_ratio = hp_rate
    prev_mp_ratio = mp_rate
    
    @persona = persona
    @persona.current_user = self
    @changed_persona_in_battle = $game_party.in_battle

    refresh

    post_persona_change(prev_hp_ratio, prev_mp_ratio)
  end
  
  def remove_persona
    prev_hp_ratio = hp_rate
    prev_mp_ratio = mp_rate
    
    @persona.current_user = nil
    @persona = nil
    
    self.post_persona_change(prev_hp_ratio, prev_mp_ratio)
  end
  
  alias persona_ast added_skill_types
  def added_skill_types
    # get skill types of actor and their persona
    skill_types = persona_ast
    skill_types |= persona_added_skill_types if UNIFIED_SKILLS
    return skill_types
  end
  
  alias persona_s skills
  def skills
    # get skills of actor and their persona
    skills = persona_s
    skills |= persona_skills if UNIFIED_SKILLS
    return skills
  end
  
  def has_a_persona_equipped
    return !is_persona? && !@persona.nil?
  end

  def persona_skills
    return @persona.skills if has_a_persona_equipped
    return []
  end
  
  def persona_added_skill_types
    return @persona.added_skill_types if has_a_persona_equipped
    return []
  end
  
  def state_resist?(state_id)
    actor_resists = state_resist_set.include?(state_id)
    persona_resists = false
    if self.has_a_persona_equipped
      persona_resists = @persona.state_resist_set.include?(state_id)
    end
    return actor_resists || persona_resists
  end
  
  alias persona_param param
  def param(param_id)
    # get the value of the actor's parameter
    value = persona_param(param_id)
    if self.has_a_persona_equipped
      # get the actor's and persona's multiplier and add both of their parameters 
      # with their respective multiplier
      user_multiplier = Persona::get_user_param_multiplier(param_id)
      persona_multiplier = Persona::get_persona_param_multiplier(param_id)
      value = (value * user_multiplier) + (@persona.param(param_id) * persona_multiplier)
    end
    return value.to_i
  end
  
  alias persona_er element_rate
  def element_rate(element_id)
    # get the value of the actor's element rate
    value = persona_er(element_id)
    if self.has_a_persona_equipped
      # get the actor's and persona's multiplier and add both of their element rate 
      # with their respective multiplier
      user_multiplier = Persona::get_user_element_rate_multiplier(element_id)
      persona_multiplier = Persona::get_persona_element_rate_multiplier(element_id)
      value = (value * user_multiplier) + (@persona.features_pi(FEATURE_ELEMENT_RATE, element_id) * persona_multiplier)
    end
    return value
  end
  
  alias persona_dr debuff_rate
  def debuff_rate(param_id)
    # get the value of the actor's debuff rate
    value = persona_dr(param_id)
    if self.has_a_persona_equipped
      # get the actor's and persona's multiplier and add both of their debuff rate 
      # with their respective multiplier
      user_multiplier = Persona::get_user_debuff_rate_multiplier(param_id)
      persona_multiplier = Persona::get_persona_debuff_rate_multiplier(param_id)
      value = (value * user_multiplier) + (@persona.features_pi(FEATURE_DEBUFF_RATE, param_id) * persona_multiplier)
    end
    return value
  end
  
  alias persona_sr state_rate
  def state_rate(state_id)
    # get the value of the actor's state rate
    value = persona_sr(state_id)
    if self.has_a_persona_equipped
      # get the actor's and persona's multiplier and add both of their state rate 
      # with their respective multiplier
      user_multiplier = Persona::get_user_state_rate_multiplier(state_id)
      persona_multiplier = Persona::get_persona_state_rate_multiplier(state_id)
      value = (value * user_multiplier) + (@persona.features_pi(FEATURE_STATE_RATE, state_id) * persona_multiplier)
    end
    return value
  end
  
  alias persona_xparam xparam
  def xparam(xparam_id)
    # get the value of the actor's x_parameter
    value = persona_xparam(xparam_id)
    if self.has_a_persona_equipped
      # get the actor's and persona's multiplier and add both of their x_parameters 
      # with their respective multiplier
      user_multiplier = Persona::get_user_xparam_multiplier(xparam_id)
      persona_multiplier = Persona::get_persona_xparam_multiplier(xparam_id)
      value = (value * user_multiplier) + (@persona.xparam(xparam_id) * persona_multiplier)
    end
    return value
  end
  
  alias persona_sparam sparam
  def sparam(sparam_id)
    # get the value of the actor's s_parameter
    value = persona_sparam(sparam_id)
    if self.has_a_persona_equipped
      # get the actor's and persona's multiplier and add both of their s_parameters 
      # with their respective multiplier
      user_multiplier = Persona::get_user_sparam_multiplier(sparam_id)
      persona_multiplier = Persona::get_persona_sparam_multiplier(sparam_id)
      value = (value * user_multiplier) + (@persona.sparam(sparam_id) * persona_multiplier)
    end
    return value
  end
  
  def has_exclusive_persona?
    return !exlusive_persona_id.nil?
  end
  
  def can_equip_persona(persona)
    persona.min_player_level <= @level && $game_party.persona_available?(persona)
  end
  
  alias persona_ge gain_exp
  def gain_exp(exp)
    persona_ge(exp)
    if self.has_a_persona_equipped
      @persona.gain_exp(exp)
    end
  end
  
  alias persona_fer final_exp_rate
  def final_exp_rate
    return persona_fer if !is_persona?
    return exr * Persona::PERSONA_EXP_GAIN_MULTIPLIER
  end
  
  alias persona_i index
  def index
    return persona_i if !is_persona?
    # return persona's index from user's personas list
    user = $game_party.menu_actor
    return $game_party.actors_personas(user.id).index(self)
  end
  
  def next_skills
    # return all the skills that the actor will learn
    self.class.learnings.select{ |learning| learning.level > @level }
  end
  
  def next_skill
    # return the next (closest in level) skill that the actor will learn
    self.next_skills.min_by{ |learning| learning.level }
  end
  
  def on_battle_start
    super
    # reset flag on battle start
    @changed_persona_in_battle = false
  end
  
  def on_turn_end
    super
    # reset flag on turn end
    @changed_persona_in_battle = false
  end
  
  def on_battle_end
    super
    @changed_persona_in_battle = false
  end
end

class Game_Party < Game_Unit
  attr_reader :personas

  alias persona_init initialize
  def initialize
    @personas = []
    @menu_persona_id = 0
    persona_init
  end
  
  alias persona_sbt setup_battle_test
  def setup_battle_test
    persona_sbt
    setup_test_battle_personas
  end
  
  def battle_personas
    members.select{|m| !m.persona.nil?}.collect{|m| m.persona }
  end
  
  def persona_in_party(persona_name=nil, persona_id=nil)
    if persona_name
      return !@personas.find{|p| p.name == persona_name}.nil?
    elsif persona_id
      return !@personas.find{|p| p.id == persona_id}.nil?
    else
      return false
    end
  end
  
  def persona_equipped_by(actor_id, persona_name)
    actor = members.find{|m| m.id == actor_id}
    return false if actor.nil?
    return false if actor.persona.nil?
    return actor.persona.name == persona_name
  end
  
  def persona_equipped(persona_name)
    persona = @personas.find{|p| p.name == persona_name}
    return persona_available?(persona)
  end
  
  def setup_test_battle_personas
    $data_system.test_battlers.each do |battler|
      # get battletest persona of each battle test actor and equip them
      actor = $game_actors[battler.actor_id]
      btest_persona_id = actor.actor.battletest_persona_id
      persona = $game_personas[btest_persona_id]
      if btest_persona_id != -1
        actor.change_persona(persona)
      end
    end
  end
  
  def add_persona_by_name(persona_name, equip=false)
    persona = $game_personas.get_by_name(persona_name)
    if persona.nil?
      msgbox("There was an attempt to add a persona with an incorrect name (#{persona_name})")
      return
    end
    add_persona_by_id(persona.id)
  end
  
  def add_persona_by_id(persona_id, equip=false)
    # inform the script's user about the mistake
    if $game_personas[persona_id].nil? || !$game_personas[persona_id].is_persona?
      msgbox("There was an attempt to add a persona with an invalid ID (#{persona_id}) or one that is not a persona")
      return
    end
    
    persona = $game_personas[persona_id]

    return if persona.nil?
    return if @personas.include?(persona)
    
    @personas.push(persona)
    # auto equip new persona if there is a member that uses only one persona
    user = members.find{|m| m.exlusive_persona_id == persona_id}
    user.change_persona(persona) if !user.nil?
    
    if equip
      # Otherwise, if flag was set, find first actor that can equp it
      for actor in all_members
        actor.change_persona(persona) if actor.can_equip_persona(persona)
      end
    end
    
    $game_player.refresh
    $game_map.need_refresh = true
  end
  
  def remove_persona_by_name(persona_name)
    persona = members.find{|m| !m.persona.nil? && m.persona.name == persona_name}
    remove_persona_by_id(persona.id)
  end
  
  def remove_persona_by_id(persona_id)
    return if !@personas.include?($game_personas[persona_id])
    # unequip persona
    user = members.find{|m| !m.persona.nil? && m.persona.id == persona_id}
    user.remove_persona if !user.nil?
    
    # remove persona from party
    @personas.delete_if{|p| p.id == persona_id}
    $game_player.refresh
    $game_map.need_refresh = true
  end
  
  def actors_personas(actor_id)
    return @personas.select{ |p| p.users.include?(actor_id) }
  end
  
  def persona_available?(persona)
    # returns if true if persona is not currently equipped by any member of the party
    members.inject(true){|available, m| available && m.persona != persona}
  end
  
  def menu_persona
    @personas.find{|p| p.id == @menu_persona_id} || $game_party.personas[0]
  end
  
  def menu_persona=(persona)
    @menu_persona_id = persona.id
  end
  
  def menu_personas
    # returns personas currently being shown in menu
    actors_personas(menu_actor.id)
  end
  
  def menu_persona_next
    # calculate the index of the next persona
    index = menu_personas.index(menu_persona) || -1
    # if next index is higher than the size of menu_personas, it rounds it down
    # to the start
    index = (index + 1) % menu_personas.size 
    self.menu_persona = actors_personas(menu_actor.id)[index]
  end
  
  def menu_persona_prev
    # calculate the index of the previous persona
    index = menu_personas.index(menu_persona) || 1
    # if previous index is lower than 0, it basically rounds it back to the end
    index = (index + menu_personas.size - 1) % menu_personas.size
    self.menu_persona = actors_personas(menu_actor.id)[index]
  end
end

class Game_Arcanas
  def initialize
    @data = []
  end

  def get_arcana_by_name(arcana_name)
    return $data_classes.find{|c| !c.nil? && c.is_arcana? && c.name == arcana_name}
  end
  
  def [](class_id)
    return nil if !$data_classes[class_id].is_arcana?
    return $data_classes[class_id]
  end
end

class Game_Personas
  attr_accessor :arcanas_mapping, :special_arcanas_mapping
  def initialize
    @data = []
    @fusion_map = Array.new
    @arcanas_mapping = {}
    @special_arcanas_mapping = {}
    register_all_database_fusions
  end

  def get_actor_id_by_name(persona_name)
    return nil if persona_name.empty?
    actor = $data_actors.find{|p| !p.nil? && p.name == persona_name}
    return nil if actor.nil?
    return actor.id
  end

  def get_by_name(persona_name)
    actor = $data_actors.find{|p| !p.nil? && p.name == persona_name}
    return nil if actor.nil?
    return self[actor.id]
  end
  
  def get_by_arcana_name(arcana_name)
    arcanas_personas = $data_actors.find_all{|p| !p.nil? && p.is_persona? && p.arcana.name == arcana_name}
    return [] if arcanas_personas.nil?
    return arcanas_personas.map{|p| self[p.id]}
  end

  def [](actor_id)
    return nil if !$data_actors[actor_id]
    return nil if !$data_actors[actor_id].is_persona?
    @data[actor_id] ||= Game_Actor.new(actor_id)
  end

  def register_all_database_fusions
    for result in $data_actors.select{|p| !p.nil? && p.is_persona?} 
      # to maintain triplets for all fusions, with 2 fusions having a nil 3rd parent
      fusion_parents = result.fusion_parents
      fusion_parents = fusion_parents.empty? ? result.special_fusion_parents : fusion_parents
      next if fusion_parents.empty?
      
      fusion_parents.concat([nil]) if fusion_parents.length == 2
      register_fusion(fusion_parents, result.id, result.fusion_conditions)
    end
  end

  def register_fusion(parents, result, conditions)
    return if parents.include?(result)
    @fusion_map.push({
      :parents => parents,
      :result => result,
      :conditions => conditions
    })
  end

  def get_fusion_data(parent_a_id, parent_b_id, parent_c_id=nil)
    def parents_valid?(parents, test_parents)
      return test_parents.all?{|t| parents.include?(t)}
    end

    parents = [parent_a_id, parent_b_id, parent_c_id]
    potential_children_data = @fusion_map.select{|d| parents_valid?(d[:parents], parents)}
    potential_children_data = potential_children_data.select do |d|
      Persona::ORDER_MATTERS_FOR.include?(d[:result]) ? (d[:parents] == parents) : true
    end
    # Will not account for potentially multiple results from different parents
    # This is intended
    result_data = potential_children_data[0] if !potential_children_data.empty?

    if !Persona::DYNAMIC_FUSION_RESULTS || !result_data.nil?
      return result_data
    end
    
    parent_a = $game_personas[parent_a_id]
    parent_b = $game_personas[parent_b_id]
    parent_c = parent_c_id.nil? ? nil : $game_personas[parent_c_id]
    
    result_arcana_name = @arcanas_mapping[parent_a.arcana_name][parent_b.arcana_name]
    if !parent_c.nil?
      result_arcana_name = @special_arcanas_mapping[result_arcana_name][parent_c.arcana_name]
    end
    
    resulting_personas = $game_personas.get_by_arcana_name(result_arcana_name)
    return nil if resulting_personas.empty?
    resulting_level = Persona.LEVEL_CALC_FUNC(parent_a, parent_b, parent_c)
    sorted_personas = resulting_personas.sort_by{|p| p.actor.initial_level < resulting_level ? 999999 : p.actor.initial_level - resulting_level}
    
    # Skip if result is one of the parents
    parents = [parent_a_id, parent_b_id, parent_c_id]
    result = sorted_personas[0].id
    return nil if parents.include?(result)

    return {
      :parents => parents,
      :result => result,
      :conditions => {}
    }
  end

  def fusion_conditions_met?(fusion_data)
    def arcana_conditions_met?(parents, arcana_conditions)
      parents.zip(arcana_conditions).all? do |p, c|
        p.arcana_rank >= c
      end
    end

    def user_level_condition_met?(result, user, min_user_level)
      return user.level >= min_user_level
    end

    def item_condition_met?(item_id)
      return true if item_id == 0
      return $game_party.has_item?($data_items[item_id])
    end

    def user_condition_formula?(result, user, condition_formula)
      Kernel.eval(condition_formula) rescue true
    end

    result_id = fusion_data[:result]
    result = $game_personas[result_id]

    if result.users.length == 1
      user_id = result.users[0]
      # Exclusive persona of a user
      user = $game_actors[user_id]
    else
      user = $game_actors[Persona:FUSION_CONDITIONS_DEFAULT_ACTOR_ID_CHECK]
    end

    parent_ids = fusion_data[:parents].reject{|p| p.nil?}
    parents = parent_ids.map{|p| $game_personas[p]}
    conditions = fusion_data[:conditions]
    return [
      arcana_conditions_met?(parents, conditions[:arcana_ranks]),
      user_level_condition_met?(result, user, conditions[:user_level]),
      item_condition_met?(conditions[:item_id]),
      user_condition_formula?(result, user, conditions[:user_condition_formula])
    ].all?
  end
end

class Window_ActorCommand < Window_Command
  alias persona_mcl make_command_list
  def make_command_list
    persona_mcl
    return unless @actor
    add_persona_command
    add_persona_skills_command if !Persona::UNIFIED_SKILLS
  end
  
  def add_persona_command
    return if Persona::HIDE_PERSONA_COMMAND.include?(@actor.id)
    name = Persona::PERSONA_MENU_NAME
    ext = nil
    command = { :name=>name, 
                :symbol=>:persona, 
                :enabled=>@actor.can_change_persona && !@actor.has_exclusive_persona?, 
                :ext=>ext}
    index = Persona::PERSONA_BATTLE_COMMAND_INDEX - 1
    index = [[0, index].max, @list.length].min
    @list.insert(index, command)
  end
  
  def add_persona_skills_command
    return if @actor.persona.nil?
    index = Persona::PERSONA_SKILLS_COMMAND_INDEX
    @actor.persona_added_skill_types.sort.each do |stype_id|
      name = "#{Persona::PERSONA_MENU_NAME} #{$data_system.skill_types[stype_id]}"
      ext = stype_id
      command = { :name=>name, 
                  :symbol=>:persona_skills, 
                  :enabled=>true, 
                  :ext=>ext}
      index = [[0, index].max, @list.length].min
      @list.insert(index, command)
      index += 1
    end
  end
  
  def refresh_persona_change
    setup(@actor)
    refresh
  end
end

class Window_BattlePersonas < Window_Command
  def initialize(actor)
    @actor = actor
    @personas = $game_party.actors_personas(@actor.id)
    super(0, 0)
    select_last
  end
  
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    @personas = $game_party.actors_personas(@actor.id)
    refresh
    select_last
  end
  
  def refresh
    contents.clear
    draw_all_items
  end
  
  def window_width
    Graphics.width
  end
  
  def window_height
    Graphics.height / 4
  end
  
  def item_width
    (width - standard_padding * 2 + spacing) / col_max - spacing
  end
  
  def col_max
    2
  end
  
  def item_height
    line_height
  end
  
  def visible_line_number
    4
  end
  
  def item_max
    @personas.size
  end
  
  def process_handling
    return unless open? && active
    return process_equip if equip_enabled? && Input.trigger?(:C)
    return process_cancel   if cancel_enabled? && Input.trigger?(:B)
  end
  
  def item
    @personas && index >= 0 ? @personas[index] : nil
  end
  
  def enable?(persona)
    @actor && @actor.persona_change_ok?(persona)
  end
  
  def current_item_enabled?
    enable?($game_party.actors_personas(@actor.id)[index])
  end
  
  def process_equip
    if current_item_enabled?
      Audio.se_play(*Persona::PERSONA_EQUIP_SOUND)
      Input.update
      deactivate
      call_equip_handler
    else
      Audio.se_play(*Persona::PERSONA_INVALID_EQUIP_SOUND)
    end
  end
  
  def call_equip_handler
    call_handler(:equip)
  end
  def equip_enabled?
    handle?(:equip)
  end
  
  def draw_item_background(index)
    equipped_persona_index = @personas.index(@actor.persona)
    if index == equipped_persona_index
      color = pending_color
      color.alpha = 100
      contents.fill_rect(item_rect(index), color)
    end
  end
  
  def draw_persona_name_and_level(persona, rect, enabled)
    change_color(system_color, enabled)
    draw_text(rect, Vocab::level_a)
    x = rect.x + text_size(Vocab::level_a).width
    y = rect.y
    txt = "#{persona.level} #{persona.name}"
    change_color(normal_color, enabled)
    draw_text(x, y, rect.width, rect.height, txt)
  end
  
  def draw_item(index)
    persona = @personas[index]
    rect = item_rect(index)
    enabled = enable?(persona)
    draw_item_background(index)
    draw_persona_name_and_level(persona, rect, enabled)
  end
  
  def select_last
    if $game_party.menu_persona.nil?
      select(0) 
    else
      select($game_party.menu_persona.index || 0)
    end
  end
  
  def pending_index=(index)
    last_pending_index = @pending_index
    @pending_index = index
    redraw_item(@pending_index)
    redraw_item(last_pending_index)
  end
end

class Window_BattleSkill < Window_SkillList
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    if !@actor.persona_skills.index(item).nil?
      change_color(Persona::PERSONA_SKILLS_COLOR, enabled)
    else
      change_color(normal_color, enabled)
    end
    draw_text(x + 24, y, width, line_height, item.name)
  end
end

class Window_MenuCommand < Window_Command
  alias persona_mcl make_command_list
  def make_command_list
    persona_mcl
    add_persona_command
  end
  
  def add_persona_command
    # add persona command to main menu
    name = Persona::PERSONA_MENU_NAME
    ext = nil
    command = { :name=>name, 
                :symbol=>:persona, 
                :enabled=>main_commands_enabled, 
                :ext=>ext}
    index = Persona::PERSONA_MENU_COMMAND_INDEX - 1
    index = [index, @list.length].min
    @list.insert(index, command)
  end
end

class Window_Command < Window_Selectable
  alias persona_init initialize
  def initialize(x, y, lazy_load=false)
    @drawn_items = []
    @lazy_load = lazy_load
    persona_init(x, y)
  end

  alias persona_refresh refresh
  def refresh
    @drawn_items = []
    persona_refresh
  end

  alias persona_cm process_cursor_move
  def process_cursor_move
    last_index = @index
    persona_cm
    if @lazy_load
      draw_around_current_index if open? && active && @index != last_index
    end
  end

  def draw_all_items
    if @lazy_load
      draw_around_current_index
    else
      super
    end
  end

  def draw_around_current_index
    draw_start = self.index - self.visible_line_number
    draw_end = self.index + self.visible_line_number
    draw_items(draw_start, draw_end)
  end

  def draw_items(start_index, end_index)
    for i in start_index..end_index
      next if i < 0 || i >= item_max || @drawn_items.include?(i)
      draw_item(i)
      @drawn_items.push(i)
    end
  end

  def redraw_around_current_index
    draw_start = self.index - self.visible_line_number
    draw_end = self.index + self.visible_line_number
    for i in draw_start..draw_end
      clear_item(i)
      draw_item(i)
    end
  end
end

class Window_Personas < Window_Command
  def initialize(actor, full_screen=false, lazy_load=true)
    @actor = actor
    @full_screen = full_screen
    super(0, 0, lazy_load=lazy_load)
    self.visible = false
    select_last
  end
  
  def personas
    $game_party.actors_personas(@actor.id) or []
  end

  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    select_last
  end
  
  def window_width
    @full_screen ? Graphics.width : (Graphics.width / 2)
  end
  
  def window_height
    Graphics.height
  end

  def col_max
    @full_screen ? 2 : 1
  end

  def item_height
    (height - standard_padding * 2) / visible_line_number
  end
  
  def visible_line_number
    4
  end
  
  def item_max
    self.personas.size
  end
  
  def current_persona
    self.personas[index]
  end
  
  def process_handling
    return unless open? && active
    super
    return if self.personas.empty?
    return process_equip if equip_enabled? && Input.trigger?(Persona::EQUIP_PERSONA_KEY)
    return process_release if handle?(:release)   && Input.trigger?(Persona::RELEASE_PERSONA_KEY)
  end
  
  def process_release
    call_handler(:release)
  end
  
  def process_equip
    if persona_equippable?
      Audio.se_play(*Persona::PERSONA_EQUIP_SOUND)
      Input.update
      call_equip_handler
    else
      Audio.se_play(*Persona::PERSONA_INVALID_EQUIP_SOUND)
    end
  end
  
  def call_equip_handler
    call_handler(:equip)
  end
  
  def equip_enabled?
    handle?(:equip)
  end
  
  def draw_all_items
    if self.personas.empty?
      draw_no_personas_msg
    else
      super
    end
  end
  
  def draw_no_personas_msg
    draw_text(0, 0, width, line_height, Persona::NO_PERSONAS_MSG)
  end
  
  def command_enabled?(index)
    return @actor.can_equip_persona(self.personas[index])
  end

  def add_command
    super
  end
  
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.y = index / col_max * item_height
    rect
  end
  
  def draw_item(index)
    persona = self.personas[index]
    
    enabled = command_enabled?(index)
    rect = item_rect(index)
    draw_item_background(index)
    draw_actor_face(persona, rect.x + 1, rect.y + 1, enabled)
    draw_actor_simple_status(persona, rect.x + 108, rect.y, enabled)
  end
  
  def draw_actor_simple_status(actor, x, y, enabled)
    change_color(normal_color, enabled)
    draw_actor_name(actor, x, y)
    draw_arcana_name(actor.arcana_name, x, y + line_height)
    draw_actor_level(actor, x, y + line_height * 2)
    change_color(normal_color)
  end
  
  def draw_arcana_name(arcana_name, x, y, width = 112)
    change_color(normal_color)
    draw_text(x, y, width, line_height, arcana_name)
  end
  
  def draw_item_background(index)
    equipped_persona_index = self.personas.index(@actor.persona)
    if index == equipped_persona_index
      color = pending_color
      color.alpha = 100
      contents.fill_rect(item_rect(index), color)
    end
  end
  
  def persona_equippable?
    persona = self.personas[index]
    return @actor.can_equip_persona(persona)
  end
  
  def process_ok
    return if self.personas.size == 0
    Sound.play_ok
    Input.update
    deactivate
    
    persona = self.personas[index]
    $game_party.menu_persona = persona
    call_ok_handler
  end
  
  def current_item_enabled?
    persona = self.personas[index]
    enabled = $game_party.persona_available?(persona) || @actor.persona == persona
    return enabled
  end
  
  def select_last
    if self.personas.nil? || $game_party.menu_persona.nil?
      select(-1)
    else
      select($game_party.menu_persona.index || 0)
    end
  end
  
  def pending_index=(index)
    last_pending_index = @pending_index
    @pending_index = index
    redraw_item(@pending_index)
    redraw_item(last_pending_index)
  end
end

class Window_PersonaStatus < Window_Command
  include Persona
  
  def initialize(persona)
    @persona = persona
    super(0, 0)
    self.visible = false
    select_last
  end
  
  def window_width
    Graphics.width
  end
  
  def window_height
    Graphics.height
  end
  
  def persona
    @persona
  end
  
  def persona=(persona)
    @persona = persona
    clear_command_list
    make_command_list
    refresh
  end
  
  def process_handling
    return unless open? && active
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    if SceneManager.scene_is?(Scene_Fusion)
      return process_equip if equip_enabled? && Input.trigger?(EQUIP_PERSONA_KEY)
      return process_release if handle?(:release)   && Input.trigger?(RELEASE_PERSONA_KEY)
    end
    super
  end
  
  def process_release
    call_handler(:release)
  end
  
  def process_equip
    if persona_equippable?
      Audio.se_play(*Persona::PERSONA_EQUIP_SOUND)
      Input.update
      call_equip_handler
    else
      Audio.se_play(*Persona::PERSONA_INVALID_EQUIP_SOUND)
    end
  end
  
  def persona_equippable?
    return $game_party.menu_actor.can_equip_persona(@persona)
  end
  
  def call_equip_handler
    call_handler(:equip)
  end
  
  def equip_enabled?
    handle?(:equip)
  end
  
  def refresh
    contents.clear
    draw_everything if !@persona.nil?
  end
  
  def draw_everything
    draw_block1   (line_height * 0)
    draw_horz_line(line_height * 1)
    draw_block2   (line_height * 2)
    draw_horz_line(line_height * 6)
    draw_block3   (line_height * 7)
    draw_horz_line(line_height * 13)
    draw_block4   (line_height * 14)
  end
  
  def draw_block1(y)
    draw_actor_name(@persona, 4, y)
    draw_arcana_name(@persona.arcana_name, 128, y)
    draw_actor_nickname(@persona, 288, y) if ! @persona.actor.hide_status_nickname
  end
  
  def draw_arcana_name(arcana_name, x, y, width = 112)
    change_color(normal_color)
    draw_text(x, y, width, line_height, arcana_name)
  end
  
  def draw_block2(y)
    draw_actor_face(@persona, 8, y)
    draw_basic_info(136, y)
    draw_exp_info(136, y)
    draw_next_skill(136, y + line_height * 3)
  end
  
  def draw_block3(y)
    draw_parameters(10, y)
    # draw vertical line separator between params and skills
    contents.fill_rect(100 - standard_padding, y, 2, line_height * 6, line_color)
    draw_all_items
  end
  
  def draw_block4(y)
    draw_ele_rates(30, y)
  end
  
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  
  def draw_basic_info(x, y)
    draw_actor_level(@persona, x, y + line_height * 0)
    draw_actor_icons(@persona, x, y + line_height * 1)
  end
  
  def draw_parameters(x, y)
    6.times {|i| draw_actor_param(@persona, x, y + line_height * i, i + 2) }
  end
  
  def draw_actor_param(actor, x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 120, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x + 30, y, 36, line_height, actor.param(param_id), 2)
  end
  
  def draw_exp_info(x, y)
    s1 = @persona.max_level? ? "-------" : @persona.exp
    s2 = @persona.max_level? ? "-------" : @persona.next_level_exp - @persona.exp
    s_next = sprintf(Vocab::ExpNext, Vocab::level)
    change_color(system_color)
    draw_text(x, y + line_height * 1, 180, line_height, Vocab::ExpTotal)
    draw_text(x, y + line_height * 2, 180, line_height, s_next)
    change_color(normal_color)
    draw_text(x, y + line_height * 1, 180, line_height, s1, 2)
    draw_text(x, y + line_height * 2, 180, line_height, s2, 2)
  end
  
  def draw_next_skill(x, y)
    next_skill = @persona.next_skill
    return if next_skill.nil?
    s_next = sprintf("Next %s at ", Vocab::skill.downcase[0...-1])
    change_color(system_color)
    draw_text(x, y, 180, line_height, s_next)
    x += text_size(s_next).width
    
    change_color(system_color)
    draw_text(x, y, 180, line_height, Vocab::level_a)
    x += text_size(Vocab::level_a).width
    
    change_color(normal_color)
    draw_text(x, y, 180, line_height, next_skill.level.to_s + ": ")
    x += text_size(next_skill.level.to_s + ": ").width
    
    change_color(normal_color)
    skill_name = $data_skills[next_skill.skill_id].name
    draw_text(x, y, 180, line_height, skill_name)
  end
  
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = ((index/6).to_i * item_width) + 100
    rect.y = (item_height * index.divmod(6)[1]) + line_height * 7
    rect
  end
  
  def item_rect_for_text(index)
    rect = item_rect(index)
    # offset is added only if there is an icon to draw
    # icon is usually there when there is a skill name
    if !@list[index][:ext].nil?
      rect.x += 20
      rect.width -= standard_padding
    end
    rect
  end

  def draw_all_items
    item_max.times {|i| draw_item(i) }
  end

  def draw_item(index)
    item = @list[index]
    return if item.nil?
    icon_index = (item.nil? || item[:ext].nil?) ? nil : item[:ext][:icon_index] 
    rect = item_rect(index)
    draw_icon(icon_index, rect.x, rect.y) if !icon_index.nil?
    change_color(normal_color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
  
  def make_command_list
    @persona.skills.each_with_index do |item, i|
      add_command(item.name, "skill_#{i}", true, {:icon_index=>item.icon_index})
    end
    @persona.next_skills.each_with_index do |item, i|
      add_command("-------", "skill_#{i}", true)
    end
  end

  def draw_ele_rates(x, y)
    icons = PERSONA_ELE_ICON_INDEXES
    10.times do |i|
      offset_x = i * (24 + 24) # icon width + space between them
      new_x = x + offset_x
      draw_icon(icons[i], new_x, y)
      if @persona.element_rate(i+1) == 1.0
        draw_normal_ele_icon(new_x, y)
      elsif @persona.element_rate(i+1) < 1.0
        draw_strong_ele_icon(new_x, y)
      elsif @persona.element_rate(i+1) > 1.0
        draw_weak_ele_icon(new_x, y)
      end
    end
  end
  
  def draw_normal_ele_icon(x, y)
    if PERSONA_NORMAL_ELE_ICON == -1
      draw_text(x, y + line_height, 24, line_height, "-", 1)
    else
      draw_icon(PERSONA_NORMAL_ELE_ICON, x, y + line_height)
    end
  end
  
  def draw_strong_ele_icon(x, y)
    if PERSONA_STRONG_ELE_ICON == -1
      draw_text(x, y + line_height, 24, line_height, "Str", 1)
    else
      draw_icon(PERSONA_STRONG_ELE_ICON, x, y + line_height)
    end
  end
  
  def draw_weak_ele_icon(x, y)
    if PERSONA_WEAK_ELE_ICON == -1
      draw_text(x, y + line_height, 24, line_height, "Wk", 1)
    else
      draw_icon(PERSONA_WEAK_ELE_ICON, x, y + line_height)
    end
  end
  
  def select_last
    select(-1)
  end
end

class Scene_Battle < Scene_Base
  alias persona_cacw create_actor_command_window
  def create_actor_command_window
    persona_cacw
    add_persona_commands_to_actor_command_window
  end
  
  def add_persona_commands_to_actor_command_window
    @actor_command_window.set_handler(:persona, method(:command_persona))
    @actor_command_window.set_handler(:persona_skills, method(:persona_skills))
    @actor_command_window.set_handler(:persona_magic, method(:persona_skills))
  end

  def command_persona
    @persona_window = Window_BattlePersonas.new(BattleManager.actor)
    @persona_window.select_last
    @persona_window.set_handler(:equip, method(:on_persona_equip))
    @persona_window.set_handler(:cancel, method(:on_persona_cancel))
  end
  
  def persona_skills
    @skill_window.actor = BattleManager.actor.persona if BattleManager.actor.persona
    @skill_window.stype_id = @actor_command_window.current_ext
    @skill_window.refresh
    @skill_window.show.activate
  end
  
  def on_persona_equip
    persona = @persona_window.item
    BattleManager.actor.change_persona(persona)
    BattleManager.actor.refresh
    @actor_command_window.activate
    @actor_command_window.refresh_persona_change
    @status_window.refresh
    @persona_window.hide
  end
  
  def on_persona_cancel
    @persona_window.hide
    @actor_command_window.activate
  end
  
  alias persona_oec on_enemy_cancel
  def on_enemy_cancel
    persona_oec
    case @actor_command_window.current_symbol
    when :persona_skills
      @skill_window.activate
    end
  end
  
  alias persona_oac on_actor_cancel
  def on_actor_cancel
    persona_oac
    case @actor_command_window.current_symbol
    when :persona_skills
      @skill_window.activate
    end
  end
end

class Scene_Menu < Scene_MenuBase
  alias persona_ccw create_command_window
  def create_command_window
    persona_ccw
    add_persona_commands_to_command_window
  end

  def add_persona_commands_to_command_window
    @command_window.set_handler(:persona,    method(:command_persona))
  end
  
  def command_persona
    @status_window.select_last
    @status_window.activate
    @status_window.set_handler(:ok,     method(:on_persona_user_ok))
    @status_window.set_handler(:cancel, method(:on_personal_cancel))
  end
  
  def on_persona_user_ok
    SceneManager.call(Scene_Personas)
  end
end

class Window_CurrentActor < Window_Base
  def initialize
    height = line_height + standard_padding * 2
    super(0, Graphics.height - height, 0, height)
    @current_actor = $game_party.menu_actor
  end

  def actor=(actor)
    @current_actor = actor
    draw_content
  end

  def draw_content
    contents.clear
    txt_width = text_size(@current_actor.name).width
    self.width = txt_width + standard_padding * 2
    self.x = Graphics.width - (txt_width + standard_padding * 2)
    create_contents
    draw_text(0, 0, self.width - standard_padding, line_height, @current_actor.name)
  end

  def move_top_right
    self.y = 0
  end

  def move_bot_right
    self.y = Graphics.height - height
  end
end

class Scene_Base
  alias persona_init initialize
  def initialize
    persona_init
    # We use an interpreter for compatibility with 
    # Hime Options & Large Choices scripts
    @interpreter = Game_Interpreter.new
    @choice = -1
  end

  def show_message_with_choices(texts, choices, default_choice_index=2)
    texts.each{|text| $game_message.add(text)}
    @interpreter.setup_choices([choices, default_choice_index])
    $game_message.choice_proc = Proc.new {|n| @choice = n }
  end
end

class Scene_Personas < Scene_Base

  def start
    super
    create_background
    @actor = $game_party.menu_actor
    @persona = @actor.persona
    @message_window = Window_Message.new
    @current_actor_window = Window_CurrentActor.new
    @current_actor_window.z = 98
    create_personas_window
    create_status_window
    on_actor_change
  end
  
  def terminate
    super
    dispose_background
  end
  
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
  
  def dispose_background
    @background_sprite.dispose
  end
  
  def create_personas_window
    @personas_window = Window_Personas.new(@actor, true)
    @personas_window.select_last
    @personas_window.set_handler(:ok, method(:on_persona_ok))
    @personas_window.set_handler(:cancel, method(:return_scene))
    @personas_window.set_handler(:equip, method(:equip_from_personas_window))
    @personas_window.set_handler(:pagedown, method(:next_actor))
    @personas_window.set_handler(:pageup,   method(:prev_actor))
    @personas_window.set_handler(:release,   method(:release_persona))
    @personas_window.z = 97 # behind status, message and choice window
    @personas_window.open
  end
  
  def create_status_window
    @status_window = Window_PersonaStatus.new($game_party.menu_persona)
    @status_window.set_handler(:cancel,   method(:close_status))
    @status_window.set_handler(:equip, method(:equip_from_status_window))
    @status_window.set_handler(:pagedown, method(:next_persona))
    @status_window.set_handler(:pageup,   method(:prev_persona))
    @status_window.set_handler(:release,   method(:release_persona))
    @status_window.z = 99 # behind message and choice window
    @status_window.open
  end
    
  def wait_for_message
    @message_window.update
    update_for_wait while $game_message.busy?
  end
  
  def update_for_wait
    Graphics.update
    Input.update
    
    $game_timer.update
    @message_window.update
  end
  
  def release_persona
    return if @choice == 0 # already accepted fusion
    return if @actor.has_exclusive_persona? && !Persona::CAN_RELEASE_EXCLUSIVE_PERSONAS

    if @status_window.active
      persona = @status_window.persona
    else
      persona = @personas_window.current_persona
    end
    actors_persona_msg = @actor.persona == persona ? "#{@actor.name}'s" : "the"
    message_texts = [
      "Are you sure you want to release #{actors_persona_msg}",
      "#{persona.name} #{Persona::PERSONA_MENU_NAME.capitalize}?"
    ]
    message_texts.push("This is #{@actor.name}'s last #{Persona::PERSONA_MENU_NAME.capitalize}!") if @personas_window.personas.size == 1
    show_message_with_choices(message_texts, ["Yes", "No"], 2)
    wait_for_message
    if @choice == 0
      Audio.se_play(*Persona::PERSONA_RELEASE_SOUND)
      $game_party.remove_persona_by_id(persona.id)
      @personas_window.refresh
      next_persona if @status_window.active
      $game_message.add("#{persona.name} has been released.")
      wait_for_message
      @choice = -1
    else
      @message_window.close
      @choice = -1
    end
  end

  def on_persona_ok
    @status_window.persona = @personas_window.current_persona
    @status_window.show.activate
    @personas_window.deactivate
  end
  
  def equip_from_status_window
    persona_to_equip = @status_window.persona
    @actor.change_persona(persona_to_equip)
    $game_party.menu_persona = @actor.persona
  end

  def equip_from_personas_window
    persona_to_equip = @personas_window.current_persona

    # get previous persona index
    if !@actor.persona.nil?
      prev_persona_index = @personas_window.personas.index(@actor.persona)
      @actor.remove_persona
      # redraw that item in window
      @personas_window.redraw_item(prev_persona_index) if !prev_persona_index.nil?
    end

    @actor.change_persona(persona_to_equip)

    #redraw that item
    index = @personas_window.personas.index(persona_to_equip)
    @personas_window.redraw_item(index)
    $game_party.menu_persona = @actor.persona
  end
  
  def skip_personas_list?
    @actor.has_exclusive_persona? && $game_party.actors_personas(@actor.id).length == 1
  end

  def on_actor_change
    if skip_personas_list?
      # if current (new actor after next/prev_actor) uses only one persona 
      # and the persona is equipped, skip to status window (does not show 
      # all personas that can be equipped by specific actor as they can only 
      # equip one and it is auto-equipped when added to the party)
      @personas_window.actor = @actor
      @personas_window.deactivate.hide
      @status_window.persona = @persona
      @status_window.show.activate
      @current_actor_window.move_top_right
      @current_actor_window.z = 100
    else
      # else show list of personas current actor can equip
      @status_window.deactivate.hide
      @personas_window.actor = @actor
      @personas_window.show.activate
      @current_actor_window.move_bot_right
      @current_actor_window.z = 99
    end
    @current_actor_window.actor = @actor
  end
  
  def next_actor
    new_actor = $game_party.menu_actor_next
    if skip_personas_list? && new_actor.persona.nil?
      # if next actor can equip only one persona and it is not equipped (not in
      # the party) then move to next actor
      next_actor
    else
      @actor = new_actor
      @persona = @actor.persona
      on_actor_change
    end
  end
  
  def prev_actor
    new_actor = $game_party.menu_actor_prev
    if skip_personas_list? && new_actor.persona.nil?
      # if pervious actor can equip only one persona and it is not equipped (not in
      # the party) then stay in current actor
      prev_actor
    else
      @actor = new_actor
      @persona = @actor.persona
      on_actor_change
    end
  end
  
  def next_persona
    if @actor.has_exclusive_persona?
      # if current actor can equip only one persona go to next actor
      next_actor
    else
      # else go to next persona
      @persona = $game_party.menu_persona_next
      @status_window.persona = @persona
      @status_window.activate # pagedown handler deactivates window
    end
  end
  
  def prev_persona
    if @actor.has_exclusive_persona?
      # if current actor can equip only one persona go to previous actor
      prev_actor
    else
      # else go to previous persona
      @persona = $game_party.menu_persona_prev
      @status_window.persona = @persona
      @status_window.activate # pagedown handler deactivates window
    end
  end
  
  def close_status
    if @actor.has_exclusive_persona?
      # if current actor can equip only one persona return scene
      SceneManager.return
    else
      # else just close the status window
      @status_window.deactivate
      @status_window.hide
      @personas_window.activate
    end
  end
end

#-------------------------------------------------------------------------------
#  ____  _    _ _ _   _____                    _   
# / ___|| | _(_) | | |  ___|__  _ __ __ _  ___| |_ 
# \___ \| |/ / | | | | |_ / _ \| '__/ _` |/ _ \ __|
#  ___) |   <| | | | |  _| (_) | | | (_| |  __/ |_ 
# |____/|_|\_\_|_|_| |_|  \___/|_|  \__, |\___|\__|
#                                   |___/          
#  __  __           _       _      
# |  \/  | ___   __| |_   _| | ___ 
# | |\/| |/ _ \ / _` | | | | |/ _ \
# | |  | | (_) | (_| | |_| | |  __/
# |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                  
# Skill Forget Module
#-------------------------------------------------------------------------------
class RPG::Actor < RPG::BaseItem
  def max_skills
    max_skills = note =~ /<Max skills: (\d+)>/ ? $1.to_i : Persona::DEFAULT_MAX_PERSONA_SKILLS
    # Force max skills to be at most 18, otherwise they won't fit in the status window
    [max_skills, 18].min
  end
end

class Game_Actor < Game_Battler
  attr_accessor :extra_skills
  attr_reader :max_skills
  @@max_skills_by_persona = {}
  
  alias persona_forget_sp setup_persona
  def setup_persona
    persona_forget_sp
    @max_skills = actor.max_skills
    @@max_skills_by_persona[self.id] = @@max_skills_by_persona[self.id] || @max_skills
    @extra_skills = []
  end
  
  def increase_max_skills_allowed(by=1)
    @max_skills += 1
    @@max_skills_by_persona[self.id] = @max_skills
  end

  alias persona_forget_is init_skills
  def init_skills
    if actor.is_persona?
      @skills = []
      # learn the highest level skills up to max skills allowed
      self.class
      .learnings
      .reject{|learning| learning.level > @level}
      .sort_by{|learning| learning.level }
      .last(actor.max_skills)
      .each { |learning| learn_skill(learning.skill_id) }
    else
      persona_forget_is
    end
  end
  
  def level_up
    @level += 1
    level_up_learnings = self.class
    .learnings
    .reject{|learning| learning.level != @level}
    level_up_learnings.each do |learning|
      if is_persona? && @skills.size >= @max_skills
        @extra_skills.push(learning.skill_id) unless @extra_skills.include?(learning.skill_id)
      else
        learn_skill(learning.skill_id)
      end
    end
    call_forget_skill_scene_if_needed
  end
  
  alias persona_learn_skill learn_skill
  def learn_skill(skill_id)
    return if @skills.include?(skill_id)
    if !is_persona?
      persona_learn_skill(skill_id)
    elsif @skills.size < @max_skills
      persona_learn_skill(skill_id)
    else
      @extra_skills.push(skill_id) unless @extra_skills.include?(skill_id)
      call_forget_skill_scene_if_needed
    end
  end

  def call_forget_skill_scene_if_needed
    if @extra_skills.size > 0 && !SceneManager.scene_is?(Scene_Battle) && !SceneManager.scene_is?(Scene_Fusion)
      $game_party.menu_persona = self
      SceneManager.call(Scene_ForgetSkill)
      Fiber.yield
    end
  end

  alias persona_forget_ce change_exp
  def change_exp(exp, show)
    persona_forget_ce(exp, show)
    refresh
  end
  
  def replace_skill(old_skill, new_skill)
    index = @skills.index(old_skill.id)
    @skills[index] = new_skill.id
  end
end

class Window_NewSkill < Window_Base
  def initialize(x, y)
    height = line_height * 2
    super(x, y, 200, height)
    self.openness = 0
  end
  
  def text=(txt)
    contents.clear
    self.width = text_size(txt).width + standard_padding * 2
    create_contents
    draw_text(0, 0, self.width - standard_padding, line_height, txt)
  end
end

class Window_PersonaStatus < Window_Command
  alias persona_forget_init initialize
  def initialize(persona, enable_cursor=false)
    persona_forget_init(persona)
    if enable_cursor
      clear_command_list
      make_command_list
    end
    select_last
  end
  
  def extra_skills
    @persona ? @persona.extra_skills : []
  end
  
  alias persona_forget_pcm process_cursor_move
  def process_cursor_move
    persona_forget_pcm if !extra_skills.empty?
  end
  
  alias persona_forget_ph process_handling
  def process_handling
    if !extra_skills.empty?
      return unless open? && active
      return process_forget if forget_enabled? && Input.trigger?(:C)
      return process_cancel if cancel_enabled? && Input.trigger?(:B)
    else
      persona_forget_ph
    end
  end
  
  def process_forget
    Input.update
    call_forget_handler
  end
  
  def call_forget_handler
    call_handler(:forget)
  end
  
  def forget_enabled?
    handle?(:forget)
  end
  
  def item_width
    ((self.width - 100)/3).to_i - standard_padding
  end
  
  def row_max
    6
  end
  
  def col_max
    4
  end

  def item_max
    [row_max * col_max, persona.max_skills].min
  end
  
  def select_last
    if extra_skills.empty?
      select(-1)
    else
      select(0)
    end
  end  
  
  def cursor_down(wrap = false)
    if (index < item_max - 1 || (wrap && horizontal?))
      select((index + 1) % item_max)
    end
  end
  
  def cursor_up(wrap = false)
    if (index > 0 || (wrap && horizontal?))
      select((index - 1 + item_max) % item_max)
    end
  end
  
  def cursor_right(wrap = false)
    new_index = [index + 6, item_max - 1].min
    if wrap && index >= item_max - 1
      new_index = 0
    end
    select(new_index)
  end
  
  def cursor_left(wrap = false)
    new_index = [index - 6, 0].max
    if wrap && index == 0
      new_index = item_max - 1
    end  
    select(new_index)
  end
end

class Scene_ForgetSkill < Scene_Base
  def start
    super
    create_windows
    create_background
  end
  
  def start_without_background
    create_main_viewport
    create_windows
  end

  def create_windows
    create_main_viewport
    create_status_window
    create_message_window
    create_new_skill_window
  end
  
  def create_status_window
    @status_window = Window_PersonaStatus.new($game_party.menu_persona, enable_cursor=true)
    @status_window.set_handler(:cancel,   method(:cancel_forget))
    @status_window.set_handler(:forget,   method(:skill_forget))
    @status_window.show.activate
  end
  
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
  
  def terminate
    super
    dispose_background
  end
  
  def dispose_background
    @background_sprite.dispose if @background_sprite
  end
  
  def post_start
    super
    show_message if $game_party.menu_persona.extra_skills.size > 0
  end
  
  def show_message
    $game_message.add("#{@status_window.persona.name} can't learn any new skills!\nSelect a skill to forget")
    wait_for_message
    @status_window.activate
  end
  
  def create_new_skill_window
    @new_skill_window = Window_NewSkill.new(150, 24 * 5)
    @new_skill_window.open
    skill_id = $game_party.menu_persona.extra_skills[0]
    skill = $data_skills[skill_id]
    txt = "New skill: " + skill.name
    @new_skill_window.text= txt
  end
  
  def create_message_window
    $game_message.clear
    @message_window = Window_Message.new
    @choice = -1
  end
  
  def wait_for_message
    @status_window.deactivate
    @message_window.activate
    @message_window.update
    update_basic while $game_message.visible
  end
  
  def cancel_forget
    persona = @status_window.persona
    skill = persona.skills[@status_window.index]
    new_skill = $data_skills[persona.extra_skills[0]]
    show_message_with_choices(["Are you sure you don't want #{persona.name}\nto learn #{new_skill.name}?"], ["Yes", "No"], 2)
    wait_for_message
    index = @status_window.index
    if @choice == 0
      @status_window.activate
      persona.extra_skills.delete_at(0)
      @status_window.refresh
      $game_message.add("#{persona.name} didn't learn #{new_skill.name}!")
      wait_for_message
      finish_new_skill
    else
      @status_window.activate
    end
  end

  def skill_forget
    persona = @status_window.persona
    @status_window.deactivate
    skill = persona.skills[@status_window.index]
    new_skill = $data_skills[persona.extra_skills[0]]
    show_message_with_choices(["Are you sure you want #{persona.name} to forget\n#{skill.name} and learn #{new_skill.name}?"], ["Yes", "No"], 2)
    wait_for_message
    index = @status_window.index
    if @choice == 0
      Audio.se_play(*Persona::PERSONA_EQUIP_SOUND)
      persona.replace_skill(skill, new_skill)
      persona.extra_skills.delete_at(0)
      # Simple way to refresh window and skills
      @status_window.persona = persona
      $game_message.add("#{persona.name} forgot #{skill.name} and learned\n#{new_skill.name}!")
      wait_for_message
      finish_new_skill
    else
      @status_window.activate
    end
  end

  def next_new_skill
    skill_id = $game_party.menu_persona.extra_skills[0]
    skill = $data_skills[skill_id]
    txt = "New skill: " + skill.name
    @new_skill_window.text= txt
    show_message
  end
  
  def finish_new_skill
    if !$game_party.menu_persona.extra_skills.empty?
      next_new_skill
    else
      @status_window.activate
      @status_window.close
      @new_skill_window.close
      update_basic while @new_skill_window.openness > 0
      SceneManager.return
    end
  end
end

#-------------------------------------------------------------------------------
#     _                                __  __           _       _      
#    / \   _ __ ___ __ _ _ __   __ _  |  \/  | ___   __| |_   _| | ___ 
#   / _ \ | '__/ __/ _` | '_ \ / _` | | |\/| |/ _ \ / _` | | | | |/ _ \
#  / ___ \| | | (_| (_| | | | | (_| | | |  | | (_) | (_| | |_| | |  __/
# /_/   \_\_|  \___\__,_|_| |_|\__,_| |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                                                      
# Arcana Module
#-------------------------------------------------------------------------------
class RPG::Actor < RPG::BaseItem
  def social_description
    note =~ /<Social description: [\t]*([^\n\r]*)>/ ? $1 : ""
  end
  
  def min_arcana_rank
    # min rank required to fuse persona
    note =~ /<Arcana rank: (\d+)>/ ? $1.to_i : 0
  end

  def arcana
    class_of_nickname = $data_classes.find{|c| !c.nil? && !c.name.empty? && c.name == self.nickname}
    return class_of_nickname if !class_of_nickname.nil?
    return $game_arcanas[self.class_id]
  end
end

class RPG::Class < RPG::BaseItem
  def is_arcana?
    note =~ /<Arcana>/ ? true : false
  end
  
  def rank_var_id
    note =~ /<Rank variable: (\d+)>/ ? $1.to_i : nil
  end
  
  def max_arcana_rank
    note =~ /<Max rank: (\d+)>/ ? $1.to_i : Persona::DEFAULT_MAX_RANK
  end
  
  def arcana_is?(arcana_name)
    arcana_name == self.name
  end
  
  def social_target
    note =~ /<Social target: [\t]*([^\n\r]*)>/ ? $1 : ""
  end
  
  def description
    note =~ /<Description: [\t]*([^\n\r]*)>/ ? $1 : ""
  end
  
  def social_links
    # gathers both actor ids and actor ids from variables and returns them
    actors = social_links_actors
    vars = []
    social_links_variables.each{ |v| vars.push($game_variables[v]) if $game_variables[v] != -1 }
    return (actors + vars).uniq
  end
  
  def social_links_actors
    # return actor ids from tag
    actors = /<Social links actors: (\d+(,\s*\d+)*)?>/.match(note)
    return [] if actors.nil?
    return actors[1].split(",").collect{ |i| i.to_i }
  end
  
  def social_links_variables
    # return variable ids from tag
    vars = /<Social links vars: (\d+(,\s*\d+)*)?>/.match(note)
    return [] if vars.nil?
    return vars[1].split(",").collect{ |i| i.to_i }
  end
end

module Cache
  def self.arcana(filename)
    load_bitmap("Graphics/" + Persona::ARCANA_IMG_FOLDER, filename)
  end
  
  def self.persona_file(filename)
    load_bitmap(Persona::GRAPHICS_DIRECTORY, filename)
  end
end

class Game_Actor < Game_Battler
  attr_reader :social_description, :max_arcana_rank, :min_arcana_rank, :arcana_name
  
  alias persona_arcana_sp setup_persona
  def setup_persona
    persona_arcana_sp
    @social_description = actor.social_description
    has_arcana_from_class = @is_persona ? self.class.is_arcana? : false
    
    # check if a class exists with the same name as the nickname
    arcana_from_nickname = $game_arcanas.get_arcana_by_name(@nickname)
    @has_arcana = has_arcana_from_class or !arcana_from_nickname.nil?
    
    if !arcana_from_nickname.nil?
      # if nickname is of arcana, get the arcana class it belongs to
      arcana_class = arcana_from_nickname
    else
      arcana_class = self.class
    end
    @arcana_name = arcana_class.name

    @max_arcana_rank = arcana_class.max_arcana_rank
    @rank_var_id = arcana_class.rank_var_id
    @min_arcana_rank = actor.min_arcana_rank
  end
  
  alias persona_arcana_cep can_equip_persona
  def can_equip_persona(persona)
    persona.min_arcana_rank <= persona.arcana_rank && persona_arcana_cep(persona)
  end
  
  def has_arcana?
    @has_arcana
  end
  
  def arcana_rank
    $game_variables[@rank_var_id] if is_persona?
  end
  
  def special_persona?
    @is_special_persona
  end
end

class Game_Player < Game_Character
  def arcana_rank_up(arcana_name)
    # increases rank of arcana by one
    arcana = $game_arcanas.get_arcana_by_name(arcana_name)
    return if arcana.nil?
    rank = $game_variables[arcana.rank_var_id]
    rank += 1 
    $game_variables[arcana.rank_var_id] = [[rank, 0].max, arcana.max_arcana_rank].min
  end
  
  def arcana_rank_down(arcana_name)
    # decreases rank of arcana by one
    arcana = $game_arcanas.get_arcana_by_name(arcana_name)
    return if arcana.nil?
    rank = $game_variables[arcana.rank_var_id]
    rank -= 1
    $game_variables[arcana.rank_var_id] = [[rank, 0].max, arcana.max_arcana_rank].min
  end
  
  def arcana_rank_up_by(arcana_name, ranks_up)
    ranks_up.times.do{ arcana_rank_up(arcana_name) }
  end
  
  def arcana_rank_down_by(arcana_name, ranks_down)
    ranks_down.times.do{ arcana_rank_down(arcana_name) }
  end
  
  def available_arcanas
    # returns arcanas which rank is higher than MIN_ARCANA_RANK
    arcanas = $data_classes.select{ |c| !c.nil? && c.is_arcana? && !c.rank_var_id.nil? }
    available_arcanas = arcanas.select{ |a| $game_variables[a.rank_var_id] >= Persona::MIN_ARCANA_RANK }
    return available_arcanas
  end
end

class Game_Variables
  alias :get_current_arcana_rank :[]
  def [](variable_id)
    # In case the variable requested is that of an arcana, we initialize
    # it to 0 if it's not set
    ret_val = get_current_arcana_rank(variable_id)
    
    # get all arcanas that have a variable id for their rank
    arcanas = $data_classes.select{ |c| !c.nil? && c.is_arcana? && !c.rank_var_id.nil? }
    var_id_points_to_arcana_rank = arcanas.map{|c| c.rank_var_id}.include?(variable_id)
    
    if var_id_points_to_arcana_rank
      return @data[variable_id] || Persona::MIN_ARCANA_RANK - 1
    else
      return ret_val
    end
  end
end

class Window_ArcanaInfo < Window_Base
  def initialize(arcana)
    super(0, 0, window_width, window_height)
    @selected_arcana = arcana
    self.openness = 0
  end
  
  def window_width
    Graphics.width
  end
  
  def window_height
    Graphics.height * 0.35
  end

  def refresh
    contents.clear
    return if @selected_arcana.nil?
    arcana_rect = draw_arcana(0, 0)
    social_target_rect = draw_social_target(0)
    arcana_name_rect = draw_arcana_name(arcana_rect.width + standard_padding, 0)
    arcana_name_end_x = (arcana_name_rect.x + arcana_name_rect.width)
    rank_x = (social_target_rect.x - arcana_name_end_x) / 2
    draw_arcana_rank(arcana_name_end_x + rank_x, 0)
    draw_arcana_info(arcana_rect.width + standard_padding, arcana_name_rect.y + arcana_name_rect.height + standard_padding)
  end
  
  def draw_arcana(x, y)
    bitmap = Cache.arcana(@selected_arcana.name)
    resize_ratio = [1.0, (window_height.to_f - y - standard_padding*2) / bitmap.height].min
    new_w = bitmap.width * resize_ratio
    new_h = (bitmap.height * resize_ratio) - 2
    new_rect = Rect.new(x, y, new_w, new_h)
    contents.stretch_blt(new_rect, bitmap, bitmap.rect)
    bitmap.dispose
    return new_rect
  end
  
  def draw_arcana_rank(x, y)
    rank = $game_variables[@selected_arcana.rank_var_id]
    rank_str = "Rank #{rank}"
    w = text_size(rank_str).width
    h = text_size(rank_str).height
    draw_text(x, y, w, h, rank_str)
  end
  
  def draw_arcana_name(x, y)
    text = @selected_arcana.name
    size = text_size(text)
    w = size.width
    h = size.height
    text_rect = Rect.new(x, y, w, h)
    draw_text(text_rect, text)
    return text_rect
  end

  def draw_social_target(y)
    if @selected_arcana.social_target.empty?
      social_target = ""
    else
      social_target = @selected_arcana.social_target
    end

    size = text_size(social_target)
    w = size.width
    h = size.height
    x = window_width - w
    social_target_rect = Rect.new(x, y, w, h)
    draw_text(social_target_rect, social_target)
    return social_target_rect
  end
  
  def draw_arcana_info(x, y)
    text = @selected_arcana.description
    return if text.empty?
    
    words = text.split(" ")
    line_num = 0
    
    text_line = words[0]
    for i in 1..words.size
      if i == words.size
        w = window_width - x
        h = line_height
        draw_text(x, y + line_num*h, w, h, text_line)
        break
      end
      
      new_text = text_line + " " + words[i]
      line_size = text_size(new_text)
      if line_size.width + x > window_width
        w = line_size.width
        h = line_height
        draw_text(x, y + line_num*h, w, h, text_line)
        line_num += 1
        text_line = words[i]
      else
        text_line += (" " + words[i])
      end
    end
  end
  
  def draw_item_background(index)
    if index == @pending_index
      contents.fill_rect(item_rect(index), pending_color)
    end
  end
end

class Window_Arcanas < Window_Command
  include Persona
  
  def initialize
    @arcanas = $game_player.available_arcanas
    load_bitmaps
    super(0, 0)
    select_last
    @selected_arcana = nil
    self.openness = 0
    select_last
  end
  
  def load_bitmaps
    @progress_bar = Cache.persona_file(ARCANA_RANKS_BAR_IMG_NAME)
    @subbar_empty = Cache.persona_file(ARCANA_PROGRESS_EMPTY_IMG_NAME)
    @subbar_filled = Cache.persona_file(ARCANA_PROGRESS_IMG_NAME)
  end
  
  def dispose
    super
    dispose_bitmaps
  end
  
  def dispose_bitmaps
    @progress_bar.dispose
    @subbar_empty.dispose
    @subbar_filled.dispose
  end
  
  def refresh
    contents.clear
    draw_all_items
    select_last
  end
  
  def window_width
    Graphics.width
  end
  
  def window_height
    Graphics.height
  end
  
  def item_width
    (width - standard_padding * 2 + spacing) / col_max - spacing
  end
  
  def item_height
    (height - standard_padding * 2) / visible_line_number
  end
  
  def visible_line_number
    3
  end
  
  def item_max
    @arcanas.size
  end
  
  def process_handling
    return unless open? && active
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return if @arcanas.empty?
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
  end
  
  def process_ok
    call_show_rank_handler
  end
  
  def call_rank_handler
    call_handler(:show_rank)
  end

  def rank_enabled?
    handle?(:show_rank)
  end
  
  def draw_item(index)
    arcana = @arcanas[index]
    
    rect = item_rect(index)
    draw_item_background(index)
    arcana_card_rect = draw_arcana(arcana, rect.x + 1, rect.y + 1)
    draw_arcana_rank(arcana, rect.x + arcana_card_rect.width + 5, rect.y + 1)
    draw_arcana_name(arcana_card_rect.width + rect.x + 5, rect.y, index)
  end
  
  def draw_arcana(arcana, x, y)
    bitmap = Cache.arcana(arcana.name)
    resize_ratio = [1.0, item_height.to_f / bitmap.height].min
    new_w = bitmap.width * resize_ratio
    new_h = (bitmap.height * resize_ratio) - 2
    new_rect = Rect.new(x, y, new_w, new_h)
    contents.stretch_blt(new_rect, bitmap, bitmap.rect)
    bitmap.dispose
    return new_rect
  end
  
  def draw_arcana_rank(arcana, x, y)
    start_x = x
    start_y = y

    rank = $game_variables[arcana.rank_var_id]
    rank_str = sprintf("Rank %i", rank)
    rank_text_size = text_size(rank_str)
    draw_text(x + (x - item_width).abs - rank_text_size.width, start_y, rank_text_size.width, rank_text_size.height, rank_str)

    start_y += rank_text_size.height

    bar_width = contents.width - start_x - 5
    rect = Rect.new(start_x, start_y, bar_width, @progress_bar.height)
    contents.stretch_blt(rect, @progress_bar, @progress_bar.rect)

    subbar_width = bar_width.to_f / arcana.max_arcana_rank

    start_y += (@progress_bar.height - @subbar_filled.height) / 2
    arcana_rank = $game_variables[arcana.rank_var_id]

    arcana_rank.times do |i|
      draw_rank_progress(start_x, start_y, i, subbar_width)
    end

    (arcana_rank...arcana.max_arcana_rank).each do |i|
      draw_rank_remaining(start_x, start_y, i, subbar_width)
    end
  end

  def draw_rank_progress(x, y, index, width)
    offset_x =  width * index
    height = @subbar_filled.height
    rect = Rect.new(x + offset_x, y, width, height)
    contents.stretch_blt(rect, @subbar_filled, @subbar_filled.rect)
  end
  
  def draw_rank_remaining(x, y, index, width)
    offset_x =  width * index
    height = @subbar_empty.height
    rect = Rect.new(x + offset_x, y, width, height)
    contents.stretch_blt(rect, @subbar_empty, @subbar_empty.rect)
  end
  
  def draw_arcana_name(x, y, index)
    arcana = @arcanas[index]
    name = arcana.name
    w = text_size(name).width
    h = text_size(name).height
    draw_text(x, y, w, h, name)
  end
  
  def draw_item_background(index)
    if index == @pending_index
      contents.fill_rect(item_rect(index), pending_color)
    end
  end
  
  def current_item_enabled?
    return true
  end
  
  def process_ok
    super
    @selected_arcana = @arcanas[index]
  end
  
  def select_last
    if @arcanas.empty?
      select(-1)
    else
      select(0)
    end
  end
  
  def pending_index=(index)
    last_pending_index = @pending_index
    @pending_index = index
    redraw_item(@pending_index)
    redraw_item(last_pending_index)
  end
  
  def selected_arcana
    return @arcanas[@index]
  end
end

class Window_MenuCommand < Window_Command
  alias persona_arcana_mc make_command_list
  def make_command_list
    persona_arcana_mc
    add_arcana_command
  end
  
  def add_arcana_command
    return if Persona::ARCANA_MENU_COMMAND_INDEX.nil?
    # add arcana command to main menu
    name = Persona::ARCANA_MENU_NAME
    ext = nil
    command = { :name=>name, 
                :symbol=>:social_links, 
                :enabled=>main_commands_enabled, 
                :ext=>ext}
    index = Persona::ARCANA_MENU_COMMAND_INDEX - 1
    index = [index, @list.length].min
    @list.insert(index, command)
  end
end

class Window_SocialLinkInfo < Window_Base
  def initialize(x, y, social_link)
    @window_height = line_height * 4
    @window_width = Graphics.width - x
    y = Graphics.height - @window_height
    super(x, y, @window_width, @window_height)
    @social_link = social_link
    self.openness = 0
  end
  
  def social_link=(new_link)
    @social_link = new_link
    refresh
  end
  
  def window_width
    @window_width
  end
  
  def window_height
    @window_height
  end
  
  def draw_link_name
    name = @social_link.name
    w = window_width
    h = text_size(name).height
    draw_text(0, 0, w, h, name)
  end
  
  def draw_link_info
    text = @social_link.social_description
    
    words = text.split(" ")
    text_line = words[0]
    line_num = 1
    words.size.times do |i|
      if i == words.size - 1
        line_size = text_size(text_line)
        w = window_width
        h = line_size.height
        draw_text(0, line_num*h, w, h, text_line)
        break
      end
      
      new_line = text_line + " " + words[i + 1]
      line_size = text_size(new_line)
      if line_size.width > window_width - standard_padding * 2
        w = line_size.width
        h = line_size.height
        draw_text(0, line_num*h, w, h, text_line)
        line_num += 1
        text_line = words[i + 1]
      else
        text_line += ((text_line.size == 0 ? "" : " ") + words[i + 1])
      end
    end
  end
  
  def refresh
    contents.clear
    return if @social_link.nil?
    draw_link_name
    draw_link_info
  end
end

class Window_SocialLinks < Window_Command
  def initialize(arcana, x, y)
    @arcana = arcana
    @social_links_ids = @arcana.social_links
    super(x, y)
    select_last
    self.openness = 0
  end
  
  def arcana=(arcana)
    return if @arcana == arcana
    @arcana = arcana
    @social_links_ids = @arcana.social_links
    refresh
    select_last
  end
  
  def selected_social_link
    return nil if @social_links_ids[@index].nil?
    $game_actors[@social_links_ids[@index]]
  end
  
  def refresh
    contents.clear
    draw_all_items
  end
  
  def window_width
    Graphics.width * 0.3
  end
  
  def window_height
    [@arcana.social_links.size, 1].max * line_height + standard_padding * 2
  end
  
  def item_width
    (width - standard_padding * 2 + spacing) / col_max - spacing
  end
  
  def item_height
    (height - standard_padding * 2) / visible_line_number
  end
  
  def visible_line_number
    @arcana.social_links.size == 0 ? 1 : @arcana.social_links.size
  end
  
  def item_max
    @arcana.social_links.size
  end
  
  def process_handling
    return unless open? && active
    return true if Input.trigger?(:C)
    super
  end
  
  def draw_item(index)
    return if @social_links_ids.size == 0
    social_link = @social_links_ids[index]
    social_link = $game_actors[social_link]
    
    rect = item_rect_for_text(index)
    draw_actor_name(social_link, rect.x + 1, rect.y + 1, window_width - standard_padding)
  end
  
  alias persona_arcana_pcm process_cursor_move
  def process_cursor_move
    last_index = @index
    persona_arcana_pcm
    if @index != last_index
      call_handler(:selection_changed)
    end
  end
  
  def select_last
    select(0)
  end
  
  def pending_index=(index)
    last_pending_index = @pending_index
    @pending_index = index
    redraw_item(@pending_index)
    redraw_item(last_pending_index)
  end
  
  def update
    super
    self.hide if @arcana.social_links.size == 0
  end
end

class Sprite_SocialLink < Sprite
  def initialize(viewport, name)
    viewport.z = 100
    super(viewport)
    @name = name
    update_bitmap
  end
  
  def dispose
    bitmap.dispose if bitmap
    super
  end
  
  def update_bitmap
    if @name.nil?
      self.bitmap = nil
    else
      self.bitmap = Cache.picture(@name)
    end
  end
end

class Scene_Arcanas < Scene_Base
  def start
    super
    create_background
    create_rank_window
  end
  
  def terminate
    super
    dispose_background
  end
  
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
  
  def dispose_background
    @background_sprite.dispose
  end
  
  def create_rank_window
    @arcanas_window = Window_Arcanas.new
    @arcanas_window.select_last
    @arcanas_window.set_handler(:ok, method(:on_arcana_ok))
    @arcanas_window.set_handler(:cancel, method(:return_scene))
    @arcanas_window.open
  end
  
  def create_social_links_window
    arcana = @arcanas_window.selected_arcana
    x = 0
    y = @info_window.height
    @social_links_window = Window_SocialLinks.new(arcana, x, y)
    @social_links_window.select_last
    @social_links_window.refresh
    @social_links_window.set_handler(:cancel, method(:arcana_info_cancel))
    @social_links_window.set_handler(:selection_changed, method(:social_link_changed))
    @social_links_window.open
  end
  
  def create_description_window
    @info_window = Window_ArcanaInfo.new(@arcanas_window.selected_arcana)
    @info_window.refresh
    @info_window.open
  end
  
  def create_social_link_info_window
    return if @social_links_window.selected_social_link.nil?
    x = @social_links_window.width
    y = @social_links_window.y + @social_links_window.height
    social_link = @social_links_window.selected_social_link
    @social_link_info_window = Window_SocialLinkInfo.new(x, y, social_link)
    @social_link_info_window.refresh
    @social_link_info_window.open
  end
  
  def change_social_link
    @social_link.dispose if @social_link
    return if @social_links_window.selected_social_link.nil?
    social_link = @social_links_window.selected_social_link
    file_name = social_link.name.downcase.gsub(" ", "_")
    @social_link = Sprite_SocialLink.new(@viewport, file_name)
    x = @social_links_window.width
    @social_link.x = x + (Graphics.width - x) / 2 - @social_link.width / 2
    @social_link.y = @info_window.height
  end
  
  def social_link_changed
    @social_link_info_window.social_link = @social_links_window.selected_social_link
    change_social_link
  end
  
  def on_arcana_ok
    @arcanas_window.hide
    create_description_window
    create_social_links_window
    change_social_link
    create_social_link_info_window
  end
  
  def arcana_info_cancel
    @social_links_window.close
    @info_window.close
    @social_link_info_window.close if @social_link_info_window
    @social_link.dispose if @social_link
    @arcanas_window.show
    @arcanas_window.active = true
  end
end

class Scene_Menu < Scene_MenuBase
  alias persona_arcana_ccw create_command_window
  def create_command_window
    persona_arcana_ccw
    add_social_links_command
  end

  def add_social_links_command
    @command_window.set_handler(:social_links,    method(:social_links))
  end
  
  def social_links
    SceneManager.call(Scene_Arcanas)
  end
end

#-------------------------------------------------------------------------------
#  _____            _       _   _               __  __           _       _      
# | ____|_   _____ | |_   _| |_(_) ___  _ __   |  \/  | ___   __| |_   _| | ___ 
# |  _| \ \ / / _ \| | | | | __| |/ _ \| '_ \  | |\/| |/ _ \ / _` | | | | |/ _ \
# | |___ \ V / (_) | | |_| | |_| | (_) | | | | | |  | | (_) | (_| | |_| | |  __/
# |_____| \_/ \___/|_|\__,_|\__|_|\___/|_| |_| |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                                                               
# Evolution Module
#-------------------------------------------------------------------------------
class RPG::Actor < RPG::BaseItem
  def evolve_at
    note =~ /<Arcana evolve rank: (\d+)>/ ? $1.to_i : -1
  end
  
  def evolve_to
    note =~ /<Evolve to: (.*)>/ ? $1 : ""
  end
end

class Game_Actor < Game_Battler
  attr_reader :evolve_at, :evolve_to
  alias persona_evolve_sp setup_persona
  def setup_persona
    persona_evolve_sp
    @evolve_at = has_arcana? ? actor.evolve_at : -1
    @evolve_to = has_arcana? ? actor.evolve_to : ""
  end

  def can_evolve?
    return (arcana_rank == @evolve_at and @evolve_to != "")
  end
end

class Game_Player < Game_Character
  alias persona_evolve_aru arcana_rank_up
  def arcana_rank_up(arcana_name)
    persona_evolve_aru(arcana_name)
    check_party_persona_evolve
  end
  
  def check_party_persona_evolve
    personas = $game_party.personas
    personas.each do |p|
      if p.can_evolve?
        # Re equip persona if was already equipped
        user = p.current_user
        user.remove_persona if !user.nil?
        evolved_persona = evolve_persona(p)
        play_evolution(p.id)
        $game_party.menu_persona = evolved_persona
        user.change_persona(evolved_persona) if !user.nil?
        SceneManager.call(Scene_EvolvedPersona)
      end      
    end
  end
  
  def evolve_persona(persona)
    $game_party.remove_persona_by_id(persona.id)
    evolved_persona = $game_personas.get_by_name(persona.evolve_to)
    $game_party.add_persona_by_id(evolved_persona.id)
    $game_variables[Persona::EVOLVING_PERSONA_VAR_ID] = persona.name
    $game_variables[Persona::RESULTING_PERSONA_VAR_ID] = evolved_persona.name
    return evolved_persona
  end
  
  def play_evolution(actor_id)
    common_event_id = Persona::COMMON_EVENT_ID[actor_id]
    common_event = $data_common_events[common_event_id]
    if common_event
      child = Game_Interpreter.new
      child.setup(common_event.list, 0)
      child.run
    end
  end
end

class Scene_EvolvedPersona < Scene_Base
  def start
    super
    create_background
    @persona = $game_party.menu_persona
    show_evolved
  end
  
  def show_evolved
    create_status_window
    @status_window.persona = @persona
    @status_window.activate
    @status_window.open
  end
  
  def terminate
    super
    dispose_background
  end
  
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
  
  def dispose_background
    @background_sprite.dispose
  end
  
  def create_status_window
    @status_window = Window_PersonaStatus.new($game_party.menu_persona)
    @status_window.set_handler(:ok,   method(:close_status))
    @status_window.set_handler(:cancel,   method(:close_status))
    @status_window.show.activate
  end
  
  def close_status
    @status_window.close
    SceneManager.return
  end
end

#-------------------------------------------------------------------------------
#  _____          _               __  __           _       _      
# |  ___|   _ ___(_) ___  _ __   |  \/  | ___   __| |_   _| | ___ 
# | |_ | | | / __| |/ _ \| '_ \  | |\/| |/ _ \ / _` | | | | |/ _ \
# |  _|| |_| \__ \ | (_) | | | | | |  | | (_) | (_| | |_| | |  __/
# |_|   \__,_|___/_|\___/|_| |_| |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                                                 
# Fusion Module
#-------------------------------------------------------------------------------
class RPG::Actor < RPG::BaseItem
  attr_reader :parents

  def fusion_parents
    # matches all the <Fusion parents> tag in note
    matches = note.scan(/<Fusion parents: (\d+),\s*(\d+)>/)
    return [] if matches.empty?
    return matches[0].map{|m| m.to_i}
  end
  
  def special_fusion_parents
    matches = note.scan(/<Special fusion: (\d+),\s*(\d+),\s*(\d+)>/)
    return [] if matches.empty?
    return matches[0].map{|m| m.to_i}
  end
  
  def fusion_conditions
    matches = note.scan(/<Fusion arcana ranks: (\d+),\s*(\d+)(?:,\s*(\d+))?>/)
    arcana_ranks = matches.empty? ? [0, 0, 0] : matches[0].map{|m| m.to_i}

    user_level = note =~ /<Fusion user level: (\d+)/ ? $1.to_i : 0

    item_id = note =~ /<Fusion item id: (\d+)/ ? $1.to_i : 0
    
    user_condition_formula = note =~ /<Fusion condition: *.>/ ? $1 : nil
    
    return {
      :arcana_ranks => arcana_ranks,
      :user_level => user_level,
      :item_id => item_id,
      :user_condition_formula => user_condition_formula
    }
  end

  def from_special_fusion?
    return !special_fusion_parents.empty?
  end

  def are_parents(potential_parents)
    return false if potential_parents.nil? || potential_parents.empty?

    parents = fusion_parents or special_fusion_parents
    
    return false if parents.nil?
    
    if Persona::ORDER_MATTERS
      return !parents.index(potential_parents).nil?
    else
      for pair in parents
        return true if potential_parents.map{|p| pair.include?(p)}.all?
      end
      return false
    end
  end
end

class Game_System
  attr_reader :fuse_count
  alias persona_fuse_init initialize
  def initialize
    persona_fuse_init
    @fuse_count = 0
  end
  
  def fuse_personas(fuse_count)
    @fuse_count = fuse_count
    SceneManager.call(Scene_Fusion)
    Fiber.yield
  end
end

class Window_ExtraExp < Window_Base
  def initialize(x, y)
    height = line_height * 2
    super(x, y, 180, height)
    @current_exp = 0
    @exp_changed = false
    self.openness = 0
  end
  
  def set_width(txt)
    contents.clear
    if text_size(txt).width > self.width - standard_padding * 2
      self.width = text_size(txt).width + standard_padding * 2
      create_contents
    end
  end
  
  def text=(txt)
    draw_text(0, 0, self.width - standard_padding, line_height, txt)
  end
  
  def exp=(exp)
    @current_exp = exp
    @exp_changed = true
  end
  
  def update
    super
    update_exp if @exp_changed
  end
  
  def update_exp
    contents.clear
    draw_text(0, 0, self.width - standard_padding, line_height, "Bonus EXP:")
    x = text_size("Bonus EXP:").width
    draw_text(x - 10, 0, self.width - standard_padding - x, line_height, @current_exp, 2)
  end
end

class Window_FusionParents < Window_Personas
  attr_reader :result_data, :fusion_results_data, :selected_personas
  def initialize(fuse_count)
    @selected_personas = []
    @fuse_count = fuse_count
    @fusion_results_data = []
    @result_data = nil
    super($game_party.menu_actor, full_screen=false, lazy_load=true)
    self.visible = true
    select_last
  end
  
  def personas
    actors = $game_party.members.select{ |a| Persona::CAN_FUSE_ACTORS_PERSONAS.include?(a.id) }
    personas = []
    for actor in actors
      actors_personas = $game_party.actors_personas(actor.id)
      # Don't include the exclusive persona if it's not allowed
      next if !actor.has_exclusive_persona? && !Persona::CAN_FUSE_EXCLUSIVE_PERSONAS 
      personas.concat(actors_personas)
    end
    return personas
  end
  
  def pop_persona
    @selected_personas.pop
    @result_data = nil
    @fusion_results_data = []
    refresh
  end
  
  def reset
    self.active = true
    select_last
    @selected_personas = []
    @fusion_results_data = []
    @result_data = nil
    refresh
  end
  
  def refresh_children
    @fusion_results_data.clear

    return if @fuse_count - 1 != @selected_personas.length
    
    def conditions_met?(fusion_data)
      return fusion_data[:conditions].empty? ? true : $game_personas.fusion_conditions_met?(fusion_data)
    end

    for last_parent in self.personas
      if @selected_personas.include?(last_parent)
        @fusion_results_data.push(nil) 
      else
        parents = @selected_personas + [last_parent]
        fusion_data = $game_personas.get_fusion_data(*parents.map{|p| p.id})

        if fusion_data.nil? || !conditions_met?(fusion_data)
          @fusion_results_data.push(nil)
        else
          @fusion_results_data.push(fusion_data)
        end
      end
    end
  end
  
  def window_width
    Graphics.width / 2
  end
  
  def window_height
    Graphics.height
  end
  
  def process_handling
    return unless open? && active
    return process_status   if status_enabled?    && Input.trigger?(:X)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
  end
  
  def process_status
    Sound.play_ok
    $game_party.menu_persona = self.personas[index]
    call_status_handler
  end
  
  def call_status_handler
    call_handler(:status)
  end

  def status_enabled?
    handle?(:status)
  end
  
  def process_cancel
    Sound.play_cancel
    Input.update
    pop_persona
    call_cancel_handler
    refresh
  end
  
  def call_cancel_handler
    call_handler(:cancel)
  end
  
  def cancel_enabled?
    handle?(:cancel)
  end
  
  def call_return_handler
    call_handler(:return)
  end
  
  def refresh
    refresh_children
    super
  end

  def process_ok
    if self.personas.size == 0
      Sound.play_cancel
      return
    end
    persona = self.personas[index]
    if fusion_selection_valid?(index)
      @selected_personas.push(persona)
      Sound.play_ok
      if @selected_personas.size == @fuse_count
        # the result has the same index with the last persona picked
        @result_data = @fusion_results_data[index]
      end
      refresh
      call_ok_handler
    else
      Audio.se_play(*Persona::PERSONA_INVALID_EQUIP_SOUND)
    end
  end
  
  def call_fuse_handler
    call_handler(:fuse)
  end
  
  def fuse_enabled?
    handle?(:fuse)
  end
  
  def command_enabled?(index)
    return Persona::CAN_FUSE_EXCLUSIVE_PERSONAS if !self.personas[index].current_user.nil? && self.personas[index].current_user.has_exclusive_persona?
    return fusion_selection_valid?(index)
  end

  def fusion_selection_valid?(index)
    return false if !@selected_personas.index(self.personas[index]).nil?
    return true if @selected_personas.empty? || @selected_personas.length < @fuse_count - 1
    # as long as a child can be created with this one and 
    # the result does not exist in the party
    return false if @fusion_results_data[index].nil?
    data = @fusion_results_data[index]
    return !$game_party.persona_in_party(nil, data[:result])
  end

  def draw_item_background(index)
    if !@selected_personas.index(self.personas[index]).nil?
      color = pending_color
      color.alpha = 100
      contents.fill_rect(item_rect(index), color)
    end
  end
  
  def select_last
    select(0)
  end
  
  def pending_index=(index)
    last_pending_index = @pending_index
    @pending_index = index
    redraw_item(@pending_index)
    redraw_item(last_pending_index)
  end
end

class Window_FusionChildren < Window_Personas
  include Persona
  
  def initialize
    @actor = nil
    @fusion_results_data = [nil]
    super($game_party.menu_actor, full_screen=false, lazy_load=true)
    self.x = Graphics.width / 2
    self.visible = true
    self.arrows_visible = false
    deactivate
    unselect
  end

  def personas
    @fusion_results_data.map{|f| f.nil? ? nil : $game_personas[f[:result]]}
  end

  def process_handling
    return
  end
  
  def top_row=(row)
    super(row)
    draw_around_current_index
  end

  def update
    super
  end

  def update_cursor
    return
  end
  
  def actor=(actor)
    return
  end

  def fusion_results_data=(fusion_results_data)
    @fusion_results_data = fusion_results_data
    refresh
  end
  
  def command_enabled?(index)
    return true
  end

  def draw_item(index)
    persona = self.personas[index]
    return if persona.nil?
    super(index)
  end

  def draw_item_background(index)
    return if @fusion_results_data.nil? || @fusion_results_data[index].nil?
    result_id = @fusion_results_data[index][:result]
    parents = @fusion_results_data[index][:parents]
    persona = $game_personas[result_id]
    if parents.compact.length == 3
      contents.fill_rect(item_rect(index), Persona::SPECIAL_FUSION_COLOR)
    end
  end

  def draw_no_personas_msg
    return
  end
end

class Window_PersonaStatus < Window_Command 
  alias persona_fuse_init initialize
  def initialize(persona, enable_cursor=false)
    persona_fuse_init(persona)
    @bonus_exp = 0
    @start_exp = false
    @step = 0
    @ok_enabled = false
    @exp_diffuse_duration_frames = 60
    @skip_exp = false
  end
  
  def disable_ok
    @ok_enabled = false
  end
  
  def enable_ok
    @ok_enabled = true
  end
  
  alias persona_ph process_handling
  def process_handling
    if SceneManager.scene_is?(Scene_Fusion)
      return process_ok   if ok_enabled? && Input.trigger?(:C)
      return process_cancel if cancel_enabled? && Input.trigger?(:B)
    else
      persona_ph
    end
  end
  
  def ok_enabled?
    handle?(:ok) && @ok_enabled && self.open?
  end
  
  def process_ok
    Sound.play_ok
    Input.update
    deactivate
    call_ok_handler
  end
  
  def bonus_exp=(exp)
    @bonus_exp = exp
    @skip_exp = false
    @step = @bonus_exp/@exp_diffuse_duration_frames
  end
  
  def bonus_exp
    @bonus_exp
  end
  
  def done_exp
    @bonus_exp == 0
  end
  
  alias persona_fuse_u update
  def update
    update_bonus_exp
    persona_fuse_u
  end
  
  def start_exp
    @start_exp = true
  end
  
  def skip_exp
    @skip_exp = true
  end

  def update_bonus_exp
    if @start_exp
      if @skip_exp
        new_exp = (@persona.exp + @bonus_exp * @persona.final_exp_rate).to_i
        @bonus_exp = 0
      else
        @bonus_exp = [@bonus_exp-@step, 0].max
        new_exp = @persona.exp + ([@step, @bonus_exp].min * @persona.final_exp_rate).to_i
      end
      # use change_exp to avoid exp rate to be taken into account
      @persona.change_exp(new_exp, false)
      @start_exp = @bonus_exp != 0
      refresh
    end
  end
end

class Scene_Fusion < Scene_Base
  def start
    super
    @exit_on_next_cancel = true
    create_background
    create_fuse_window
    create_result_window
    create_message_window
    create_extra_exp_window
    create_status_window
  end
  
  def terminate
    super
    dispose_background
  end
  
  def create_extra_exp_window
    @extra_exp_window = Window_ExtraExp.new(350, 24 * 5)
  end
  
  def create_message_window
    $game_message.clear
    @message_window = Window_Message.new
    @choice = -1
  end
  
  def create_fuse_window
    @fuse_window = Window_FusionParents.new($game_system.fuse_count)
    @fuse_window.select_last
    # called when a new persona is selected
    @fuse_window.set_handler(:ok, method(:on_process_ok))
    # called when there are selected personas and removes the last chosen one
    @fuse_window.set_handler(:cancel, method(:on_process_cancel))
    # shows the selected persona's status
    @fuse_window.set_handler(:status, method(:show_persona_status))
    @fuse_window.z -= 2
  end
  
  def create_status_window
    @status_window = Window_PersonaStatus.new($game_party.menu_persona)
    # called when viewing a persona's status and returns to fuse windows
    @status_window.set_handler(:cancel,   method(:return_status))
    @status_window.deactivate.close.unselect
    @status_window.disable_ok
    @status_window.z -= 1
  end
  
  def create_result_window
    @results_window = Window_FusionChildren.new
    @results_window.z -= 2
  end

  def show_persona_status
    @status_window.persona = @fuse_window.personas[@fuse_window.index]
    @status_window.show.activate.enable_ok
    @status_window.open
    @fuse_window.deactivate
  end
  
  def on_process_ok
    if @fuse_window.selected_personas.size < $game_system.fuse_count
      @exit_on_next_cancel = false
      @results_window.fusion_results_data = @fuse_window.fusion_results_data
    elsif @fuse_window.selected_personas.size == $game_system.fuse_count
      @exit_on_next_cancel = false
      show_fusion_result
      ask_fusion_confirmation
    end
  end

  def on_process_cancel
    if @exit_on_next_cancel && @fuse_window.selected_personas.length == 0
      @fuse_window.deactivate
      return_scene
    else
      @results_window.fusion_results_data = @fuse_window.fusion_results_data
      @exit_on_next_cancel = @fuse_window.selected_personas.length == 0
    end
  end
  
  def on_fuse_cancel
    @status_window.disable_ok
  end
  
  def wait_for_message
    @status_window.deactivate.disable_ok
    @message_window.open
    @message_window.activate
    @message_window.update
    update_basic while $game_message.visible
    @status_window.activate
  end
  
  def show_fusion_result
    resulting_persona_id = @fuse_window.result_data[:result]
    resulting_persona = $game_personas[resulting_persona_id]
    @status_window.persona = resulting_persona
    @status_window.show.activate.enable_ok
    @status_window.open
    @fuse_window.deactivate
    
    bonus_exp = Persona.FUSION_EXP_CALC(resulting_persona).to_i
    @status_window.bonus_exp = bonus_exp
    txt = "Bonus EXP:"
    @extra_exp_window.text = txt
    @extra_exp_window.exp = bonus_exp
    @extra_exp_window.set_width("Bonus EXP:#{bonus_exp}")
    @extra_exp_window.show
  end
  
  def return_status
    return if @message_window.open?
    @status_window.deactivate.close.disable_ok
    @fuse_window.activate
    if !@fuse_window.result_data.nil?
      # Viewing the result of the fusion
      @extra_exp_window.close
      @fuse_window.pop_persona
      @results_window.fusion_results_data = @fuse_window.fusion_results_data
    end
  end
  
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
  
  def dispose_background
    @background_sprite.dispose
  end 
  
  def update
    super
    @results_window.index = @fuse_window.index
    @results_window.top_row = @fuse_window.top_row
  end

  def wait_for_exp
    @status_window.start_exp
    while !@status_window.done_exp
      @extra_exp_window.exp= @status_window.bonus_exp

      @extra_exp_window.update
      @status_window.update
      Graphics.update
      Input.update

      if Input.trigger?(:C) || Input.trigger?(:B)
        @status_window.skip_exp
      end
    end
    @extra_exp_window.exp = @status_window.bonus_exp
    
    @extra_exp_window.update
    @status_window.update
  end
  
  def on_fuse_confirm
    parents = @fuse_window.selected_personas
    parents_users = parents.select{|p| p.current_user}
    first_user = parents_users.empty? ? nil : parents_users[0]
    parents_str = parents.collect{|p| p.name }.join(" + ")
    fusion_data = @fuse_window.result_data
    
    $game_message.add("Fused #{parents_str} into\n#{@status_window.persona.name}!")
    wait_for_message
    
    for persona in parents
      $game_party.remove_persona_by_id(persona.id)
    end
    
    $game_party.add_persona_by_id(@status_window.persona.id)
    first_user.change_persona(@status_window.persona) if !first_user.nil?
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

  def on_fuse_deny
    @message_window.close
    @status_window.close
    @extra_exp_window.close
    @choice = -1
    @fuse_window.pop_persona
    @fuse_window.activate
    @results_window.fusion_results_data = @fuse_window.fusion_results_data
  end

  def run_skill_forget_if_needed(persona)
    if persona.extra_skills.size > 0
      @status_window.deactivate.close
      @extra_exp_window.close
      while @status_window.openness > 0
        @status_window.update 
        @extra_exp_window.update
      end
      $game_party.menu_persona = persona
      SceneManager.call(Scene_ForgetSkill)
    end
  end
  
  def ask_fusion_confirmation
    return if $game_message.choice_proc == 0 # return if already accepted fusion
    return if @fuse_window.result_data.nil?
    @fuse_window.deactivate
    @extra_exp_window.open
    resulting_persona_id = @fuse_window.result_data[:result]
    resulting_persona = $game_personas[resulting_persona_id]
    show_message_with_choices(
      [
        "Are you sure you want to create the #{resulting_persona.name}",
        "#{Persona::PERSONA_MENU_NAME.capitalize}"
      ],
      ["Yes", "No"],
      2
    )
    wait_for_message
    if @choice == 0
      wait_for_exp
      on_fuse_confirm
    else
      on_fuse_deny
    end
  end
end

#-------------------------------------------------------------------------------
#  ____  _            __  __ _        __  __           _       _      
# / ___|| |__  _   _ / _|/ _| | ___  |  \/  | ___   __| |_   _| | ___ 
# \___ \| '_ \| | | | |_| |_| |/ _ \ | |\/| |/ _ \ / _` | | | | |/ _ \
#  ___) | | | | |_| |  _|  _| |  __/ | |  | | (_) | (_| | |_| | |  __/
# |____/|_| |_|\__,_|_| |_| |_|\___| |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                                                     
# Shuffle Module
#-------------------------------------------------------------------------------
class RPG::Enemy < RPG::BaseItem
  def drop_cards
    return note.scan(/<Card drop: (.*), ([0-9][.]?[0-9]+)>/)
  end
end

module Cache
  def self.card(filename)
    load_bitmap("Graphics/" + Persona::CARD_IMG_FOLDER, filename)
  end
end

class Scene_Battle < Scene_Base
  def hide_actor_window
    @status_window.hide
    10.times do
      @status_window.update
    end
  end
end

module BattleManager
  class <<self
    
    attr_reader :cards_dropped
    
    alias persona_shuffle_pv process_victory
    def process_victory
      @cards_dropped = $game_troop.make_drop_cards
      
      @cards_dropped = $game_system.prepare_cards(@cards_dropped)
      
      if not Persona::SHUFFLE_TIME_ENABLED or @cards_dropped.empty?
        persona_shuffle_pv
        return
      end

      SceneManager.scene.hide_actor_window
      cards = $game_system.get_cards()
      shuffle_method = $game_system.get_shuffle_method(cards)
      case shuffle_method
      when "Matching"
        SceneManager.call(Scene_ShuffleMatching)
      when "Horizontal"
        SceneManager.call(Scene_ShuffleHorizontalRotating)
      when "Diagonal"
        SceneManager.call(Scene_ShuffleDiagonalRotating)
      when "Combination"
        # Defaults to combination
        SceneManager.call(Scene_ShuffleRotating)
      end
      SceneManager.scene.cards = cards
      SceneManager.scene.start

      if $game_system.shuffle_result == "Penalty"
        # if player drew a penalty card then skip battle rewards
        $game_message.add(Persona::PENALTY_CARD_RESULT_MSG)
        $game_message.add(sprintf(Vocab::Victory, $game_party.name))
        wait_for_message
        SceneManager.return
        battle_end(0)
        replay_bgm_and_bgs
        return true
      else
        if $game_system.shuffle_result == ""
          $game_message.add(Persona::NO_CARD_RESULT_MSG)
        elsif $game_system.shuffle_result == "Blank"
          $game_message.add(Persona::BLANK_CARD_RESULT_MSG)
        elsif $game_system.shuffle_result == "Duplicate"
          $game_message.add(Persona::DUPLICATE_PERSONA_RESULT_MSG)
        end
      end
      
      SceneManager.scene.main
      Graphics.transition(30)
      persona_shuffle_pv
    end
    
    alias persona_shuffle_ge gain_exp
    def gain_exp
      persona_shuffle_ge
      $game_party.battle_personas.each do |m|
        $game_party.menu_persona = m
        next if m.extra_skills.empty?
        $game_party.menu_persona = m
        SceneManager.call(Scene_ForgetSkill)
        SceneManager.scene.start_without_background
        SceneManager.scene.update while SceneManager.scene_is?(Scene_ForgetSkill)
      end
    end
    
    alias persona_shuffle_bs battle_start
    def battle_start
      persona_shuffle_bs
      $game_system.reset_shuffle_result
    end
  end
end

class Game_Enemy < Game_Battler
  def make_drop_cards
    cards = []
    enemy.drop_cards.each do |card, prob|
      if rand < prob.to_f * drop_item_rate
        cards.push(card)
      end
    end
    return cards
  end
end

class Game_Message
  alias persona_shuffle_init initialize
  def initialize
    persona_shuffle_init
    shuffle_clear
  end
  
  def shuffle_busy?
    shuffle_has_text?
  end
  
  def shuffle_clear
    @shuffle_texts = []
  end
  
  def shuffle_add(text)
    @shuffle_texts.push(text)
  end
  
  def shuffle_has_text?
    @shuffle_texts.size > 0
  end
  
  def shuffle_all_text
    @shuffle_texts.inject("") {|r, text| r += text + "\n" }
  end
end

class Game_System
  attr_accessor :shuffle_result
  
  alias persona_shuffle_init initialize
  def initialize
    persona_shuffle_init
    @shuffle_result = nil
  end
  
  def reset_shuffle_result
    @shuffle_result = nil
  end

  def get_cards
    card_items = BattleManager.cards_dropped
    if $game_variables[Persona::SHUFFLE_ITEMS_VAR_ID] != 0
      card_items = $game_variables[Persona::SHUFFLE_ITEMS_VAR_ID]
      $game_variables[Persona::SHUFFLE_ITEMS_VAR_ID] = nil
      card_items = $game_system.filter_cards(card_items) if Persona::FILTER_MANUAL_CARDS
      check_cards_personas(card_items)
    else
      card_items = BattleManager.cards_dropped
    end
    
    if card_items.nil? || card_items == 0
      msgbox("No cards were defined in variable with id #{Persona::SHUFFLE_ITEMS_VAR_ID} for the shuffle time!")
    end
    
    return card_items.collect{|c| Sprite_Card.new(@viewport, c) }
  end
  
  def check_cards_personas(card_items)
    for card_item in card_items
      next if card_item == "Blank" || card_item ==  "Penalty"
      actor = $game_personas.get_by_name(card_item)
      if actor.nil?
        msgbox("#{card_item} persona was not found in the actor database!")
        exit_shuffle
      end
    end
  end
  
  def get_shuffle_method(cards)
    # determine shuffle method from variable or other
    if $game_variables[Persona::FORCE_SHUFFLE_METHOD_VAR_ID] == 0
      shuffle_method = Persona.SHUFFLE_SELECTION(cards)
    else
      shuffle_method = $game_variables[Persona::FORCE_SHUFFLE_METHOD_VAR_ID]
      $game_variables[Persona::FORCE_SHUFFLE_METHOD_VAR_ID] = 0
    end
    return shuffle_method
  end

  def shuffle_time
    cards = get_cards()
    shuffle_method = get_shuffle_method(cards)
    case shuffle_method
    when "Matching"
      SceneManager.call(Scene_ShuffleMatching)
    when "Horizontal"
      SceneManager.call(Scene_ShuffleHorizontalRotating)
    when "Diagonal"
      SceneManager.call(Scene_ShuffleDiagonalRotating)
    when "Combination"
      # Defaults to Combination
      SceneManager.call(Scene_ShuffleRotating)
    end
    SceneManager.scene.cards = cards
    SceneManager.scene.start
    Fiber.yield
  end
  
  def prepare_cards(cards)
    penalty_cnt = cards.count("Penalty")
    penalty_cnt = [[penalty_cnt, Persona::MIN_PENALTY_CARDS].max, Persona::MAX_PENALTY_CARDS].min
    blank_cnt = cards.count("Blank")
    blank_cnt = [[blank_cnt, Persona::MIN_BLANK_CARDS].max, Persona::MAX_BLANK_CARDS].min
    
    # remove all bank/penalty
    cards = cards.select{|c| ["Blank", "Penalty"].index(c).nil? }

    if !Persona::SHUFFLE_ALLOW_DUPLICATES
      cards = cards.uniq
    end
    
    return [] if cards.empty?
    
    cards.concat Array.new(penalty_cnt) {"Penalty"}
    cards.concat Array.new(blank_cnt) {"Blank"}

    return cards.shuffle
  end
end

class Game_Troop < Game_Unit
  def make_drop_cards
    dead_members.inject([]) {|r, enemy| r += enemy.make_drop_cards }
  end
end

class Window_AcceptShuffle < Window_Command
  def initialize
    clear_command_list
    make_command_list
    x, y = get_window_position
    super(x, y)
    self.z = 250
    self.openness = 0
    refresh
    select(0)
    activate
  end
  
  def get_window_position
    case Persona::WINDOW_POSITIONS[Persona::ACCEPT_POSITION]
    when "BL"
      x = 0
      y = Graphics.height - window_height
    when "BR"
      x = Graphics.width - window_width
      y = Graphics.height - window_height
    when "TL"
      x = 0
      y = 0
    when "TR"
      x = Graphics.width - window_width
      y = 0
    end
    return x, y
  end
  
  def update_open
    self.openness += 16
    @opening = false if open?
  end
  
  def visible_line_number
    2
  end

  def make_command_list
    add_command("Accept",   :accept,   true)
    add_command("Decline",  :decline,  true)
  end
end

class Window_MatchCounter < Window_Base
  def initialize(max_tries)
    @max_tries = max_tries
    @tries_left = max_tries + 1
    height = fitting_height(1)
    x, y = get_window_position
    super(x, y, window_width, window_height)
    self.z = 250
    self.openness = 0
    tried
  end
  
  def get_window_position
    case Persona::WINDOW_POSITIONS[Persona::ACCEPT_POSITION]
    when "BL"
      x = 0
      y = Graphics.height - window_height
    when "BR"
      x = Graphics.width - window_width
      y = Graphics.height - window_height
    when "TL"
      x = 0
      y = 0
    when "TR"
      x = Graphics.width - window_width
      y = 0
    end
    return x, y
  end
  
  def window_width 
    180
  end
  
  def window_height
    fitting_height(1)
  end
  
  def tried
    @tries_left -= 1
    txt = "Tries left: #{@tries_left}/#{@max_tries}"
    contents.clear
    draw_text(0, 0, self.width - standard_padding, line_height, txt)
  end
  
  def lost?
    return @tries_left == 0
  end
end

class Window_ShuffleMessage < Window_Message
  def update_fiber
    if @fiber
      @fiber.resume
    elsif $game_message.shuffle_busy? && !$game_message.scroll_mode
      @fiber = Fiber.new { fiber_main }
      @fiber.resume
    else
      $game_message.visible = false
    end
  end
  
  def fiber_main
    $game_message.visible = true
    update_background
    update_placement
    loop do
      process_all_text if $game_message.shuffle_has_text?
      process_input
      $game_message.shuffle_clear
      @gold_window.close
      Fiber.yield
      break unless text_continue?
    end
    close_and_wait
    $game_message.visible = false
    @fiber = nil
  end
  
  def process_all_text
    open_and_wait
    text = convert_escape_characters($game_message.shuffle_all_text)
    pos = {}
    new_page(text, pos)
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  
  def text_continue?
    $game_message.shuffle_has_text? && !settings_changed?
  end
  
  def new_page(text, pos)
    contents.clear
    reset_font_settings
    pos[:x] = 0
    pos[:y] = 0
    pos[:new_x] = 0
    pos[:height] = calc_line_height(text)
    clear_flags
  end
end

class Sprite_Card < Sprite_Base
  attr_accessor :repeat_path, :tease, :card_index
  attr_reader :current_path, :path_indx, :card_name

  attr_reader :effect_duration, :effect_remaining_duration
  
  def initialize(viewport, card_name)
    super(viewport)
    @card_name = card_name
    @bitmap_name = @card_name
    
    # new
    @path_indx = 0  # index of current location in the path list
    @current_path = [] # current path to follow
    @repeat_path = false  # repeat the path if reaches last position
    @flip = false # flip the card (from face down to up and vice verse)
    @tease = false  # shows the card for some frames and flips it back face-down
    @back_bitmap = Persona::CARD_BACK_NAME  # name of bitmap for the back of the card
    @match_selected = false # if true card is shown face up
    @bitmap_changed = true
    
    @card_index = -1
    @on_path_end = nil

    # Total duration of visual effect in frames
    @effect_duration = 0
    # Current effect progress in frames, goes from @effect_duration->0
    @effect_remaining_duration = 0
    @repeat_effect = false
    @path_locked = false
  end

  def match_selected?
    return @match_selected
  end
  
  def card_name=(card_name)
    @card_name = card_name
    update_bitmap
  end

  def match_selected=(selected)
    @match_selected = selected
  end
  
  def set_current_path(path, on_path_end=nil, repeat_path=false, locked=false)
    # Cannot change until current path is finished
    return if @path_locked
    @current_path = path
    @path_indx = 0
    @on_path_end = on_path_end
    @repeat_path = repeat_path
    @path_locked = locked
  end

  def clear_path
    @current_path = []
    @path_indx = 0
    @on_path_end = nil
    @repeat_path = false
  end
  
  def continue_with_path(path, on_path_end=nil, repeat_path=false, locked=false)
    return if @path_locked
    current_step = path.find_all{|p| p[1] >= self.y }.min_by{ |p| Math.sqrt((p[0] - self.x)**2 + (p[1] - self.y)**2) }
    current_index = path.index(current_step)
    @current_path = path
    @path_indx = current_index
    @repeat_path = repeat_path
    @on_path_end = on_path_end
    @path_locked = locked
  end

  def on_path_end=(on_end)
    @on_path_end = on_end
  end
  
  def cx
    # center x of card bitmap relatively to current x location
    return self.x if self.bitmap.nil?
    self.x + self.bitmap.width / 2
  end
  
  def cy
    # center y of card bitmap relatively to current y location
    return self.y if self.bitmap.nil?
    self.y + self.bitmap.height / 2
  end

  def starting_position(x, y)
    self.x = x
    self.y = y
  end
  
  def dispose
    bitmap.dispose if bitmap
    super
  end
  
  def update
    super
    if @card_name
      update_bitmap if @bitmap_changed
      update_flip if @flip
      update_position
      
      update_effect
    else
      self.bitmap = nil
      @effect_type = nil
      @bitmap_changed = true
    end
  end
  
  def resize_bitmap(bitmap, new_width, new_height)
    new_bitmap = Bitmap.new(new_width, new_height)
    new_bitmap.stretch_blt(new_bitmap.rect, bitmap, bitmap.rect)
    return new_bitmap
  end
  
  def update_bitmap
    new_bitmap = Cache.card(@bitmap_name)
    self.bitmap = resize_bitmap(new_bitmap, new_bitmap.width, new_bitmap.height)
    init_visibility
    @bitmap_changed = false
  end
  
  def init_visibility
    @card_visible = true
  end
  
  def update_position
    return if @current_path.length == 0 || @path_indx >= @current_path.length

    new_pos = @current_path[@path_indx]
    self.x = new_pos[0]
    self.y = new_pos[1]
    self.z = new_pos[2] unless new_pos[2].nil?
    
    # zoom_x and zoom_y is calculated depending of the z position of the card
    # to make it look like it has gone to the back
    # self.zoom_x = z
    # self.zoom_y = z
    @path_indx += 1 if @path_indx < @current_path.length
    
    if @path_indx == @current_path.size
      @path_indx = 0 if @repeat_path
      if !@on_path_end.nil?
        @on_path_end.call(@card_index)
      end
      @path_locked = false
    end
  end
  
  def done_moving
    return !@repeat_path && @path_indx == @current_path.length
  end
  
  def dim_card
    if @effect_type.nil?
      current_color = self.color
      self.color.set(0, 0, 0, 128)
    end
  end
  
  def moving?
    return !@current_path.empty? && @path_indx < @current_path.length
  end

  def teasing?
    return @effect_type == :tease
  end

  def flipping?
    return @effect_type == :flip
  end
  
  def visible_on_screen?
    return false if self.bitmap.nil?
    return self.y + self.bitmap.height > 0 && self.y < Graphics.height &&
           self.x + self.bitmap.width > 0 && self.x < Graphics.width
  end
  
  def start_effect(effect_type)
    return if (@effect_type == effect_type && @effect_remaining_duration > 0) || !@effect_type.nil?
    @effect_type = effect_type
    case @effect_type
    when :appear
      @effect_duration = 0.25 * Graphics.frame_rate
    when :disappear
      @effect_duration = 0.25 * Graphics.frame_rate
    when :matching_selected
      @effect_duration = 1.0 * Graphics.frame_rate
    when :tease
      @effect_duration = 0.15 * Graphics.frame_rate
    when :flip
      @effect_duration = 0.10 * Graphics.frame_rate
    end
    @effect_remaining_duration = @effect_duration.ceil
  end
  
  def revert_to_normal
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.opacity = 255
    self.src_rect.y = 0
    @effect_type = nil
  end
  
  def update_effect
    if @effect_remaining_duration >= 0
      case @effect_type
      when :appear
        update_appear
      when :disappear
        update_disappear
      when :matching_selected
        update_matching_selected if @effect_remaining_duration == @effect_duration
      when :tease
        update_tease
      when :flip
        update_flip
      end
      @effect_remaining_duration -= 1
      if @effect_remaining_duration < 0
        if @repeat_effect && @effect_remaining_duration == 0
          @effect_remaining_duration = @effect_duration
        else
          @effect_type = nil
        end
      end
    end
  end
  
  def update_flip
    # Flash at the start of the effect only
    self.flash(Color.new(255, 255, 255), 30) if @effect_remaining_duration == @effect_duration
    if @effect_remaining_duration == 0
      @bitmap_name = @bitmap_name == @back_bitmap ? @card_name : @back_bitmap # flip card. goes from @back_bitmap to card.name and vice versa
      @flip = false
      @bitmap_changed = true
      @repeat_effect = false
    end
  end
  
  def update_tease
    if @effect_remaining_duration == (0.6 * @effect_duration).ceil
      self.flash(Color.new(255, 255, 255), 0)
      @bitmap_name = @card_name
      @bitmap_changed
      @bitmap_changed = true
    elsif @effect_remaining_duration == 0
      self.flash(Color.new(255, 255, 255), 25)
      @bitmap_name = @back_bitmap
      @tease = false
      @bitmap_changed = true
    end
    @repeat_effect = false
  end

  def update_matching_selected
    self.flash(Color.new(255, 0, 0, 125), @effect_duration)
    @repeat_effect = false
  end
  
  def update_appear
    self.opacity = 256 * (1 - @effect_remaining_duration / @effect_duration)
  end
  
  def update_disappear
    self.opacity = 256 * @effect_remaining_duration / @effect_duration
  end

  def visible
    super
  end
end

class Sprite_ShuffleLines < Sprite
  def initialize(viewport, picture)
    super(viewport)
    @picture = picture
    self.opacity = 0
    @disappear = false
    update
  end
  
  def dispose
    bitmap.dispose if bitmap
    super
  end
  
  def start_disappear
    @disappear = true
  end
  
  def update
    super
    update_bitmap
    update_position
    update_zoom
    update_other
  end
  
  def update_bitmap
    if @picture.empty?
      self.bitmap = nil
    else
      self.bitmap = Cache.load_bitmap(Persona::GRAPHICS_DIRECTORY, @picture)
    end
  end
  
  def update_position
    self.x = 0
    self.y = 0
    self.z = 500
  end
  
  def update_zoom
    self.zoom_x = 1.0
    self.zoom_y = 1.0
  end
  
  def update_other
    self.opacity += 25 if self.opacity < 255 && !@disappear
    self.opacity -= 25 if @disappear
    self.blend_type = 0
    self.angle = 0
    self.tone.set(0, 0, 0)
  end
end

class Scene_BaseShuffle < Scene_Base
  def start
    super
    Graphics.freeze
    create_attributes
    create_acceptance_window
    create_counter_window if needs_counter_window?
    create_background
    create_paths
    start_cards_appear
    setup_music
    Graphics.transition(Persona::SHUFFLE_TRANSITION_DURATION)
  end
  
  def cards=(cards)
    @cards = cards
  end

  def terminate
    super
    @cards.each{|c| c.dispose}
    @background_sprite.dispose if !@background_sprite.nil?
    @lines_picture.dispose if !@lines_picture.nil?
  end
  
  def start_cards_appear
    @cards.each{ |card| card.start_effect(:appear)}
  end
  
  def setup_music
    @last_bgm = RPG::BGM.last
    @last_bgs = RPG::BGS.last
    
    Audio.bgm_play(*Persona::SHUFFLE_BGM) if !Persona::SHUFFLE_BGM.nil?
    Audio.bgs_play(*Persona::SHUFFLE_BGS) if !Persona::SHUFFLE_BGS.nil?
  end
  
  def create_attributes
    # center of screen
    @cx = (Graphics.width / 2).to_i
    @cy = (Graphics.height / 2).to_i
    
    # dimensions of the cards
    card_bitmap = Cache.card("Blank")
    @card_width = card_bitmap.width
    @card_height = card_bitmap.height
    
    # result of shuffle
    @card_selected = nil
    
    @message_window = Window_ShuffleMessage.new
    @counter_window = nil
    
    # current phase of the shuffle time process
    @shuffle_phase = "Show"
    @shuffle_paths = []
    @accepted = false
    
    @cursor_index = 0
  end
  
  def create_acceptance_window
    @acceptance_window = Window_AcceptShuffle.new
    @acceptance_window.set_handler(:accept,   method(:start_shuffle_time))
    @acceptance_window.set_handler(:decline,   method(:exit_shuffle))
    @acceptance_window.open
  end
  
  def create_counter_window
    # Override in subclasses that need it
  end
  
  def needs_counter_window?
    false # Override in subclasses that need it
  end
  
  def start_shuffle_time
    @acceptance_window.close
    start_specific_shuffle
    @accepted = true
  end
  
  def start_specific_shuffle
  end
  
  def create_background
    @background_sprite = Sprite.new
    if Persona::SHUFFLE_BACKGROUND
      @background_sprite.bitmap = Cache.load_bitmap(Persona::GRAPHICS_DIRECTORY, Persona::SHUFFLE_BACKGROUND)
    else
      @background_sprite.bitmap = SceneManager.background_bitmap
      @background_sprite.bitmap.appear
    end
  end
  
  def update
    super
    update_cards
    update_specific_logic
    process_input if !teasing_phase && @accepted
  end
  
  def update_all_windows
    @acceptance_window.update
    @counter_window.update if @counter_window
  end
  
  def update_specific_logic
  end
  
  def update_for_wait
    Graphics.update
    Input.update
    
    $game_timer.update
    @message_window.update
    @counter_window.update if @counter_window
    @lines_picture.update if @lines_picture
    if @card_selected
      update_selected_card 
      update_other_cards
    else
      update_cards
    end
  end
  
  def update_cards
    @cards.each{|card| card.update}
  end
  
  def wait_for_message
    @message_window.update
    update_for_wait while $game_message.visible
  end
  
  def update_selected_card
    @card_selected.update
  end

  def update_other_cards
    @cards.each do |card|
      next if card == @card_selected
      card.update
    end
  end
  
  def teasing_phase
    @cards.select{|c| c.teasing? }.length > 0
  end
  
  def cards_done_moving
    @cards.inject(true){ |done, c| done && c.done_moving }
  end
  
  # Abstract method - override in subclasses
  def process_input
    # Override in subclasses
  end
  
  def show_selected_card
    x1 = @card_selected.x
    y1 = @card_selected.y
    # the multiplier is to center the card after the zoom effect from the z position
    x2 = @cx - @card_width / 2 * (150.0/110.0)
    y2 = @cy - @card_height
    @card_selected.set_current_path(lerp(x1, y1, x2, y2))
    @card_selected.z = 150
  end
  
  def show_results
    if !@card_selected.nil?
      persona = $game_personas.get_by_name(@card_selected.card_name)
    else
      persona = nil
    end
    
    if @card_selected.nil?
      Audio.se_play(*Persona::SHUFFLE_BLANK_SOUND)
      $game_message.shuffle_add(Persona::NO_CARD_DRAW_MSG)
      $game_system.shuffle_result = ""
      wait_for_message
    elsif @card_selected.card_name == "Blank"
      Audio.se_play(*Persona::SHUFFLE_BLANK_SOUND)
      $game_message.shuffle_add(Persona::BLANK_CARD_DRAW_MSG)
      $game_system.shuffle_result = "Blank"
      wait_for_message
    elsif @card_selected.card_name == "Penalty"
      Audio.se_play(*Persona::SHUFFLE_PENALTY_SOUND)
      $game_message.shuffle_add(Persona::PENALTY_CARD_DRAW_MSG)
      $game_system.shuffle_result = "Penalty"
      wait_for_message
    elsif $game_party.persona_in_party(persona.name)
      Audio.se_play(*Persona::SHUFFLE_DUPLICATE_SOUND)
      $game_message.shuffle_add(sprintf(Persona::DUPLICATE_PERSONA_DRAW_MSG, @card_selected.card_name))
      $game_system.shuffle_result = "Duplicate"
      wait_for_message
    elsif !@card_selected.nil?
      Audio.se_play(*Persona::SHUFFLE_CARD_SOUND)
      $game_message.shuffle_add(sprintf(Persona::PERSONA_CARD_DRAW_MSG, @card_selected.card_name))
      $game_system.shuffle_result = persona.name
      wait_for_message
      $game_party.add_persona_by_id(persona.id)
    end
    Graphics.fadeout(30)
    exit_shuffle
  end
  
  def exit_shuffle
    @last_bgm.replay if @last_bgm
    @last_bgs.replay if @last_bgs
    terminate
    SceneManager.return
  end
  
  def create_main_viewport
    @viewport = Viewport.new
    @viewport.z = 200
  end
  
  def create_paths
    @cards.each_with_index do |card, i|
      max_cols = Persona::MAX_CARDS_PER_ROW
      x, y, z = show_position(i/max_cols, i%max_cols, max_cols)
      card.starting_position(x, y)
      card.set_current_path([[x, y, z]], nil, true)
    end
    create_specific_paths
  end
  
  # Abstract method - override in subclasses
  def create_specific_paths
    # Override in subclasses
  end
  
  def show_position(i, j, max_cols=Persona::MAX_CARDS_PER_ROW)
    # number of cards on current row
    row_cards = [max_cols, @cards.size - (i*max_cols)].min
    # calculate y depending on the current row
    y = (Graphics.height - @card_height * (@cards.size / max_cols + 1))/2 + i * @card_height
    # calculate starting x depending on the number of cards in current row
    start_x = Graphics.width / 2 - (@card_width / 2) * row_cards 
    
    # calculate x depending on width of card
    x = start_x + @card_width * j
    return x, y, 100
  end
  
  def lerp(x1, y1, x2, y2, steps = (Graphics.frame_rate / 4).ceil, z=100)
    path = []
    (0..steps).each do |i|
      t = i.to_f / steps
      x = x1 + t * (x2 - x1)
      y = y1 + t * (y2 - y1)
      path.push([x, y])
    end
    return path
  end
  
  def duplicate_cards(cards)
    new_cards = []
    cards.each_with_index do |card,i| 
      new_cards.push(Sprite_Card.new(@viewport, card.card_name))
      new_cards[-1].x = card.x
      new_cards[-1].y = card.y
      new_cards[-1].z = card.z
    end
    return cards + new_cards
  end
  
  def finish_shuffle
    show_results
  end
end

class Scene_ShuffleMatching < Scene_BaseShuffle
  
  def needs_counter_window?
    true
  end
  
  def create_counter_window
    @counter_window = Window_MatchCounter.new(Persona::MATCHING_TRIES)
  end
  
  def start_specific_shuffle
    start_matching
  end
  
  def start_matching
    new_cards = []
    
    initial_card_count = @cards.size

    # duplicates all the cards for the matching method
    @cards = duplicate_cards(@cards)
    @cards.shuffle!
    
    # picks random cards and shows them for a short amount of frames
    @cards.sample(initial_card_count/2).each{ |c| c.tease=true } 
    
    # max cards per row
    max_cols = Persona::MAX_CARDS_PER_ROW
    @cards.each_with_index do |card, i|
      # at first make all the cards go to the center of the screen
      x1 = card.x
      y1 = card.y
      x2 = @cx - @card_width / 2
      y2 = @cy - @card_height / 2
      travel1 = lerp(x1, y1, x2, y2)
      
      # make them wait there for a second
      wait = []
      (Graphics.frame_rate).to_i.times do |i|
        wait.push([x2, y2, 100])
      end
      
      x1 = @cx
      y1 = @cy
      # calculate their position in the matching process
      x2, y2, z = show_position(i/max_cols, i%max_cols, max_cols)
      # create path to that position
      travel2 = lerp(x1, y1, x2, y2)
      
      # add the path to the card's path
      card.set_current_path(travel1 + wait + travel2, nil, false)
      # flips them while they go to the center of the screen
      card.start_effect(:flip)
    end
    
    @counter_window.open
    # calculate all x,y indexes of the cards. used only for up and down movement
    # in matching shuffle method
    @card_indexes = @cards.each_with_index.collect{|n, i| [i/Persona::MAX_CARDS_PER_ROW, i%Persona::MAX_CARDS_PER_ROW]}
  end
  
  def update_specific_logic
    determine_loss_matching
  end
  
  def determine_loss_matching
    if @counter_window.lost?
      (Graphics.frame_rate/2).times{update_matches }
      
      @counter_window.close
      @message_window.z = 250
      $game_message.shuffle_add(Persona::MATCHING_LOSE_MESSAGE)
      wait_for_message
      finish_shuffle
    end
  end
  
  def update_for_matched
    Graphics.update
    Input.update
    
    $game_timer.update
    update_matches
  end
  
  def update_matches
    @cards.each{ |c| c.update }
  end
  
  def process_input
    process_input_matching if cards_done_moving
  end
  
  def process_input_matching
    if @cards.inject(false){|done, c| done || c.tease }
      # runs only once to quickly the cards that will be teased
      @cards.each{|c| c.start_effect(:tease) if c.tease }
    end
    
    process_movement_input
    
    if !@cards[@cursor_index].teasing? && !@cards[@cursor_index].flipping?
      # if the current card is not being teased and is not being flipped
      # then flash the card with red colour (meaning the cursor is on that
      # card)
      @cards[@cursor_index].start_effect(:matching_selected)
    end
    
    if Input.trigger?(:C) && !@cards[@cursor_index].match_selected?
      Sound.play_ok
      
      @cards[@cursor_index].revert_to_normal
      # flip (show) selected card
      @cards[@cursor_index].start_effect(:flip)
      @cards[@cursor_index].match_selected = true
      
      selected_cards = @cards.select{ |c| c.match_selected? }
      if selected_cards.length == 2
        # show cards for half a second
        (Graphics.frame_rate / 2).to_i.times{ |i| update_for_matched }
        
        if selected_cards[0].card_name != "Blank" && selected_cards[0].card_name == selected_cards[1].card_name
          # keep selected cards face up and disappear all other
          @cards.each{|c| c.start_effect(:disappear) if !c.match_selected? }
          selected_cards[1].start_effect(:disappear)
          
          @card_selected = selected_cards[0]
          @counter_window.close
          show_selected_card
          
          finish_shuffle
        else
          Sound.play_cancel
          @counter_window.tried
        end
        
        selected_cards.each do |c| 
          c.match_selected = false
          c.start_effect(:flip)
        end
      end
    end
  end
  
  def process_movement_input
    # calculate x,y of current index
    index = [@cursor_index/Persona::MAX_CARDS_PER_ROW, @cursor_index%Persona::MAX_CARDS_PER_ROW]
    if Input.trigger?(:UP)
      Sound.play_cursor
      @cards[@cursor_index].revert_to_normal
      
      # make row change more "natural"
      index[0] -= 1 # previous row
      # if it was first row and pressed up, go to last row
      index[0] = @card_indexes[-1][0] if index[0] < 0
      # if went from one row to another with different number of cards
      # fix x index being more than the number of cards of that row
      index[1] = @card_indexes[-1][1] if index[1] > @card_indexes[-1][1]
      prev_card_x = @cards[@cursor_index].x
      new_indx = index[0]*Persona::MAX_CARDS_PER_ROW + index[1]
      # get all cards of new row
      new_row_cards = @cards.select{|c| c.y == @cards[new_indx].y}
      # get index of card in the new row with the closest x position as the 
      # last one
      new_card = new_row_cards.each_with_index.min_by{|c, i| (c.x - prev_card_x).abs}[1]
      # calculate new index in list of all cards
      @cursor_index = new_card + index[0] * Persona::MAX_CARDS_PER_ROW
    elsif Input.trigger?(:RIGHT)
      Sound.play_cursor
      @cards[@cursor_index].revert_to_normal
      
      @cursor_index += 1
      @cursor_index = 0 if @cursor_index > @cards.length - 1
    elsif Input.trigger?(:DOWN)
      Sound.play_cursor
      @cards[@cursor_index].revert_to_normal
      
      # same concept with :UP
      index[0] += 1
      index[0] = @card_indexes[0][0] if index[0] > @card_indexes[-1][0]
      index[1] = @card_indexes[-1][1] if index[1] > @card_indexes[-1][1]
      prev_card_x = @cards[@cursor_index].x
      new_indx = index[0]*Persona::MAX_CARDS_PER_ROW + index[1]
      new_row_cards = @cards.select{|c| c.y == @cards[new_indx].y}
      new_card = new_row_cards.each_with_index.min_by{|c, i| (c.x - prev_card_x).abs}[1]
      @cursor_index = new_card + index[0] * Persona::MAX_CARDS_PER_ROW
    elsif Input.trigger?(:LEFT)
      Sound.play_cursor
      @cards[@cursor_index].revert_to_normal
      
      @cursor_index -= 1
      @cursor_index = @cards.length - 1 if @cursor_index < 0
    end
  end
  
  def create_specific_paths
    # Matching doesn't need shuffle paths
  end
end

class Scene_ShuffleRotating < Scene_BaseShuffle
  
  def initialize(shuffle_method = "Combination")
    super()
    @shuffle_method = shuffle_method
  end
  
  def start_specific_shuffle
    start_shuffle
  end
  
  def start_shuffle
    @cards.each_with_index do |card, i|
      x1 = card.x
      y1 = card.y
      x2 = @shuffle_paths[i][0][0]
      y2 = @shuffle_paths[i][0][1]
      # basically makes the card wait some frames before it goes to the
      # shuffle path. all cards go one by one
      wait = []
      (@shuffle_paths[0].size / @cards.size * i).times do |i|
        wait.push([x1, y1])
      end
      # appends to the wait list the intermediate points between the current 
      # position of the card and the starting position in the shuffle path
      card.set_current_path(wait + lerp(x1, y1, x2, y2), nil, false)
      card.start_effect(:flip) # make the card flip face down
    end
    @shuffle_phase = "Shuffle"
    # calculate all x,y indexes of the cards. used only for up and down movement
    # in matching shuffle method
    @card_indexes = @cards.each_with_index.collect{|n, i| [i/Persona::MAX_CARDS_PER_ROW, i%Persona::MAX_CARDS_PER_ROW]}
  end
  
  def update_cards
    @cards.each_with_index do |card, i| 
      card.update
      
      # if it's a shuffle method, set its path in the shuffling and 
      # make it repeat it
      if @shuffle_phase == "Shuffle"
        if card.path_indx == card.current_path.size - 1 && !card.repeat_path
        # if the card has reached its destination in the shuffle path
          card.set_current_path(@shuffle_paths[i], nil, true)
        end
      end
    end
  end
  
  def process_input
    # if last card is repeating its path then it has entered the shuffle loop
    # therefore we accept input for selection
    process_input_shuffle if @shuffle_phase == "Shuffle" && Input.trigger?(:C) && @cards[-1].repeat_path
  end
  
  def process_input_shuffle
    @shuffle_phase = "Selected"
    # card selected is the one with the shortest distance between the
    # center of the screen, with z value that of the max z value of the 
    # path the cards are following (is closer to the "screen")
    Sound.play_ok
    z = @cards[0].current_path.max_by{|coords| coords[2] }[2]
    @card_selected = @cards.min_by{ |card| Math.sqrt((@cx - card.cx)**2 + (@cy - card.cy)**2 + (z - card.z)**2) }
    show_selected_card

    for card in @cards
      next if card == @card_selected
      card.start_effect(:disappear)
    end
    
    @card_selected.start_effect(:flip)
    finish_shuffle
  end
  
  def create_specific_paths
    case @shuffle_method
      when "Horizontal"
        @cards.size.times do |i|
          @shuffle_paths.push(calculate_horizontal_path)
        end
      when "Diagonal"
        @cards.size.times do |i|
          if i % 2 == 0
            @shuffle_paths.push(calculate_diagonal_path)
          else
            @shuffle_paths.push(calculate_diagonal_path(true))
          end
        end
      when "Combination"
        @cards.size.times do |i|
          if i % 2 == 0
            @shuffle_paths.push(calculate_horizontal_path)
          else
            @shuffle_paths.push(calculate_diagonal_path(rand > 0.5))
          end
        end
      else
        msgbox("
        Undefined shuffle method #{@shuffle_method}.
        Please use one of: \"Horizontal\", \"Diagonal\" or \"Combination\"
        (Setting to \"Combination\")")
        @shuffle_method = "Combination"
        create_specific_paths
    end
  end

  def calculate_horizontal_path
    movement_path = []
    xs = []
    ys = []
    
    sx = @card_width / 3 # left-most position
    ex = Graphics.width - (@card_width + @card_width/4) # right-most position
    sy = (Graphics.height - @card_height) / 2 # top-most position
    width = ex - sx
    total_distance = width * 2
    # will take one second to make a full loop
    step = (total_distance / Graphics.frame_rate) 
    xs = []
    for i in (sx...ex).step(step)
        xs.push(i)
    end
    xs = xs + xs.reverse
    
    y_step = 3
    z_step = 3
    # x positions are calculated, now calculate the y and z depending on the
    # x position
    xs.size.times do |i|  
      if i <= xs.size / 4 # last quarter of the round
        x = xs[i]
        y = sy + i * y_step
        z = 100 + i * z_step  # incease z (comes closer and becomes bigger)
        movement_path.push([x, y, z])
      elsif i <= 2 * xs.size / 4 # first
        x = xs[i]
        y = movement_path[i - 1][1] - y_step
        # decrease z (goes further away and becomes smaller)
        z = movement_path[i - 1][2] - z_step 
        movement_path.push([x, y, z])
      elsif i <= 3 * xs.size / 4 # second
        x = xs[i]
        y = movement_path[i - 1][1] - y_step
        z = movement_path[i - 1][2] - z_step
        movement_path.push([x, y, z])
      else # third
        x = xs[i]
        y = movement_path[i - 1][1] + y_step
        z = movement_path[i - 1][2] + z_step
        movement_path.push([x, y, z])
      end
    end
    return movement_path
  end

  def calculate_diagonal_path(mirrored=false)
    movement_path = []
    xs = []
    ys = []
    
    # left-most position
    sx = @card_width / 4
    # right-most position
    ex = Graphics.width - @card_width
    width = ex - sx
    total_distance = width * 2
    # will take one second to make a full loop
    step = (total_distance / Graphics.frame_rate) 
    for i in (sx...ex).step(step)
        xs.push(i)
    end
    # if mirrored goes from right to left first  
    if mirrored
      xs = xs.reverse + xs
    else
      # else from left to right first
      xs = xs + xs.reverse
    end
    
    # top-most position
    sy = 0
    # bottom-most position
    ey = Graphics.height - @card_height
    height = ey - sy
    total_distance = height * 2
    # will take one second to make a full loop
    step = (total_distance / Graphics.frame_rate)
    for i in (sy...ey).step(step)
      ys.push(i)
    end
    ys = ys + ys.reverse
    
    y_step = 3
    z_step = 3
    xs.size.times do |i|  
      if i <= xs.size / 4 # last quarter of loop
        x = xs[i]
        z = 100 + i * z_step
        movement_path.push([x, ys[i], z])
      elsif i <= 2 * xs.size / 4 # first
        x = xs[i]
        z = movement_path[i - 1][2] - z_step
        movement_path.push([x, ys[i], z])
      elsif i <= 3 * xs.size / 4 # second
        x = xs[i]
        z = movement_path[i - 1][2] - z_step
        movement_path.push([x, ys[i], z])
      else # last
        x = xs[i]
        z = movement_path[i - 1][2] + z_step
        movement_path.push([x, ys[i], z])
      end
    end
    return movement_path
  end
end

class Scene_ShuffleHorizontalRotating < Scene_ShuffleRotating
  def initialize
    super("Horizontal")
  end
end

class Scene_ShuffleDiagonalRotating < Scene_ShuffleRotating
  def initialize
    super("Diagonal")
  end
end
