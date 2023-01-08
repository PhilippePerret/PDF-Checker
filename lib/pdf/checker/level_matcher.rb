module PDF
class Checker
class LevelMatcher
  include ErrorModule

  COORDONNATE_TOLERANCE = PDF::Checker.config[:coordonates_tolerance]

  attr_reader :text_object
  attr_reader :regstring
  attr_reader :properties
  
  def initialize(text_object, regstring, properties = nil)
    @text_object  = text_object
    @regstring    = regstring
    @properties   = properties
    @matching_properties = []
    @unmatching_properties = []
  end

  def match_all?
    text_is_matching? && props_are_matching?
  end

  def at
    text_object.at.inspect
  end

  def good_properties
    if @matching_properties.empty?
      ERRORS[:failures][:any_good_properties]
    else
      "#{ERRORS[:failures][:the_good_properties]} #{@matching_properties.pretty_join}"
    end
  end

  def bad_properties
    @unmatching_properties.map do |dbad|
      "#{dbad[:property].inspect} (#{ERRORS[:failures][:expected]} #{dbad[:expected].inspect}, #{ERRORS[:failures][:actual]} #{dbad[:actual].inspect})"
    end.pretty_join
  end

  ##
  # Est-ce que les propriétés matchent ?
  # Même si le texte ne matchait pas, on regarde quand même les propriétés
  # pour faire le panorama le plus complet.
  def props_are_matching?
    unless properties.nil?
      properties.is_a?(Hash) || raise(ERRORS[:object_text_properties_must_be_an_hash])
      properties.each do |prop, expected|
        text_object.respond_to?(prop) || raise(ERRORS[:unknow_text_object_property] % prop.inspect)
        actual = text_object.send(prop)
        # 
        # Estimation de la pertinence
        # 
        if  case prop
            when :at, :left, :top
              #
              # Une valeur chiffrée : ce sera toujours une estimation,
              # qui dépend de la tolérance. Mais dans le plus basique des
              # cas, on arrondit.
              # 
              estimate_numeric_value(prop, actual, expected)
            else
              # 
              # Une valeur non numérique, comme un texte par exemple
              # 
              expected == actual
            end 
        then
          @matching_properties << prop
        else
          @unmatching_properties << {property: prop, expected: expected, actual: actual}
        end
      end
      return @unmatching_properties.empty?
    else
      return true
    end

  end

  def text_is_matching?
    :TRUE == @textmaches ||= check_if_content_is_matching
  end

  def check_if_content_is_matching
    if regstring.is_a?(String)
      return :FALSE if content.index(regstring).nil?
    elsif regstring.is_a?(Regexp)
      return :FALSE if content.match?(regstring).nil?
    else
      raise ERRORS[:invalid_type_to_search_text] % regstring.class.to_s
    end
    return :TRUE
  end

  def data_errors_for_template
    {at: self.at, text: content.inspect, goods: good_properties, bads: bad_properties}
  end

  private

    ##
    # Estimation d'une valeur numérique en fonction de la tolérance
    # acceptée.
    def estimate_numeric_value(prop, expected, actual)
      if prop == :at
        x, y    = actual
        xe, ye  = expected
        unless xe.nil? # not to estimate
          return false unless estimate_numeric_value(:left, xe, x)
        end
        unless ye.nil? # not to estimate
          return false unless estimate_numeric_value(:top, ye, y)
        end
        return true
      else
        return (expected.round(1) - actual.round(1)).abs <= COORDONNATE_TOLERANCE
      end
    end

    # @return [String] Contenu textuel du texte-objet
    def content
      @content ||= text_object.content
    end

end #/class LevelMatcher
end #/class Checker
end #/module PDF
