require 'test_helper'

class TestButtonElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::Button.new :elem, :label => 'Do it!'
    assert !elem.labelled?
    expected = %|<input class="elem_button" id="elem" name="elem" type="button" value="Do it!"/>\n|
    assert_equal expected, elem.to_html    
  end
  
end