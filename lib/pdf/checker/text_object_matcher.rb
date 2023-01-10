module PDF
class Checker
class TextObjectMatcher
  include ErrorModule
  include Prawn::Measurements

  COORDONNATE_TOLERANCE = PDF::Checker.config[:coordonates_tolerance]
  COOR_MIN_TOLERANCE = 0.5
  OUTPUT_UNIT = PDF::Checker.config[:default_output_unit]

attr_reader :text_object
attr_reader :options
def initialize(text_object, options)
  @text_object  = text_object
  @options      = options
  # 
  # Pour mettre les textes contenus (ou non contenus si négatif)
  # 
  @texts_matched  = []
end

def does_or_neg_contains?(searched)
  regstr = searched.dup
  if regstr.is_a?(Array)
    regstr.each do |regstr|
      does_or_neg_contains?(regstr) || return
    end
    return true
  else
    contains?(regstr)
  end
end
#/ # does_or_neg_contains?

def contains?(regstr)
  if  case regstr
      when String
         if strict?
           content == regstr
         else
           content.include?(regstr)
         end
       when Regexp
         content.match?(regstr)
       end === not(negative?) 
  then
    # 
    # Text +regstr+ trouvé
    # 
    # puts "- #{regstr.inspect} TROUVÉ dans : #{content.inspect}"
    @texts_matched << regstr # à quoi ça sert ? message d'erreur éclairant ?
    return true
  else
    # 
    # Texte non trouvé (positif) ou trouvé (négatif)
    # 
    # puts "- #{regstr.inspect} NON TROUVÉ dans : #{content.inspect}"
    return false
  end
end #/ #contains?

# @return [Boolean] true if text-objects matches properties +props+
# @param [Hash] props Table of properties. 
#     Key is property name, a method text-object must respond to
#     Value is the property value expected.
# 
def has_properties?(**props)
  #
  # Si un delta est défini
  # 
  @delta = props.delete(:delta) if props.key?(:delta)
  # 
  # Si c'est un check strict (delta = 0 et text exact)
  # 
  if props.key?(:strict)
    @options.merge!(strict: props.delete(:strict)) 
    @strictmode = nil
  end
  # 
  # Pour mettre les bonnes propriétés
  # 
  @good_props = []
  # 
  # Pour mettre les mauvaises propriétés
  # 
  @bad_props = []
  # 
  # Boucle sur chaque propriétés
  # 
  props.each do |prop, expected|
    if estimate_property(prop, expected)
      @good_props << prop
    else
      @bad_props << {prop: prop, expected: expected, actual: prop_value(prop)}
    end
  end
  # 
  # Le résultat attendu (il est positif — ou négatif) si la liste
  # des mauvaise propriétés est vide.
  # 
  return @bad_props.empty?
end

# @return [foo] Value of property +prop+ for TextObject
def prop_value(prop)
  return text_object.send(prop)
end

def estimate_property(prop, expected)
  actual = prop_value(prop)
  case prop
  when :at, :left, :top, :right, :bottom, :bot
    estimate_numeric_value(prop, expected)
  else
    actual == expected
  end == not(negative?)
end

##
# Estimation d'une valeur numérique en fonction de la tolérance
# acceptée.
def estimate_numeric_value(prop, expected)
  if prop == :at
    xe, ye  = expected
    unless xe.nil? # not to estimate
      return false if not(coordonate_in_delta?(:left, xe))
    end
    unless ye.nil? # not to estimate
      return false if not(coordonate_in_delta?(:top, ye))
    end
    return true
  else
    return coordonate_in_delta?(prop, expected)
  end
end

def coordonate_in_delta?(prop, expected)
  actual = text_object.send(prop)
  # puts "-> coordonate_in_delta?".bleu
  # puts "actual = #{actual.inspect} (#{actual.round})".bleu
  # puts "expected = #{expected.inspect} (#{expected.round})".bleu
  # puts "delta = #{delta.inspect}".bleu
  return (expected.round(3) - actual.round(3)).abs <= delta
end

def delta
  @delta ||= strict? ? 0 : COOR_MIN_TOLERANCE
end
def delta=(value)
  @delta = value  
end

# --- Helper Methods ---

##
# En cas d'erreur, cette méthode retourne les raisons de l'échec
# @note
#   A priori, elle n'est utile que sur le test des propriétés, c'est-à-dire quand le texte a déjà été trouvé dans le texte-objet
# @return [String] Un message d'erreur au format humain
def error_message(regstr)
  ERRORS[:failures][:text_with_good_and_bad_property] % {
    text:     content.inspect,
    searched: regstr.inspect,
    at:       self.at,
    goods:    goods_props_for_error_message,
    bads:     bads_props_for_error_message,
  }
end

def goods_props_for_error_message
  if @good_props.count > 0
    if @good_props.count > 1
      ERRORS[:failures][:the_good_properties] % @good_props.map{|p|":#{p}"}.pretty_join
    else
      ERRORS[:failures][:the_good_property] % ":#{@good_props.first}"
    end
  else
    ERRORS[:failures][:any_good_properties]  
  end
end

def bads_props_for_error_message
  @bad_props.map do |dbad|
    ":#{dbad[:prop]} <#{ERRORS[:failures][:expected]} #{dbad[:expected]}, #{ERRORS[:failures][:actual]} #{dbad[:actual]}>"
  end.pretty_join
end

def at
  if OUTPUT_UNIT != :pt
    case OUTPUT_UNIT
    when :mm then text_object.at.map{|n| "#{pt2mm(n).round(3)}mm" }
    when :cm then text_object.at.map{|n| "#{(pt2mm(n).to_f / 10).round(3)}cm" }
    end
  else
    text_object.at
  end.inspect
end

# --- Data Methods ---

# @return [String] Le contenu textuel du texte-objet
def content
  @content ||= text_object.content.freeze
end

# --- Predicate Methods ---

# @return [Boolean] true si le texte doit être trouvé exactement
def strict?
  :TRUE == @strictmode ||= (options[:strict] ? :TRUE : :FALSE)
end

# @return [Boolean] true si c'est un test négatif (not.<...>)
def negative?
  :TRUE == @negmode ||= (options[:negative] ? :TRUE : :FALSE)
end


end #/class TextObjectMatcher
end #/class Checker
end #/module PDF
