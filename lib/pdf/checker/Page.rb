# encoding: utf-8
module PDF
class Checker
class Page
  include Minitest::Assertions
  include ActiveChecker
  attr_accessor :assertions

  # [PDF::Checker] owner
  attr_reader :checker

  # [PDF::Reader::Page]
  attr_reader :reader_page

  ##
  # Initialise a PDF::Checker::Page
  # 
  # @param [PDF::Checker] checker Owner instance
  # @param [PDF::Reader::Page] Instance of page
  def initialize(checker, page)
    @checker = checker
    @reader_page = page
    @assertions  = 0 
    @negative = false # pour inverser les tests
  end

  # @return [Array<String>] List of every texts.
  def texts
    @texts ||= begin
      require 'iconv'
      texts_objects.map do |ptext| 
        # ptext.content
        # puts "ptext.content = #{ptext.content.inspect}:#{ptext.content.class}"
        # sleep 4
        c = ptext.content
        c = c.join(' ') if c.is_a?(Array)
        Iconv.iconv('utf-8', 'iso8859-1', c).join(' ')
      end
    end
  end
  alias :strings :texts # pour correspondre à PDF::Checker

  # @return [String] Whole refactored text of the page
  def text
    @text ||= texts.join(' ')
  end

  # @return [Array[String]] All the sentences of the text.
  # @note 
  #   Any sentence can start with a dot-like.
  def sentences
    @sentences ||= begin
      ary = []
      segs = text.split(/([.?!¿…])[ \n]?/).reverse
      while (seg = segs.pop)
        ary << "#{seg}#{segs.pop}"
      end
      ary
    end
  end
  alias :phrases :sentences

  # @return [Array<PDF::Checker::Page::Text] List of all text 
  # objects of the page.
  def texts_objects
    @texts_objects ||= get_all_textes
  end
  # - Shortcuts -

  # @return [Integer] page number
  def number      ; reader_page.number      end
  def objects     ; reader_page.objects     end
  def fonts       ; reader_page.fonts       end
  # def text        ; reader_page.text        end # no, see above
  def raw_content ; reader_page.raw_content end

end #/class Page
end #/class Checker
end #/module PDF
