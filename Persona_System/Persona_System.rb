# Tags on actors (that are personas)
# ==============================================================================
# You can specify which actor is a persona by simply adding the following tag:
#        <Persona>
# By adding the tag bellow:
#        <User: actor_id[, actor_id[, ...]]>
# on a persona actor you can specify the users that  can equip the specific
# persona. Remember that for the <User: ...> tag to work the actor must be a
# persona.  Also, you can specify as many persona users as you want in the list.
# For convenience, you can set the default users of a persona that doesn't have
# that tag through  the options module.
# Personas can't learn an infinite number of skills. You can specify the
# maximum number of skills a persona can learn by using the following tag:
#        <Max skills: number>
# The default number of maximum skills for all personas is set to 4, but you can
# change it through the options module! Lastly, a persona has the ability to evolve
# into a stronger one when it reaches a specific arcana rank! You can specify the
# rank of the arcana at which the persona will evolve with the following tag:
#        <Evolve at: rank>
# and the persona to which it will evolve to with the following one:
#        <Evolve to: persona_name>
# Additionally, you can set arcana rank and player level
# requirements to personas, so that a user can only equip
# that persona when they meet those requirements. 
# To apply a minimum arcana rank requirement for a specific 
# persona you use the following tag:
#        <Arcana rank: rank>
# To apply a minimum player level requirement  for a specific persona
# you use the following tag:
#        <Player level: level>
# ------------------------------------------------------------------------------
# Tags on actors (that use personas)
# ==============================================================================
# You can specify that a specific actor can use ONLY one (which will be
# automatically equipped) by using the following tag:
#        <Persona: actor_id>
# Also, to specify which persona will be equipped in Battle test on a specific
# ctor, you can use the following tag:
#        <Battletest persona: actor_id>
# ------------------------------------------------------------------------------
# Tags on classes (Arcana)
# ==============================================================================
# You can specify which classes represent an arcana by adding the tag
# bellow:
#        <Arcana>
# Each arcana's current rank is stored in a game variable. Those variables
# can be set for each Arcana separately by adding the following tag:
#        <Rank variable: variable_id>
# Of course, you can set the maximum  rank of each arcana by adding the
# tag bellow on each arcana:
#        <Max rank: rank>
# The default maximum  rank is set to 10, but can be changed through the
# options module. As in the original game, each arcana has its own social link(s).
# You can specify who is or are those links by adding the following tags
# to specify by actor id:
#        <Social links actors: actor_id[,actor_id[,...]]>
# and to specify by variable id (in which actor ids are stored):
#        <Social links actors: actor_id[,actor_id[,...]]>
# As far as naming those social links and their description goes, you can
# use the tag bellow to specify the name of the social link:
#        <Social target: name>
# and the one bellow to specify its description:
#        <Description: description>
# You can specify the description of an actor's social link by adding
# this tag:
#        <Social description: description>
# ------------------------------------------------------------------------------
# Tags on enemies
# ==============================================================================
# There is only one tag that is used on enemies and it specifies the card
# that an enemy can drop:
#        <Card drop: card_name, chance>
# The chance is specified by a floating number and not a percentage, for
# example using the tag bellow on an enemy, has a 30% chance to drop the
# Ghoul card:
#        <Card drop: Ghoul, 0.3>
# ------------------------------------------------------------------------------
# Add persona to party
# ==============================================================================
# You can add a persona to your party by calling the following script:
#        $game_party.add_persona(actor_id)
# It is important to remember that you cannot have duplicate personas in
# your party! Also, for developing purposes a message box will be displayed
# if you try adding an actor as a persona that is not actually a persona!
# Personas can also be acquired through the Shuffle Time that happens after
# a battle and if the enemy troop has dropped any cards. You can learn
# more about Shuffle Time by going to the back of the room.
# ------------------------------------------------------------------------------
# Remove social link through variable
# ==============================================================================
# If you have specified someone as a social link of an arcana via
# variables (see Tags on class (Arcanas)) you can remove a social
# link by setting the specific variable's value to -1. Do remember
# that if you have specified that social link through the actor social
# link tag, then even if you remove that actor they will still be a
# social link. Social links specified via actor ids cannot be removed!
# ------------------------------------------------------------------------------
# Increase/Decrease arcana rank
# ==============================================================================
# You can increase an arcana's rank by making the following script
# call:
#        $game_player.arcana_rank_up(arcana_name).
# You can also decrease an arcana's rank by making the following
# script call:
#        $game_player.arcana_rank_down(arcana_name).
# The minimum arcana rank can be set though the persona module!
# For convenience you can use the script call bellow to increase the
# arcana's rank by
# multiple ranks:
#        $game_party.arcana_rank_up_by(arcana_name, ranks)  
# The same can be done to decrease the arcana's rank by multiple ranks
# by making the following script call:
#        $game_party.arcana_rank_down_by(arcana_name, ranks)
# ------------------------------------------------------------------------------
# Persona in party or equipped
# ==============================================================================
# You can check if a persona is in the party by using the following
# script call:
#        $game_party.persona_in_party(persona_name).
# 
# You can check if a persona is currently equipped by simply calling
# the following script:
#        $game_party.persona_equipped(persona_name)
# 
# Also, you can check if a persona is equipped by a specific actor
# with the following script call:
#        $game_party.persona_equipped_by(actor_id, persona_name)
# ------------------------------------------------------------------------------
# Shuffle Time
# ==============================================================================
# Shuffle Time happens after battle and gives the player a chance to
# receive new Persona cards. Shuffle Time happens only if the enemies have
# dropped at least two cards. Of course, you can change this number
# through the options module. There are three types of cards in Shuffle
# Time:
#        Persona cards,
#        Blank cards and
#        Penalty cards.
# When a Blank card is picked, nothing happens whereas when a Penalty
# card is picked, the player gains no battle rewards! There are also
# two different shuffle methods:
#        Rotating card either horizontally, diagonally or a combination
#        of both and
#        Memory match, where player matches two cards and has at most
#        five attempts.
# You can change the maximum number of tries the player has through
# the options module! Also, you can force the next Shuffle Time method
# to be a specific one (among the available) by setting the value of
# the variable with ID 1 to the method you want. For example "Horizontal"
# if you want the next Shuffle Time method to be Horizontal or "Matching"
# if you want it to be the Matching one. Of course, you can change which
# variable you want to specify the method, though the options module.
# Lastly, you can call the shuffle scene with whichever cards you want
# by firstly setting the variable with ID 2 to a script call with a
# list of persona names like this:
#        ["name_1", "name_2", ...]
# and then by calling the scene with the following command:
#        $game_system.shuffle_time
# It is important to remember that you cannot have duplicate personas
# in your party! Additionally, a message box will be displayed if you
# try running Shuffle Time without setting the list of cards to be included!
# You can access the result of the last shuffle time by simply calling
# the following script command:
#        $game_system.shuffle_result.
# ------------------------------------------------------------------------------
# Fusion
# ==============================================================================
# Fusion is the system in which two or more personas are combined
# together to create a new persona. You can use the following tag
# bellow on a persona to specify which personas need to be fused to
# create that one:
#        <Fusion parents: actor_id1, actor_id2>
# For example, if you use the following tag on Himiko:
#        <Fusion parents: 13, 14>
# then when you try fusing Andras with Forneus, the fusion will result
# to... Himiko.
# You can also fuse three personas together to create special
# ones too! To specify the parents of a "special" persona you can
# use the following tag:
#        <Special fusion: actor_id1, actor_id2, actor_id3>
# Last but not least! To call the persona fusion scene you use the
# following script call:
#        $game_system.fuse_personas(2).
# For the special fusion scene you use the following script call:
#        $game_system.fuse_personas(3).
# ------------------------------------------------------------------------------
# Persona and user parameters
# ==============================================================================
# Personas can be equiped through the main menu command called
# "Persona". Personas add percentages of their parameters and
# stats to the actor they're equiped on. The default percentage
# is set to 100%, but can be changed through the persona options
# module. You can also change the percentage of the user's parameters
# that are added to the end result. The default percentage is also
# set to 100% and can be changed though the options module too.
# ==============================================================================
# Mady by vFoggy
# ==============================================================================
# 
#-------------------------------------------------------------------------------
#  ____                                   __  __           _       _      
# |  _ \ ___ _ __ ___  ___  _ __   __ _  |  \/  | ___   __| |_   _| | ___ 
# | |_) / _ \ '__/ __|/ _ \| '_ \ / _` | | |\/| |/ _ \ / _` | | | | |/ _ \
# |  __/  __/ |  \__ \ (_) | | | | (_| | | |  | | (_) | (_| | |_| | |  __/
# |_|   \___|_|  |___/\___/|_| |_|\__,_| |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                                                         
#   ___        _   _                 
#  / _ \ _ __ | |_(_) ___  _ __  ___ 
# | | | | '_ \| __| |/ _ \| '_ \/ __|
# | |_| | |_) | |_| | (_) | | | \__ \
#  \___/| .__/ \__|_|\___/|_| |_|___/
#       |_|                          
# Persona Module Options
#-------------------------------------------------------------------------------
module Persona
  PERSONA_EXP_GAIN_MULTIPLIER = 1.0
  
              # phys, absorb, fire, ice, lightning, water, earth, wind, light, dark
  PERSONA_ELE_ICON_INDEXES = [115, 112, 96, 97, 98, 99, 100, 101, 102, 103]
  # icon index that indicates that indicates the persona's strong element
  # -1 will just show "Str"
  PERSONA_STRONG_ELE_ICON = -1  
  # icon index that indicates that indicates the persona's weak element
  # -1 will just show "Wk"
  PERSONA_WEAK_ELE_ICON = -1
  # icon index that indicates that indicates the persona's normal element
  # -1 will just show "-"
  PERSONA_NORMAL_ELE_ICON = -1
  
  # rates multipliers. if all are the same only one number can be used for all
  USER_ELEMENT_RATE_MULTIPLIER = 1.0
  USER_DEBUFF_RATE_MULTIPLIER = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  USER_STATE_RATE_MULTIPLIER = 1.0
  PERSONA_ELEMENT_RATE_MULTIPLIER = 1.0
  PERSONA_DEBUFF_RATE_MULTIPLIER = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  PERSONA_STATE_RATE_MULTIPLIER = 1.0
  
  # parameter multipliers. if all are the same only one number can be used for all
  USER_PARAM_MULTIPLIER = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  USER_XPARAM_MULTIPLIER = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  USER_SPARAM_MULTIPLIER = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  PERSONA_PARAM_MULTIPLIER = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  PERSONA_XPARAM_MULTIPLIER = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  PERSONA_SPARAM_MULTIPLIER = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  
  # Name of the persona option in the menu and battle command
  PERSONA_MENU_NAME = "Persona" # alternative name for persona.
  
  # index of persona command in battle commands window
  PERSONA_BATTLE_COMMAND_INDEX = 2 
  # index of persona command in main menu
  PERSONA_MENU_COMMAND_INDEX = 1
  
  # name of the button images displayed in the persona list menu window
  SELECT_PERSONA_BUTTON_IMG_NAME = "select_persona_button"
  EQUIP_PERSONA_BUTTON_IMG_NAME = "equip_persona_button"
  
  # better keep a space at the beginning of the text
  SELECT_PERSONA_TEXT = " Show status"
  EQUIP_PERSONA_TEXT = " Equip persona"
  # written on actor's personas list when no personas are available
  NO_PERSONAS_MSG = "No available personas."
  
  # key used to equip persona
  EQUIP_PERSONA_KEY = :X
  
  # ids of the default users for a persona that has no users specified
  # can be an empty list
  DEFAULT_PERSONA_USERS = [1]
  
  # if true then skills of both user and persona will appear under user's skill
  # list
  UNIFIED_SKILLS = true
  # when UNIFIED_SKILLS is false, this color is used to differentiate persona's
  # skills from user's skills in the battle's skills list.
  # use Color.new(0, 0, 0) for normal color
  PERSONA_SKILLS_COLOR = Color.new(0, 255, 0) # green
  # index from which the persona's skill commands start (for multiple skill types)
  PERSONA_SKILLS_COMMAND_INDEX = 4

