require 'test_helper'

class TestSelectHourElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::SelectHour.new :hour
    assert_equal [*(0..23)], elem.collect(&:value)
    assert_equal [*('00'..'23')], elem.collect(&:label)
    
    elem = ActiveForm::Element::SelectHour.new :hour, :increment => 12
    assert_equal [0, 12], elem.collect(&:value)
    assert_equal ["00", "12"], elem.collect(&:label)
  end
  
  def test_assign_value
    elem = ActiveForm::Element::SelectHour.new :hour, :value => 22
    assert_equal 22, elem.value
    elem = ActiveForm::Element::SelectHour.new :hour, :value => Date.new(2004, 1, 1)
    assert_equal 0, elem.value
    elem = ActiveForm::Element::SelectHour.new :hour, :value => Time.local(2004, 1, 1, 13, 15, 5)
    assert_equal 13, elem.value
  end
  
  def test_out_of_range_value
    elem = ActiveForm::Element::SelectHour.new :hour, :value => -5
    assert_equal 0, elem.value                           
    elem = ActiveForm::Element::SelectHour.new :hour, :value => 28
    assert_equal 23, elem.value
  end
  
  def test_select_multiple
    elem = ActiveForm::Element::SelectHour.new :hour, :multiple => true
    elem.values = [20, 21, 22]
    assert_equal [20, 21, 22], elem.export_value
  end
  
end
