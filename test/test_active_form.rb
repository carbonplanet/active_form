require 'test_helper'

class TestActiveForm < Test::Unit::TestCase

  def test_common_stub_instance_methods
    assert ActiveForm::Definition.instance_methods.include?('to_html')
    assert ActiveForm::Element::Base.instance_methods.include?('to_html')   
    assert ActiveForm::Element::Section.instance_methods.include?('to_html')  
  end
  
  def test_element_module_loading
    assert ActiveForm::Element::load(:text)
    assert ActiveForm::Element::load(:section)
    assert_raises(ActiveForm::Element::NotFoundException) do
      ActiveForm::Element::load(:unknown)
    end 
    assert ActiveForm::Element::loaded?(:text)
    assert ActiveForm::Element::loaded?(:section)
    assert !ActiveForm::Element::loaded?(:unknown)
  end
  
  def test_element_module_create
    assert_kind_of ActiveForm::Element::Text, ActiveForm::Element::build(:text, :test_element)
    assert_kind_of ActiveForm::Element::Section, ActiveForm::Element::build(:section, :test_element)
    assert_nil ActiveForm::Element::build(:unknown, :test_element)
  end
  
  def test_element_module_type_existence
    assert ActiveForm::Element::exists?(:text)
    assert ActiveForm::Element::exists?(:section)
    assert !ActiveForm::Element::exists?(:unknown)
  end
  
  def test_is_element_by_module
    assert ActiveForm::Element::element?(ActiveForm::Element::Text)
    assert ActiveForm::Element::element?(ActiveForm::Element::Section)
    assert ActiveForm::Element::element?(ActiveForm::Definition)
    assert !ActiveForm::Element::element?(ActiveForm)
  end
  
  def test_is_element_by_class
    assert ActiveForm::Definition.element?
    assert ActiveForm::compose(:form).element?
    assert ActiveForm::Element::Base.element?
    assert ActiveForm::Element::Base.new(:element).element?
    assert ActiveForm::Element::Section.element?
    assert ActiveForm::Element::Section.new(:section).element?
  end
  
  def test_is_container
    assert ActiveForm::Definition.container?
    assert ActiveForm::compose(:test_form).container?
    assert !ActiveForm::Element::Base.container?
    assert !ActiveForm::Element::Base.new(:test_element).container?
    assert ActiveForm::Element::Section.container?
    assert ActiveForm::Element::Section.new(:test_group).container?
  end
  
  def test_element_name
    form = ActiveForm::compose :test_form
    assert_equal :test_form, form.name
    section = ActiveForm::Element::Section.new :test_group
    assert_equal :test_group, section.name
    elem = ActiveForm::Element::Base.new :test_element
    assert_equal :test_element, elem.name    
  end
  
  def test_element_type
    form = ActiveForm::compose :test_form
    assert_equal :form, form.element_type
    section = ActiveForm::Element::Section.new :test_group
    assert_equal :section, section.element_type
    elem = ActiveForm::Element::Base.new :test_element
    assert_equal :base, elem.element_type 
    elem = ActiveForm::Element::Text.new :test_element
    assert_equal :text, elem.element_type
  end
  
  def test_container_reference
    form = ActiveForm::compose :test_form
    assert_equal nil, form.container
    assert !form.contained?
    elem = ActiveForm::Element::Base.new form, :element
    assert_equal form, elem.container
    assert elem.contained?
    section = ActiveForm::Element::Section.new form, :element
    assert_equal form, section.container
    assert section.contained?
  end
  
  def test_standalone_identifier
    form = ActiveForm::compose :test_form
    assert_equal "test_form", form.identifier
    section = ActiveForm::Element::Section.new :test_section
    assert_equal "test_section", section.identifier
    elem = ActiveForm::Element::Base.new :test_element
    assert_equal "test_element", elem.identifier    
  end
  
  def test_nested_identifier
    form = ActiveForm::compose :form
    assert_equal "form", form.identifier
    section = ActiveForm::Element::Section.new(form, :section)
    assert_equal "form_section", section.identifier
    elem = ActiveForm::Element::Base.new(form, :element)
    assert_equal "form_element", elem.identifier   
  end
  
  def test_nested_section_identifier
    form = ActiveForm::compose :form
    assert_equal "form", form.identifier
    section = ActiveForm::Element::Section.new(form, :section_a)
    assert_equal "form_section_a", section.identifier
    elem_a = ActiveForm::Element::Base.new(section, :element_a)
    assert_equal "form_section_a_element_a", elem_a.identifier
    elem_b = ActiveForm::Element::Base.new(section, :element_b)
    assert_equal "form_section_a_element_b", elem_b.identifier
  end
  
  def test_nested_definition_identifier
    form_a = ActiveForm::compose :form_a
    assert_equal "form_a", form_a.identifier
    form_b = ActiveForm::compose form_a, :form_b
    assert_equal "form_a_form_b", form_b.identifier
    form_c = ActiveForm::compose form_b, :form_c
    assert_equal "form_a_form_b_form_c", form_c.identifier
    elem = ActiveForm::Element::Base.new(form_c, :element)
    assert_equal "form_a_form_b_form_c_element", elem.identifier
  end
  
  def test_nested_section_identifier
    form = ActiveForm::compose :form
    assert_equal "form", form.identifier
    section_a = ActiveForm::Element::Section.new(form, :section_a)
    assert_equal "form_section_a", section_a.identifier
    section_b = ActiveForm::Element::Section.new(section_a, :section_b)
    assert_equal "form_section_a_section_b", section_b.identifier
    section_c = ActiveForm::Element::Section.new(section_b, :section_c)
    assert_equal "form_section_a_section_b_section_c", section_c.identifier
    elem = ActiveForm::Element::Base.new(section_c, :element)
    assert_equal "form_section_a_section_b_section_c_element", elem.identifier
  end
  
  def test_nested_section_name
    form = ActiveForm::compose :form
    assert_equal "form", form.element_name
    section = ActiveForm::Element::Section.new(form, :section_a)
    assert_equal "form[section_a]", section.element_name
    elem_a = ActiveForm::Element::Base.new(section, :element_a)
    assert_equal "form[section_a][element_a]", elem_a.element_name
    elem_b = ActiveForm::Element::Base.new(section, :element_b)
    assert_equal "form[section_a][element_b]", elem_b.element_name
  end
  
  def test_nested_definition_name
    form_a = ActiveForm::compose :form_a
    assert_equal "form_a", form_a.element_name
    form_b = ActiveForm::compose form_a, :form_b
    assert_equal "form_a[form_b]", form_b.element_name
    form_c = ActiveForm::compose form_b, :form_c
    assert_equal "form_a[form_b][form_c]", form_c.element_name
    elem = ActiveForm::Element::Base.new(form_c, :element)
    assert_equal "form_a[form_b][form_c][element]", elem.element_name
  end
  
  def test_nested_section_name
    form = ActiveForm::compose :form
    assert_equal "form", form.element_name
    section_a = ActiveForm::Element::Section.new(form, :section_a)
    assert_equal "form[section_a]", section_a.element_name
    section_b = ActiveForm::Element::Section.new(section_a, :section_b)
    assert_equal "form[section_a][section_b]", section_b.element_name
    section_c = ActiveForm::Element::Section.new(section_b, :section_c)
    assert_equal "form[section_a][section_b][section_c]", section_c.element_name
    elem = ActiveForm::Element::Base.new(section_c, :element)
    assert_equal "form[section_a][section_b][section_c][element]", elem.element_name
  end
  
  def test_default_element_label
    form = ActiveForm::compose :form do |f|
      f.text_element :element_a
      f.text_element :element_b, :label => 'B-label'
      f.text_element :element_c
      f.section :section_a do |s|
        s.text_element :element_d
        s.text_element :element_e
      end
    end
    assert_equal 'Element A', form[:element_a].label
    assert_equal 'B-label', form[:element_b].label
    assert_equal 'Element D', form[:section_a][:element_d].label
    assert_equal 'form[section_a][element_d]', form[:section_a][:element_d].element_name
  end
  
  def test_set_elements
    elem_a = ActiveForm::Element::build(:text, :element_a)
    elem_b = ActiveForm::Element::build(:text, :element_b)
    elem_c = ActiveForm::Element::build(:text, :element_c)
    form = ActiveForm::compose :form
    form.elements = [elem_a, elem_b, elem_c]
    assert_equal [:element_a, :element_b, :element_c], form.element_names
  end
  
  def test_insert_one_loose_element
    form = ActiveForm::compose :form
    elem_a = ActiveForm::Element::build(:text, :element_a)
    assert form.insert_element(elem_a)
    elem_b = ActiveForm::Element::build(:text, :element_b)
    assert form.insert_element(elem_b)
    assert_equal [:element_a, :element_b], form.element_names
    elem_c = ActiveForm::Element::build(:text, :element_c)
    elem_d = ActiveForm::Element::build(:text, :element_d)
    assert form << elem_c << elem_d
    assert_equal [:element_a, :element_b, :element_c, :element_d], form.element_names
  end
  
  def test_insert_multiple_loose_elements
    elem_a = ActiveForm::Element::build(:text, :element_a)
    elem_b = ActiveForm::Element::build(:text, :element_b)
    elem_c = ActiveForm::Element::build(:text, :element_c)
    form = ActiveForm::compose :form
    form.insert_elements(elem_a, elem_b, elem_c)    
    assert_equal [:element_a, :element_b, :element_c], form.element_names
    form = ActiveForm::compose :form
    form.insert_elements([elem_a, elem_b, elem_c])    
    assert_equal [:element_a, :element_b, :element_c], form.element_names
  end
  
  def test_insert_one_element_at
    elem_a = ActiveForm::Element::build(:text, :element_a)
    elem_b = ActiveForm::Element::build(:text, :element_b)
    elem_c = ActiveForm::Element::build(:text, :element_c)
    elem_d = ActiveForm::Element::build(:text, :element_d)
    form = ActiveForm::compose :form
    form.insert_element(elem_a, 0)
    form.insert_element(elem_b, 0)
    form.insert_element(elem_c, 0)
    assert_equal [:element_c, :element_b, :element_a], form.element_names
    form = ActiveForm::compose :form
    form.insert_element(elem_a)
    form.insert_element(elem_b)
    form.insert_element(elem_c, 0)
    assert_equal [:element_c, :element_a, :element_b], form.element_names
    form.insert_element(elem_d, 2)
    assert_equal [:element_c, :element_a, :element_d, :element_b], form.element_names
  end
  
  def test_insert_multiple_elements_at
    elem_a = ActiveForm::Element::build(:text, :element_a)
    elem_b = ActiveForm::Element::build(:text, :element_b)
    elem_c = ActiveForm::Element::build(:text, :element_c)
    elem_d = ActiveForm::Element::build(:text, :element_d)
    form = ActiveForm::compose :form
    form.insert_elements(elem_a, elem_b)
    form.insert_elements(elem_c, elem_d, 1)
    assert_equal [:element_a, :element_c, :element_d, :element_b], form.element_names
  end
  
  # define element methods:
  
  def test_define_element
    form = ActiveForm::compose :form
    assert form.define_element(:text, :element_a)
    assert_equal 1, form.elements.length
    assert_equal :element_a, form.elements.last.name
    assert form.element_names.include?(:element_a)
    assert form.define_element(:text, :element_b)
    assert_equal 2, form.elements.length
    assert_equal :element_b, form.elements.last.name
    assert form.element_names.include?(:element_b)    
  end
  
  def test_define_element_at
    form = ActiveForm::compose :form
    assert form.define_element_at(0, :text, :element_a)
    assert form.define_element_at(0, :text, :element_b)
    assert form.define_element_at(1, :text, :element_c)
    assert form.define_element_at(2, :text, :element_d)
    assert_equal [:element_b, :element_c, :element_d, :element_a], form.element_names
  end
  
  def test_define_element_at_top
    form = ActiveForm::compose :form
    assert form.define_element_at_top(:text, :element_a)
    assert form.define_element_at_top(:text, :element_b)
    assert form.define_element_at_top(:text, :element_c)
    assert_equal [:element_c, :element_b, :element_a], form.element_names
  end
  
  def test_define_element_at_bottom
    form = ActiveForm::compose :form
    assert form.define_element_at_bottom(:text, :element_a)
    assert form.define_element_at_bottom(:text, :element_b)
    assert form.define_element_at_bottom(:text, :element_c)
    assert_equal [:element_a, :element_b, :element_c], form.element_names
  end
  
  def test_define_element_using_syntactic_sugar
    form = ActiveForm::compose :form
    form.text_element     :element_a, :label => 'a text element'
    form.hidden_element   :element_b, :label => 'a hidden element'
    form.password_element :element_c, :label => 'a password element'
    assert_equal [:element_a, :element_b, :element_c], form.elements.collect(&:name)
    assert_equal [:text, :hidden, :password], form.elements.collect(&:element_type)
    assert_equal ['a text element', 'a hidden element', 'a password element'], form.elements.collect(&:label)
  end
  
  def test_define_element_initialize_with_options_and_attributes
    form = ActiveForm::compose :form
    form.text_element :element_a, :label => 'test label', :css_style => 'color: red', :css_class => 'special'
    assert_equal 'test label', form.elements.first.label
    assert_equal 'color: red', form.elements.first.css_style.to_s
    assert_equal 'special', form.elements.first.css_class.to_s
  end  
  
  def test_define_element_with_block
   form = ActiveForm::compose :form
    form.define_element :text, :element_a do |e|
      e.css_class << 'special'
      e.css_style = 'color: red'
    end
    expected = { "type" => "text", "name"=>"form[element_a]", "class"=>"elem_text special", "id"=>"form_element_a", "style"=>"color: red", "value"=>"", "size"=>30 }
    assert_equal expected, form[:element_a].element_attributes
  end
  
  def test_update_attributes_and_options_on_sample_element
    form = ActiveForm::compose :form
    elem = form.extended_sample_element :element_a, :label => 'test label', :css_style => 'color: red', :css_class => 'special', :flipped => true
    assert elem.flipped?
    assert_equal 'test label', form.elements.first.label
    assert_equal 'special', form.elements.first.css_class.to_s
    elem.update :label => 'changed label', :css_class => 'other', :flipped => false, :flopped => true
    assert !elem.flipped?
    assert elem.flopped?
    assert_equal 'changed label', form.elements.first.label
    assert_equal 'other', form.elements.first.css_class.to_s
  end
  
  def test_update_attributes_and_options_on_text_element
    form = ActiveForm::compose :form
    elem = form.text_element :element_a, :label => 'test label', :css_style => 'color: red', :css_class => 'special'
    assert_equal 'test label', form.elements.first.label
    assert_equal 'special', form.elements.first.css_class.to_s
    elem.update :label => 'changed label', :css_class => 'other'
    assert_equal 'changed label', form.elements.first.label
    assert_equal 'other', form.elements.first.css_class.to_s
  end
  
  def test_update_all_elements
    form = ActiveForm::compose :form do |f|
      f.text_element :element_a, :label => 'one',   :description => 'this is the first'
      f.text_element :element_b, :label => 'two',   :description => 'this is the second'
      f.text_element :element_c, :label => 'three', :description => 'this is the third'
    end
    assert_equal ['one', 'two', 'three'], form.elements.collect(&:label)
    assert_equal ['this is the first', 'this is the second', 'this is the third'], form.elements.collect(&:description)
    form.update_elements(:description => nil)
    assert_equal [nil, nil, nil], form.elements.collect(&:description)
    form.update_elements(:label => 'new', :css_class => 'marked')
    assert_equal ['new', 'new', 'new'], form.elements.collect(&:label)
    assert_equal ['marked', 'marked', 'marked'], form.elements.collect { |e| e.css_class.to_s }
  end
  
  def test_update_some_elements
    form = ActiveForm::compose :form do |f|
      f.text_element :element_a, :label => 'one'
      f.text_element :element_b, :label => 'two'  
      f.text_element :element_c, :label => 'three'
    end
    assert_equal ['one', 'two', 'three'], form.elements.collect(&:label)
    form.update_elements(:element_a, :element_c, :label => 'new')
    assert_equal ['new', 'two', 'new'], form.elements.collect(&:label)
    form.update_elements(:element_b, :element_c, :css_class => 'marked')
    assert_equal ['elem_text', 'marked', 'marked'], form.elements.collect { |e| e.css_class.to_s }
  end
  
  def test_index_of_element
    form = ActiveForm::compose :form
    form.define_element(:text, :element_a)
    form.define_element(:text, :element_b)
    form.define_element(:text, :element_c)
    assert_equal 0, form.index_of_element(:element_a)
    assert_equal 1, form.index_of_element(:element_b)
    assert_equal 2, form.index_of_element(:element_c)
  end
  
  def test_get_element_by_index
    form = ActiveForm::compose :form
    elem_a = form.define_element(:text, :element_a)
    elem_b = form.define_element(:text, :element_b)
    elem_c = form.define_element(:text, :element_c)
    assert_equal elem_a, form.get_element_by_index(0)
    assert_equal elem_b, form.get_element_by_index(1)
    assert_equal elem_c, form.get_element_by_index(2)
  end
  
  def test_if_container_element_exists
    form = ActiveForm::compose :form
    form.define_element(:text, :element_a)
    form.define_element(:text, :element_b)
    assert form.element_exists?(:element_a)
    assert form.element_exists?(:element_b)
    assert !form.element_exists?(:unknown)
  end
  
  def test_reset_elements
    form = ActiveForm::compose :form
    form.define_element(:text, :element_a)
    form.define_element(:text, :element_b)
    assert_equal [:element_a, :element_b], form.element_names
    assert_equal 2, form.elements.length
    assert_equal 2, form.name_to_index_lookup.length
    form.reset_elements!
    assert_equal [], form.element_names
    assert_equal 0, form.elements.length
    assert_equal 0, form.name_to_index_lookup.length
  end
  
  def test_name_to_index_lookup_assignment_fails
    form = ActiveForm::compose :form
    assert_raises(NoMethodError) { form.name_to_index_lookup = Hash.new }
  end
  
  def test_container_set_and_replace_element
    form = ActiveForm::compose :form
    elem_a = form.define_element(:text, :element_a)
    elem_b = form.define_element(:text, :element_b)
    assert_equal [elem_a, elem_b], form.elements
    good_replacement = ActiveForm::Element::build(:section, :element_b)
    assert form.set_element(:element_b, good_replacement)
    assert_equal [elem_a, good_replacement], form.elements
    new_replacement = ActiveForm::Element::build(:text, :element_a)
    form[:element_a] = new_replacement
    assert_equal [new_replacement, good_replacement], form.elements 
    bad_replacement = ActiveForm::Element::build(:section, :element_c)
    assert_raises(ActiveForm::Element::MismatchException) { form.set_element(:element_b, bad_replacement) }  
  end
  
  def test_container_get_element
    form = ActiveForm::compose :form
    elem_a = form.define_element(:text, :element_a)
    elem_b = form.define_element(:text, :element_b)
    elem_c = form.define_element(:text, :element_c)
    assert_equal elem_a, form.get_element(:element_a)
    assert_equal elem_b, form.get_element(:element_b)
    assert_equal elem_c, form.get_element(:element_c)
  end
  
  def test_container_get_element_with_hash_syntax
    form = ActiveForm::compose :form
    elem_a = form.define_element(:text, :element_a)
    elem_b = form.define_element(:text, :element_b)
    elem_c = form.define_element(:text, :element_c)
    assert_equal elem_a, form[:element_a]
    assert_equal elem_b, form[:element_b]
    assert_equal elem_c, form[:element_c]
  end
  
  def test_container_get_element_at
    form = ActiveForm::compose :form
    elem_a = form.define_element(:text, :element_a)
    elem_b = form.define_element(:text, :element_b)
    elem_c = form.define_element(:text, :element_c)
    assert_equal elem_a, form.element_at(0)
    assert_equal elem_b, form.element_at(1)
    assert_equal elem_c, form.element_at(2)
  end
  
  def test_container_remove_element
    form = ActiveForm::compose :form do |f|
      f.define_element(:text, :element_a)
      f.define_element(:text, :element_b)
      f.define_element(:text, :element_c)
      f.define_element(:text, :element_d)
    end
    assert_equal [:element_a, :element_b, :element_c, :element_d], form.collect(&:name)
    expected = {:element_a=>0, :element_c=>2, :element_b=>1, :element_d=>3}
    assert_equal expected, form.name_to_index_lookup
    assert form.remove_element(:element_b)
    assert_equal [:element_a, :element_c, :element_d], form.collect(&:name)
    expected = {:element_a=>0, :element_c=>1, :element_d=>2}
    assert form.remove_elements(:element_a, :element_d)
    assert_equal [:element_c], form.collect(&:name)
    expected = {:element_c=>0}
  end
  
  def test_container_remove_element_at
    form = ActiveForm::compose :form do |f|
      f.define_element(:text, :element_a)
      f.define_element(:text, :element_b)
      f.define_element(:text, :element_c)
      f.define_element(:text, :element_d)
    end
    assert_equal [:element_a, :element_b, :element_c, :element_d], form.collect(&:name)
    expected = {:element_a=>0, :element_c=>2, :element_b=>1, :element_d=>3}
    assert_equal expected, form.name_to_index_lookup
    assert form.remove_element_at(1)
    assert_equal [:element_a, :element_c, :element_d], form.collect(&:name)
    expected = {:element_a=>0, :element_c=>1, :element_d=>2}
    assert form.remove_elements_at(0, 2)
    assert_equal [:element_c], form.collect(&:name)
    expected = {:element_c=>0}
  end
  
  def test_container_remove_elements_of_type
    form = ActiveForm::compose :form do |f|
      f.define_element(:text, :element_a)
      f.define_element(:password, :element_b)
      f.define_element(:textarea, :element_c)
      f.define_element(:submit, :element_d)
    end
    assert_equal [:element_a, :element_b, :element_c, :element_d], form.collect(&:name)
    form.remove_elements_of_type(:text)
    assert_equal [:element_b, :element_c, :element_d], form.collect(&:name)
    form.remove_elements_of_type(:submit, :textarea)
    assert_equal [:element_b], form.collect(&:name)
  end
  
  # value handling
    
  def test_unbound_element_value
    elem = ActiveForm::Element::build(:text, :elem_a) 
    elem.element_value = 'one'
    assert_equal 'one', elem.element_value    
  end 
  
  def test_bound_element_value
    form = ActiveForm::compose :form
    elem = form.text_element :elem_a
    expected = {"elem_a"=>nil}
    assert_equal expected, form.values
    elem.element_value = 'value'
    expected = { "elem_a" => 'value' }
    assert_equal expected, form.values
    form.values[:elem_a] = 'changed'
    assert_equal 'changed', elem.element_value
  end
    
  def test_assign_values
    values = { :elem_b => "two", :elem_a => "one" }
    form = ActiveForm::compose :form, :values => values do |f|
      f.text_element :elem_a
      f.text_element :elem_b
    end
    assert_equal 'one', form[:elem_a].element_value
    assert_equal 'two', form[:elem_b].element_value
    
    form[:elem_a].element_value = 'new'
    assert_equal 'new', form[:elem_a].element_value
    values[:elem_b] = 'other'
    assert_equal 'other', form[:elem_b].element_value
    form[:elem_b].element_value = 'changed'
    assert_equal 'changed', values[:elem_b]
  end
  
  # formatting and casting
  
  def test_define_formatting_filter
    filter = lambda { |value| value.join(' ') }
    elem = ActiveForm::Element::build :text, :elem_a, :formatting_filter => filter
    assert_equal 'a b c', elem.formatting_filter(['a', 'b', 'c'])
    elem = ActiveForm::Element::build :text, :elem_a do |e|
      filter = e.define_formatting_filter { |value| value.join('-') }
    end
    assert_equal 'a-b-c', elem.formatting_filter(['a', 'b', 'c'])
  end  
  
  def test_define_casting_filter
    filter = lambda { |value| value.split(' ') }
    elem = ActiveForm::Element::build :text, :elem_a, :casting_filter => filter
    assert_equal ['a', 'b', 'c'], elem.casting_filter('a b c')
    elem = ActiveForm::Element::build :text, :elem_a do |e|
      filter = e.define_casting_filter { |value| value.split('-') }
    end
    assert_equal ['a', 'b', 'c'], elem.casting_filter('a-b-c')
  end
  
  def test_internal_element_value
    form = ActiveForm::compose :contact_form do |f|       
      f.text_element :firstname, :value => %w{ F r e d } do |e|
        e.define_formatting_filter { |value| value.join }
        e.define_casting_filter { |value| value.split('') }
      end
      f.text_element :lastname, :value => 'flintstone' do |e|
        e.define_formatting_filter { |value| value.upcase }
        e.define_casting_filter { |value| value.downcase }
      end
    end
    assert_equal ["F", "r", "e", "d"], form[:firstname].element_value
    assert_equal 'Fred', form[:firstname].formatted_value
    form[:firstname].value = 'Barney'
    assert_equal ["B", "a", "r", "n", "e", "y"], form[:firstname].element_value
    assert_equal 'Barney', form[:firstname].formatted_value
    
    assert_equal 'flintstone', form[:lastname].element_value
    assert_equal 'FLINTSTONE', form[:lastname].formatted_value    
    form[:lastname].value = 'RUBBLE'    
    assert_equal 'rubble', form[:lastname].element_value
    assert_equal 'RUBBLE', form[:lastname].formatted_value
  end
     
  def test_nested_value_assignment 
    values = ActiveForm::Values.new
    values[:section_a] = {}
    values[:section_a][:section_b] = {}
    values[:section_a][:section_b][:section_c] = {}
    values[:section_a][:section_b][:section_c][:element] = 'test value'
    
    form = ActiveForm::compose :form, :values => values do |f|
      f.section :section_a do |ga|
        ga.section :section_b do |gb|
          gb.section :section_c do |gc|
            elem = gc.text_element :element
          end
        end
      end
    end
    
    assert_equal :element, form[:section_a][:section_b][:section_c][:element].name
    assert_equal :section_c, form[:section_a][:section_b][:section_c].name
    assert_equal :section_b, form[:section_a][:section_b].name
    assert_equal :section_a, form[:section_a].name
    
    assert_equal values[:section_a][:section_b][:section_c][:element], form[:section_a][:section_b][:section_c][:element].element_value
    assert_equal values[:section_a][:section_b][:section_c], form[:section_a][:section_b][:section_c].element_value
    assert_equal values[:section_a][:section_b], form[:section_a][:section_b].element_value
    assert_equal values[:section_a], form[:section_a].element_value
    assert_equal values, form.element_value
    
    assert_equal values[:section_a][:section_b][:section_c][:element], form[:section_a][:section_b][:section_c][:element].values
    assert_equal values[:section_a][:section_b][:section_c], form[:section_a][:section_b][:section_c].values
    assert_equal values[:section_a][:section_b], form[:section_a][:section_b].values
    assert_equal values[:section_a], form[:section_a].values
    assert_equal values, form.values
    
    values[:section_a][:section_b][:section_c][:element] = 'changed value'    
    assert_equal 'changed value', form[:section_a][:section_b][:section_c][:element].element_value
    expected = { "element" => "changed value" }
    assert_equal expected, form[:section_a][:section_b][:section_c].element_value
    
    form[:section_a][:section_b][:section_c][:element].element_value = 'new value'   
    assert_equal 'new value', form[:section_a][:section_b][:section_c][:element].element_value
    assert_equal 'new value', values[:section_a][:section_b][:section_c][:element]
    expected = { "element" => "new value" }
    assert_equal expected, form[:section_a][:section_b][:section_c].element_value
    
    new_values = { "section_c" => { "element" => "other value" } }  
    form[:section_a][:section_b].update_values(new_values)
    assert_equal new_values, form[:section_a][:section_b].values    
    assert_equal "other value", form[:section_a][:section_b][:section_c][:element].element_value    
    
    new_values = ActiveForm::Values.new
    new_values[:section_a] = {}
    new_values[:section_a][:section_b] = {}
    new_values[:section_a][:section_b][:section_c] = {}
    new_values[:section_a][:section_b][:section_c][:element] = 'updated value'
    
    form.update_values(new_values)    
    assert_equal values[:section_a][:section_b][:section_c][:element], form[:section_a][:section_b][:section_c][:element].element_value
        
    form.update_values({}, true)  
    assert_equal nil, form[:section_a][:section_b][:section_c][:element].element_value
    expected = { "element" => nil }  
    assert_equal expected, form[:section_a][:section_b][:section_c].element_value
    expected = { "section_c"=> { "element" => nil } }
    assert_equal expected , form[:section_a][:section_b].element_value
    expected = { "section_b" => { "section_c"=> { "element" => nil } } }
    assert_equal expected, form[:section_a].element_value 
    expected = { "section_a" => { "section_b" => { "section_c"=> { "element" => nil } } } }
    assert_equal expected, form.element_value
    
    new_values = { "section_c" => { "element" => "other value" } } 
    form[:section_a][:section_b].update_values(new_values)  
    assert_equal new_values, form[:section_a][:section_b].values    
    assert_equal "other value", form[:section_a][:section_b][:section_c][:element].element_value  
  end
    
  def test_more_nested_tests_one
    
    values = ActiveForm::Values.new
    
    form = ActiveForm::compose :form, :values => values do |f|
      f.section :section_a do |ga|
        ga.section :section_b do |gb|
          gb.section :section_c do |gc|
            gc.text_element :element do |e|
              e.define_formatting_filter { |value| value.join }
              e.define_casting_filter { |value| value.is_a?(Array) ? value : value.split('') }
            end
          end
        end
      end
    end
    
    params = Hash.new
    params[:form] = {}
    params[:form][:section_a] = {}
    params[:form][:section_a][:section_b] = {}
    params[:form][:section_a][:section_b][:section_c] = {}
    params[:form][:section_a][:section_b][:section_c][:element] = 'Fred'
    
    form[:section_a][:section_b][:section_c][:element].element_value = ["B", "a", "r", "n", "e", "y"] 
    
    assert_equal ["B", "a", "r", "n", "e", "y"], form[:section_a][:section_b][:section_c][:element].element_value    
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>["B", "a", "r", "n", "e", "y"]}}}}   
    assert_equal expected, form.values 
    
    form.update_from_params(params)
    
    assert_equal ["F", "r", "e", "d"], form[:section_a][:section_b][:section_c][:element].element_value 
    assert_equal 'Fred', form[:section_a][:section_b][:section_c][:element].formatted_value
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>["F", "r", "e", "d"]}}}}
    assert_equal expected, form.values  
           
    form[:section_a][:section_b][:section_c][:element].element_value = ["B", "a", "r", "n", "e", "y"]
    
    assert_equal ["B", "a", "r", "n", "e", "y"], form[:section_a][:section_b][:section_c][:element].element_value 
    assert_equal 'Barney', form[:section_a][:section_b][:section_c][:element].formatted_value
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>["B", "a", "r", "n", "e", "y"]}}}}
    assert_equal expected, form.values
    
    params[:form][:section_a][:section_b][:section_c][:element] = 'Betty'    
    form.update_from_params(params)
    
    assert_equal ["B", "e", "t", "t", "y"], form[:section_a][:section_b][:section_c][:element].element_value 
    assert_equal 'Betty', form[:section_a][:section_b][:section_c][:element].formatted_value 
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>["B", "e", "t", "t", "y"]}}}}
    assert_equal expected, form.values
    
    form[:section_a][:section_b][:section_c][:element].element_value = 'Wilma'
    
    assert_equal ["W", "i", "l", "m", "a"], form[:section_a][:section_b][:section_c][:element].element_value
    assert_equal 'Wilma', form[:section_a][:section_b][:section_c][:element].formatted_value  
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>["W", "i", "l", "m", "a"]}}}}
    assert_equal expected, form.values
    
    form[:section_a][:section_b][:section_c][:element].element_value =  ['P', 'e', 'b', 'b', 'l', 'e', 's']
    
    ref = form[:section_a][:section_b][:section_c][:element]
    
    assert_equal ['P', 'e', 'b', 'b', 'l', 'e', 's'], form[:section_a][:section_b][:section_c][:element].element_value
    assert_equal 'Pebbles', form[:section_a][:section_b][:section_c][:element].formatted_value  
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>['P', 'e', 'b', 'b', 'l', 'e', 's']}}}}
    assert_equal ['P', 'e', 'b', 'b', 'l', 'e', 's'], ref.element_value
    assert_equal expected, form.values
    
    form.params = {"form"=>{"section_a"=>{"section_b"=>{"section_c"=>{"element"=>'Other'}}}}}
    assert_equal 'Other', form[:section_a][:section_b][:section_c][:element].formatted_value
    assert_equal ["O", "t", "h", "e", "r"], form[:section_a][:section_b][:section_c][:element].element_value
    assert_equal ["O", "t", "h", "e", "r"], ref.element_value
  end  
  
  def test_more_nested_tests
    
    values = ActiveForm::Values.new
    
    form = ActiveForm::compose :form, :values => values do |f|
      f.section :section_a do |ga|
        ga.section :section_b do |gb|
          gb.section :section_c do |gc|
            gc.text_element :element do |e|
              e.define_formatting_filter { |value| value.to_s }
              e.define_casting_filter { |value| value.to_i }
            end
          end
        end
      end
    end
    
    params = Hash.new
    params[:form] = {}
    params[:form][:section_a] = {}
    params[:form][:section_a][:section_b] = {}
    params[:form][:section_a][:section_b][:section_c] = {}
    params[:form][:section_a][:section_b][:section_c][:element] = '123'
    
    form[:section_a][:section_b][:section_c][:element].element_value = 456
    
    assert_equal 456, form[:section_a][:section_b][:section_c][:element].element_value 
    assert_equal '456', form[:section_a][:section_b][:section_c][:element].formatted_value    
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>456}}}}   
    assert_equal expected, form.values 
    
    form.update_from_params(params)
    
    assert_equal 123, form[:section_a][:section_b][:section_c][:element].element_value 
    assert_equal '123', form[:section_a][:section_b][:section_c][:element].formatted_value 
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>123}}}}
    assert_equal expected, form.values  
          
    form[:section_a][:section_b][:section_c][:element].element_value = '456'

    expected = {"section_b"=>{"section_c"=>{"element"=>456}}}
    assert_equal expected, form[:section_a].element_value
        
    assert_equal 456, form[:section_a][:section_b][:section_c][:element].element_value  
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>456}}}}
    assert_equal expected, form.values
    
    params[:form][:section_a][:section_b][:section_c][:element] = '789'      
    form.update_from_params(params)
   
    assert_equal 789, form[:section_a][:section_b][:section_c][:element].element_value  
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>789}}}}
    assert_equal expected, form.values
    
    form[:section_a][:section_b][:section_c][:element].element_value = '007'
    
    assert_equal 7, form[:section_a][:section_b][:section_c][:element].element_value  
    expected = {"section_a"=>{"section_b"=>{"section_c"=>{"element"=>7}}}}
    assert_equal expected, form.values  
  end
  
  def test_custom_value_object
    obj = CustomValueObject.new  
    form = ActiveForm::compose :form, :binding => obj do |f|
      f.text_element :name
      f.text_element :city
    end
    
    obj.value['name'] = 'Fred Flintstone'
    obj.value['city'] = 'Bedrock'
    
    assert_equal 'Fred Flintstone', form[:name].element_value
    assert_equal 'Bedrock', form[:city].element_value
    
    form[:city].element_value = 'Yellowstone'    
    assert_equal 'Yellowstone', form[:city].element_value
    assert_equal 'Yellowstone', obj.value['city']
    
    form.params = { "form" => { "city" => "Bricktown" } }
    assert_equal 'Bricktown', form[:city].element_value
    assert_equal 'Bricktown', obj.value['city']    
  end
  
  def test_custom_value_object_binding
    form = ActiveForm::compose :form do |f|
      f.text_element :name
      f.text_element :city
    end
  
    obj = form.bind_to(CustomValueObject.new)   
    form.params = { "form" => { "name" => "Fred Flintstone", "city" => "Bricktown" } }
    
    assert_equal 'Fred Flintstone', form[:name].element_value
    assert_equal 'Fred Flintstone', obj.value['name'] 
    assert_equal 'Bricktown', form[:city].element_value
    assert_equal 'Bricktown', obj.value['city']    
  end
  
  def test_default_fallback_value
    form = ActiveForm::compose :form do |f|
      f.text_element :name, :default => 'anonymous'
      f.text_element :language, :default => 'EN', :value => 'NL'
    end
    assert_equal nil, form[:name].value
    assert_equal 'anonymous', form[:name].fallback_value
    assert_equal 'anonymous', form[:name].export_value
    assert_equal 'NL', form[:language].value
    assert_equal 'EN', form[:language].fallback_value
    assert_equal 'NL', form[:language].export_value
    form[:language].value = nil
    assert_equal nil, form[:language].value
    assert_equal 'EN', form[:language].fallback_value
    assert_equal 'EN', form[:language].export_value
    form[:language].value = "   "
    assert_equal '   ', form[:language].value
    assert_equal 'EN', form[:language].fallback_value
    assert_equal 'EN', form[:language].export_value
  end
  
  def test_export_values_with_default_values
    form = ActiveForm::compose :form do |f|
      f.text_element :name, :default => 'anonymous'
      f.section :details do |s|
        s.text_element :city
        s.text_element :district
        s.text_element :country, :default => 'US'
        s.section :specs do |gg|
          gg.text_element :specification, :default => 'special'
        end
      end
    end
    assert_equal nil, form[:name].value
    assert_equal 'anonymous', form[:name].fallback_value
    assert_equal 'anonymous', form[:name].export_value
    
    expected = {"name"=>nil, "details"=>{"city"=>nil, "specs"=>{"specification"=>nil}, "district"=>nil, "country"=>nil}}
    assert_equal expected, form.values
    
    expected = {"name"=>"anonymous", "details"=>{"city"=>nil, "specs"=>{"specification"=>"special"}, "district"=>nil, "country"=>"US"}}
    assert_equal expected, form.export_values
    
    form[:details][:country].value = 'BE'   
    expected = {"name"=>"anonymous", "details"=>{"city"=>nil, "specs"=>{"specification"=>"special"}, "district"=>nil, "country"=>"BE"}}
    assert_equal expected, form.values(true) # equivalent to export_values
    
    form[:name].value = 'Fred Flintstone'  
    assert_equal 'Fred Flintstone', form[:name].value
    assert_equal 'anonymous', form[:name].fallback_value
    assert_equal 'Fred Flintstone', form[:name].export_value
  end
  
  def test_localizer 
    translations = {
      'contact_form_firstname_label' => 'Voornaam',
      'contact_form_lastname_label' => 'Achternaam',
      'contact_form_country_label' => 'Land',
      'contact_form_password_label' => 'Wachtwoord',
      'contact_form_password_new_label' => 'Nieuw wachtwoord',
      'contact_form_password_confirm_label' => 'Wachtwoord bevestiging'      
    }   
    form = ActiveForm::compose :contact_form do |f|
      f.define_localizer { |formname, elemname, key| translations[ [formname, elemname, key].compact.join('_') ] }
      f.text_element :firstname
      f.text_element :lastname
      f.text_element :country
      f.section :password do |s|
        s.password_element :new
        s.password_element :confirm
      end       
    end
    assert form.localized?
    assert form[:firstname].localized?
    assert form[:password][:confirm].localized?       
    form.elements.each do |e|
      assert_equal translations[e.identifier + '_label'], e.label
    end 
  end
  
  def test_localizer_fallback
    translations = {
      'contact_form_firstname_title' => 'Uw voornaam',
      'contact_form_firstname_label' => 'Voornaam',
      'contact_form_lastname_label' => 'Achternaam',
      'contact_form_country_label' => nil
    }
    form = ActiveForm::compose :contact_form do |f|
      f.define_localizer { |formname, elemname, key| translations[ [formname, elemname, key].compact.join('_') ] }       
      f.text_element :firstname,  :title => 'Your firstname'
      f.text_element :lastname,   :title => 'Your familyname'
      f.text_element :country
      f.password_element :password                
    end
    assert form.localized? 
    assert_equal 'Uw voornaam', form[:firstname].title
    assert_equal 'Voornaam', form[:firstname].label
    assert_equal 'Achternaam', form[:lastname].label
    assert_equal 'Your familyname', form[:lastname].title
    assert_equal 'Country', form[:country].label
    assert_equal 'Password', form[:password].label
  end
  
  def test_form_submitted
    form = ActiveForm::compose :form do |f|
      f.text_element :name
      f.text_element :language
      f.submit_element :send
    end
    assert !form.submitted?
    # coming from click on submit button
    form[:send].value = 'Send' 
    assert form.submitted?
  end
  
  def test_render_individual_element
    form = ActiveForm::compose :form do |f|
      f.text_element :name
      f.text_element :language
      f.submit_element :send
    end
    expected = %|<label for="form_name">Name</label>\n|
    assert_equal expected, form.label_for_name
    expected = %|<input class="elem_text" id="form_name" name="form[name]" size="30" type="text"/>\n|
    assert_equal expected, form.html_for_name
    assert_equal form[:language].to_html, form.html_for_language
    assert_equal form[:send].to_html, form.html_for_send
  end
  
