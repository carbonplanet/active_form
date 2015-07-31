require 'test_helper'

class TestValidatesAsAlpha < Test::Unit::TestCase
  
  def test_validator_defaults
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_alpha
    end
    assert elem.validate
    elem.value = 123
    assert !elem.validate
    assert_equal ["Mystring: should contain alphabetical characters only"], elem.errors.collect(&:message)
    assert_equal ["Mystring: should contain alphabetical characters only"], elem.gather_validation_advice.collect(&:message)
  end
  
  def test_validator_check
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_alpha
    end
    invalid = [123, '%a$', '_', 'Foo Bar']
    valid = [nil, '', ' ','abc', 'AbC']
    invalid.each { |value| elem.value = value; assert !elem.validate }
    valid.each { |value| elem.value = value; assert elem.validate }
  end
  
end