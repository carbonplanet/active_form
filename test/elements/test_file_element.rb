require 'test_helper'

class TestFileElement < Test::Unit::TestCase
  
  def test_set_attributes
    [:title, :lang, :size, :accept].each do |attribute|
      assert ActiveForm::Element::File.element_attribute_names.include?(attribute)
    end 
    elem = ActiveForm::Element::File.new :elem, :size => 20, :accept => 'image/jpeg image/jpg image/png'
    expected = {"name"=>"elem", "class"=>"elem_file", "id"=>"elem", "size"=>20, "type"=>"file", "accept"=>"image/jpeg image/jpg image/png"}
    assert_equal expected, elem.element_attributes
  end
  
  def test_element_to_html
    elem = ActiveForm::Element::File.new :elem
    expected = %|<input class="elem_file" id="elem" name="elem" type="file"/>\n|
    assert_equal expected, elem.to_html    
  end
  
end