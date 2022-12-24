require 'test_helper'
require_relative '_required_'

class EssaiPageAnalysis < Minitest::Test


  def test_reader
    assert_respond_to checker, :reader
    assert_instance_of PDF::Reader, checker.reader
  end

  def test_infos
    assert_respond_to checker, :info
    assert_respond_to checker, :creator
    assert_respond_to checker, :producer
    assert_respond_to checker, :pdf_version
    assert_respond_to checker, :metadata
    refute checker.metadata
    refute checker_long.metadata
    assert_respond_to checker, :page_count
    assert_equal 1, checker.page_count, "checker should have 1 page (get #{checker.page_count})"
    assert_equal 4, checker_long.page_count, "checker_long should have 4 page (get #{checker_long.page_count})"

    [
      [:info          , {Producer:'Prawn', Creator:'Prawn'}],
      [:creator       , 'Prawn'],
      [:producer      , 'Prawn'],
      [:pdf_version   , 1.3],
    ].each do |prop, expected|
      actual = checker.send(prop)
      assert_equal expected, actual, "Property #{prop.inspect} of checker is wrong.\n    Expected: #{expected.inspect}:#{expected.class}\n    Actual: #{actual.inspect}:#{actual.class}"
      actual = checker_long.send(prop)
      assert_equal expected, actual, "Property #{prop.inspect} of checker_long is wrong.\n    Expected: #{expected.inspect}:#{expected.class}\n    Actual: #{actual.inspect}:#{actual.class}"
    end
  end



end # class Minitest::Test
