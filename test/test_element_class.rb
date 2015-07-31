require 'test_helper'

ActiveForm::Element::create :simple_widget do
   
  def render_element(builder = create_builder)
    builder.h1(label, { :id => identifier, :class => css })
  end 
    
end

ActiveForm::Element::Input::create :special_widget do
  
  def default_attributes
    super.merge(:type => 'special')
  end 
  
end

class TestElementClass < Test::Unit::TestCase
  
  def test_create_element_class
    assert_equal ActiveForm::Element::SimpleWidget , ActiveForm::Element::get(:simple_widget)
    elem = ActiveForm::Element::build(:simple_widget, :easy)
    assert_kind_of ActiveForm::Element::SimpleWidget, elem
    assert_kind_of ActiveForm::Element::Base, elem
    expected= %|<h1 class=\"elem_simple_widget\" id=\"easy\">Easy</h1>\n|
    assert_equal expected, elem.to_html
  end
  
  def test_create_input_element_class
    assert_equal ActiveForm::Element::SpecialWidget, ActiveForm::Element::get(:special_widget)
    elem = ActiveForm::Element::build(:special_widget, :magic)
    assert_kind_of ActiveForm::Element::SpecialWidget, elem
    assert_kind_of ActiveForm::Element::Input, elem
    assert_kind_of ActiveForm::Element::Base, elem
    expected= %|<input class="elem_special_widget" id="magic" name="magic" type="special"/>\n|
    assert_equal expected, elem.to_html
  end
  
  def test_sample_element_attribute_names
    assert !ActiveForm::Element::Base.element_attribute_names.include?(:foo)
    assert !ActiveForm::Element::Base.element_attribute_names.include?(:bar)
    assert !ActiveForm::Element::Base.element_attribute_names.include?(:baz)    
    assert ActiveForm::Element::Sample.element_attribute_names.include?(:foo)
    assert ActiveForm::Element::Sample.element_attribute_names.include?(:bar)
    assert !ActiveForm::Element::Sample.element_attribute_names.include?(:baz)    
    assert ActiveForm::Element::ExtendedSample.element_attribute_names.include?(:foo)
    assert ActiveForm::Element::ExtendedSample.element_attribute_names.include?(:bar)
    assert ActiveForm::Element::ExtendedSample.element_attribute_names.include?(:baz)
  end
  
  def test_sample_attribute_methods
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:foo)
    assert ActiveForm::Element::Sample.new(:test).respond_to?(:foo)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:foo)
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:baz)
    assert !ActiveForm::Element::Sample.new(:test).respond_to?(:baz)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:baz)
    
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:foo=)
    assert ActiveForm::Element::Sample.new(:test).respond_to?(:foo=)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:foo=)
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:baz=)
    assert !ActiveForm::Element::Sample.new(:test).respond_to?(:baz=)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:baz=)
  end
  
  def test_sample_element_html_flag_names
    assert !ActiveForm::Element::Base.element_html_flag_names.include?(:flipped)
    assert !ActiveForm::Element::Base.element_html_flag_names.include?(:flopped)
    assert ActiveForm::Element::Sample.element_html_flag_names.include?(:flipped)
    assert !ActiveForm::Element::Sample.element_html_flag_names.include?(:flopped)
    assert ActiveForm::Element::ExtendedSample.element_html_flag_names.include?(:flipped)
    assert ActiveForm::Element::ExtendedSample.element_html_flag_names.include?(:flopped)
  end
  
  def test_sample_html_flag_methods
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:flipped)
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:flopped)
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:flipped=)
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:flopped=)
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:flipped?)
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:flopped?)    
    assert ActiveForm::Element::Sample.new(:test).respond_to?(:flipped)
    assert !ActiveForm::Element::Sample.new(:test).respond_to?(:flopped)
    assert ActiveForm::Element::Sample.new(:test).respond_to?(:flipped=)
    assert !ActiveForm::Element::Sample.new(:test).respond_to?(:flopped=)
    assert ActiveForm::Element::Sample.new(:test).respond_to?(:flipped?)
    assert !ActiveForm::Element::Sample.new(:test).respond_to?(:flopped?)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:flipped)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:flopped)  
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:flipped=)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:flopped=)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:flipped?)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:flopped?)  
  end
  
  def test_sample_option_flag_methods
    assert !ActiveForm::Element::Base.new(:test).respond_to?(:closed)
    assert ActiveForm::Element::Sample.new(:test).respond_to?(:closed)
    assert ActiveForm::Element::Sample.new(:test).respond_to?(:closed=)
    assert ActiveForm::Element::Sample.new(:test).respond_to?(:closed?)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:closed)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:closed=)
    assert ActiveForm::Element::ExtendedSample.new(:test).respond_to?(:closed?)
  end
  
  def test_attributes
    element = ActiveForm::Element::Sample.new(:test)
    element.foo = 'one'
    element.bar = 'two'
    assert_equal 'one', element.foo
    assert_equal 'two', element.bar    
  end
  
  def test_element_attributes
    element = ActiveForm::Element::ExtendedSample.new(:test)
    element.attributes[:custom] = 'special' #non-standard
    element.foo = 'one'
    element.flipped = true
    element.closed = true
    assert element.closed?
    expected = { "flipped"=>"flipped", "name"=>"test", "class"=>"elem_extended_sample", "foo"=>"one", "id"=>"test", "custom"=>"special" }
    assert_equal expected, element.element_attributes
  end
  
  def test_html_flags
    element = ActiveForm::Element::ExtendedSample.new(:test)
    element.flipped = true
    element.flopped = 'yes'
    assert element.flipped?
    assert element.flopped?
    element.flipped = false
    assert !element.flipped?
    assert !element.rotated?
    element.rotated = 'true'
    assert element.rotated?
  end
  
  def test_default_css_class
    assert_equal "active_form", ActiveForm::compose(:test).default_css_class
    assert_equal "elem_base", ActiveForm::Element::Base.new(:test).default_css_class
    assert_equal "active_section", ActiveForm::Element::Section.new(:test).default_css_class
  end
  
  def test_css_class_attribute
    element = ActiveForm::Element::ExtendedSample.new(:test)
    element.css_class = 'one two three'
    css_class_full = 'one two three elem_extended_sample'
    assert_equal ['one', 'two', 'three'], element.css_class
    assert_equal css_class_full, element.css
    assert_equal css_class_full, element.element_class
    element.css_class += 'four'
    assert_equal ['one', 'two', 'three', 'four'], element.css_class
    element.css_class -= 'two'
    assert_equal ['one', 'three', 'four'], element.css_class
    element.css_class << 'five six'
    assert_equal 'one three four five six', element.css_class.to_s
    element.css_class = 'seven'
    assert_equal 'seven', element.css_class.to_s
  end
  
  def test_css_style_attribute
    element = ActiveForm::Element::ExtendedSample.new(:test)
    element.css_style = 'background: red'
    assert_equal 'background: red', element.css_style.to_s
    assert_equal element.css_style.to_s, element.style
    element.css_style << 'padding: 20px'
    assert_equal 'background: red;padding: 20px', element.css_style.to_s
    element.css_style = nil
    assert_equal '', element.css_style.to_s
    element.css_style = ['color: blue', 'background: black']
    assert_equal 'color: blue;background: black', element.css_style.to_s
    element.css_style -= 'color: blue'
    assert_equal 'background: black', element.css_style.to_s
    assert_equal element.css_style.to_s, element.style
    assert_equal element.css_style.to_s, element.element_style
    expected = {"name"=>"test", "class"=>"elem_extended_sample", "id"=>"test", "style"=>"background: black"}
    assert_equal expected, element.element_attributes    
  end
  
  def test_skip_css_class
    element = ActiveForm::Element::ExtendedSample.new(:test)
    expected = {"name"=>"test", "class"=>"elem_extended_sample", "id"=>"test"}
    assert_equal expected, element.element_attributes
    element.skip_css_class = true
    expected = {"name"=>"test", "class"=>"elem_extended_sample", "id"=>"test"}
    assert_equal expected, element.element_attributes  
  end
  
  def test_skip_css_style
    element = ActiveForm::Element::ExtendedSample.new(:test)
    element.css_style = 'background: red'
    expected = {"name"=>"test", "class"=>"elem_extended_sample", "id"=>"test", "style"=>"background: red"}
    assert_equal expected, element.element_attributes
    element.skip_css_style = true
    expected = {"name"=>"test", "class"=>"elem_extended_sample", "id"=>"test"}
    assert_equal expected, element.element_attributes
  end
  
end