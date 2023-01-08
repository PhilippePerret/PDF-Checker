require 'test_helper'
class ConfigTests < Minitest::Test

  def teardown
    super
    PDF::Checker.reset_config
  end

  def test_set_config_respond
    assert_respond_to PDF::Checker, :set_config
  end
  def test_config_respond
    assert_respond_to PDF::Checker, :config
  end
  def test_config_instance_config
    assert_instance_of PDF::Checker::Config, PDF::Checker.config
  end

  def test_config_default_values
    defvals = PDF::Checker.config.values
    assert defvals
    assert_instance_of Hash, defvals
    assert defvals.key?(:top_based)
    assert defvals.key?(:coordonates_tolerance)
  end

  def test_set_config
    defvals = PDF::Checker.config.values
    delta = defvals[:coordonates_tolerance].freeze
    assert_equal(delta, PDF::Checker.config[:coordonates_tolerance])
    PDF::Checker.set_config(coordonates_tolerance: 4)
    assert_equal(4, PDF::Checker.config[:coordonates_tolerance])
    assert_equal(4, PDF::Checker.config.get(:coordonates_tolerance))
    PDF::Checker.config.set(coordonates_tolerance: 5)
    assert_equal(5, PDF::Checker.config[:coordonates_tolerance])
    assert_equal(5, PDF::Checker.config.get(:coordonates_tolerance))
  end

end #/ConfigTests
