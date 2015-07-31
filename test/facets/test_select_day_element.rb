require 'test_helper'

class TestSelectDayElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::SelectDay.new :day
    assert_equal [*(1..31)], elem.collect(&:value)
    assert_equal [*('01'..'31')], elem.collect(&:label)
    
    elem = ActiveForm::Element::SelectDay.new :day, :increment => 7
    assert_equal [1, 8, 15, 22, 29], elem.collect(&:value)
    assert_equal ["01", "08", "15", "22", "29"], elem.collect(&:label)
  end
  
  def test_assign_value
    elem = ActiveForm::Element::SelectDay.new :day, :value => 22
    assert_equal 22, elem.value
    elem = ActiveForm::Element::SelectDay.new :day, :value => Date.new(2004, 9, 22)
    assert_equal 22, elem.value
    elem = ActiveForm::Element::SelectDay.new :day, :value => Time.local(2004, 9, 22, 13, 15, 5)
    assert_equal 22, elem.value
  end
  
  def test_out_of_range_value
    elem = ActiveForm::Element::SelectDay.new :day, :value => -5
    assert_equal 1, elem.value                           
    elem = ActiveForm::Element::SelectDay.new :day, :value => 34
    assert_equal 31, elem.value
  end
  
  def test_select_multiple
    elem = ActiveForm::Element::SelectDay.new :day, :multiple => true
    elem.values = [2, 3, 4]
    assert_equal [2, 3, 4], elem.export_value
  end
  
end