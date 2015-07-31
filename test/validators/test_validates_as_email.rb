require 'test_helper'

class TestValidatesAsEmail < Test::Unit::TestCase
  
  def test_validator_defaults
    elem = ActiveForm::Element::build(:text, :mystring) { |e| e.validates_as_email }
    assert elem.validate
    elem.value = 'abc'
    assert !elem.validate
    assert_equal ["Mystring: is not a valid email address"], elem.errors.collect(&:message)
    assert_equal ["Mystring: is not a valid email address"], elem.gather_validation_advice.collect(&:message)
  end
  
  def test_validator_check
    elem = ActiveForm::Element::build(:text, :mystring) { |e| e.validates_as_email }
    invalid = ['123a', '%a$', '_', 'Foo Bar']
    valid = [nil, '', ' ', 'info@loobmedia.com', 'info@looboommediaz.com']
    invalid.each { |value| elem.value = value; assert !elem.validate }
    valid.each { |value| elem.value = value; assert elem.validate }
  end
  
  def test_validate_with_resolve
    # this is hard to test with some ISP's
    elem = ActiveForm::Element::build(:text, :mystring) { |e| e.validates_as_email :resolve => true }
    elem.value = 'info@loobmedia.com'
    assert elem.validate
  end
  
end