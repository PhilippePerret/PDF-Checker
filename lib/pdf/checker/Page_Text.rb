=begin
  class PDF::Checker::Page::Text
  ------------------------------
  Abstraction du texte complet d'une page.
  Abstract the whole text of a page.

  Is a text object defined between 'begin_text_object' and 
  'end_text_object'

=end
require 'iconv'

module PDF
class Checker
class Page
class Text

  attr_reader :page
  attr_reader :properties

  # @return [LevelMatcher] Un level matcher — instance de niveau de correspondance —
  #     qui indique le degré de correspondance de l'objet texte avec
  #     les données fournies, à savoir :
  # @param [String|Regex] regstr Le texte à trouver (string ou expression régulière)
  # @param [Hash] props Les propriétés (:font, :size, :at, etc.)
  # and match properties +props+
  def matching_level(regstr, props = nil, options = nil)
    return LevelMatcher.new(self, regstr, props)
  end

  # @param [PDF::Checker::Page] page which contains text
  # @param [ShowTextReceiver] receiver
  def initialize(page)
    @page       = page
    @properties = {}
  end

  # @param [Symbol] property (:name of receiver)
  # @param [Any] args Arguments of receiver
  def set(property, args)
    properties.merge!(property => args)
  end

  def content
    @content ||= begin
      str = get_raw_content
      str = str.join(' ') if str.is_a?(Array)
      Iconv.iconv('utf-8', 'iso8859-1', str).join(' ') # TODO en fonction des langues (LANG)
    end
  end
  def font  ; properties[:text_font_and_size][0] end
  def size  ; properties[:text_font_and_size][1] end

  # @note
  #   Le top de ce :at est top-based, c'est-à-dire calculé par 
  #   rapport au top de la page, et pas par rapport au bas comme c'est
  #   le cas dans la famille PDF::Reader et Prawn
  def at        ; @at       ||= [left, top]       end
  def top       ; @top      ||= position[:top]    end
  def left      ; @left     ||= position[:left]   end
  def bot       ; @bot      ||= position[:bot]    end
  def right     ; @right    ||= position[:right]  end
  def position  ; @position ||= get_position      end

  private

    def get_position
      pos = if properties[:move_text_position]
        properties[:move_text_position]
      else
        # ?
      end || return
      x, y = pos
      x += page.x
      y += page.y
      y = page.height - y if PDF::Checker.config[:top_based]
      return {top: y, left: x, bot: nil, right: page.width}
    end

    def get_raw_content
      if properties.key?(:show_text_with_positioning)
        (0...properties[:show_text_with_positioning][0].count).step(2).map do |i|
          properties[:show_text_with_positioning][0][i]
        end.join('').force_encoding('utf-8')
      elsif properties.key?(:show_text)
        properties[:show_text]
      end      
    end
end #/class Text
end #/class Page
end #/class Checker
end #/module PDF
