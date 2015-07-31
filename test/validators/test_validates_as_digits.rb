require 'test_helper'

class TestValidatesAsDigits < Test::Unit::TestCase
  
  def test_validator_defaults
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_digits
    end
    assert elem.validate
    elem.value = 'abc123'
    assert !elem.validate
    assert_equal ["Mystring: should contain digits (0-9) only"], elem.errors.collect(&:message)
    assert_equal ["Mystring: should contain digits (0-9) only"], elem.gather_validation_advice.collect(&:message)
  end
  
  def test_validator_check
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_digits
    end
    invalid = ['123a', '%a$', '_', 'Foo Bar']
    valid = [nil, '', ' ', 123, '45']
    invalid.each { |value| elem.value = value; assert !elem.validate }
    valid.each { |value| elem.value = value; assert elem.validate }
  end
  
end