end

# class TestHtmlRendering < Test::Unit::TestCase
#   
#   def test_truth
#     
#     form = ActiveForm::compose :form do |f|
#       f.text_element :elem_a
#       f.text_element :elem_b
#       f.section :section, :class => 'specialsection' do |s|
#         g.text_element :elem_a, :style => 'color: red' do |e|
#           e.define_formatting_filter { |value| value.join(', ') }
#           e.define_casting_filter { |value| value.split(/,\s+/) }
#         end       
#         g.text_element :elem_b, :class => 'specialelem'
#         g.section :section do |s|
#           g.text_element :elem_a, :disabled => true
#           g.text_element :elem_b, :readonly => true
#         end
#       end
#     end 
#     
#     form.define_form :one do |f|
#       f.text_element :sub_a
#       f.text_element :sub_b
#     end
#     
#     form.define_form :two do |f|
#       f.text_element :sub_a
#       f.text_element :sub_b do |e|
#         e.onblur = "alert('yes!')"
#       end
#     end
#     
#     ActiveForm::Definition.define_container_wrapper do |builder, elem, render|      
#       builder.form(elem.element_attributes) {
#         builder.table(:border => 1) {
#           builder.thead { builder.tr { builder.th(elem.label, :colspan => 2) } }
#           builder.tbody { elem.render_elements(builder) }
#         }
#         builder << elem.script_tag
#       }   
#     end
#     
#     ActiveForm::Definition.define_element_wrapper do |builder, elem, render|
#       style = StyleAttribute.new
#       style << 'margin: 20px'
#       style << 'display: none' if elem.hidden?
#       builder.tr { builder.td { builder.table(:border => 1, :style => style, &render) } }
#     end  
#     
#     ActiveForm::Element::Base.define_element_wrapper do |builder, elem, render|
#       builder.tr(:class => 'label') { builder.td(:colspan => 2) { elem.render_label(builder) } }
#       builder.tr(:id => "elem_#{elem.identifier}", :class => elem.css, :style => elem.style) { builder.td(:class => 'elem', :colspan => 2, &render) }
#     end
#     
#     ActiveForm::Element::Section.define_element_wrapper do |builder, elem, render|
#       builder.tr { builder.td { builder.table(:border => 1, :style => 'background: orange; margin: 20px', &render) } }
#     end
#     
#     form.update_from_params(:form => { :elem_a => 'test', :elem_b => 'tester', :section => { :elem_a => 'one, two, three' }, :two => { :sub_a => 'subvalue' } })
#     
#     #form.display
#     
#     ActiveForm::Definition.reset_element_wrapper
#     ActiveForm::Definition.reset_container_wrapper
#     ActiveForm::Element::Base.reset_element_wrapper
#     ActiveForm::Element::Section.reset_element_wrapper
#   end
#   
# end