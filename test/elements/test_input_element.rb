require 'test_helper'

class TestInputElement < Test::Unit::TestCase
  
  def test_set_attributes
    [:title, :lang, :type, :value].each do |attribute|
      assert ActiveForm::Element::Input.element_attribute_names.include?(attribute)
    end
    
    elem = ActiveForm::Element::Input.new :elem, :type => 'password', :value => 'secret'
    expected = {"name"=>"elem", "class"=>"elem_input", "type"=>"password", "id"=>"elem", "value"=>"secret"}
    assert_equal expected, elem.element_attributes
  end
  
  def test_element_to_html
    elem = ActiveForm::Element::Input.new :elem, :type => 'hidden'
    expected = %|<input class="elem_input" id="elem" name="elem" type="hidden"/>\n|
    assert_equal expected, elem.to_html    
  end
  
  def test_autocomplete_off
    elem = ActiveForm::Element::Input.new :elem, :type => 'text', :autocomplete_off => true
    expected = %|<input autocomplete="off" class="elem_input" id="elem" name="elem" type="text"/>\n|
    assert_equal expected, elem.to_html 
  end
  
  def test_accesskey_attribute
    elem = ActiveForm::Element::Input.new :elem, :type => 'text', :accesskey => 'f'
    expected = %|<input accesskey="f" class="elem_input" id="elem" name="elem" type="text"/>\n|
    assert_equal expected, elem.to_html 
  end
  
  def test_tabindex_attribute
    elem = ActiveForm::Element::Input.new :elem, :type => 'text', :tabindex => '2'
    expected = %|<input class="elem_input" id="elem" name="elem" tabindex="2" type="text"/>\n|
    assert_equal expected, elem.to_html 
  end
  
end