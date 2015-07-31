require 'test_helper'

class TestTextElement < Test::Unit::TestCase
  
  def test_set_attributes
    [:title, :lang, :type, :value, :maxlength, :size].each do |attribute|
      assert ActiveForm::Element::Text.element_attribute_names.include?(attribute)
    end
    
    elem = ActiveForm::Element::Text.new :elem, :value => 'string', :maxlength => 20, :size => 20
    expected = {"type" => "text", "name"=>"elem", "class"=>"elem_text", "id"=>"elem", "value"=>"string", "maxlength"=>20, "size"=>20}
    assert_equal expected, elem.element_attributes
  end
  
  def test_option_flag_to_html_flag
    form = ActiveForm::compose :form do |f|
      f.text_element :firstname, :readonly => true
      f.text_element :lastname, :disabled => true
    end
    expected = {"name"=>"form[firstname]", "readonly"=>"readonly", "class"=>"elem_text readonly", "type"=>"text", "id"=>"form_firstname", "value"=>"", "size"=>30}
    assert_equal expected, form[:firstname].element_attributes
    expected = {"name"=>"form[lastname]", "class"=>"elem_text disabled", "type"=>"text", "id"=>"form_lastname", "disabled"=>"disabled", "value"=>"", "size"=>30}
    assert_equal expected, form[:lastname].element_attributes   
  end
  
  def test_frozen_value
    elem = ActiveForm::Element::Text.new :elem, :frozen => true, :value => "Freeze me!"
    assert elem.frozen?
    assert_equal "Freeze me!", elem.formatted_value
    elem.frozen_value = "I'm frozen now!"
    assert_equal "I'm frozen now!", elem.formatted_value
    assert_equal "I'm frozen now!", elem.to_html
    
    elem.frozen = false
    assert !elem.frozen?
    expected = %|<input class="elem_text" id="elem" name="elem" size="30" type="text" value="Freeze me!"/>\n|
    assert_equal expected, elem.to_html 
  end
  
  def test_freeze_filter
    elem = ActiveForm::Element::Text.new :elem, :frozen => true, :value => "Freeze me!"
    elem.freeze_filter = lambda { |value| value.to_s.upcase }
    assert elem.frozen?
    assert_equal "FREEZE ME!", elem.formatted_value
    elem.frozen_value = "I'm frozen now!"
    assert_equal "I'm frozen now!", elem.formatted_value
    elem.frozen = false
    assert_equal "Freeze me!", elem.formatted_value
  end
  
  def test_element_to_html
    elem = ActiveForm::Element::Text.new :elem
    expected = %|<input class="elem_text" id="elem" name="elem" size="30" type="text"/>\n|
    assert_equal expected, elem.to_html    
  end
  
  def test_element_with_attributes_to_html
    elem = ActiveForm::Element::Text.new :elem, :size => 20, :value => 'hello world'
    assert_equal 'hello world', elem.element_value
    elem.element_value = 'new value'
    assert_equal 'new value', elem.element_value
    expected = %|<input class="elem_text" id="elem" name="elem" size="20" type="text" value="new value"/>\n|
    assert_equal expected, elem.to_html
  end
  
  def test_element_with_casting_and_formatting_filters
    elem = ActiveForm::Element::Text.new :elem, :value => ['one', 'two', 'three'] # this is regarded as element_value
    elem.define_formatting_filter { |value| value.join(', ') }
    elem.define_casting_filter { |value| value.split(/,\s+/) }
    assert_equal ['one', 'two', 'three'], elem.element_value
    assert_equal 'one, two, three', elem.formatted_value
    expected = %|<input class="elem_text" id="elem" name="elem" size="30" type="text" value="one, two, three"/>\n|
    assert_equal expected, elem.to_html
    elem.value = 'a, b, c, d, e'
    assert_equal ['a', 'b', 'c', 'd', 'e'], elem.element_value    
    expected = %|<input class="elem_text" id="elem" name="elem" size="30" type="text" value="a, b, c, d, e"/>\n|
    assert_equal expected, elem.to_html
  end
  
  def test_export_value_for_grouped_elements
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a, :group => :grp
      f.text_element :elem_b, :group => :grp
      f.text_element :elem_c
    end
    form.update_values(:elem_a => 'One', :elem_b => 'Two')
    expected = { "elem_c" => nil, "grp" => ["One", "Two"] }
    assert_equal expected, form.export_values  
  end
  
end