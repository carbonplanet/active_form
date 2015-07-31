require 'test_helper'

class TestPasswordElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::Password.new :elem, :value => 'secret'
    expected = %|<input class="elem_password" id="elem" name="elem" size="30" type="password" value="secret"/>\n|
    assert_equal expected, elem.to_html    
  end
  
  def test_render_frozen
    elem = ActiveForm::Element::Password.new :elem, :value => 'secret', :frozen => true
    assert_equal '&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;', elem.to_html  
  end
  
end