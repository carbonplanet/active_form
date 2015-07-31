require 'test_helper'

class TestHiddenElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::Hidden.new :elem, :value => 'test'
    expected = %|<input id="elem" name="elem" type="hidden" value="test"/>\n|
    assert_equal expected, elem.to_html    
  end
  
end