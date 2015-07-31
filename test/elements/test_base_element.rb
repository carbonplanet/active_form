require 'test_helper'

ActiveForm::Element::Base::create :sample_input do
 
  def render_element(builder = create_builder)
    builder.input(element_attributes)
    builder.input(element_attributes)
    builder.input(element_attributes)
  end
  
end

ActiveForm::Element::modify :sample_input do
  
  def render_element(builder = create_builder)
    builder.textarea(formatted_value, element_attributes)
  end
  
end

class TestBaseElement < Test::Unit::TestCase
  
  def test_standard_attributes
    assert ActiveForm::Element::Base.element_attribute_names.include?(:title)
    assert ActiveForm::Element::Base.element_attribute_names.include?(:lang)
    elem = ActiveForm::Element::Base.new :elem
    assert elem.respond_to?(:title=)
    assert elem.respond_to?(:style=)
    assert elem.respond_to?(:class=)
    assert elem.respond_to?(:lang=)
    assert_equal Hash.new, elem.attributes    
    expected = {"name"=>"elem", "class"=>"elem_base", "id"=>"elem"}
    assert_equal expected, elem.element_attributes
  end
  
  def test_set_standard_attributes
    elem = ActiveForm::Element::Base.new :elem, :title => 'My Element', :lang => 'nl-nl', :unknown => 'will be skipped'
    expected = {"title"=>"My Element", "lang"=>"nl-nl"}
    assert_equal expected, elem.attributes
    expected = {"name"=>"elem", "class"=>"elem_base", "title"=>"My Element", "id"=>"elem", "lang"=>"nl-nl"}
    assert_equal expected, elem.element_attributes
  end
  
  def test_set_custom_attributes
    elem = ActiveForm::Element::Base.new :elem, :unknown => 'will be skipped'
    expected = {}
    assert_equal expected, elem.attributes
    elem.attributes[:custom] = 'attribute'
    expected = {"custom"=>"attribute"}
    assert_equal expected, elem.attributes
  end
  
  def test_standard_option_flags
    elem = ActiveForm::Element::Base.new :elem
    [:frozen, :hidden, :disabled, :readonly, :required].each do |method|
      assert ActiveForm::Element::Base.element_option_flag_names.include?(method)
      assert elem.respond_to?("#{method}") 
      assert elem.respond_to?("#{method}=")
      assert elem.respond_to?("#{method}?")
    end
  end
  
  def test_option_flags_in_css_class
    elem = ActiveForm::Element::Base.new :elem, :frozen => true, :hidden => true, :disabled => true, :readonly => true, :required => true
    elem.css_class += "special"
    assert_equal "elem_base special", elem.css_class.to_s
    assert_equal "frozen hidden disabled readonly required", elem.runtime_css_class.to_s
    assert_equal "elem_base special frozen hidden disabled readonly required", elem.css
  end
  
  def test_option_flags_in_css_style
    elem = ActiveForm::Element::Base.new :elem, :frozen => true, :hidden => true, :disabled => true, :required => true
    assert_equal "", elem.css_style.to_s
    assert_equal "display: none", elem.style
    assert_equal elem.runtime_css_style.to_s, elem.style
  end
  
  def test_label_css
    elem = ActiveForm::Element::Base.new :elem, :hidden => true
    assert_equal "hidden", elem.label_css
    elem = ActiveForm::Element::Base.new :elem, :hidden => true, :required => true
    assert_equal "hidden required", elem.label_css
    [:frozen, :readonly, :disabled].each do |flag|
      elem = ActiveForm::Element::Base.new :elem, flag => true
      assert_equal "inactive", elem.label_css
    end
  end
  
  def test_frozen_flag_inheritance
    form = ActiveForm::compose :form
    elem = form.text_element :elem
    section = form.section :section, :frozen => true
    nested = section.text_element :nested
    assert !form.frozen?; assert !elem.frozen?; assert section.frozen?; assert nested.frozen?
    elem.frozen = true
    assert !form.frozen?; assert elem.frozen?;  assert section.frozen?; assert nested.frozen?
    elem.frozen = false
    assert !form.frozen?; assert !elem.frozen?; assert section.frozen?; assert nested.frozen?
    form.frozen = true
    assert form.frozen?;  assert elem.frozen?;  assert section.frozen?; assert nested.frozen?
  end
  
  def test_render_label
    elem = ActiveForm::Element::Base.new :elem, :label => 'My Element'
    assert elem.labelled?
    assert_equal %|<label for="elem">My Element</label>\n|, elem.render_label
    elem.hidden = true
    assert_equal %|<label class="hidden" for="elem">My Element</label>\n|, elem.render_label
    elem.hidden = false; elem.required = true; elem.frozen = true
    assert_equal %|<label class="inactive required" for="elem">My Element</label>\n|, elem.render_label
  end
  
  def test_frozen_element
    elem = ActiveForm::Element::Base.new :elem, :frozen => true
    assert elem.frozen?
    assert_equal "elem_base", elem.css_class.to_s
    assert_equal "frozen", elem.runtime_css_class.to_s
    assert_equal "elem_base frozen", elem.css
    assert_equal %|<label class="inactive" for="elem">Elem</label>\n|, elem.render_label 
    elem.frozen = false
    assert !elem.frozen?
    assert_equal "elem_base", elem.css
    assert_equal %|<label for="elem">Elem</label>\n|, elem.render_label
  end
  
  def test_render_input
    elem = ActiveForm::Element::Base.new :elem
    assert_equal elem.render_element, elem.render_input
    elem = ActiveForm::Element::Base.new :elem, :frozen => true
    assert elem.frozen?
    assert_equal elem.render_frozen, elem.render_input
  end
  
  def test_element_to_html
    elem = ActiveForm::Element::Base.new :elem
    expected = %|<span class="elem_base" id="elem">Elem</span>\n|
    assert_equal expected, elem.to_html    
  end
  
  def test_to_label
    elem = ActiveForm::Element::Base.new :elem, :label => 'My Element'
    assert_equal elem.render_label, elem.to_label
  end
  
  def test_to_input
    elem = ActiveForm::Element::Base.new :elem
    assert_equal elem.render_element, elem.to_input
    elem = ActiveForm::Element::Base.new :elem, :frozen => true
    assert elem.frozen?
    assert_equal elem.render_frozen, elem.to_input
  end
  
  def test_modified_element_class_definition
    elem = ActiveForm::Element::SampleInput.new :elem, :value => 'Some text...'
    expected = %|<textarea class="elem_sample_input" id="elem" name="elem">Some text...</textarea>\n|
    assert_equal expected, elem.to_html 
  end
  
end