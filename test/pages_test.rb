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

  def test_one_page_other_properties
    # Pour fouiller les propriétés avant de les tester
    page = checker.page(1)

    # puts "page fonts: #{page.fonts.inspect}"
    # => {:"F1.0"=>{:Type=>:Font, :Subtype=>:Type1, :BaseFont=>:Helvetica, :Encoding=>:WinAnsiEncoding}}
    puts "(court) page text: #{page.text.inspect}"

    # page = checker_long.page(2)
    # # puts "(long) page text: #{page.text.inspect}"

    ###############################################################
    ###################       IMPORTANT !      ####################
    ### CE BOUT DE CODE EST À ÉTUDIER PARTICULIÈREMENT, PARCE   ###
    ### QU'IL SEMBLE POUVOIR RETOURNER TOUT CE QUI CONCERNE LES ###
    ### DONNÉES DU DOCUMENT 
    ###############################################################
    receiver = PDF::Reader::RegisterReceiver.new
    page.reader_page.walk(receiver)
    receiver.callbacks.each do |cb|
      puts cb
    end
=begin
  @PRODUIT : 
    {:name=>:page=, :args=>[<PDF::Reader::Page page: 1>]}
    {:name=>:save_graphics_state, :args=>[]}
    {:name=>:begin_text_object, :args=>[]}
    {:name=>:move_text_position, :args=>[36.0, 736.82]}
    {:name=>:set_text_font_and_size, :args=>[:"F1.0", 10]}
    {:name=>:show_text_with_positioning, :args=>[["Bonjour tout le monde\xA0!"]]}
    {:name=>:end_text_object, :args=>[]}
    {:name=>:restore_graphics_state, :args=>[]}
=end
  end


end # class Minitest::Test
