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
    @checker        = checker
    @reader_page    = page
    # puts "page = #{page.methods(true)}"
    # puts "\n+++ properties : #{page.properties.inspect}"
    # puts "\n+++ width/height : #{page.width}/#{page.height}"
    # exit
    @assertions     = 0 
    @negative       = false # pour inverser les tests
    @search_strings = nil # les textes à chercher
    @matchers       = nil # les level-matchers des textes trouvés
  end

  # @return [Boolean] true si la page contient les textes +searched+
  # 
  # Parfois, quand le texte cherché est découpé, on ne trouve pas
  # ce qu'on veut. Cette méthode permet, avant une recherche plus
  # profonde, de s'assurer que le texte est bien contenu dans la
  # page, en regardant dans le texte complet.
  # 
  # @param [Array<String>] searched Liste des textes à trouver.
  # 
  def matches_texts?(searched, **options)
    strict = options[:strict] === true
    searched.each do |regstr|
      case regstr
      when String
        if strict then text == regstr else text.include?(regstr) end
      when Regexp
        text.match?(regstr)
      end == not(@negative) || return
    end
    return true
  end

  # @return [Array<PDF::Checker::Page::Text>] List of every texts-objects.
  def texts
    @texts ||= begin
      require 'iconv'
      texts_objects.map do |ptext|
        ptext.content
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
  def width       ; reader_page.width       end # en points-pdf
  def height      ; reader_page.height      end # idem
  def x           ; origin.x                end # idem
  def y           ; origin.y                end # idem
  def number      ; reader_page.number      end
  def objects     ; reader_page.objects     end
  def fonts       ; reader_page.fonts       end
  def raw_content ; reader_page.raw_content end
  # @return [PDF::Reader::Point] Le point d'origine de la page, qui
  # répond notamment à #x et #y (mais bon, pour le moment, je 
  # n'obtiens toujours que les coordonnées 0,0)
  def origin
    reader_page.origin
  end

end #/class Page
end #/class Checker
end #/module PDF
