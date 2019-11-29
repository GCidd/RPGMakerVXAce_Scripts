 RPG::BaseItem
    attr_reader :sold
    def sold
      unique? && (@sold || false)
    end
    
    def sold=(s)
      @sold = s
    end
    
    def unique?
      note =~ /<Unique>/ ? true : false
    end
    
    def switch_availability
      note =~ /<Switch availability: (\d+)>/ ? $1.to_i : -1
    end
    
    def item_requirements
      matches = note.scan(/<Requires item: (\d+), (\d+)>/)
      return matches if matches.empty?
      
      requirements = []
      for m in matches
        requirements.push([m[0].to_i, m[1].to_i])
      end
      return requirements
    end
  end
  
  class Scene_Shop < Scene_MenuBase
    alias fog_prepare prepare
    def prepare(goods, purchase_only)
      fog_prepare(filter_with_tags(goods), purchase_only)
    end
    
    def filter_with_tags(goods)
      filtered_goods = []
      for i in goods
        case i[0]
        when 0
          item = $data_items[i[1]]
        when 1
          item = $data_weapons[i[1]]
        when 2
          item = $data_armors[i[1]]
        end
        filtered_goods.push(i) if requirements_met(item)
      end
      return filtered_goods
    end
    
    def requirements_met(item)
      return !unique_sold(item) && switch_available(item) && items_requirements_met(item)
    end
    
    def unique_sold(item)
      return false if !item.unique?
      return item.sold if item.unique?
    end
    
    def switch_available(item)
      return true if item.switch_availability == -1
      return $game_switches[item.switch_availability]
    end
    
    def items_requirements_met(item)
      return true if item.item_requirements.empty?
      requirements_met = true
      item.item_requirements.each do |id, cnt|
        requirements_met &= $game_party.item_number($data_items[id]) >= cnt
        return requirements_met if !requirements_met
      end
      return requirements_met
    end
    
    alias fog_db do_buy
    def do_buy(number)
      fog_db(number)
      @item.sold = true if @item.unique?
    end
    
    alias fog_ds do_sell
    def do_sell(number)
      fog_ds(number)
      @item.sold = false if @item.unique?
    end
end
  