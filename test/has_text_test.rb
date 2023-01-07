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

  def test_doc_not_has_text_with_only_text
    assert_success { pdf.not.has_text("Au revoir") }
    assert_failure { pdf.not.has_text("Bonjour")}
    err_msg = "Le texte ne devrait pas contenir 'Bonjour'"
    assert_failure(err_msg) { pdf.not.has_text("Bonjour", err_msg)}
  end

  def test_page_has_text_with_only_text
    assert_success { pdf.page(1).has_text("Bonjour") }
    assert_failure { long_pdf.page(2).has_text("Bonjour") }
    assert_success { long_pdf.page(1).has_text("long texte simple")}
    assert_failure { pdf.page(1).has_text("Au revoir")}
    err_msg = "La page devrait contenir 'Au revoir'"
    assert_failure(err_msg) { pdf.page(1).has_text("Au revoir", err_msg)}
  end

end #/class HasTextTest
