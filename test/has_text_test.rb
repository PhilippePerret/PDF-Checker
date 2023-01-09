=begin

  Test avec la nouvelle formule des classes PDF::Checker::Assertion

  TODO
    Tout est à faire, seules les classes de base ont été implémentées
    mais ne contiennent qu'une méthode #proceed qui ne fait rien pour
    le moment.

=end
require 'test_helper'
require 'pdf/checker'
require_relative '_required_'
class NewHasTextTest < Minitest::Test

  def pdf
    @pdf ||= checker_long
  end

  # def test_checker_respond_to_has_text
  #   assert_respond_to pdf, :has_text
  #   assert_instance_of PDF::Checker::TextAssertion, pdf.has_text("bonjour")
  # end

  # def test_assertion_respond_to_negative?
  #   assneg = pdf.not.has_text("Au revoir")
  #   assert_respond_to assneg, :negative?
  #   assert assneg.negative?
  #   asspos = pdf.has_text("bonjour")
  #   assert_respond_to asspos, :negative?
  #   refute asspos.negative?
  # end

  def test_has_text_succeeds_if_doc_has_text
    assert_success { pdf.page(1).has_text("texte simple") }
    assert_success { pdf.page(1).has_text(["long texte simple", 'façon automatique', /Lorem(.+?)dolor/])}
  end

  def test_has_text_fails_if_doc_has_not_text
    assert_failure { pdf.page(1).has_text("Au revoir") }
  end

  # TODO : test en mode :strict (options de has_text)
  # TODO : test avec :count attendu

end #/NewHasTextTest
