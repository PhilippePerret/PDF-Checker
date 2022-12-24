module Minitest
class Test

  def pdf_file
    File.join(ASSETS_FOLDER,'pdfs','bonjour.pdf')
  end

  def pdf_long_simple
    @pdf_long_simple ||= File.join(ASSETS_FOLDER,'pdfs','long_texte_simple.pdf')
  end

  def checker
    @checker ||= PDF::Checker.new(pdf_file)
  end

  def checker_long
    @checker_long ||= PDF::Checker.new(pdf_long_simple)
  end

end #/class Test
end #/module Minitest
