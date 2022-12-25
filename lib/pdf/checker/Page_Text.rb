=begin
  class PDF::Checker::Page::Text
  ------------------------------
  Abstraction du texte complet d'une page.
  Abstract the whole text of a page.

  Is a text object defined between 'begin_text_object' and 
  'end_text_object'

=end
module PDF
class Checker
class Page
class Text

  attr_reader :properties

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
      if properties.key?(:show_text_with_positioning)
        (0...properties[:show_text_with_positioning][0].count).step(2).map do |i|
          properties[:show_text_with_positioning][0][i]
        end.join('').force_encoding('utf-8')
      elsif properties.key?(:show_text)
        properties[:show_text]
      end
    end
  end
  def font ; properties[:text_font_and_size][0] end
  def size ; properties[:text_font_and_size][1] end

end #/class Text
end #/class Page
end #/class Checker
end #/module PDF
