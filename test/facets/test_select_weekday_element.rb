require 'test_helper'

class TestSelectWeekdayElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::SelectWeekday.new :day
    assert_equal [*(0..6)], elem.collect(&:value)
    assert_equal ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], elem.collect(&:label)
    
    elem = ActiveForm::Element::SelectWeekday.new :day, :use_short_day => true
    assert_equal [*(0..6)], elem.collect(&:value)
    assert_equal ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], elem.collect(&:label)
  end
  
  def test_only_weekdays
    elem = ActiveForm::Element::SelectWeekday.new :day, :weekdays_only => true
    assert_equal [*(1..5)], elem.collect(&:value)
    assert_equal ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], elem.collect(&:label)
  end
  
  def test_only_weekends
    elem = ActiveForm::Element::SelectWeekday.new :day, :weekend_only => true
    assert_equal [6, 0], elem.collect(&:value)
    assert_equal ["Saturday", "Sunday"], elem.collect(&:label)
  end
  
  def test_subset
    elem = ActiveForm::Element::SelectWeekday.new :day, :subset => [1, 2, 3]
    assert_equal [1, 2, 3], elem.collect(&:value)
    assert_equal ["Monday", "Tuesday", "Wednesday"], elem.collect(&:label)
  end

  def test_out_of_range_value
    elem = ActiveForm::Element::SelectWeekday.new :day, :value => -5
    assert_equal 0, elem.value                           
    elem = ActiveForm::Element::SelectWeekday.new :day, :value => 9
    assert_equal 6, elem.value
  end

  def test_assign_value
    elem = ActiveForm::Element::SelectWeekday.new :day, :value => 1
    assert_equal 1, elem.value
    elem = ActiveForm::Element::SelectWeekday.new :day, :value => Date.new(2006, 9, 11)
    assert_equal 1, elem.value
    elem = ActiveForm::Element::SelectWeekday.new :day, :value => Date.new(2006, 9, 12)
    assert_equal 2, elem.value
    elem = ActiveForm::Element::SelectWeekday.new :day, :value => Time.local(2006, 9, 11, 13, 15, 5)
    assert_equal 1, elem.value
  end
  
  def test_assign_value_and_return_as_string
    elem = ActiveForm::Element::SelectWeekday.new :day, :value => 3
    assert_equal "Wednesday", elem.to_dayname
    elem = ActiveForm::Element::SelectWeekday.new :day, :value => 3, :type_cast => :string
    assert_equal "Wednesday", elem.to_dayname
    assert_equal "Wednesday", elem.export_value
    elem = ActiveForm::Element::SelectWeekday.new :day, :value => Date.new(2006, 9, 11), :type_cast => :string
    assert_equal "Monday", elem.to_dayname
    assert_equal "Monday", elem.export_value
  end
  
  def test_select_multiple
    elem = ActiveForm::Element::SelectWeekday.new :day, :multiple => true
    elem.values = [0, 3, 5]
    assert_equal [0, 3, 5], elem.export_value    
    elem = ActiveForm::Element::SelectWeekday.new :day, :multiple => true, :type_cast => :string
    elem.values = [0, 3, 5]
    assert_equal ["Sunday", "Wednesday", "Friday"], elem.export_value
  end
    
end