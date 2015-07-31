require 'test_helper'

class TestValidatesWithinLengthRange < Test::Unit::TestCase
  
  def test_validator_defaults
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_within_length_range
    end
    assert elem.validate
    assert_equal [], elem.errors.collect(&:message)
    assert_equal ["Mystring: length should be within 0 and 1 characters"], elem.gather_validation_advice.collect(&:message)
  end
  
  def test_validator_with_range
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_within_length_range :range => (3..9)
    end
    assert !elem.validate
    assert_equal ["Mystring: length should be within 3 and 9 characters"], elem.errors.collect(&:message)
    assert_equal ["Mystring: length should be within 3 and 9 characters"], elem.gather_validation_advice.collect(&:message)
    testvalues = { 'ab' => false, 'abc' => true, 'abcdefghi' => true, 'abcdefghij' => false }
    testvalues.each { |(value, expected)| elem.value = value; assert_equal expected, elem.validate }
  end
  
  def test_validator_with_array
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_within_length_range :range => [3, 5, 8, 13]
    end
    assert !elem.validate
    assert_equal ["Mystring: length should be within 3 and 13 characters"], elem.errors.collect(&:message)
    testvalues = { 'ab' => false, 'abc' => true, 'abcde' => true, 'abcdefghi' => false }
    testvalues.each { |(value, expected)| elem.value = value; assert_equal expected, elem.validate }
  end
  
  def test_custom_validation_message
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_within_length_range :range => (3..9) do |v|
        v.message = "%1$s: length should be within %3$s and %4$s characters but was %5$s"
      end
    end
    elem.value = 'ab'
    assert !elem.validate
    assert_equal ["Mystring: length should be within 3 and 9 characters but was 2"], elem.errors.collect(&:message)
  end
  
end