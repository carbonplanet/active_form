require 'test_helper'

class TestTextareaElement < Test::Unit::TestCase
  
  def test_set_attributes
    [:title, :lang, :rows, :cols].each do |attribute|
      assert ActiveForm::Element::Textarea.element_attribute_names.include?(attribute)
    end   
    elem = ActiveForm::Element::Textarea.new :elem, :rows => 5, :cols => 30
    expected = {"name"=>"elem", "class"=>"elem_textarea", "id"=>"elem", "rows"=>5, "cols"=>30}
    assert_equal expected, elem.element_attributes
  end
  
  def test_element_to_html
    elem = ActiveForm::Element::Textarea.new :elem, :value => 'test' 
    expected = %|<textarea class="elem_textarea" cols="40" id="elem" name="elem" rows="20">test</textarea>\n|
    assert_equal expected, elem.to_html    
    elem = ActiveForm::Element::Textarea.new :elem, :value => 'test', :rows => 5, :cols => 30 
    expected = %|<textarea class="elem_textarea" cols="30" id="elem" name="elem" rows="5">test</textarea>\n|
    assert_equal expected, elem.to_html
  end
  
end