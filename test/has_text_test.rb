=begin

  Test avec la nouvelle formule des classes PDF::Checker::Assertion

=end
require 'test_helper'
require 'pdf/checker'
require_relative '_required_'
class NewHasTextTest < Minitest::Test

  def pdf
    @pdf ||= checker_long
  end

  def pdf_simple
    @pdf_simple ||= checker
  end
  alias :spdf :pdf_simple


  def test_checker_respond_to_has_text
    assert_respond_to pdf.page(1), :has_text
    assert_instance_of PDF::Checker::TextAssertion, pdf.page(1).has_text("texte simple")
  end

  def test_assertion_respond_to_negative?
    assneg = pdf.page(1).not.has_text(["Au revoir"])
    assert_respond_to assneg, :negative?
    assert assneg.negative?
    asspos = pdf.page(1).has_text(["texte simple"])
    assert_respond_to asspos, :negative?
    refute asspos.negative?
  end

  def test_has_text_succeeds_if_doc_has_text
    assert_success { pdf.page(1).has_text("texte simple") }
    assert_success { pdf.page(1).has_text(["long texte simple", 'façon automatique', /Lorem(.+?)dolor/])}
  end

  def test_has_text_succeeds_with_count_defined
    options = {count: 1}
    assert_success { pdf.page(1).has_text("texte simple", **options)}
    options = {count: 2}
    assert_failure { pdf.page(1).has_text("texte simple", **options)}
  end

  def test_has_text_fails_if_doc_has_not_text
    assert_failure { pdf.page(1).has_text("Au revoir") }
  end
  def test_not_has_text_succeeds_if_doc_has_not_text
    assert_success { pdf.page(1).not.has_text("Au revoir") }
  end

  def test_with_properties_fails_when_call_without_has_text
    assert_raises { pdf.page(1).with_properties(**{}) }
  end

  def test_has_text_with_properties_succeeds_with_good_text
    props = {font: :"F1.0", size: 10}
    assert_success { pdf.page(1).has_text('texte simple').with_properties(**props)}
    # Version courte
    assert_success { pdf.page(1).has_text('texte simple').with(**props) }
  end

  def test_has_text_with_bad_properties_fails
    props = {font: :"F1.0", size: 12}
    assert_failure { pdf.page(1).has_text('texte simple').with_properties(**props)}
    # Version courte
    assert_failure { pdf.page(1).has_text('texte simple').with(**props) }
    # - font error -
    props = {font:'Helvetica', size:10}
    assert_failure { pdf.page(1).has_text('texte simple').with(**props) }
  end

  def test_has_text_and_at
    assert_success { pdf.page(1).has_text('texte simple').at(737) }
  end

  def test_at_with_strict_mode
    assert_success { pdf.page(1).has_text('texte simple').at(737, **{strict: false}) }
    assert_failure { pdf.page(1).has_text('texte simple').at(737, **{strict: true}) }
    assert_success { pdf.page(1).has_text('texte simple').at(736.82, **{strict: true}) }
  end

  def test_has_text_mode_strict
    assert_success { pdf.page(1).has_text('texte simple') }
    assert_failure { pdf.page(1).has_text('texte simple', **{strict:true}) }
    assert_success { pdf_simple.page(1).has_text('Bonjour tout le monde !')}
    assert_success { pdf_simple.page(1).has_text('Bonjour tout le monde !', **{strict:true})}
  end


  # TODO : test avec :count attendu (il faut tester deux cas : avec
  # :count dans les options has_text et avec :count dans les properties)

end #/NewHasTextTest
