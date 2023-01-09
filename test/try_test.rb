require 'test_helper'
module Prawn
  class MyDocument < Document
    def move_cursor_to(new_y)
      self.y = new_y + font.ascender + bounds.absolute_bottom
      # Original is : 
      # self.y = new_y + bounds.absolute_bottom
    end
  end #/class MyDocument
end #/module Prawn

class TryTest < Minitest::Test

  # J'essaie de faire un document
  def test_creation_document
    PDF::Checker.set_config(:default_output_unit, :mm)
    pdf_path = File.join(TRY_FOLDER, 'placement.pdf')
    File.delete(pdf_path) if File.exist?(pdf_path)
    texte = "Place a 10 mm et 50 mm"


    # Prawn::Document.generate(pdf_path, **{margin:0}) do
    Prawn::MyDocument.generate(pdf_path, **{margin:0}) do
      puts "self.y avant = #{self.y.inspect}"
      puts "ascender : #{font.ascender}" # <=== PRENDRE EN COMPTE
      # NOTER DONC QUE :
      # Lorsqu'on écrit ave move_cursor_to et text, il faut ajouter
      # cet ascender pour connaitre la position exacte. Mais, pour
      # ce checker, pour le moment, je n'ai aucun moyen de savoir si
      # on a écrit avec text ou draw_text (qui conserve, lui, la 
      # valeur vraiment définie).
      # Les deux solutions :
      #   - on peut trouver un callback (par receiver) qui définit si
      #     le texte a été écrit par text ou draw_text, voire autre
      #     chose encore
      #   - soit, pour que les tests soient bons, il faut réécrive
      #     la méthode 'move_cursor_to' pour qu'elle ajoute l'ascender
      #     de la fonte courante… (ce qui oblige l'utilisateur à
      #     modifier son programme…)
      # 
      puts "descender : #{font.descender}"

      # print_text_method = :draw_text
      print_text_method = :text

      case print_text_method
      when :text
        puts "bounds.absolute_bottom = #{bounds.absolute_bottom}"
        move_cursor_to(12)
        text texte
        # avec 12
        # => PROPERTIES : {:move_text_position=>[0.0, 3.384], :text_font_and_size=>[:"F1.0", 12], :show_text_with_positioning=>[["Place a 10 mm et 50 mm"]]}
        # avec 100
        # => PROPERTIES : {:move_text_position=>[0.0, 91.384], :text_font_and_size=>[:"F1.0", 12], :show_text_with_positioning=>[["Place a 10 mm et 50 mm"]]}
      when :draw_text
        draw_text texte, **{at:[0, 12]}
        # avec 12
        # => PROPERTIES : {:move_text_position=>[0.0, 12.0], :text_font_and_size=>[:"F1.0", 12], :show_text_with_positioning=>[["Place a 10 mm et 50 mm"]]}
        # avec 100
        # => PROPERTIES : {:move_text_position=>[0.0, 100.0], :text_font_and_size=>[:"F1.0", 12], :show_text_with_positioning=>[["Place a 10 mm et 50 mm"]]}
      end
      puts "self.y après = #{self.y.inspect}"
    end
    apdf = PDF::Checker.new(pdf_path)
    puts "PROPERTIES : #{apdf.page(1).texts_objects[0].properties.inspect}"
    # puts "\n*** SCÉNARIO : #{apdf.page(1).scenario}"
    assert_success { apdf.page(1).has_text(texte)}
    props = {at: [0, 100]}
    assert_success { apdf.page(1).has_text(texte).with(**props)}
  end

end #/TryTest
