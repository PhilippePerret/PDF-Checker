require 'test_helper'
class IntegerExtensionTest < Minitest::Test

  def test_pages_method
    assert_respond_to 4, :page
    assert_respond_to 4, :pages
    expected = {count: 4, type: :page}
    actual   = 4.pages
    assert_equal expected, actual, "4.pages ne retourne pas le bon résultat. Attendu : #{expected.inspect}. Reçu : #{actual.inspect}."
    actual = 0.page
    expected = {count:0, type: :page}
    assert_equal expected, actual, "0.page ne retourne pas le bon résultat. Attendu : #{expected.inspect}. Reçu : #{actual.inspect}."
  end

  def test_images_method
    assert_respond_to 4, :image
    assert_respond_to 4, :images
    expected = {count: 4, type: :image}
    actual   = 4.images
    assert_equal expected, actual, "4.images ne retourne pas le bon résultat. Attendu : #{expected.inspect}. Reçu : #{actual.inspect}."
    actual = 0.image
    expected = {count:0, type: :image}
    assert_equal expected, actual, "0.image ne retourne pas le bon résultat. Attendu : #{expected.inspect}. Reçu : #{actual.inspect}."
  end

  def test_graphics_method
    assert_respond_to 4, :graphic
    assert_respond_to 4, :graphics
    expected = {count: 4, type: :graphic}
    actual   = 4.graphics
    assert_equal expected, actual, "4.graphics ne retourne pas le bon résultat. Attendu : #{expected.inspect}. Reçu : #{actual.inspect}."
    actual = 0.graphic
    expected = {count:0, type: :graphic}
    assert_equal expected, actual, "0.graphic ne retourne pas le bon résultat. Attendu : #{expected.inspect}. Reçu : #{actual.inspect}."
  end

end #/ class IntegerExtensionTest
