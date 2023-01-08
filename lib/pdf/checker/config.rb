module PDF
class Checker
  def self.config
    @@config ||= Config.new
  end
  def self.set_config(values, or_key_value = nil)
    config.set(values, or_key_value)
  end
  def self.reset_config # pour les tests
    @@config = nil
  end
class Config

  attr_reader :values

  def initialize
    @values = default_values
  end

  def set(vals, or_key_value = nil)
    if vals.is_a?(Symbol)
      @values.merge!( vals => or_key_value)
      redef_constants([vals])
    else
      @values.merge!(vals)
      redef_constants(vals.keys)
    end
  end

  def get(key)
    return values[key]
  end
  alias :[] :get # pour pouvoir faire PDF::Checker.config[:<key>]

  def redef_constants(keys)
    keys.each do |key|
      case keys
      when :default_output_unit
        redefine_level_matcher_constant('OUTPUT_UNIT', key)
      when :coordonates_tolerance
        redefine_level_matcher_constant('COORDONNATE_TOLERANCE', key)
      end
    end
  end

  def default_values
    {
      top_based: true,
      coordonates_tolerance: 2,
      default_output_unit: :pt
    }
  end


  private

    def redefine_level_matcher_constant(const_name, config_key)
      PDF::Checker::LevelMatcher.send(:remove_const, const_name)
      PDF::Checker::LevelMatcher.const_set(const_name, get(config_key))
    end
end #/class Config
end #/class Checker
end #/module PDF

