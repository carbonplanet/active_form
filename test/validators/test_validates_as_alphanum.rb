require 'test_helper'

class TestValidatesAsAlphanum < Test::Unit::TestCase
  
  def test_validator_defaults
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_alphanum
    end
    assert elem.validate
    elem.value = 'Foo Bar'
    assert !elem.validate
    assert_equal ["Mystring: should contain alphabetical characters or numbers only"], elem.errors.collect(&:message)
    assert_equal ["Mystring: should contain alphabetical characters or numbers only"], elem.gather_validation_advice.collect(&:message)
  end
  
  def test_validator_check
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_alphanum
    end
    invalid = ['%a$', '_', 'Foo Bar']
    valid = [nil, '', ' ', 123, 'abc', 'AbC', 'abc1234']
    invalid.each { |value| elem.value = value; assert !elem.validate }
    valid.each { |value| elem.value = value; assert elem.validate }
  end
  
end