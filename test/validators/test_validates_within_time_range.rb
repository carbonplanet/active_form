require 'test_helper'

class TestValidatesWithinTimeRange < Test::Unit::TestCase
  
  def test_validator_defaults
    elem = ActiveForm::Element::build(:select_date, :mydate) do |e|
      e.validates_within_time_range
    end
    assert elem.validate
  end
  
  def test_validation_within_time_range
    elem = ActiveForm::Element::build(:select_date, :mydate) do |e|
      e.validates_within_time_range :range => (Time.local(2006, 8, 1)..Time.local(2006, 12, 31))
    end
    elem.value = Time.local(2006, 9, 11)
    assert elem.validate
    elem.value = Time.local(2006, 5, 5)
    assert !elem.validate
    assert_equal ["Mydate: specify a valid time or date between August 01, 2006 00:00 and December 31, 2006 00:00"], elem.errors.collect(&:message)
    elem.value = Date.new(2006, 9, 11)
    assert elem.validate
    elem.value = '2006-9-11'
    assert elem.validate
  end
  
  def test_validation_within_date_range
    elem = ActiveForm::Element::build(:select_date, :mydate) do |e|
      e.validates_within_time_range :range => (Date.new(2006, 8, 1)..Date.new(2006, 12, 31))
    end
    elem.value = Date.new(2006, 9, 11)
    assert elem.validate
    elem.value = Date.new(2006, 5, 5)
    assert !elem.validate
    assert_equal ["Mydate: specify a valid time or date between August  1, 2006 and December 31, 2006"], elem.errors.collect(&:message)
    elem.value = Time.local(2006, 9, 11)
    assert elem.validate
    elem.value = '2006-9-11'
    assert elem.validate
  end
  
  def test_validation_within_specific_array_of_dates
    elem = ActiveForm::Element::build(:select_date, :mydate) do |e|
      e.validates_within_time_range :range => [Date.new(2006, 8, 1), Date.new(2006, 9, 11)], :message => '%s: specify either August 1 or September 11'
    end
    elem.value = Date.new(2006, 9, 11)
    assert elem.validate   
    elem.value = Date.new(2006, 5, 5)
    assert !elem.validate
    assert_equal ["Mydate: specify either August 1 or September 11"], elem.errors.collect(&:message)
  end
  
end