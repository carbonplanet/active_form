require 'test_helper'

class TestImageElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::Image.new :elem
    expected = %|<input class="elem_image" id="elem" name="elem" type="image"/>\n|
    assert_equal expected, elem.to_html    
  end
  
end