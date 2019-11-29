#===============================================================================
#
# Script Name: Nickname Base Stats
# Author: vFoggy
# Description: 
#   This script increases an actor's parameters depending on their nickname.
#   The parameters are taken from a weapon in the database that has the same
#   name as the actor's nickname. Basically if an actor's nickname exists as a
#   weapon, their base params, xparams and sparams will increase according to  
#   the weapon's params. 
#
#===============================================================================

class Game_Actor < Game_Battler
  
    alias fog_setup setup
    def setup(actor_id)
      fog_setup(actor_id)
      @nickname_stats = $data_weapons.find{|i| !i.nil? && i.name == @nickname}
    end
    
    def nickname_plus(param_id)
      if @nickname_stats
        features = @nickname_stats.features.select{|f| f.code == FEATURE_PARAM}
        features.select!{|f| f.data_id == param_id}
        nickname_value = features.inject(0){|v, f| v+f.value} * @nickname_stats.params[param_id]
        return nickname_value
      else
        return 0
      end
    end
    
    alias fog_pb param_base
    def param_base(param_id)
      fog_pb(param_id) + nickname_plus(param_id)
    end
    
    alias fog_xparam xparam
    def xparam(xparam_id)
      nickname_value = 0
      if !@nicknamestats.nil?
        features = @nickname_stats.features.select{|f| f.code == FEATURE_XPARAM}
        features.select!{|f| f.data_id == xparam_id}
        nickname_value = features.inject(0){|v, f| v+f.value}
      end
      fog_xparam(xparam_id) + nickname_value
    end
    
    alias fog_sparam sparam
    def sparam(sparam_id)
      nickname_value = 0
      if !@nicknamestats.nil?
        features = @nickname_stats.features.select{|f| f.code == FEATURE_SPARAM}
        features.select!{|f| f.data_id == sparam_id}
        nickname_value = features.inject(0){|v, f| v+f.value}
      end
      fog_sparam(sparam_id) + nickname_value
    end
end
