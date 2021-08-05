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
# You can also have a persona of a specific arcana have a different class! 
# This can be done just by setting its  nickname to the arcana you want! 
# Don't forget to use the following tag to hide its nickname in the status window! 
# \C[24]<Hide status nickname>\C[0].
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
# You can add a persona to your party by calling the following script (by id):
#        $game_party.add_persona_by_id(actor_id)
# of by using the following one (by name):
#        $game_party.add_persona_by_name("actor_name")
# It is important to remember that you cannot have duplicate personas in
# your party! Also, for developing purposes a message box will be displayed 
# if you try adding an actor as a persona that is not actually a persona! 
# a persona or if you misstype a name by accident!
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
# the variable with ID 10 to the method you want. For example "Horizontal"
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
    RELEASE_PERSONA_BUTTON_IMG_NAME = "release_persona_button"
    
    # better keep a space at the beginning of the text
    SELECT_PERSONA_TEXT = " Show status"
    EQUIP_PERSONA_TEXT = " Equip persona"
    RELEASE_PERSONA_TEXT = " Release persona"
    # written on actor's personas list when no personas are available
    NO_PERSONAS_MSG = "No personas available."
    
    # key used to equip persona
    EQUIP_PERSONA_KEY = :X
    RELEASE_PERSONA_KEY = :Z
    
    # ids of the default users for a persona that has no users specified
    # can be an empty list
    DEFAULT_PERSONA_USERS = [1]
    
    # if true user can remove personas from actors that can use only one persona
    CAN_RELEASE_ONLY_PERSONAS = true
    PERSONA_RELEASE_SOUND = ["Audio/SE/Evasion1", 100, 100]
    
    # if true then skills of both user and persona will appear under user's skill
    # list
    UNIFIED_SKILLS = true
    # when UNIFIED_SKILLS is false, this color is used to differentiate persona's
    # skills from user's skills in the battle's skills list.
    # use Color.new(0, 0, 0) for normal color
    PERSONA_SKILLS_COLOR = Color.new(0, 255, 0) # green
    # index from which the persona's skill commands start (for multiple skill types)
    PERSONA_SKILLS_COMMAND_INDEX = 4
    # hides the persona command from actor ids
    HIDE_PERSONA_COMMAND = []
  
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
    ARCANA_MENU_COMMAND_INDEX = 2 # set to nil to hide
    
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
    
    # message displayed when the party already has the drawn persona
    DUPLICATE_PERSONA_DRAW_MSG = "You drew a card of the Persona %s!\nBut you already have this Persona..."
    # message displayed in the battle results when the party already has the drawn persona
    DUPLICATE_PERSONA_RESULT_MSG = ""
    
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
    SHUFFLE_DUPLICATE_SOUND = ["Audio/SE/Blind", 100, 100]  # persona already in party sound
    
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