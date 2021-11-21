module FOG_ANIM_BEHIND
    ANIMATION_LIST = [14]
  end
  
  class RPG::Animation
    def from_behind?
      FOG_ANIM_BEHIND::ANIMATION_LIST.index(id) != -1
    end
  end
  
  class Sprite_Base
    alias fog_asp animation_set_sprites
    def animation_set_sprites(frame)
      fog_asp(frame)
      @ani_sprites.each_with_index do |sprite, i|
        next unless sprite
        sprite.z = self.z - 10 + i if @animation.from_behind?
      end
    end
end
