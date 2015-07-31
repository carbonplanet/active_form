require 'test_helper'

class TestSelectNumericRangeElement < Test::Unit::TestCase
  
  def test_select_multiple
    elem = ActiveForm::Element::SelectNumericRange.new :numbers, :range => (0..10), :increment => 2, :multiple => true
    assert_equal [0, 2, 4, 6, 8, 10], elem.collect(&:value)
    elem.values = [4, 6]
    assert_equal [4, 6], elem.export_value
    elem.values = [1, 7]
    assert_equal [2, 8], elem.export_value   
  end
  
end