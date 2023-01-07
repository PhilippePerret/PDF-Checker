require 'minitest/assertions'
module PDF
class Checker
  include Minitest::Assertions
  include ActiveChecker

  attr_reader :path
  attr_reader :options
  attr_accessor :assertions

  # Initialize a new PDF Checker to check a PDF document.
  # 
  # @param [String] path to the PDF file
  # @param [Hash] options Some options
  def initialize(path, options = nil)
    @assertions = 0
    @path     = path
    @options  = options
    @negative = false # pour inverser les tests
  end

  def inspect
    @inspect ||= "#<PDF::Checker path=#{path} options=#{options.inspect}>"
  end

  # = main properties =
  # 

  # @return [PDF::Reader] of the checked document
  def reader
    @reader ||= PDF::Reader.new(file)
  end
  # @return [PDF::Inspector::Text] instance of the checked document
  def text_analysis
    @text_analysis ||= PDF::Inspector::Text.analyze(file)
  end
  # @return [PDF::Inspector::Page] instance of the checked document
  def page_analysis
    @page_analysis ||= PDF::Inspector::Page.analyze(file)
  end

  def strings
    @strings ||= text_analysis.strings
  end

  def plain_text
    @plain_text ||= strings.join(' ')
  end

  def file
    @file ||= File.open(path,'rb')
  end
end #/class Checker
end #/module PDF