#-------------------------------------------------------------------------------
#  ____  _    _ _ _   _____                    _   
# / ___|| | _(_) | | |  ___|__  _ __ __ _  ___| |_ 
# \___ \| |/ / | | | | |_ / _ \| '__/ _` |/ _ \ __|
#  ___) |   <| | | | |  _| (_) | | | (_| |  __/ |_ 
# |____/|_|\_\_|_|_| |_|  \___/|_|  \__, |\___|\__|
#                                   |___/          
#  __  __           _       _         ___        _   _                 
# |  \/  | ___   __| |_   _| | ___   / _ \ _ __ | |_(_) ___  _ __  ___ 
# | |\/| |/ _ \ / _` | | | | |/ _ \ | | | | '_ \| __| |/ _ \| '_ \/ __|
# | |  | | (_) | (_| | |_| | |  __/ | |_| | |_) | |_| | (_) | | | \__ \
# |_|  |_|\___/ \__,_|\__,_|_|\___|  \___/| .__/ \__|_|\___/|_| |_|___/
#                                         |_|                          
# Skill Forget Module Options
#-------------------------------------------------------------------------------
  # max number of skills a persona can have
  DEFAULT_MAX_PERSONA_SKILLS = 4

#-------------------------------------------------------------------------------
#     _                                __  __           _       _      
#    / \   _ __ ___ __ _ _ __   __ _  |  \/  | ___   __| |_   _| | ___ 
#   / _ \ | '__/ __/ _` | '_ \ / _` | | |\/| |/ _ \ / _` | | | | |/ _ \
#  / ___ \| | | (_| (_| | | | | (_| | | |  | | (_) | (_| | |_| | |  __/
# /_/   \_\_|  \___\__,_|_| |_|\__,_| |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                                                      
#   ___        _   _                 
#  / _ \ _ __ | |_(_) ___  _ __  ___ 
# | | | | '_ \| __| |/ _ \| '_ \/ __|
# | |_| | |_) | |_| | (_) | | | \__ \
#  \___/| .__/ \__|_|\___/|_| |_|___/
#       |_|                          
# Arcana Module Options
#-------------------------------------------------------------------------------
  # min arcana rank. arcanas start with 0 rank and will be shown only 
  # when at MIN_RANK or higher
  MIN_RANK = 1
  DEFAULT_MAX_RANK = 10 # default maximum rank of persona arcana
  
  # folder of the arcana cards images
  ARCANA_IMG_FOLDER = "Persona/Arcanas/" # inside Graphics folder
  
  # name of the social links in the menu
  ARCANA_MENU_NAME = "Social Links" # alternative name for Social Links
  ARCANA_MENU_COMMAND_INDEX = 2
  
  # file names for the arcana rank progression bar
  ARCANA_RANKS_BAR_IMG_NAME = "bar"
  ARCANA_PROGRESS_IMG_NAME = "progress"
  ARCANA_PROGRESS_EMPTY_IMG_NAME = "progress_empty"

#-------------------------------------------------------------------------------
#  _____            _       _   _               __  __           _       _      
# | ____|_   _____ | |_   _| |_(_) ___  _ __   |  \/  | ___   __| |_   _| | ___ 
# |  _| \ \ / / _ \| | | | | __| |/ _ \| '_ \  | |\/| |/ _ \ / _` | | | | |/ _ \
# | |___ \ V / (_) | | |_| | |_| | (_) | | | | | |  | | (_) | (_| | |_| | |  __/
# |_____| \_/ \___/|_|\__,_|\__|_|\___/|_| |_| |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                                                               
#   ___        _   _                 
#  / _ \ _ __ | |_(_) ___  _ __  ___ 
# | | | | '_ \| __| |/ _ \| '_ \/ __|
# | |_| | |_) | |_| | (_) | | | \__ \
#  \___/| .__/ \__|_|\___/|_| |_|___/
#       |_|                          
# Evolution Module Options
#-------------------------------------------------------------------------------
    # ID of common event that runs when a persona is being evolved
    COMMON_EVENT_ID = 1
    
    # variable id in which the name of the persona that is being evolved is stored
    EVOLVING_PERSONA_VAR_ID = 13
    # variable id in which the name of the persona to which the persona will be evolved
    RESULTING_PERSONA_VAR_ID = 14

#-------------------------------------------------------------------------------
#  _____          _               __  __           _       _      
# |  ___|   _ ___(_) ___  _ __   |  \/  | ___   __| |_   _| | ___ 
# | |_ | | | / __| |/ _ \| '_ \  | |\/| |/ _ \ / _` | | | | |/ _ \
# |  _|| |_| \__ \ | (_) | | | | | |  | | (_) | (_| | |_| | |  __/
# |_|   \__,_|___/_|\___/|_| |_| |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                                                 
#   ___        _   _                 
#  / _ \ _ __ | |_(_) ___  _ __  ___ 
# | | | | '_ \| __| |/ _ \| '_ \/ __|
# | |_| | |_) | |_| | (_) | | | \__ \
#  \___/| .__/ \__|_|\___/|_| |_|___/
#       |_|                          
# Fusion Module Options
#-------------------------------------------------------------------------------
  # list of actor ids whose personas can be fused.
  # example: if [1, 4, 6] then the player can fuse personas that belong to 
  # the actors with id 1, 4 and 6
  CAN_USE_ACTORS_PERSONAS = [1]
  
  # color of the special fusion result in the fusion results window. RGB values
  SPECIAL_FUSION_COLOR = Color.new(255, 255, 0) # yellow

  # method to calculate the fusion resulting persona extra exp
  def self.FUSION_EXP_CALC(persona)
    # you can use this method to calculate the total experience the persona 
    # child will earn from the fusion process. keep the first line
    return 0 unless persona.persona? || persona.nil?
    [persona.arcana_rank, 0].max * 1000 + persona.level * 1000 + rand(5) * 100 + rand(10) * 10 + rand(10)
  end
  
  # if true, then the player has to choose the fusing personas in the order
  # in which they are specified in the tag.
  ORDER_MATTERS = true

#-------------------------------------------------------------------------------
#  ____  _            __  __ _        __  __           _       _      
# / ___|| |__  _   _ / _|/ _| | ___  |  \/  | ___   __| |_   _| | ___ 
# \___ \| '_ \| | | | |_| |_| |/ _ \ | |\/| |/ _ \ / _` | | | | |/ _ \
#  ___) | | | | |_| |  _|  _| |  __/ | |  | | (_) | (_| | |_| | |  __/
# |____/|_| |_|\__,_|_| |_| |_|\___| |_|  |_|\___/ \__,_|\__,_|_|\___|
#                                                                     
#   ___        _   _                 
#  / _ \ _ __ | |_(_) ___  _ __  ___ 
# | | | | '_ \| __| |/ _ \| '_ \/ __|
# | |_| | |_) | |_| | (_) | | | \__ \
#  \___/| .__/ \__|_|\___/|_| |_|___/
#       |_|                          
# Shuffle Module Options
#-------------------------------------------------------------------------------
  # possible window positions
  WINDOW_POSITIONS = [
      "BL",   # Bottom Left
      "BR",   # Bottom Right
      "TL",   # Top Left
      "TR"    # Top Right
  ]
  
  # folder of images of cards
  CARD_IMG_FOLDER = "Persona/Cards/" # inside Graphics folder
  # name of the image of the back of the cards
  CARD_BACK_NAME = "Back" # should be inside CARD_IMG_FOLDER
  # background file of shuffle time
  SHUFFLE_BACKGROUND = "Shuffle_Background" # should be inside Persona folder
  
  # index of window position (WINDOW_POSITIONS) for shuffle time accept window
  ACCEPT_POSITION = 1
  # index of window position (WINDOW_POSITIONS) that displays the tries left
  # for the matching method
  COUNTER_POSITION = 1
  
  MATCHING_TRIES = 5
  
  # max numbers of cards displayed per row in shuffle time (before shuffling
  # and during the matching) must be set according to the image size of the
  # cards if there are too many per row they will go out of screen
  MAX_CARDS_PER_ROW = 5
  
  # minimum number of penalty and blank cards a shuffle time must have
  MIN_PENALTY_CARDS = 1
  MIN_BLANK_CARDS = 1
  # maximum number of penalty and blank cards a shuffle time must have
  MAX_PENALTY_CARDS = 2
  MAX_BLANK_CARDS = 2
  # number of cards required to be dropped (without blank and penalty) 
  # to initiate shuffle time
  MIN_CARDS_TO_SHUFFLE = 2
  
  # variable id from which the next shuffle method is set
  FORCE_SHUFFLE_METHOD_VAR_ID = 10
  
  # variable id from which the next shuffle cards are set
  SHUFFLE_ITEMS_VAR_ID = 11
  # if true then duplicates cards will be included in the shuffle time
  # does not apply to blank and penalty cards. use the 
  # MIN/MAX_PENALTY/BLANK_CARDS options
  ALLOW_DUPLICATES = false
  # if true then the cards set with the variable will be filtered according
  # to MIN/MAX_PENALTY_CARDS etc.
  FILTER_MANUAL_CARDS = false
  
  # Messages
  # message displayed when player loses at the matching shuffle method
  MATCHING_LOSE_MESSAGE = "You lost!"
  
  # message displayed when no card was drawn (only happens in matching method)
  NO_CARD_DRAW_MSG = "You didn't draw any card!"
  # message dispalyed in the battle results when no card is drawn
  NO_CARD_RESULT_MSG = "Nothing happened."
  
  # message displayed when the blank card is drawn
  BLANK_CARD_DRAW_MSG = "You drew a Blank Card..."
  # message dispalyed in the battle results when the blank card is drawn
  BLANK_CARD_RESULT_MSG = "Nothing happened."
  
  # message displayed when the penalty card is drawn
  PENALTY_CARD_DRAW_MSG = "You drew a Penalty Card..."
  # message displayed in the battle results when the penalty card is drawn
  PENALTY_CARD_RESULT_MSG = "All the rewards you gained from this battle \nhave vanished..."

  # message that is displayed when a card is picked. must have the %s which 
  # is where the persona's name will be put
  PERSONA_CARD_DRAW_MSG = "You drew a card of the Persona %s!"
  
  # [Audio file directory, Volume level, Pitch]
  # music to play while shuffling
  SHUFFLE_BGM = ["Audio/BGM/Field2", 100, 100]
  # could be the sound of cards
  SHUFFLE_BGS = nil
  SHUFFLE_PENALTY_SOUND = ["Audio/SE/Collapse1", 100, 100]
  SHUFFLE_BLANK_SOUND = ["Audio/SE/Blind", 100, 100] # same sound plays for no card too
  SHUFFLE_CARD_SOUND = ["Audio/SE/Applause2", 100, 100]
  
  # you can change the method below and make it decide the shuffle method
  # however you want
  def self.SHUFFLE_SELECTION(cards)
    if cards.size <= 6
      return ["Horizontal", "Diagonal"].sample
    elsif cards.size <= 10
      return "Combination"
    elsif cards.size <= 15
      return "Matching"
    end
  end
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#  _____           _          __               _   _                 
# | ____|_ __   __| |   ___  / _|   ___  _ __ | |_(_) ___  _ __  ___ 
# |  _| | '_ \ / _` |  / _ \| |_   / _ \| '_ \| __| |/ _ \| '_ \/ __|
# | |___| | | | (_| | | (_) |  _| | (_) | |_) | |_| | (_) | | | \__ \
# |_____|_| |_|\__,_|  \___/|_|    \___/| .__/ \__|_|\___/|_| |_|___/
#                                       |_|                          
#                   _   
#  _ __   __ _ _ __| |_ 
# | '_ \ / _` | '__| __|
# | |_) | (_| | |  | |_ 
# | .__/ \__,_|_|   \__|
# |_|                   
# 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

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
  def persona?
    note =~ /<Persona>/ ? true : false
  end
  
  def users
    # returns list of actors that can use specific persona
    matches = /<User: (\d+(,[ ]?\d+)*)?>/.match(note)
    return Persona::DEFAULT_PERSONA_USERS if matches.nil?
    user_str = matches[1]
    user_str.split(",").collect{ |i| i.to_i }
  end
  
  def only_persona
    note =~ /<Persona: (\d+)>/ ? $1.to_i : nil
  end
  
  def min_player_level
    # min player level required to fuse persona
    note =~ /<Player level: (\d+)>/ ? $1.to_i : 0
  end
  
  def battletest_persona
    # get persona to use for battletest
    note =~ /<Battletest persona: (\d+)>/ ? $1.to_i : 0
  end
