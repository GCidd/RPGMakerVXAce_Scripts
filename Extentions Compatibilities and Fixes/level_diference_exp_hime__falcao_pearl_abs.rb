# Compatibility script for Level Difference Exp by Hime and Falcao Pearl ABS.
# Makes the ABS script use the exp calculated from Level Difference Exp script.
# ---------------------
# By vFoggy

class Game_Event < Game_Character
    def kill_enemy
      @secollapse = nil
      @killed = true
      @priority_type = 0 if @deadposee
      gain_exp
      gain_gold
      
      $game_player.followers.each do |follower|
        next if follower.actor.nil?
        etext = 'Exp '  + follower.actor.gained_exp.to_s if @enemy.exp > 0
        follower.pop_damage("#{etext}") if etext
      end
      
      g_exp = $game_player.actor.gained_exp
      etext = 'Exp '  + g_exp.to_s if g_exp > 0
      gtext = 'Gold ' + @enemy.gold.to_s if @enemy.gold > 0
      $game_player.pop_damage("#{etext} #{gtext}") if etext || gtext
      
      make_drop_items
      run_assigned_commands
    end
    
    
    def gain_exp
      $game_party.all_members.each do |actor|
        actor.gained_exp = actor.exp_from_enemy(@enemy)
        actor.gain_exp(actor.gained_exp)
      end
    end
  end
  
  class Game_Actor < Game_Battler
    def gained_exp=(exp)
      @gained_exp = exp
    end
end
