require 'test_helper'
require_relative '_required_'

class SimpleTestPdfChecker < Minitest::Test


  def test_initialize
    
    assert_raises(ArgumentError) { PDF::Checker.new }

  end

  # Test:
  #   PDF::Checker#strings 
  # against a simple "Hello world!"-like text.
  # 
  def test_strings 
    assert_respond_to checker, :strings
    assert_instance_of Array, checker.strings, "PDF::Checker#strings should return an Array (is a #{checker.strings.class} instance)."
    assert checker.strings.include?('Bonjour tout le monde !')

  end

  def test_plain_text
    assert_respond_to checker, :plain_text
    assert_equal 'Bonjour tout le monde !', checker.plain_text
  end

  def test_include_string
    assert_respond_to checker, :include?

    # Succeeds with…
    [
      'Bonjour tout le monde !',
      'Bonjour', 
      'jour',
      /B.+jour/,
      ['Bonjour','le','monde'],
      ['jour', 'le', 'mon'],
      {string:'Bonjour'},
      {string:'Bonjour', before:'monde'},
      {string:'le', after:'Bonjour', before:'monde', near:'tout'},
      [/B.+jour/,'le','monde', {string:' '}],
    ].each do |searched|
      assert checker.include?(searched), "#{searched.inspect} should be find in strings with include?"
    end

    # Fails with…
    [
      'Sonjour',
      ['Bonjour','monde', 'la'],
      /Bon[0-9]/,
      {string:'Conjour'},
      {string:'Bonjour', after:'monde'},
    ].each do |searched|
      refute checker.include?(searched), "#{searched.inspect} should not be find in strings with include?."
    end
  end
end #/SimpleTestPdfChecker
