class Game_Vehicle < Game_Character
    alias fog_init initialize
    def initialize(type)
      fog_init(type)
      @step_anime = true
    end
    
    alias fog_go get_off
    def get_off
      fog_go
      @step_anime = true
    end
    
    alias fog_uaa update_airship_altitude
    def update_airship_altitude
      fog_uaa
      @step_anime = true
    end
end
