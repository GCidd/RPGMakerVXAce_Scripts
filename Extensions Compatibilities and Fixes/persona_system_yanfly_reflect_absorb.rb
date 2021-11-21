module Persona
  PERSONA_REFLECT_STRING = "Rpl"
  PERSONA_ABSORB_STRING = "Abs"
  
  PERSONA_ABSORB_ELE_ICON = -1
  PERSONA_REFLECT_ELE_ICON = -1
end

class Game_Actor < Game_Battler
  
  alias fog_mrfps item_mrf
  def item_mrf(user, item)
    result = fog_mrfps(user, item)
    result += element_reflect_rate(item.damage.element_id)
    if !persona? && !@persona.nil?
      result += @persona.element_reflect_rate(item.damage.element_id)
    end
    return result
  end
  
  def element_rate(element_id)
    if persona?
      persona_rate = super(element_id)
      persona_mult = PERSONA_ELEMENT_RATE_MULTIPLIER.is_a?(Array) ? PERSONA_ELEMENT_RATE_MULTIPLIER[element_id] : PERSONA_ELEMENT_RATE_MULTIPLIER
      persona_value = persona_rate * persona_mult
      if element_absorb?(element_id)
        return [persona_value - 2.0, -0.01].min
      else
        return persona_value
      end
    else
      user_rate = super(element_id)
      user_mult = USER_ELEMENT_RATE_MULTIPLIER.is_a?(Array) ? USER_ELEMENT_RATE_MULTIPLIER[element_id] : USER_ELEMENT_RATE_MULTIPLIER   
      user_value = user_rate * user_mult

      if !persona? && !@persona.nil?
        persona_rate = @persona.features_pi(FEATURE_ELEMENT_RATE, element_id)
        persona_mult = PERSONA_ELEMENT_RATE_MULTIPLIER.is_a?(Array) ? PERSONA_ELEMENT_RATE_MULTIPLIER[element_id] : PERSONA_ELEMENT_RATE_MULTIPLIER
        persona_value = persona_rate * persona_mult
      else
        return [user_value - 2.0, -0.01].min
      end
      
      if @persona.element_absorb?(element_id) || element_absorb?(element_id)
        user_absorb_value = (user_value - 2.0 * user_mult)
        persona_absorb_value = (persona_value - 2.0 * persona_mult)
        puts [user_absorb_value + persona_absorb_value, -0.01].min
        return [user_absorb_value + persona_absorb_value, -0.01].min
      else
        return persona_value + user_value
      end
    end
  end
  
end

class Window_PersonaStatus < Window_Command
  include Persona
  
  def draw_ele_rates(x, y)
    icons = PERSONA_ELE_ICON_INDEXES
    puts @persona.name
    10.times do |i|
      offset_x = i * (24 + 24)
      new_x = x + offset_x
      draw_icon(icons[i], new_x, y)
      
      if @persona.element_absorb?(i+1)
        draw_absorb_ele_icon(new_x, y)
      elsif @persona.element_reflect_rate(i+1) > 0
        draw_reflect_ele_icon(new_x, y)
      elsif @persona.element_rate(i+1) == 1.0
        draw_normal_ele_icon(new_x, y)
      elsif @persona.element_rate(i+1) < 1.0
        draw_strong_ele_icon(new_x, y)
      elsif @persona.element_rate(i+1) > 1.0
        draw_weak_ele_icon(new_x, y)
      end
    end
  end
  
  def draw_reflect_ele_icon(x, y)
    if PERSONA_REFLECT_ELE_ICON == -1
      draw_text(x, y + line_height, 24, line_height, PERSONA_REFLECT_STRING, 1)
    else
      draw_icon(PERSONA_REFLECT_ELE_ICON, x, y + line_height)
    end
  end
  
  
  def draw_absorb_ele_icon(x, y)
    if PERSONA_ABSORB_ELE_ICON == -1
      draw_text(x, y + line_height, 24, line_height, PERSONA_ABSORB_STRING, 1)
    else
      draw_icon(PERSONA_ABSORB_ELE_ICON, x, y + line_height)
    end
  end
  
end