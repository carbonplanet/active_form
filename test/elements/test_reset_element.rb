require 'test_helper'

class TestResetElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::Reset.new :elem, :label => 'Reset data'
    assert !elem.labelled?
    expected = %|<input class="elem_reset" id="elem" name="elem" type="reset" value="Reset data"/>\n|
    assert_equal expected, elem.to_html    
  end
  
end