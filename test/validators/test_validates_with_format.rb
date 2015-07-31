require 'test_helper'

class TestValidatesWithFormat < Test::Unit::TestCase
  
  def test_validator_defaults
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_with_format :regexp => /^[a-z]{3}/
    end
    assert elem.validate
    elem.value = '123 abcd'
    assert !elem.validate
    assert_equal ["Mystring: has an invalid format"], elem.errors.collect(&:message)
    assert_equal ["Mystring: has an invalid format"], elem.gather_validation_advice.collect(&:message)
  end
  
  def test_validator_check
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_with_format :regexp => /^[a-z]{3}/
    end
    invalid = [123, '%a$', 'AbC', 'abCde', '_', 'Foo Bar']
    valid = [nil, '', ' ', 'abcdef', 'abc abc', 'zxf 99']
    invalid.each { |value| elem.value = value; assert !elem.validate }
    valid.each { |value| elem.value = value; assert elem.validate }
  end
  
end