require 'test_helper'
require_relative '_required_'

class EssaiPageAnalysis < Minitest::Test


  def test_one_page
    assert_respond_to checker, :page
    assert_raises(ArgumentError) { checker.page }
    assert_silent { checker.page(1) }
    assert checker.page(1)
    assert_instance_of PDF::Checker::Page, checker.page(1)
    assert_silent { checker.page(10) }
    refute checker.page(10)
  end

  def test_page_count
    assert_respond_to checker, :has_page_count?
    assert checker.has_page_count?(1)
    refute checker.has_page_count?(2)
    assert checker_long.has_page_count?(4)
  end

  def test_one_page_properties
    skip
    page = checker.page(1)
    assert_respond_to page, :number
    assert_equal 1, page.number, "Page should have number #{1} (get #{page.number.inspect}."

    puts "page properties : #{page.reader_page.instance_variables}"
    # puts "page.objects : #{page.reader_page.objects.inspect}"
    page.objects.each do |objet|
      # puts "\n#{objet}"

    end
    objet = page.objects.first
    # puts "objet properties : #{objet.instance_variables}"

    # TODO : poursuivre les essais si nécessaire
  end

  def test_one_page_text
    page = checker.page(1)
    assert_respond_to page, :text
    actual = page.text
    expected = 'Bonjour tout le monde!' # noter l'absence de l'insécable
    assert_equal expected, actual
  end

  def test_one_page_raw_content
    page = checker.page(1)
    assert_respond_to page, :raw_content
    # puts "page.raw_content : #{page.raw_content.inspect}"
  end

  def test_receiver_callbacks
    # Pour voir si c'est intéressant d'avoir un fichier pouvant
    # renvoyer tous les callbacks d'une page ou d'un fichier

    # puts checker.page(1).receivers_callbacks
    # puts checker_long.page(2).receivers_callbacks

    # puts checker.page(1).show_texts_with_positioning.inspect
    # puts checker_long.page(1).show_texts_with_positioning.inspect

    # texte = checker.page(1).textes.first
    texte = checker_long.page(1).textes[1]
    # props = texte.properties
    
    puts "content : #{texte.content.inspect}"
    puts "Fonte du texte : #{texte.font}"
    puts "Taille du texte : #{texte.size}"

  end
  def test_one_page_other_properties
    skip
    # Pour fouiller les propriétés avant de les tester
    page = checker.page(1)

    # puts "page fonts: #{page.fonts.inspect}"
    # => {:"F1.0"=>{:Type=>:Font, :Subtype=>:Type1, :BaseFont=>:Helvetica, :Encoding=>:WinAnsiEncoding}}
    puts "(court) page text: #{page.text.inspect}"

    # page = checker_long.page(2)
    # # puts "(long) page text: #{page.text.inspect}"

  end


end # class Minitest::Test
