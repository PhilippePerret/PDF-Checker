=begin
Pour tester une page en particulier
=end
require 'test_helper'
require_relative '_required_'

class SimplePageTestor < Minitest::Test

  def page(num = nil, long = false)
    if num.nil?
      @page
    else
      @page = (long ? checker_long : checker).page(num)
    end
  end

  def setup
    super
    page(1, false)
  end

  def test_texts_method
    assert_respond_to page, :texts
    assert_instance_of Array, page.texts
    assert_instance_of String, page.texts.first
    expected = "Bonjour tout le monde !"
    actual   = page.texts.first
    assert_equal expected, actual
  end

  def test_text_method
    assert_respond_to page, :text
    assert_instance_of String, page.text
    expected = "Bonjour tout le monde !"
    actual   = page.text
    assert_equal expected, actual
  end


  def test_sentences_method
    page(1, true)
    assert_respond_to page, :sentences
    assert_instance_of Array, page.sentences
    assert_instance_of String, page.sentences.first
    [
      [0, "Ceci est un fichier avec un long texte simple."],
      [1 , "Il sert principalement à voir comment sera traité un texte qui ne contient que des paragraphes, étalés sur plusieurs pages de façon automatique."]
    ].each do |sentence_index, expected|
      actual = page.sentences[sentence_index]
      assert_equal expected, actual
    end
  end

  def test_sentences_method_on_long_text
    page(1, true)
    # puts page.sentences.inspect
  end

  def test_phrase_alias_method
    assert_respond_to page, :phrases
  end

end # class Minitest::Test
