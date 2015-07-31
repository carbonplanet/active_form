require 'test_helper'

class TestSelectMonthElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::SelectMonth.new :month
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], elem.collect(&:value)
    expected = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    assert_equal expected, elem.collect(&:label)
    
    elem = ActiveForm::Element::SelectMonth.new :month, :use_month_numbers => true
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], elem.collect(&:value)
    expected = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    assert_equal expected, elem.collect(&:label)
    
    elem = ActiveForm::Element::SelectMonth.new :month, :use_short_month => true
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], elem.collect(&:value)
    expected = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    assert_equal expected, elem.collect(&:label)
    
    elem = ActiveForm::Element::SelectMonth.new :month, :use_short_month => true, :add_month_numbers => true
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], elem.collect(&:value)
    expected = ["01 - Jan", "02 - Feb", "03 - Mar", "04 - Apr", "05 - May", "06 - Jun", "07 - Jul", "08 - Aug", "09 - Sep", "10 - Oct", "11 - Nov", "12 - Dec"]
    assert_equal expected, elem.collect(&:label)
    
    elem = ActiveForm::Element::SelectMonth.new :month, :increment => 3
    assert_equal [1, 4, 7, 10], elem.collect(&:value)
    assert_equal ["January", "April", "July", "October"], elem.collect(&:label)
  end
  
  def test_subset
    elem = ActiveForm::Element::SelectMonth.new :month, :subset => [1, 2, 3, 10, 11, 12]
    assert_equal [1, 2, 3, 10, 11, 12], elem.collect(&:value)
    assert_equal ["January", "February", "March", "October", "November", "December"], elem.collect(&:label)
  end
  
  def test_assign_value
    elem = ActiveForm::Element::SelectMonth.new :month, :value => 9
    assert_equal 9, elem.value
    elem = ActiveForm::Element::SelectMonth.new :month, :value => Date.new(2004, 9, 22)
    assert_equal 9, elem.value
    elem = ActiveForm::Element::SelectMonth.new :month, :value => Time.local(2004, 9, 22, 13, 15, 5)
    assert_equal 9, elem.value
  end
  
  def test_push_value_towards_increment_value
    elem = ActiveForm::Element::SelectMonth.new :month, :increment => 3, :value => 6
    assert_equal [1, 4, 7, 10], elem.collect(&:value)
    assert_equal 7, elem.value
  end
  
  def test_out_of_range_value
    elem = ActiveForm::Element::SelectMonth.new :month, :value => -5
    assert_equal 1, elem.value                           
    elem = ActiveForm::Element::SelectMonth.new :month, :value => 28
    assert_equal 12, elem.value
  end
  
  def test_assign_value_and_return_as_string
    elem = ActiveForm::Element::SelectMonth.new :month, :value => 3
    assert_equal "March", elem.to_monthname
    elem = ActiveForm::Element::SelectMonth.new :month, :value => 9, :type_cast => :string
    assert_equal "September", elem.to_monthname
    assert_equal "September", elem.export_value
    elem = ActiveForm::Element::SelectMonth.new :month, :value => Date.new(2006, 9, 11), :type_cast => :string, :use_short_month => true
    assert_equal "Sep", elem.to_monthname
    assert_equal "Sep", elem.export_value
  end
  
  def test_select_multiple
    elem = ActiveForm::Element::SelectMonth.new :month, :multiple => true
    elem.values = [1, 3, 5]
    assert_equal [1, 3, 5], elem.export_value    
    elem = ActiveForm::Element::SelectMonth.new :month, :multiple => true, :type_cast => :string
    elem.values = [1, 3, 5]
    assert_equal ["January", "March", "May"], elem.export_value
  end
  
end