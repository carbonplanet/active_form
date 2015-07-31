require 'test_helper'

class TestSubmitElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::Submit.new :elem, :label => 'Send'
    assert !elem.labelled?
    expected = %|<input class="elem_submit" id="elem" name="elem" type="submit" value="Send"/>\n|
    assert_equal expected, elem.to_html    
  end
  
end