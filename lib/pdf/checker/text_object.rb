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

  # [PDF::Checker::TextAssertion] Pour chercher des textes dans cet
  # objet textuel.
  attr_accessor :matcher

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
  # @return [Hash] Les données de la fonte ({:Type, :Subtype, :BaseFont, :Encoding})
  def data_font
    page.fonts[font_id]
  end
  def font_id
    @font_id ||= properties[:text_font_and_size][0]
  end
  def font
    @font ||= get_real_font_name  
  end
  alias :font_name :font
  def size      ; properties[:text_font_and_size][1] end
  alias :font_size :size
  def style     ; get_style_from_font end
  alias :font_style :style

  def at        ; @at       ||= [left, top]       end
  def top       ; @top      ||= position[:top]    end
  def left      ; @left     ||= position[:left]   end
  def bot       ; @bot      ||= position[:bot]    end
  def right     ; @right    ||= position[:right]  end
  def position  ; @position ||= get_position      end

  private

  def get_real_font_name
    fn = font_id.dup
    return fn unless fn.to_s.match?(/F[0-9].[0-9]/)
    fn = page.fonts[fn]
    return fn[:BaseFont].to_s.split('-').first
  end

    # Hack method to get style from font
    # (Je pourrais mieux le faire avec Prawn, mais là, je sèche…)
    def get_style_from_font
      case data_font[:BaseFont].to_s.downcase
      when /(bold.+italic|italic.+bold)/ then [:bold, :italic]
      when /(oblique|italic)/ then :italic
      when /bold/   then :bold
      when /common/ then :common
      when /roman/  then :roman
      else :regular
      end
    end

    def get_position
      pos = if properties[:move_text_position]
        properties[:move_text_position]
      else
        # ?
      end || return
      x, y = pos
      # x += page.x
      # y += page.y
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
