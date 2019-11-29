module CLONE_SWAP_OPTIONS
    
  CLONE_STATE_ID    = 75      #state that shows enemy is a clone
  BOSS_NAME         = "Slime" #name of the boss
  SWAP_ANIMATION_ID = 15      #animation played when swapping
  PLAY_ANIMATION    = true    
  
end

#------------------------------------------------------------------------------
#*Alias method for Yanfly's make_state_popup
# *if the state to be popuped is the state that shows that the enemy is a clone
# then it doesn't popup so that the player does not know which one is the clone
#------------------------------------------------------------------------------
class Game_BattlerBase
  alias make_state_popup_fog make_state_popup
  def make_state_popup(state_id, type)
    return if state_id == 75
    make_state_popup_fog(state_id, type)
  end
end

class Game_BattlerBase
  include CLONE_SWAP_OPTIONS
  def is_clone?
    state?(CLONE_STATE_ID)
  end
end

class Game_Troop < Game_Unit
  include CLONE_SWAP_OPTIONS
  def change_position
    clone = members.select{ |enemy| enemy.is_clone? } 
    return if clone.empty?
    clone = clone.length == 1 ? clone[0] : clone[rand > 0.5 ? 1 : 0]
    
    boss = members.find{|enemy| enemy.original_name == BOSS_NAME }
    
    if PLAY_ANIMATION
      boss.animation_id = SWAP_ANIMATION_ID 
      members.each { |enemy| enemy.is_clone? ? enemy.animation_id = SWAP_ANIMATION_ID : next }
    end
    boss.screen_x, clone.screen_x = clone.screen_x, boss.screen_x
    boss.screen_y, clone.screen_y = clone.screen_y, boss.screen_y
    boss.refresh
    clone.refresh
    SceneManager.scene.wait_for_animation
  end
end