end

module Cache
  def self.persona_file(filename)
    load_bitmap("Graphics/Persona/", filename)
  end
end

module DataManager
  class <<self   
    alias persona_cgo create_game_objects
    def create_game_objects
      persona_cgo
      $game_personas = Game_Personas.new
    end 
  end
end

class Game_Actor < Game_Battler
  include Persona
  
  attr_reader :users, :only_persona, :min_player_level
  alias persona_su setup
  def setup(actor_id)
    @persona = nil
    @changed_persona = false
    persona_su(actor_id)
    setup_persona
  end
  
  def setup_persona
    @is_persona = actor.persona?
    @users = actor.users
    @only_persona = actor.only_persona
    @min_player_level = actor.min_player_level
  end
  
  def persona?
    @is_persona
  end
  
  def persona
    @persona
  end
  
  def can_change_persona
    !@changed_persona
  end 
  
  def persona_change_ok?(persona)
    return false if @changed_persona
    return false if @persona == persona
    return false if !can_equip_persona(persona)
    return true
  end
  
  def change_persona(persona)
    return if !persona_change_ok?(persona)
    return if $game_party.personas.find{|p| p.id == persona.id}.nil?
    # when changing persona keep the same hp rate the actor had with the 
    # previous one
    
    prev_hp_rate = hp_rate
    prev_mp_rate = mp_rate
    
    @persona = persona
    @changed_persona = true if $game_party.in_battle
    refresh
    
    @hp = (mhp * prev_hp_rate).to_i
    @mp = (mmp * prev_mp_rate).to_i
  end
  
  def force_change_persona(persona_id)
    return if $game_party.personas.find{|p| p.id == persona_id}.nil?
    # force change persona without checking if it is ok
    prev_hp_rate = hp_rate
    prev_mp_rate = mp_rate
    
    @persona = $game_personas[persona_id]
    @changed_persona = true if $game_party.in_battle
    refresh
    
    @hp = (mhp * prev_hp_rate).to_i
    @mp = (mmp * prev_mp_rate).to_i
  end
  
  def remove_persona
    prev_hp_rate = hp_rate
    prev_mp_rate = mp_rate
    
    @persona = nil
    
    @hp = (mhp * prev_hp_rate).to_i
    @mp = (mmp * prev_mp_rate).to_i
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
  
  def persona_skills
    return @persona.skills if !persona? && !@persona.nil?
    return []
  end
  
  def persona_added_skill_types
    return @persona.added_skill_types if !persona? && !@persona.nil?
    return []
  end
  
  def state_resist?(state_id)
    actor_resists = state_resist_set.include?(state_id)
    persona_resists = false
    if !persona? && !@persona.nil?
      persona_resists = @persona.state_resist_set.include?(state_id)
    end
    return actor_resists || persona_resists
  end
  
  alias persona_param param
  def param(param_id)
    # get the value of the actor's parameter
    value = persona_param(param_id)
    if !persona? && !@persona.nil?
      # get the actor's and persona's multiplier and add both of their parameters 
      # with their respective multiplier
      user_mult = USER_PARAM_MULTIPLIER.is_a?(Array) ? USER_PARAM_MULTIPLIER[param_id] : USER_PARAM_MULTIPLIER
      persona_mult = PERSONA_PARAM_MULTIPLIER.is_a?(Array) ? PERSONA_PARAM_MULTIPLIER[param_id] : PERSONA_PARAM_MULTIPLIER
      value = (value * user_mult) + (@persona.param(param_id) * persona_mult)
    end
    return value.to_i
  end
  
  alias fog_er element_rate
  def element_rate(element_id)
    # get the value of the actor's element rate
    value = features_pi(FEATURE_ELEMENT_RATE, element_id)
    if !persona? && !@persona.nil?
      # get the actor's and persona's multiplier and add both of their element rate 
      # with their respective multiplier
      user_mult = USER_ELEMENT_RATE_MULTIPLIER.is_a?(Array) ? USER_ELEMENT_RATE_MULTIPLIER[xparam_id] : USER_ELEMENT_RATE_MULTIPLIER
      persona_mult = PERSONA_ELEMENT_RATE_MULTIPLIER.is_a?(Array) ? PERSONA_ELEMENT_RATE_MULTIPLIER[xparam_id] : PERSONA_ELEMENT_RATE_MULTIPLIER
      value = (value * user_mult) + (@persona.features_pi(FEATURE_ELEMENT_RATE, element_id) * persona_mult)
    end
    return value
  end
  
  alias fog_dr debuff_rate
  def debuff_rate(param_id)
    # get the value of the actor's debuff rate
    value = features_pi(FEATURE_DEBUFF_RATE, param_id)
    if !persona? && !@persona.nil?
      # get the actor's and persona's multiplier and add both of their debuff rate 
      # with their respective multiplier
      user_mult = USER_DEBUFF_RATE_MULTIPLIER.is_a?(Array) ? USER_DEBUFF_RATE_MULTIPLIER[xparam_id] : USER_DEBUFF_RATE_MULTIPLIER
      persona_mult = PERSONA_DEBUFF_RATE_MULTIPLIER.is_a?(Array) ? PERSONA_DEBUFF_RATE_MULTIPLIER[xparam_id] : PERSONA_DEBUFF_RATE_MULTIPLIER
      value = (value * user_mult) + (@persona.features_pi(FEATURE_DEBUFF_RATE, param_id) * persona_mult)
    end
    return value
  end
  
  alias fog_sr state_rate
  def state_rate(state_id)
    # get the value of the actor's state rate
    value = features_pi(FEATURE_STATE_RATE, state_id)
    if !persona? && !@persona.nil?
      # get the actor's and persona's multiplier and add both of their state rate 
      # with their respective multiplier
      user_mult = USER_STATE_RATE_MULTIPLIER.is_a?(Array) ? USER_STATE_RATE_MULTIPLIER[xparam_id] : USER_STATE_RATE_MULTIPLIER
      persona_mult = PERSONA_STATE_RATE_MULTIPLIER.is_a?(Array) ? PERSONA_STATE_RATE_MULTIPLIER[xparam_id] : PERSONA_STATE_RATE_MULTIPLIER
      value = (value * user_mult) + (@persona.features_pi(FEATURE_STATE_RATE, state_id) * persona_mult)
    end
    return value
  end
  
  alias persona_xparam xparam
  def xparam(xparam_id)
    # get the value of the actor's x_parameter
    value = persona_xparam(xparam_id)
    if !persona? && !@persona.nil?
      # get the actor's and persona's multiplier and add both of their x_parameters 
      # with their respective multiplier
      user_mult = USER_PARAM_MULTIPLIER.is_a?(Array) ? USER_XPARAM_MULTIPLIER[xparam_id] : USER_XPARAM_MULTIPLIER
      persona_mult = PERSONA_PARAM_MULTIPLIER.is_a?(Array) ? PERSONA_XPARAM_MULTIPLIER[xparam_id] : PERSONA_PARAM_MULTIPLIER
      value = (value * user_mult) + (@persona.xparam(xparam_id) * persona_mult)
    end
    return value
  end
  
  alias persona_sparam sparam
  def sparam(sparam_id)
    # get the value of the actor's s_parameter
    value = persona_sparam(sparam_id)
    if !persona? && !@persona.nil?
      # get the actor's and persona's multiplier and add both of their s_parameters 
      # with their respective multiplier
      user_mult = USER_PARAM_MULTIPLIER.is_a?(Array) ? USER_SPARAM_MULTIPLIER[sparam_id] : USER_SPARAM_MULTIPLIER
      persona_mult = PERSONA_PARAM_MULTIPLIER.is_a?(Array) ? PERSONA_SPARAM_MULTIPLIER[sparam_id] : PERSONA_SPARAM_MULTIPLIER
      value = (value * user_mult) + (@persona.sparam(sparam_id) * persona_mult)
    end
    return value
  end
  
  def only_persona?
    return !only_persona.nil?
  end
  
  def can_equip_persona(persona)
    persona.min_player_level <= @level && $game_party.persona_available(persona)
  end
  
  alias persona_ge gain_exp
  def gain_exp(exp)
    persona_ge(exp)
    if !persona? && !@persona.nil?
      @persona.gain_exp(exp)
    end
  end
  
  alias persona_fer final_exp_rate
  def final_exp_rate
    return persona_fer if !persona?
    return exr * Persona::PERSONA_EXP_GAIN_MULTIPLIER
  end
  
  alias persona_i index
  def index
    return persona_i if !persona?
    # return persona's index from user's personas list
    user = $game_party.menu_actor
    return $game_party.actors_personas(user.id).index(self)
  end
  
  def next_skill
    # return the next (closest in level) skill that the actor will learn
    self.class.learnings.select{ |learning| learning.level > @level}.min_by{ |learning| learning.level }
  end
  
  def next_skills
    # return all the skills that the actor will learn
    self.class.learnings.select{ |learning| learning.level > @level }
  end
  
  def on_battle_start
    super
    # reset flag on battle start
    @changed_persona = false
  end
  
  def on_turn_end
    super
    # reset flag on turn end
    @changed_persona = false
  end
end

class Game_Party < Game_Unit
  alias persona_init initialize
  def initialize
    @personas = []
    @menu_persona_id = 0
    persona_init
  end
  
  def personas
    # returns party's personas
    @personas.collect{ |id| $game_personas[id] }
  end
  
  alias persona_sbt setup_battle_test
  def setup_battle_test
    persona_sbt
    setup_test_battle_personas
  end
  
  def battle_personas
    members.reject{|m| m.persona.nil?}.collect{|m| m.persona}
  end
  
  def persona_in_party(persona_name)
    return !personas.find{|p| p.name == persona_name}.nil?
  end
  
  def persona_equipped_by(actor_id, persona_name)
    actor = members.find{|m| m.id == actor_id}
    return false if actor.nil?
    return false if actor.persona.nil?
    return actor.persona.name == persona_name
  end
  
  def persona_equipped(persona_name)
    persona = personas.find{|p| p.name == persona_name}
    return persona_available(persona)
  end
  
  def setup_test_battle_personas
    $data_system.test_battlers.each do |battler|
      # get battletest persona of each battle test actor and equip them
      actor = $game_actors[battler.actor_id]
      btest_persona = $data_actors[battler.actor_id].battletest_persona
      if btest_persona != 0
        actor.change_persona($game_actors[btest_persona])
      end
    end
  end
  
  def add_persona(persona_id)
    # inform user (script user) about the mistake just in case
    if $game_personas[persona_id].nil?
      msgbox("There was an attempt to add a persona with an invalid ID (ID=#{persona_id})")
    end
    
    @personas.push(persona_id) if !@personas.include?(persona_id) && !$game_personas[persona_id].nil?
    # auto equip new persona if there is a member that uses only one persona
    user = members.find{|m| m.only_persona == persona_id}
    user.change_persona($game_personas[persona_id]) if !user.nil?
    
    $game_player.refresh
    $game_map.need_refresh = true
  end
  
  def remove_persona(persona_id)
    # unequip persona
    user = members.find{|m| !m.persona.nil? && m.persona.id == persona_id}
    user.remove_persona if !user.nil?
    
    # remove persona from party
    @personas.delete(persona_id)
    $game_player.refresh
    $game_map.need_refresh = true
  end
  
  def actors_personas(actor_id)
    # get the of the personas that belong to the actor
    ids = @personas.select{ |id| $game_personas[id].users.include?(actor_id) }
    # if the party has no personas that belong to the actor an empty list is returned
    return ids.collect{ |id| $game_personas[id] }
  end
  
  def persona_available(persona)
    # returns if true if persona is not currently equipped by any member of the party
    members.inject(true){|available, m| available && m.persona != persona}
  end
  
  def menu_persona
    $game_personas[@menu_persona_id] || menu_personas[0]
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

