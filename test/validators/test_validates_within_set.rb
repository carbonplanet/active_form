require 'test_helper'

class TestValidatesWithinSet < Test::Unit::TestCase
  
  def test_validator_defaults
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_within_set
    end
    assert !elem.validate
    assert_equal ["Mystring: invalid value"], elem.errors.collect(&:message)
    assert_equal ["Mystring: invalid value"], elem.gather_validation_advice.collect(&:message)
  end
  
  def test_validator_with_range
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_within_set :set => ['a', 'b', 'c']
    end
    assert !elem.validate
    assert_equal ["Mystring: invalid value"], elem.errors.collect(&:message)
    assert_equal ["Mystring: invalid value"], elem.gather_validation_advice.collect(&:message)
    testvalues = { 'a' => true, 'b' => true, 'c' => true, 'd' => false, 'foo' => false }
    testvalues.each { |(value, expected)| elem.value = value; assert_equal expected, elem.validate }
  end
  
  def test_validator_with_array
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_within_set :set => ('a'..'c')
    end
    assert !elem.validate
    assert_equal ["Mystring: invalid value"], elem.errors.collect(&:message)
    testvalues = { 'a' => true, 'b' => true, 'c' => true, 'd' => false, 'foo' => false }
    testvalues.each { |(value, expected)| elem.value = value; assert_equal expected, elem.validate }
  end
  
  def test_custom_validation_message
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_within_set :set => (3..9) do |v|
        v.message = "%1$s: value is not within these values: %3$s"
      end
    end
    elem.value = 'abc'
    assert !elem.validate
    assert_equal ["Mystring: value is not within these values: 3, 4, 5, 6, 7, 8, 9"], elem.errors.collect(&:message)
  end
  
end