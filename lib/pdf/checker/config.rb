module PDF
class Checker
  def self.config
    @@config ||= Config.new
  end
  def self.set_config(**values)
    config.set(**values)
  end
  def self.reset_config # pour les tests
    @@config = nil
  end
class Config

  attr_reader :values

  def initialize
    @values = default_values
  end

  def set(vals)
    @values.merge!(vals)
  end

  def get(key)
    return values[key]
  end
  alias :[] :get # pour pouvoir faire PDF::Checker.config[:<key>]

  def default_values
    {
      top_based: true,
      coordonates_tolerance: 2
    }
  end
end #/class Config
end #/class Checker
end #/module PDF

