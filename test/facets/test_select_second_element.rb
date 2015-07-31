require 'test_helper'

class TestSelectSecondElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::SelectSecond.new :seconds
    assert_equal [*(0..59)], elem.collect(&:value)
    assert_equal [*('00'..'59')], elem.collect(&:label)
    
    elem = ActiveForm::Element::SelectSecond.new :seconds, :increment => 5
    assert_equal [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55], elem.collect(&:value)
    assert_equal ["00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"], elem.collect(&:label)
    
    elem = ActiveForm::Element::SelectSecond.new :seconds, :increment => 10
    assert_equal [0, 10, 20, 30, 40, 50], elem.collect(&:value)
    assert_equal ["00", "10", "20", "30", "40", "50"], elem.collect(&:label)
  end
  
  def test_assign_value
    elem = ActiveForm::Element::SelectSecond.new :seconds, :value => 22
    assert_equal 22, elem.value
    elem = ActiveForm::Element::SelectSecond.new :seconds, :value => Date.new(2004, 1, 1)
    assert_equal 0, elem.value
    elem = ActiveForm::Element::SelectSecond.new :seconds, :value => Time.local(2004, 1, 1, 13, 15, 5)
    assert_equal 5, elem.value
  end
  
  def test_out_of_range_value
    elem = ActiveForm::Element::SelectSecond.new :seconds, :value => -5
    assert_equal 0, elem.value                           
    elem = ActiveForm::Element::SelectSecond.new :seconds, :value => 80
    assert_equal 59, elem.value
  end
  
  def test_push_value_towards_increment_value
    elem = ActiveForm::Element::SelectSecond.new :seconds, :increment => 5, :value => 22
    assert_equal 20, elem.value
    elem = ActiveForm::Element::SelectSecond.new :seconds, :increment => 10, :value => 26
    assert_equal 30, elem.value
  end
  
  def test_select_multiple
    elem = ActiveForm::Element::SelectSecond.new :seconds, :multiple => true, :increment => 30
    elem.values = [12, 35, 46]
    assert_equal [0, 30], elem.export_value
  end
  
end