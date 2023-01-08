require 'test_helper'
require_relative '_required_'

class HasTextTest < Minitest::Test

  def setup
    super
  end

  def pdf
    @checker ||= checker
  end

  def long_pdf
    @long_pdf ||= checker_long  
  end

  def test_has_text_respond
    assert_respond_to pdf, :has_text
    assert_respond_to pdf.page(1), :has_text
  end

  def test_doc_has_text_with_only_text
    err_msg = "Le texte devrait contenir 'Au revoir'"
    assert_fails(err_msg) { pdf.has_text("Au revoir", err_msg) }
    assert_fails { pdf.has_text("Au revoir") }
    assert_success { pdf.has_text("Bonjour") }
  end

  def test_doc_not_has_text_with_one_text
    assert_success { pdf.not.has_text("Au revoir") }
    assert_failure { pdf.not.has_text("Bonjour")}
    err_msg = "Le texte ne devrait pas contenir 'Bonjour'"
    assert_failure(err_msg) { pdf.not.has_text("Bonjour", err_msg)}
  end

  def test_page_has_text_with_one_text
    assert_success { pdf.page(1).has_text("Bonjour") }
    assert_failure { long_pdf.page(2).has_text("Bonjour") }
    assert_success { long_pdf.page(1).has_text("long texte simple")}
    assert_failure { pdf.page(1).has_text("Au revoir")}
    err_msg = "La page devrait contenir 'Au revoir'"
    assert_failure(err_msg) { pdf.page(1).has_text("Au revoir", err_msg)}
  end

  def test_page_has_text_with_several_texts
    assert_success { pdf.page(1).has_text(['Bonjour', 'monde'])}
    assert_failure { pdf.page(1).has_text(['Au revoir', 'le monde'])}
  end

  def test_has_text_with_several_texts_and_custom_err_message
    err_msg = "Le texte de la page 1 devrait contenir '%{expected}'."
    exp_message = "Le texte de la page 1 devrait contenir 'Au revoir'."
    assert_failure(exp_message) { pdf.page(1).has_text(['monde', 'Au revoir'], err_msg) }
  end

  def test_with_properties_sans_objets
    err = assert_raises { pdf.with_properties(**{at: [100,200]})}
    expected = "Aucun objet n'est défini"
    actual = err.message
    assert actual.start_with?(expected), "Le message d'erreur devrait commencer par #{expected.inspect}. Il vaut #{actual.inspect}."
  end

  def test_with_properties_avec_objets
    PDF::Checker.set_config(**{top_based: true, coordonates_tolerance: 2})
    props = {font: :'F1.0', size: 10, at:[38, 55]}
    assert_success { pdf.page(1).has_text("Bonjour").with_properties(**props)}
    props = {font: :'F1.0', size: 10, at:[30, 55]}
    assert_failure { pdf.page(1).has_text("Bonjour").with_properties(**props)}
    props = {font: 'ArialNew', size: 12}
    assert_failure { pdf.page(1).has_text('Bonjour').with(**props)}
  end

  def test_to_get_properties
    PDF::Checker.set_config(:default_output_unit, :mm)
    # C'est un faux test qui doit permettre d'obtenir certaines
    # valeurs
    props = {at: [13.mm, 19.mm]}
    puts pdf.page(1).has_text('Bonjour').with(**props)
  end

end #/class HasTextTest
