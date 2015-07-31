require 'test_helper'

class TestValidatesAsNumber < Test::Unit::TestCase
  
  def test_validator_defaults
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_number
    end
    assert elem.validate
    elem.value = 'abc'
    assert !elem.validate
    assert_equal ["Mystring: should be numeric"], elem.errors.collect(&:message)
    assert_equal ["Mystring: should be numeric"], elem.gather_validation_advice.collect(&:message)
  end
  
  def test_validator_check
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_number
    end
    invalid = ['123a', '%a$', '_', 'Foo Bar']
    valid = [nil, '', ' ', 123, '45', '123,45', '1.5', 1.25]
    invalid.each { |value| elem.value = value; assert !elem.validate }
    valid.each { |value| elem.value = value; assert elem.validate }
  end
  
end