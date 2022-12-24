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

  # - Shortcuts -

  # @return [Integer] page number
  def number      ; reader_page.number      end
  def objects     ; reader_page.objects     end
  def fonts       ; reader_page.fonts       end
  def text        ; reader_page.text        end
  def raw_content ; reader_page.raw_content end

end #/class Page
end #/class Checker
end #/module PDF