class Game_Personas
  def initialize
    @data = []
  end
  
  def [](actor_id)
    return nil if !$data_actors[actor_id]
    return nil if !$data_actors[actor_id].persona?
    @data[actor_id] ||= Game_Actor.new(actor_id)
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
    name = Persona::PERSONA_MENU_NAME
    ext = nil
    command = { :name=>name, 
                :symbol=>:persona, 
                :enabled=>@actor.can_change_persona, 
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
      Sound.play_equip
      Input.update
      call_equip_handler
    else
      Sound.play_buzzer
    end
  end
  
  def call_equip_handler
    call_handler(:ok)
  end
  def equip_enabled?
    handle?(:ok)
  end
  
  def draw_item_background(index)
    equiped_persona_index = @personas.index(@actor.persona)
    if index == equiped_persona_index
      color = pending_color
      color.alpha = 100
      contents.fill_rect(item_rect(index), color)
    end
  end
  
  def draw_persona_name_level(persona, rect, enabled)
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
    draw_persona_name_level(persona, rect, enabled)
  end
  
  def process_ok
    super
    persona = @personas[index]
    $game_party.menu_persona = persona
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

class Window_Keys < Window_Base
  include Persona
  def initialize
    width = 200
    height = line_height
    super(Graphics.width - width, Graphics.height - height, width, height)
    determine_window_size
    draw_content
    self.visible = false
  end
  
  def determine_window_size
    # determines window's size according to the size of the button images
    @select_button = Cache.persona_file(SELECT_PERSONA_BUTTON_IMG_NAME)
    @equip_button = Cache.persona_file(EQUIP_PERSONA_BUTTON_IMG_NAME)
    # largest height and width between the two button images
    height = [@select_button.height, @equip_button.height].max
    width = [@select_button.width, @equip_button.width].max
    # increase width by largest width between two texts
    width += [text_size(SELECT_PERSONA_TEXT).width, text_size(EQUIP_PERSONA_TEXT).width].max
    
    # max width of window is half the width of the game window so that it doesn't
    # overlap with the personas window
    self.width = [width + standard_padding * 2, Graphics.width / 2].min
    self.height = height * 2 + line_height + standard_padding
    
    self.x = Graphics.width - self.width
    self.y = Graphics.height - self.height
    
    create_contents
  end
  
  def draw_content
    contents.clear
    
    # draw top button (select)
    x = @select_button.width
    txt_height = text_size(SELECT_PERSONA_TEXT).height
    btn_height = @select_button.height
    y = [txt_height, btn_height].max / 2
    contents.blt(0, y - btn_height / 2, @select_button, @select_button.rect)
    draw_text(x, y - txt_height/2, self.width - x - standard_padding, line_height, SELECT_PERSONA_TEXT)
    
    # draw bottom button (equip)
    x = @select_button.width
    txt_height = text_size(EQUIP_PERSONA_TEXT).height
    btn_height = @equip_button.height
    y = contents.height / 2 + [txt_height, btn_height].max / 2
    contents.blt(0, y - btn_height / 2, @equip_button, @equip_button.rect)
    draw_text(x, y - txt_height / 2, self.width - x - standard_padding, line_height, EQUIP_PERSONA_TEXT)
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

class Window_MenuStatus < Window_Selectable
  def ok_enabled?
    actor = $game_party.members[index]
    # can't view persona's status for actor that can use only one persona and 
    # that persona is not equipped
    return false if actor.only_persona? && actor.persona.nil?
    handle?(:ok)
  end
end

class Window_Personas < Window_Command
  include Persona
  
  def initialize(actor)
    @actor = actor
    @personas = $game_party.actors_personas(@actor.id)
    super(0, 0)
    self.visible = false
    select_last
  end
  
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    @personas = $game_party.actors_personas(@actor.id)
    refresh
    select_last
  end
  
  def personas
    @personas
  end
  
  def window_width
    Graphics.width / 2
  end
  
  def window_height
    Graphics.height
  end
  
  def item_height
    (height - standard_padding * 2) / visible_line_number
  end
  
  def visible_line_number
    4
  end
  
  def item_max
    @personas.size
  end
  
  def current_persona
    @personas[index]
  end
  
  def process_handling
    return unless open? && active
    return process_equip if equip_enabled? && Input.trigger?(EQUIP_PERSONA_KEY)
    super
  end
  
  def process_equip
    if persona_equippable?
      Sound.play_equip
      Input.update
      call_equip_handler
    else
      Sound.play_buzzer
    end
  end
  
  def call_equip_handler
    call_handler(:equip)
  end
  
  def equip_enabled?
    handle?(:equip)
  end
    
  def refresh
    super
    contents.clear
    draw_all_items
  end
  
  def draw_all_items
    draw_no_personas_msg if @personas.empty?
    super
  end
  
  def draw_no_personas_msg
    draw_text(0, 0, width, line_height, NO_PERSONAS_MSG)
  end
  
  def draw_item(index)
    persona = @personas[index]
    
    enabled = @actor.can_equip_persona(persona)
    rect = item_rect(index)
    draw_item_background(index)
    draw_actor_face(persona, rect.x + 1, rect.y + 1, enabled)
    draw_actor_simple_status(persona, rect.x + 108, rect.y, enabled)
  end
    
  def draw_actor_simple_status(actor, x, y, enabled)
    change_color(normal_color, enabled)
    draw_actor_name(actor, x, y)
    draw_actor_class(actor, x, y + line_height)
    draw_actor_level(actor, x, y + line_height * 2)
    change_color(normal_color)
  end
  
  def draw_item_background(index)
    equiped_persona_index = @personas.index(@actor.persona)
    if index == equiped_persona_index
      color = pending_color
      color.alpha = 100
      contents.fill_rect(item_rect(index), color)
    end
  end
  
  def persona_equippable?
    persona = @personas[index]
    return @actor.can_equip_persona(persona)
  end
  
  def process_ok
    Sound.play_ok
    Input.update
    deactivate
    
    persona = @personas[index]
    $game_party.menu_persona = persona
    call_ok_handler
  end
  
  def current_item_enabled?
    persona = @personas[index]
    enabled = $game_party.persona_available(persona) || @actor.persona == persona
    return enabled
  end
  
  def select_last
    if @personas.nil? || $game_party.menu_persona.nil?
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
    return if @persona == persona
    @persona = persona
    refresh
  end
  
  def process_handling
    return unless open? && active
    return process_equip if equip_enabled? && Input.trigger?(EQUIP_PERSONA_KEY)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    super
  end
  
  def process_equip
    if persona_equippable?
      Sound.play_equip
      Input.update
      call_equip_handler
    else
      Sound.play_buzzer
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
    draw_actor_class(@persona, 128, y)
    draw_actor_nickname(@persona, 288, y)
  end
  
  def draw_block2(y)
    draw_actor_face(@persona, 8, y)
    draw_basic_info(136, y)
    draw_exp_info(136, y)
    draw_next_skill(136, y + line_height * 3)
  end
  
  def draw_block3(y)
    draw_parameters(10, y)
    draw_skills(100, y)
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
  
  def draw_skills(x, y)
    col_width = ((self.width - x) / 3).to_i
    cols_max_x = [0, 0] # first and second cols only needed
    @persona.skills.each_with_index do |item, i|
      col = i.div(6)
      offset_x = col_width * col 
      offset_y = line_height * i.divmod(6)[1]
      draw_item_name(item, x + offset_x, y + offset_y, true, col_width - 24)
    end
    next_skills_i = @persona.skills.length
    @persona.next_skills.each_with_index do |item, i|
      i += next_skills_i
      offset_x = 150 * (i/6).to_i
      offset_y = line_height * i.divmod(6)[1]
      draw_text(x + offset_x, y + offset_y, col_width, line_height, "-------")
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
      elsif @persona.element_rate(i+1) > 1.0
        draw_strong_ele_icon(new_x, y)
      elsif @persona.element_rate(i+1) < 1.0
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
    @actor_command_window.set_handler(:persona, method(:command_persona))
    @actor_command_window.set_handler(:persona_skills, method(:persona_skills))
    @actor_command_window.set_handler(:persona_magic, method(:persona_skills))
  end
  
  def persona_skills
    @skill_window.actor = BattleManager.actor.persona if BattleManager.actor.persona
    @skill_window.stype_id = @actor_command_window.current_ext
    @skill_window.refresh
    @skill_window.show.activate
  end
  
  def command_persona
    @persona_window = Window_BattlePersonas.new(BattleManager.actor)
    @persona_window.select_last
    @persona_window.set_handler(:ok, method(:on_persona_ok))
    @persona_window.set_handler(:cancel, method(:on_persona_cancel))
  end
  
  def on_persona_ok
    persona = @persona_window.item
    BattleManager.actor.change_persona(persona)
    BattleManager.actor.refresh
    @persona_window.hide
    @actor_command_window.activate
    @actor_command_window.refresh_persona_change
    @status_window.refresh
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
  include Persona
  
  alias persona_ccw create_command_window
  def create_command_window
    persona_ccw
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

class Scene_Personas < Scene_Base
  def start
    super
    create_background
    @actor = $game_party.menu_actor
    @persona = @actor.persona
    create_personas_window
    create_buttons_window
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
  
  def create_buttons_window
    @buttons_window = Window_Keys.new
    @buttons_window.open
  end
  
  def create_personas_window
    @personas_window = Window_Personas.new(@actor)
    @personas_window.select_last
    @personas_window.set_handler(:ok, method(:on_persona_ok))
    @personas_window.set_handler(:cancel, method(:return_scene))
    @personas_window.set_handler(:equip, method(:persona_equip))
    @personas_window.set_handler(:pagedown, method(:next_actor))
    @personas_window.set_handler(:pageup,   method(:prev_actor))
    @personas_window.open
  end
  
  def create_status_window
    @status_window = Window_PersonaStatus.new($game_party.menu_persona)
    @status_window.set_handler(:cancel,   method(:close_status))
    @status_window.set_handler(:equip, method(:persona_equip))
    @status_window.set_handler(:pagedown, method(:next_persona))
    @status_window.set_handler(:pageup,   method(:prev_persona))
    @status_window.open
  end
    
  def on_persona_ok
    @status_window.persona = @personas_window.current_persona
    @status_window.show.activate
    @personas_window.deactivate
  end
  
  def persona_equip
    # get previous persona index
    prev_persona_index = @personas_window.personas.index(@actor.persona)
    @actor.remove_persona
    # redraw that item in window
    @personas_window.redraw_item(prev_persona_index) if !prev_persona_index.nil?
    #equip new persona
    if @status_window.active
      @actor.change_persona(@persona)
    else
      @actor.change_persona(@personas_window.current_persona)
    end
    #redrwa that item
    index = @personas_window.personas.index(@actor.persona)
    @personas_window.redraw_item(index)
  end
  
  def on_actor_change
    if @actor.only_persona? && !@persona.nil?
      # if current (new actor after next/prev_actor) uses only one persona 
      # and the persona is equipped, skip to status window (does not show 
      # all personas that can be equipped by specific actor as he can only 
      # equip one and it is auto-equipped when added to the party)
      @personas_window.deactivate
      @personas_window.hide
      @buttons_window.hide
      @status_window.persona = @persona
      @status_window.show.activate
    else
      # else show list of personas current actor can equip
      @status_window.deactivate
      @status_window.hide
      @buttons_window.show
      @personas_window.actor = @actor
      @personas_window.show.activate
    end
  end
  
  def next_actor
    new_actor = $game_party.menu_actor_next
    if new_actor.only_persona? && new_actor.persona.nil?
      # if next actor can equip only one persona and it is not equipped (not in
      # the party) then stay in current actor
      $game_party.menu_actor_prev
    else
      @actor = new_actor
      @persona = @actor.persona
      on_actor_change
    end
  end
  
  def prev_actor
    new_actor = $game_party.menu_actor_prev
    if new_actor.only_persona? && new_actor.persona.nil?
      # if pervious actor can equip only one persona and it is not equipped (not in
      # the party) then stay in current actor
      $game_party.menu_actor_next
    else
      @actor = new_actor
      @persona = @actor.persona
      on_actor_change
    end
  end
  
  def next_persona
    if @actor.only_persona?
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
    if @actor.only_persona?
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
    if @actor.only_persona?
      # if current actor can equip only one persona return scene
      SceneManager.return
      return
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
    # min rank required to fuse persona
    note =~ /<Max skills: (\d+)>/ ? $1.to_i : Persona::DEFAULT_MAX_PERSONA_SKILLS
  end
end

class Game_Actor < Game_Battler
  attr_accessor :extra_skills
  attr_reader :max_skills
  
  alias persona_forget_sp setup_persona
  def setup_persona
    persona_forget_sp
    @extra_skills = []
    @max_skills = actor.max_skills
  end
  
  alias persona_forget_is init_skills
  def init_skills
    if actor.persona?
      @skills = []
      # reverse learning so that persona doesn't learn low level skills
      self.class.learnings.reverse.each do |learning|
        learn_skill(learning.skill_id) if learning.level <= @level
        # is used instead of @max_skills because persona sestup is done 
        # after actor initialization
        break if @skills.size >= actor.max_skills 
      end
    else
      persona_forget_is
    end
  end
  
  def level_up
    @level += 1
    self.class.learnings.each do |learning|
      if persona? && @skills.size >= @max_skills
        @extra_skills.push(learning.skill_id) if learning.level == @level
      else
        learn_skill(learning.skill_id) if learning.level == @level
      end
    end
  end
  
  alias persona_forget_ce change_exp
  def change_exp(exp, show)
    persona_forget_ce(exp, show)
    if @extra_skills.size > 0
      $game_party.menu_persona = self
      if !SceneManager.scene_is?(Scene_Battle)
        SceneManager.call(Scene_ForgetSkill)
      end
    end
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
  def initialize(persona)
    persona_forget_init(persona)
    if !extra_skills.empty?
      clear_command_list
      make_command_list
    end
    select_last
  end
  
  def extra_skills
    @persona ? @persona.extra_skills : []
  end
  
  def draw_skills(x, y)
    col_width = ((self.width - x) / 3).to_i
    cols_max_x = [0, 0] # first and second cols only needed
    @persona.skills.each_with_index do |item, i|
      col = i.div(6)
      offset_x = col_width * col 
      offset_y = line_height * i.divmod(6)[1]
      draw_item_name(item, x + offset_x, y + offset_y, true, col_width - 24)
    end
    next_skills_i = @persona.skills.length
    @persona.next_skills.each_with_index do |item, i|
      i += next_skills_i
      break if i >= @persona.max_skills
      offset_x = 150 * (i/6).to_i
      offset_y = line_height * i.divmod(6)[1]
      draw_text(x + offset_x, y + offset_y, col_width, line_height, "-------")
    end
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
    Sound.play_equip
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
    ((self.width - 100)/3).to_i
  end
  
  def row_max
    [(item_max + col_max - 1) / item_max, 1].max
  end
  
  def item_max
    @persona ? @persona.max_skills : 1
  end
  
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = ((index/6).to_i * item_width) + 100
    rect.y = (item_height * index.divmod(6)[1]) + line_height * 7
    rect
  end
  
  def col_max
    3
  end
  
  def select_last
    if extra_skills.empty?
      select(-1)
    else
      select(0)
    end
  end  
  
  def cursor_down(wrap = false)
    if col_max >= 2 && (index < item_max - 1 || (wrap && horizontal?))
      select((index + 1) % item_max)
    end
  end
  
  def cursor_up(wrap = false)
    if col_max >= 2 && (index > 0 || (wrap && horizontal?))
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
  alias persona_forget_start start
  def start
    persona_forget_start
    create_windows
    create_background
  end
  
  def start_without_bg
    create_windows
  end
  
  def create_windows
    create_main_viewport
    create_status_window
    create_message_window
    create_new_skill_window
  end
  
  def create_status_window
    @status_window = Window_PersonaStatus.new($game_party.menu_persona)
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
    @choice = 0
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
    
    $game_message.add("Are you sure you don't want #{persona.name}\nto learn #{new_skill.name}?")
    $game_message.choices.push("Yes")
    $game_message.choices.push("No")
    $game_message.choice_cancel_type = 2
    $game_message.choice_proc = Proc.new {|n| @choice = n }
    wait_for_message
    index = @status_window.index
    if @choice == 0
      @status_window.activate
      persona.extra_skills.delete_at(0)
      @status_window.refresh
      $game_message.add("#{persona.name} didn't learn #{new_skill.name}!")
      wait_for_message
    else
      @status_window.activate
      return
    end
    finish_new_skill
  end
  
  def skill_forget
    persona = @status_window.persona
    @status_window.deactivate
    skill = persona.skills[@status_window.index]
    new_skill = $data_skills[persona.extra_skills[0]]
    $game_message.add("Are you sure you want #{persona.name} to forget\n#{skill.name} and learn #{new_skill.name}?")
    $game_message.choices.push("Yes")
    $game_message.choices.push("No")
    $game_message.choice_cancel_type = 2
    $game_message.choice_proc = Proc.new {|n| @choice = n }
    wait_for_message
    index = @status_window.index
    if @choice == 0
      persona.replace_skill(skill, new_skill)
      persona.extra_skills.delete_at(0)
      @status_window.refresh
      $game_message.add("#{persona.name} forgot #{skill.name} and learned\n#{new_skill.name}!")
      wait_for_message
    else
      @status_window.activate
      return
    end
    finish_new_skill
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
  
  def battletest_persona
    # get persona to use for battletest
    note =~ /<Battletest persona: (\d+)>/ ? $1.to_i : 0
  end
end

class RPG::Class < RPG::BaseItem
  def arcana?
    note =~ /<Arcana>/ ? true : false
  end
  
  def rank_var_id
    note =~ /<Rank variable: (\d+)>/ ? $1.to_i : nil
  end
  
  def max_rank
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
    actors = /<Social links actors: (\d+(,[ ]?\d+)*)?>/.match(note)
    return [] if actors.nil?
    return actors[1].split(",").collect{ |i| i.to_i }
  end
  
  def social_links_variables
    # return variable ids from tag
    vars = /<Social links vars: (\d+(,[ ]?\d+)*)?>/.match(note)
    return [] if vars.nil?
    return vars[1].split(",").collect{ |i| i.to_i }
  end
end

module Cache
  def self.arcana(filename)
    load_bitmap("Graphics/" + Persona::ARCANA_IMG_FOLDER, filename)
  end
  
  def self.persona_file(filename)
    load_bitmap("Graphics/Persona/", filename)
  end
end

class Game_Actor < Game_Battler
  include Persona

  attr_reader :social_description, :max_arcana_rank, :min_arcana_rank
  alias persona_arcana_sp setup_persona
  def setup_persona
    persona_arcana_sp
    @social_description = actor.social_description
    @is_arcana = @is_persona ? self.class.arcana? : false
    
    # check if a class exists with the same name as the nickname
    nickname_of_arcana = !$data_classes.find{|c| !c.nil? && c.arcana? && c.name == @nickname }.nil?
    if !@is_arcana && nickname_of_arcana
      # if class is not of an arcana but the nickname is then actor is an arcana
      @is_arcana = true
    end
    
    if nickname_of_arcana
      # if nickname is of arcana, get the arcana class it belongs to
      arcana_class = $data_classes.find{|c| !c.nil? && c.arcana? && c.name == @nickname }
    else
      arcana_class = self.class
    end

    @max_arcana_rank = @is_persona ? arcana_class.max_rank : nil
    @rank_var_id = arcana_class.rank_var_id
    @min_arcana_rank = actor.min_arcana_rank
  end
  
  alias persona_arcana_cep can_equip_persona
  def can_equip_persona(persona)
    persona.min_arcana_rank <= persona.arcana_rank && persona_arcana_cep(persona)
  end
  
  def arcana_name
    # return appropriate arcana name
    if @is_arcana && self.class.arcana?
      return self.class.name
    elsif @is_arcana
      return @nickname
    else
      return ""
    end
  end
  
  def arcana?
    @is_arcana
  end
  
  def arcana_rank
    $game_variables[@rank_var_id] if arcana?
  end
  
  def special_persona?
    @is_special_persona
  end
end

class Game_Player < Game_Character
  include Persona
  def arcana_rank_up(arcana_name)
    # increases rank of arcana by one
    arcana = $data_classes.find{ |c| !c.nil? && c.arcana? && c.name == arcana_name }
    return if arcana.nil?
    rank = $game_variables[arcana.rank_var_id]
    rank += 1 
    $game_variables[arcana.rank_var_id] = [rank, 0].max
  end
  
  def arcana_rank_down(arcana_name)
    # decreases rank of arcana by one
    arcana = $data_classes.find{ |c| !c.nil? && c.arcana? && c.name == arcana_name }
    return if arcana.nil?
    rank = $game_variables[arcana.rank_var_id]
    rank -= 1 
    $game_variables[arcana.rank_var_id] = [rank, 0].max
  end
  
  def arcana_rank_up_by(arcana_name, ranks_up)
    ranks_up.times.do{ arcana_rank_up(arcana_name) }
  end
  
  def arcana_rank_down_by(arcana_name, ranks_down)
    ranks_down.times.do{ arcana_rank_down(arcana_name) }
  end
  
  def available_arcanas
    # returns arcanas which rank is higher than MIN_RANK
    arcanas = $data_classes.select{ |c| !c.nil? && c.arcana? && !c.rank_var_id.nil? }
    available_arcanas = arcanas.select{ |a| $game_variables[a.rank_var_id] >= MIN_RANK }
    return available_arcanas
  end
end

class Game_Variables
  alias :arcana_rank :[]
  def [](variable_id)
    ret_val = arcana_rank(variable_id)
    
    # get all arcanas that have a variable id for their rank
    arcanas = $data_classes.select{ |c| !c.nil? && c.arcana? && !c.rank_var_id.nil? }
    # get their variable id
    ids = arcanas.collect{ |c| c.rank_var_id }
    
    if ids.index(variable_id).nil?
      # return value of variable if it is not an arcana's rank
      return ret_val
    else
      # if id is one of arcanas' rank return its rank
      # or if it is nil, return default value which is Persona::MIN_RANK - 1
      @data[variable_id] || 0
    end
  end
end

class Window_ArcanaInfo < Window_Base
  def initialize(arcana)
    super(0, 0, window_width, window_height)
    @selected_arcana = arcana
    @arcana_y = 0
    @info_x = 0
    @info_y = 0
    self.openness = 0
  end
  
  def window_width
    Graphics.width
  end
  
  def window_height
    Graphics.height * 0.35
  end
  
  def draw_arcana_rank
    rank_str = " Rank #{$game_variables[@selected_arcana.rank_var_id]}"
    w = text_size(rank_str).width
    h = text_size(rank_str).height
    draw_text(0, 0, w, h, rank_str)
    @arcana_y += h
  end
  
  def draw_arcana
    bitmap = Cache.arcana(@selected_arcana.name)
    ratio_h = 1.0 - ((window_height - bitmap.height - @arcana_y - standard_padding*2).abs / bitmap.height.to_f)
    ratio_h += (window_height > bitmap.height ? 1.0 : 0.0)
    ratio_w = ratio_h
    new_w = bitmap.width * ratio_w
    new_h = (bitmap.height * ratio_h) - 2
    new_rect = Rect.new(0, @arcana_y, new_w, new_h)
    contents.stretch_blt(new_rect, bitmap, bitmap.rect)
    bitmap.dispose
    
    @info_x += new_w
  end
  
  def draw_arcana_name
    if @selected_arcana.social_target.empty?
      social_target = ""
    else
      social_target = @selected_arcana.social_target
    end
    
    text = " #{@selected_arcana.name}    #{social_target}"
    w = window_width
    h = text_size(text).height
    draw_text(@info_x, 0, w, h, text)
    
    @info_y += h
  end
  
  def draw_arcana_info
    text = @selected_arcana.description
    return if text.empty?
    
    words = text.split(" ")
    line_num = 0
    
    text_line = " " + words[0]
    for i in 1..words.size
      if i == words.size
        w = window_width - @info_x
        h = line_height
        draw_text(@info_x, @info_y + line_num*h, w, h, text_line)
        break
      end
      
      new_text = text_line + " " + words[i]
      line_size = text_size(new_text)
      if line_size.width + @info_x > window_width
        w = line_size.width
        h = line_height
        draw_text(@info_x, @info_y + line_num*h, w, h, text_line)
        line_num += 1
        text_line = (" " + words[i])
      else
        text_line += (" " + words[i])
      end
    end
  end
  
  def refresh
    contents.clear
    return if @selected_arcana.nil?
    draw_arcana_rank
    draw_arcana
    draw_arcana_name
    draw_arcana_info
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
  
  def process_ok
    call_show_rank_handler
  end
  
  def call_rank_handler
    call_handler(:show_rank)
  end
  def rank_enabled?
    handle?(:show_rank)
  end
  
  def draw_actor_simple_status(actor, x, y, enabled)
    change_color(normal_color, enabled)
    draw_actor_name(actor, x, y)
    change_color(normal_color)
  end
  
  def draw_arcana(arcana, x, y)
    bitmap = Cache.arcana(arcana.name)
    ratio_h = 1 - ((item_height - bitmap.height).abs / bitmap.height.to_f)
    ratio_h += (item_height > bitmap.height ? 1.0 : 0.0)
    ratio_w = ratio_h
    new_w = bitmap.width * ratio_w
    new_h = (bitmap.height * ratio_h) - 2
    new_rect = Rect.new(x, y, new_w, new_h)
    contents.stretch_blt(new_rect, bitmap, bitmap.rect)
    bitmap.dispose
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
  
  def draw_arcana_rank(arcana, x, y)
    start_x = x + 100
    start_y = y
    
    rank = $game_variables[arcana.rank_var_id]
    rank_str = sprintf("Rank %i", rank)
    w = text_size(rank_str).width
    h = text_size(rank_str).height
    draw_text(start_x, start_y, w, h, rank_str)
    
    start_y += h
    
    bar_width = contents.width - start_x
    rect = Rect.new(start_x, start_y, bar_width, @progress_bar.height)
    contents.stretch_blt(rect, @progress_bar, @progress_bar.rect)
    subbar_width = (bar_width.to_f) / arcana.max_rank
    
    arcana_rank = $game_variables[arcana.rank_var_id]
    for i in 0...arcana_rank
      draw_rank_progress(start_x, start_y, i, subbar_width)
    end
    
    for i in arcana_rank...arcana.max_rank
      draw_rank_remaining(start_x, start_y, i, subbar_width)
    end
  end
  
  def draw_item_background(index)
    if index == @pending_index
      contents.fill_rect(item_rect(index), pending_color)
    end
  end
  
  def draw_item(index)
    arcana = @arcanas[index]
    
    rect = item_rect(index)
    draw_item_background(index)
    draw_arcana(arcana, rect.x + 1, rect.y + 1)
    draw_arcana_rank(arcana, rect.x + 1, rect.y + 1)
  end
  
  def current_item_enabled?
    return true
  end
  
  def process_ok
    super
    @selected_arcana = @arcanas[index]
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
    @social_links_window.open
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
  include Persona

  attr_reader :evolve_at, :evolve_to
  alias persona_evolve_sp setup_persona
  def setup_persona
    persona_evolve_sp
    @evolve_at = arcana? ? actor.evolve_at : -1
    @evolve_to = arcana? ? actor.evolve_to : ""
  end
end

class Game_Player < Game_Character
  alias persona_evolve_aru arcana_rank_up
  def arcana_rank_up(arcana_name)
    persona_evolve_aru(arcana_name)
    check_party_persona_evolve
  end
  
  def check_party_persona_evolve
    # check members' personas first and if one will be evolved equip it 
    # automatically to the actor that had the persona equipped
    members = $game_party.members
    members.each do |m|
      next if m.persona.nil?
      persona = m.persona
      if persona.arcana_rank == persona.evolve_at
        evolved_persona = evolve_persona(persona)
        m.change_persona(evolved_persona)
        play_evolution
        $game_party.menu_persona = evolved_persona
        SceneManager.call(Scene_EvolvedPersona)
      end      
    end
    
    # find all others and evolve them
    members_personas = members.collect{|m| m.persona }
    personas = $game_party.personas
    personas.each do |p|
      next if !members_personas.find{|mp| mp == p}.nil?
      if p.arcana_rank == p.evolve_at
        evolved_persona = evolve_persona(p)
        play_evolution
        $game_party.menu_persona = evolved_persona
        SceneManager.call(Scene_EvolvedPersona)
      end      
    end
  end
  
  def evolve_persona(persona)
    $game_party.remove_persona(persona.id)
    evolved_persona = $data_actors.find{|a| !a.nil? && a.name == persona.evolve_to}
    evolved_persona = $game_personas[evolved_persona.id]
    $game_party.add_persona(evolved_persona.id)
    $game_variables[EVOLVING_PERSONA_VAR_ID] = persona.name
    $game_variables[RESULTING_PERSONA_VAR_ID] = evolved_persona.name
    return evolved_persona
  end
  
  def play_evolution
    common_event = $data_common_events[Persona::COMMON_EVENT_ID]
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
  def fuse_parents
    # matches all the <Fusion parents> tag in note
    matches = note.scan(/<Fusion parents: (\d+),[ ]?(\d+)>/)
    if matches.empty?
      return nil
    else
      # for each <Fusion parents> tag, append the parents to a list and return
      parents = []
      for m in matches
        parents.push([m[0].to_i, m[1].to_i])
      end
      return parents
    end
  end
  
  def special_fusion
    # get ids required for special fusion. returns empty list if there are no ids
    # as it is now it matches more than 3 ids, but will return only the first 3
    # kept as is for the future
    matches = /<Special fusion: (\d+(,[ ]?\d+)*)?>/.match(note)
    return [] if matches.nil?
    parents = matches[1]
    parents.split(",").collect{ |i| i.to_i }[0...3]
  end
  
  def are_parents(persona_a_id, persona_b_id)
    parents_pairs = fuse_parents # get all parents of persona
    return false if parents_pairs.nil?
    if Persona::ORDER_MATTERS
      # if order matters search for index of pair and return true if found
      return !parents_pairs.index([persona_a_id, persona_b_id]).nil?
    else
      # sort each pair and search for index of pair provided
      return !parents_pairs.map{|p| p.sort }.index([persona_a_id, persona_b_id].sort).nil?
    end
  end
  
  def are_special_parents(parents)
    s_p = special_fusion
    if Persona::ORDER_MATTERS
      return parents[0] == s_p[0] && parents[1] == s_p[1] && parents[2] == s_p[2]
    else
      return parents.inject(true){|r, p| r && s_p.index(p).nil? }
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
    SceneManager.call(Scene_Fuse)
    Fiber.yield
  end
  
  def get_fusion_child(parent_a, parent_b)
    # get all personas that have parents
    children = $data_actors.select{|a| !a.nil? && a.persona? && !a.fuse_parents.nil? }
    # find child of those parents
    child = children.find{|a| a.are_parents(parent_a.id, parent_b.id) }
    return nil if child.nil?
    return $game_actors[child.id]
  end
  
  def get_special_fusion(parents)
    # get all 
    parents_ids = parents.collect{|p| p.id}
    special = $data_actors.find{|a| !a.nil? && a.are_special_parents(parents_ids) }
    return nil if special.nil?
    return $game_actors[special.id]
  end
end

class Window_ExtraExp < Window_Base
  def initialize(x, y)
    height = line_height * 2
    super(x, y, 180, height)
    @current_exp = 0
    @exp_changed = false
    self.visible = false
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

class Window_Fuse < Window_Command
  include Persona
  
  attr_reader :result, :children
  def initialize(fuse_count)
    @selected_personas = []
    @fuse_count = fuse_count
    @children = []
    @result = nil
    @personas = available_personas
    super(0, 0)
    select_last
  end
  
  def selected_personas
    @selected_personas
  end
  
  def remove_last_persona
    @selected_personas.pop
    @result = nil
    refresh
  end
  
  def reset
    self.active = true
    select_last
    @selected_personas = []
    @result = nil
    @personas = available_personas
    refresh
  end
  
  def refresh
    contents.clear
    refresh_children
    draw_all_items
  end
  
  def refresh_children
    @children.clear
    # calculate children only when the last persona is not selected
    return if @fuse_count - @selected_personas.size > 1
    parent_a = @selected_personas[0]
    
    
    if @fuse_count == 2
      # normal fusion
      for parent_b in @personas
        child = $game_system.get_fusion_child(parent_a, parent_b)
        @children.push(child)
      end
    elsif @fuse_count == 3
      # special fusion
      for persona_c in @personas
        special_parents = @selected_personas + [persona_c]
        child = $game_system.get_special_fusion(special_parents)
        @children.push(child)
      end
    end
  end
  
  def window_width
    Graphics.width / 2
  end
  
  def window_height
    Graphics.height
  end
  
  def item_width
    (width - standard_padding * 2 + spacing) / col_max - spacing
  end
  
  def item_height
    line_height
  end
  
  def visible_line_number
    8
  end
  
  def item_max
    @personas.size
  end
  
  def process_handling
    return unless open? && active
    return process_status   if status_enabled?    && Input.trigger?(:X)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
  end
  
  def process_status
    Sound.play_ok
    $game_party.menu_persona = @personas[index]
    call_status_handler
  end
  
  def call_status_handler
    call_handler(:status)
  end
  def status_enabled?
    handle?(:status)
  end
  
  def available_personas
    actors = $game_party.members.select{ |a| !CAN_USE_ACTORS_PERSONAS.index(a.id).nil? }
    personas = actors.inject([]){|res, a| res += $game_party.actors_personas(a.id)}
    return personas
  end
  
  def process_cancel
    Sound.play_cancel
    Input.update
    if @selected_personas.size == 0
      call_return_handler
      deactivate
    else
      @selected_personas.pop
      refresh
      call_cancel_handler
    end
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
  
  def process_ok
    if current_item_enabled?
      persona = @personas[index]
      @selected_personas.push(persona)
      Sound.play_ok
      if @selected_personas.size == @fuse_count
        # the result has the same index with the last persona picked
        @result = @children[index]
        call_fuse_handler
      else
        refresh
        call_ok_handler
      end
    else
      Sound.play_buzzer
    end
  end
  
  def call_fuse_handler
    call_handler(:fuse)
  end
  
  def fuse_enabled?
    handle?(:fuse)
  end
  
  def draw_actor_level(persona, x, y)
    change_color(system_color)
    draw_text(x, y, 32, line_height, Vocab::level_a)
    change_color(normal_color)
    offset_x = text_size(Vocab::level_a).width
    draw_text(x + offset_x, y, 24, line_height, persona.level)
  end
  
  def draw_persona_info(persona, x, y, enabled)
    change_color(normal_color, enabled)
    offset_x = 0
    
    draw_actor_class(persona, x + offset_x, y)
    offset_x += text_size(persona.arcana_name + " ").width
    
    draw_actor_level(persona, x + offset_x, y)
    offset_x += text_size(Vocab::level_a + persona.level.to_s + " ").width
    
    draw_actor_name(persona, x + offset_x, y)
    change_color(normal_color)
  end
  
  def draw_item_background(index)
    if !@selected_personas.index(@personas[index]).nil?
      color = pending_color
      color.alpha = 100
      contents.fill_rect(item_rect(index), color)
    end
  end
  
  def draw_item(index)
    persona = @personas[index]
    
    enabled = !@selected_personas.index(persona).nil?
    rect = item_rect(index)
    draw_item_background(index)
    draw_persona_info(persona, rect.x, rect.y, enabled)
  end
  
  def current_item_enabled?
    persona = @personas[index]
    return false if !@selected_personas.index(persona).nil?
    return true if @selected_personas.size == 0
    return true if @selected_personas.size < @fuse_count - 1
    return !@children[index].nil?
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

class Window_FuseResults < Window_Base
  include Persona
  
  def initialize
    @children = []
    super(window_width, 0, window_width, window_height)
  end
  
  def children=(children)
    @children = children
    refresh
  end
  
  def refresh
    contents.clear
    @children.size.times{|i| draw_item(i)}
  end
  
  def window_width
    Graphics.width / 2
  end
  
  def window_height
    Graphics.height
  end
  
  def col_max
    return 1
  end
  
  def spacing
    return 32
  end
  
  def item_width
    (width - standard_padding * 2 + spacing) / col_max - spacing
  end
  
  def item_height
    line_height
  end
  
  def item_max
    @children.size
  end
  
  def draw_actor_level(persona, x, y, enabled=true)
    change_color(system_color, enabled)
    draw_text(x, y, 32, line_height, Vocab::level_a)
    change_color(normal_color, enabled)
    offset_x = text_size(Vocab::level_a).width
    draw_text(x + offset_x, y, 24, line_height, persona.level)
  end
  
  def draw_actor_class(actor, x, y, width = 112, enabled=true)
    change_color(normal_color, enabled)
    draw_text(x, y, width, line_height, actor.arcana_name)
  end
  
  def draw_actor_name(actor, x, y, width = 112, enabled=true)
    change_color(hp_color(actor), enabled)
    draw_text(x, y, width, line_height, actor.name)
  end
  
  def draw_item_background(index)
    if @children[index].special_persona?
      contents.fill_rect(item_rect(index), Persona::SPECIAL_FUSION_COLOR)
    end
  end
  
  def draw_persona_info(persona, x, y, enabled)
    offset_x = 0
    
    draw_actor_class(persona, x + offset_x, y, 112, enabled)
    offset_x += text_size(persona.arcana_name + " ").width
    
    draw_actor_level(persona, x + offset_x, y, enabled)
    offset_x += text_size(Vocab::level_a + persona.level.to_s + " ").width
    
    draw_actor_name(persona, x + offset_x, y, 112, enabled)
  end
  
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = index / col_max * item_height
    rect
  end
  
  def draw_item(index)
    child = @children[index]
    return if child.nil?
    rect = item_rect(index)
    users = $game_party.members.select{|m| !child.users.index(m.id).nil? }
    enabled = true
    draw_item_background(index)
    draw_persona_info(child, rect.x, rect.y, enabled)
  end
end

class Window_PersonaStatus < Window_Command 
  alias persona_fuse_init initialize
  def initialize(persona)
    persona_fuse_init(persona)
    @bonus_exp = 0
    @start_exp = false
    @step = 0
    @ok_enabled = false
  end
  
  def disable_ok
    @ok_enabled = true
  end
  
  def enable_ok 
    @ok_enabled = false
  end
  
  alias persona_ph process_handling
  def process_handling
    if SceneManager.scene_is?(Scene_Fuse)
      return process_ok   if ok_enabled? && Input.trigger?(:C)
      return process_cancel if cancel_enabled? && Input.trigger?(:B)
    else
      persona_ph
    end
  end
  
  def ok_enabled?
    handle?(:ok) && !@ok_enabled
  end
  
  def process_ok
    Sound.play_ok
    Input.update
    deactivate
    call_ok_handler
  end
  
  def bonus_exp=(exp)
    @bonus_exp = exp
    @step = @bonus_exp/30
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
  
  def update_bonus_exp
    if @start_exp
      @bonus_exp = [@bonus_exp-@step, 0].max
      new_exp = @persona.exp + ([@step, @bonus_exp].min * @persona.final_exp_rate).to_i
      @persona.change_exp(new_exp, false)
      @start_exp = @bonus_exp != 0
      refresh
    end
  end
end

class Scene_Fuse < Scene_Base
  def start
    super
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
    @fuse_window = Window_Fuse.new($game_system.fuse_count)
    @fuse_window.select_last
    # called when a new persona is selected
    @fuse_window.set_handler(:ok, method(:on_process_ok))
    # called when the last persona for the fusion was selected and opens the status window
    @fuse_window.set_handler(:fuse, method(:fuse))
    # called when there are no selected personas and leaves the scene
    @fuse_window.set_handler(:return, method(:return_scene))
    # called when there are selected personas and removes the last chosen one
    @fuse_window.set_handler(:cancel, method(:on_fuse_cancel))
    # shows the selected persona's status
    @fuse_window.set_handler(:status, method(:on_status_ok))
    @fuse_window.z -= 2
  end
  
  def create_status_window
    @status_window = Window_PersonaStatus.new($game_party.menu_persona)
    # called when confirming a fusion
    @status_window.set_handler(:ok,   method(:fuse_confirm))
    # called when viewing a persona's status and returns to fuse windows
    @status_window.set_handler(:cancel,   method(:return_status))
    @status_window.deactivate
    @status_window.z -= 1
  end
  
  def create_result_window
    @results_window = Window_FuseResults.new
    @results_window.z -= 2
  end
  
  def wait_for_message
    @status_window.deactivate
    @message_window.activate
    @message_window.update
    update_basic while $game_message.visible
    @status_window.activate
  end
  
  def on_status_ok
    @status_window.persona = $game_party.menu_persona
    @status_window.show
    @status_window.disable_ok
    @fuse_window.deactivate
    @status_window.activate
  end
  
  def return_status
    return if @message_window.open?
    @status_window.deactivate
    @status_window.hide
    @extra_exp_window.hide
    
    @fuse_window.activate
    @fuse_window.selected_personas.pop if @fuse_window.selected_personas.length == $game_system.fuse_count
  end
  
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
  
  def dispose_background
    @background_sprite.dispose
  end 
  
  def on_process_ok
    if @fuse_window.selected_personas.size == $game_system.fuse_count - 1
      @results_window.children = @fuse_window.children
    end
  end
  
  def on_fuse_cancel
    @results_window.children = @fuse_window.children
  end
  
  def fuse
    @status_window.persona = $game_personas[@fuse_window.result.id]
    @fuse_window.deactivate
    @status_window.enable_ok
    
    persona = @fuse_window.result
    bonus_exp = Persona.FUSION_EXP_CALC(persona).to_i
    @status_window.bonus_exp = bonus_exp
    txt = "Bonus EXP:"
    @extra_exp_window.text = txt
    @extra_exp_window.exp = bonus_exp
    @extra_exp_window.set_width("Bonus EXP:#{bonus_exp}")
    
    @status_window.show.activate
    @extra_exp_window.show
  end
  
  def wait_for_exp
    @status_window.start_exp
    while !@status_window.done_exp
      @extra_exp_window.exp= @status_window.bonus_exp
      
      @extra_exp_window.update
      @status_window.update
      Graphics.update
    end
    @extra_exp_window.exp = @status_window.bonus_exp
    
    @extra_exp_window.update
    @status_window.update
  end
  
  def fuse_confirm
    return if @choice == 0 # return if already accepted fusion
    return if @fuse_window.result.nil?
    $game_message.add("Are you sure you want to create the #{@fuse_window.result.name}")
    $game_message.add("persona?")
    $game_message.choices.push("Yes")
    $game_message.choices.push("No")
    $game_message.choice_cancel_type = 2
    $game_message.choice_proc = Proc.new {|n| @choice = n }
    wait_for_message
    if @choice == 0
      wait_for_exp
      fusing = @fuse_window.selected_personas.collect{|p| p.name }.join(" + ")
      $game_message.add("Fused #{fusing} into\n#{@fuse_window.result.name}!")
      wait_for_message
      for persona in @fuse_window.selected_personas
        $game_party.remove_persona(persona.id)
      end
      $game_party.add_persona(@status_window.persona.id)
      
      @extra_exp_window.hide
      @status_window.hide
      @results_window.children = []
      @fuse_window.reset
      @choice = -1
    else
      @message_window.close
      @choice = -1
      @fuse_window.remove_last_persona
      return
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
    include Persona
    
    attr_reader :cards_dropped
    
    alias persona_shuffle_pv process_victory
    def process_victory
      @cards_dropped = $game_troop.make_drop_cards
      
      @cards_dropped = $game_system.filter_cards(@cards_dropped)
      
      if !@cards_dropped.empty?
        SceneManager.scene.hide_actor_window
        # call personastatus scene, start it and 
        # wait until scene has finished
        # this is done because scene is not changing when called by the 
        # usual way (SceneManager.call(Scene_ForgetSkill) 
        # or maybe i'm doing something wrong (?). same with scene_personastatus
        # in gain_exp method
        SceneManager.call(Scene_Shuffle)
        SceneManager.scene.start
        wait_for_shuffle
      end
      
      if $game_system.shuffle_result == "Penalty"
        # if player drew a penalty card then skip battle rewards
        $game_message.add(PENALTY_CARD_RESULT_MSG)
        $game_message.add(sprintf(Vocab::Victory, $game_party.name))
        wait_for_message
        SceneManager.return
        battle_end(0)
        replay_bgm_and_bgs
        return true
      else
        if $game_system.shuffle_result == ""
          $game_message.add(NO_CARD_RESULT_MSG)
        elsif $game_system.shuffle_result == "Blank"
          $game_message.add(BLANK_CARD_RESULT_MSG)
        end
        persona_shuffle_pv
      end
    end
    
    alias persona_shuffle_ge gain_exp
    def gain_exp
      persona_shuffle_ge
      $game_party.battle_personas.each do |m|
        next if m.extra_skills.empty?
        $game_party.menu_persona = m
        SceneManager.call(Scene_ForgetSkill)
        SceneManager.scene.start_without_bg
        SceneManager.scene.show_message
        SceneManager.scene.update while SceneManager.scene_is?(Scene_ForgetSkill)
      end
    end
    
    alias persona_shuffle_bs battle_start
    def battle_start
      persona_shuffle_bs
      $game_system.reset_shuffle_result
    end
    
    def wait_for_shuffle
      # wait for shuffle_time to finish
      SceneManager.scene.update while SceneManager.scene_is?(Scene_Shuffle)
      Graphics.transition(30)
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
  include Persona
  
  attr_accessor :shuffle_result
  alias persona_shuffle_init initialize
  def initialize
    persona_shuffle_init
    @shuffle_result = nil
  end
  
  def reset_shuffle_result
    @shuffle_result = nil
  end
  
  def shuffle_time
    SceneManager.call(Scene_Shuffle)
    Fiber.yield
  end
  
  def filter_cards(cards)
    if !ALLOW_DUPLICATES
      blanks = cards.count("Blank")
      penalties = cards.count("Penalty")
      # keep unique cards except blank and penalty
      cards = cards.uniq.select{|c| ["Blank", "Penalty"].index(c).nil? }
      # add blanks and penalties back
      cards += (["Blank"] * blanks + ["Penalty"] * penalties)
    end
    
    if cards.uniq.sort == ["Blank", "Penalty"] || cards.empty?
      # if there are only blank and penalty cards then just empty the
      # list and return, so that there is no shuffle time
      return []
    elsif cards.select{|c| c != "Blank" || c != "Penalty"}.length < MIN_CARDS_TO_SHUFFLE 
      return []
    end
    
    # count penalty and blank cards dropped
    penalty_cnt = cards.count("Penalty")
    blank_cnt = cards.count("Blank")
    
    # check for min and max penalty/blank cards and "fix" the number
    
    if penalty_cnt < MIN_PENALTY_CARDS
      (MIN_PENALTY_CARDS - penalty_cnt).times{ cards.push("Penalty") }
    elsif penalty_cnt > MAX_PENALTY_CARDS
      cards.delet("Penalty")
      MAX_PENALTY_CARDS.times{ cards.push("Penalty") }
    end
    
    if penalty_cnt < MIN_BLANK_CARDS
      (MIN_BLANK_CARDS - penalty_cnt).times{ cards.push("Blank") }
    elsif penalty_cnt > MAX_BLANK_CARDS
      cards.delet("Blank")
      MAX_BLANK_CARDS.times{ cards.push("Blank") }
    end
    return cards.shuffle
  end
end

class Game_Troop < Game_Unit
  def make_drop_cards
    dead_members.inject([]) {|r, enemy| r += enemy.make_drop_cards }
  end
end

class Window_AcceptShuffle < Window_Command
  include Persona
  
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
    case WINDOW_POSITIONS[ACCEPT_POSITION]
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
  include Persona
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
    case WINDOW_POSITIONS[ACCEPT_POSITION]
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

class Scene_Shuffle < Scene_Base
  include Persona
  
  def start
    super
    create_attributes
    create_acceptance_window
    create_counter_window
    create_background
    create_paths
    start_cards_appear
    setup_music
  end
  
  def terminate
    super
    @cards.each{|c| c.dispose}
    @background_sprite.dispose
  end
  
  def start_cards_appear
    @cards.each{ |card| card.start_effect(:appear)}
  end
  
  def setup_music
    @last_bgm = RPG::BGM.last
    @last_bgs = RPG::BGS.last
    
    Audio.bgm_play(*SHUFFLE_BGM) if !SHUFFLE_BGM.nil?
    Audio.bgs_play(*SHUFFLE_BGS) if !SHUFFLE_BGS.nil?
  end
  
  def create_attributes
    get_cards
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
    
    # determine shuffle method from variable or other
    if $game_variables[FORCE_SHUFFLE_METHOD_VAR_ID] == 0
      @shuffle_method = Persona.SHUFFLE_SELECTION(@cards)
    else
      @shuffle_method = $game_variables[FORCE_SHUFFLE_METHOD_VAR_ID]
      $game_variables[FORCE_SHUFFLE_METHOD_VAR_ID] = 0
    end
    # current phase of the shuffle time process
    @shuffle_phase = "Show"
    @shuffle_paths = []
    
    @cursor_index = 0
  end
  
  def get_cards
    card_items = BattleManager.cards_dropped
    if $game_variables[SHUFFLE_ITEMS_VAR_ID] != 0
      card_items = $game_variables[SHUFFLE_ITEMS_VAR_ID]
      $game_variables[SHUFFLE_ITEMS_VAR_ID] = nil
      card_items = $game_system.filter_cards(card_items) if FILTER_MANUAL_CARDS
    else
      card_items = BattleManager.cards_dropped
    end
    
    if card_items.nil? || card_items == 0
      msgbox("No cards were defined in variable with id #{SHUFFLE_ITEMS_VAR_ID} for the shuffle time!")
      cancel_shuffle
      return
    end
    
    @cards = card_items.collect{|c| Sprite_Card.new(@viewport, c) }
  end
  
  def create_acceptance_window
    @acceptance_window = Window_AcceptShuffle.new
    @acceptance_window.set_handler(:accept,   method(:start_shuffle_time))
    @acceptance_window.set_handler(:cancel,   method(:cancel_shuffle))
    @acceptance_window.open
  end
  
  def create_counter_window
    @counter_window = Window_MatchCounter.new(MATCHING_TRIES)
  end
  
  def start_shuffle_time
    @acceptance_window.close
    if @shuffle_method == "Matching"
      start_matching
    else
      start_shuffle
    end
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
      card.current_path = wait + get_intermediate_points(x1, y1, x2, y2)
      card.repeat_path = false
      card.start_effect(:flip) # make the card flip face down
    end

    @shuffle_phase = "Shuffle"
    # calculate all x,y indexes of the cards. used only for up and down movement
    # in matching shuffle method
    @card_indexes = @cards.each_with_index.collect{|n, i| [i/MAX_CARDS_PER_ROW, i%MAX_CARDS_PER_ROW]}
  end
  
  def start_matching
    new_cards = []
    
    # picks random cards and shows them for a short amount of frames
    @cards.sample(@cards.size/2).each{ |c| c.tease=true } 
    
    # diplicates all the cards for the matching method
    @cards.each{ |card| new_cards.push(Sprite_Card.new(@viewport, card.card)) }
    
    # shuffles all the cards, appends them together and shuffles them again
    @cards = @cards.shuffle + new_cards.shuffle
    @cards.shuffle!
    
    # max cards per row
    max_cols = MAX_CARDS_PER_ROW
    @cards.each_with_index do |card, i|
      # at first make all the cards go to the center of the screen
      x1 = card.x
      y1 = card.y
      x2 = @cx - @card_width / 2
      y2 = @cy - @card_height / 2
      travel1 = get_intermediate_points(x1, y1, x2, y2)
      
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
      travel2 = get_intermediate_points(x1, y1, x2, y2)
      
      # add the path to the card's path
      card.current_path = travel1 + wait + travel2
      # card does not loop this path
      card.repeat_path = false
      # flips them while they go to the center of the screen
      card.start_effect(:flip)
    end
    
    @counter_window.open
    # calculate all x,y indexes of the cards. used only for up and down movement
    # in matching shuffle method
    @card_indexes = @cards.each_with_index.collect{|n, i| [i/MAX_CARDS_PER_ROW, i%MAX_CARDS_PER_ROW]}
  end
  
  def cancel_shuffle
    @last_bgm.replay
    @last_bgs.replay
    SceneManager.return
  end
  
  def create_background
    @background_sprite = Sprite.new
    if SHUFFLE_BACKGROUND
      @background_sprite.bitmap = Cache.load_bitmap("Graphics/Persona/", SHUFFLE_BACKGROUND)
    else
      @background_sprite.bitmap = SceneManager.background_bitmap
    end
  end
  
  def update
    super
    update_cards
    determine_loss_matching if @shuffle_method == "Matching"
    process_input if !teasing_phase
  end
  
  def update_all_windows
    @acceptance_window.update
    @counter_window.update
  end
  
  def determine_loss_matching
    if @counter_window.lost?
      @counter_window.close
      @message_window.z = 250
      $game_message.shuffle_add(MATCHING_LOSE_MESSAGE)
      wait_for_message
      SceneManager.return
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
  
  def update_for_wait
    Graphics.update
    Input.update
    
    $game_timer.update
    @message_window.update
    @counter_window.update if @counter_window
    if @card_selected
      update_selected_card 
      update_other_cards
    end
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

  def update_cards
    @cards.each_with_index do |card, i| 
      card.update
      
      # if it's a shuffle method, set its path in the shuffling and 
      # make it repeat it
      if @shuffle_phase == "Shuffle"
        if card.path_indx == card.current_path.size - 1 && !card.repeat_path
        # if the card has reached its destination in the shuffle path
          card.current_path = @shuffle_paths[i]
          card.repeat_path = true
        end
      end
    end
  end
  
  def teasing_phase
    @cards.select{|c| c.teasing? }.length > 0
  end
  
  def cards_done_moving
    @cards.inject(true){ |done, c| done && c.done_moving }
  end
  
  def process_input
    # if last card is repeating its path then it has entered the shuffle loop
    # therefore we accept input for selection
    process_input_shuffle if @shuffle_phase == "Shuffle" && Input.trigger?(:C) && @cards[-1].repeat_path
    process_input_matching if @shuffle_method == "Matching" && cards_done_moving
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
        
        if selected_cards[0].card != "Blank" && selected_cards[0].card == selected_cards[1].card
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
    index = [@cursor_index/MAX_CARDS_PER_ROW, @cursor_index%MAX_CARDS_PER_ROW]
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
      new_indx = index[0]*MAX_CARDS_PER_ROW + index[1]
      # get all cards of new row
      new_row_cards = @cards.select{|c| c.y == @cards[new_indx].y}
      # get index of card in the new row with the closest x position as the 
      # last one
      new_card = new_row_cards.each_with_index.min_by{|c, i| (c.x - prev_card_x).abs}[1]
      # calculate new index in list of all cards
      @cursor_index = new_card + index[0] * MAX_CARDS_PER_ROW
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
      new_indx = index[0]*MAX_CARDS_PER_ROW + index[1]
      new_row_cards = @cards.select{|c| c.y == @cards[new_indx].y}
      new_card = new_row_cards.each_with_index.min_by{|c, i| (c.x - prev_card_x).abs}[1]
      @cursor_index = new_card + index[0] * MAX_CARDS_PER_ROW
    elsif Input.trigger?(:LEFT)
      Sound.play_cursor
      @cards[@cursor_index].revert_to_normal
      
      @cursor_index -= 1
      @cursor_index = @cards.length - 1 if @cursor_index < 0
    end
  end
  
  def show_selected_card
    x1 = @card_selected.x
    y1 = @card_selected.y
    x2 = @cx - @card_width / 2
    y2 = @cy - @card_height
    @card_selected.current_path = get_intermediate_points(x1, y1, x2, y2)
    @card_selected.repeat_path = false
    @card_selected.z = 150
  end
  
  def finish_shuffle
    if @card_selected.nil?
      Audio.se_play(*SHUFFLE_BLANK_SOUND)
      $game_message.shuffle_add(NO_CARD_DRAW_MSG)
      wait_for_message
    elsif @card_selected.card == "Blank"
      Audio.se_play(*SHUFFLE_BLANK_SOUND)
      $game_message.shuffle_add(BLANK_CARD_DRAW_MSG)
      wait_for_message
    elsif @card_selected.card == "Penalty"
      Audio.se_play(*SHUFFLE_PENALTY_SOUND)
      $game_message.shuffle_add(PENALTY_CARD_DRAW_MSG)
      wait_for_message
    elsif !@card_selected.nil?
      Audio.se_play(*SHUFFLE_CARD_SOUND)
      $game_message.shuffle_add(sprintf(PERSONA_CARD_DRAW_MSG, @card_selected.card))
      wait_for_message
      
      persona = $data_actors.find{ |p| !p.nil? && p.name == @card_selected.card }
      $game_party.add_persona(persona.id)
    end
    @last_bgm.replay
    @last_bgs.replay
    $game_system.shuffle_result = @card_selected.nil? ? "" : @card_selected.card
    SceneManager.return
    Graphics.fadeout(30)
    terminate
  end
  
  def create_main_viewport
    @viewport = Viewport.new
    @viewport.z = 200
  end
  
  def create_paths
    @cards.each_with_index do |card, i|
      max_cols = MAX_CARDS_PER_ROW
      x, y, z = show_position(i/max_cols, i%max_cols, max_cols)
      card.starting_position(x, y)
      card.current_path = [[x, y, z]]
      card.repeat_path = true
    end
    create_shuffle_paths
  end
  
  def show_position(i, j, max_cols=MAX_CARDS_PER_ROW)
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
  
  def get_intermediate_points(x1, y1, x2, y2)
    dist_x = (x1 - x2).abs
    dist_y = (y1 - y2).abs
    up_x = x1 > x2 ? -1 : 1 # if card has to go to the right or left
    up_y = y1 > y2 ? -1 : 1 # if card has to go upwards of downwards
    total_pos = 15
    xs = [*0..total_pos].collect{ |i| x1 + (i * up_x) * dist_x/total_pos}
    ys = [*0..total_pos].collect{ |i| y1 + (i * up_y) * dist_y/total_pos}
    movement_path = xs.zip(ys)
    return movement_path
  end
  
  def create_shuffle_paths
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
