# encoding: utf-8
module PDF
class Checker
class Page

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
  end

  # @return [Array<String>] List of every texts.
  def texts
    @texts ||= begin
      require 'iconv'
      texts_objects.map do |ptext| 
        # ptext.content
        Iconv.iconv('utf-8', 'iso8859-1', ptext.content).join(' ')
      end
    end
  end

  # @return [String] Whole refactored text of the page
  def text
    @text ||= begin
      # require 'iconv'
      # Iconv.iconv('utf-8', 'iso8859-1', *texts).join(' ')
      texts.join(' ')
    end
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
