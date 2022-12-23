module PDF
class Checker

  attr_reader :path
  attr_reader :options

  # Initialize a new PDF Checker to check a PDF document.
  # 
  # @param [String] path to the PDF file
  # @param [Hash] options Some options
  def initialize(path, options = nil)
    @path     = path
    @options  = options
  end

  def strings
    text_analysis = PDF::Inspector::Text.analyze(file)
    text_analysis.strings
  end

  def plain_text
    @plain_text ||= strings.join(' ')
  end

  def file
    @file ||= File.open(path,'rb')
  end
end #/class Checker
end #/module PDF
