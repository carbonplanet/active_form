require 'test_helper'

class TestDefinition < Test::Unit::TestCase
  
  def test_standard_attributes
    assert ActiveForm::Definition.element_attribute_names.include?(:title)
    assert ActiveForm::Definition.element_attribute_names.include?(:lang)
    assert ActiveForm::Definition.element_attribute_names.include?(:method)
    assert ActiveForm::Definition.element_attribute_names.include?(:enctype)
    assert ActiveForm::Definition.element_attribute_names.include?(:accept)
    assert ActiveForm::Definition.element_attribute_names.include?(:"accept-charset")
    form = ActiveForm::compose :form
    assert form.respond_to?(:title=)
    assert form.respond_to?(:style=)
    assert form.respond_to?(:class=)
    assert form.respond_to?(:lang=)
    assert_equal '#form', form.action
    assert_equal 'post', form.method
    expected = {"action"=>"#form", "method"=>"post"}
    assert_equal expected, form.attributes
    expected = {"class"=>"active_form", "action"=>"#form", "id"=>"form", "method"=>"post"}
    assert_equal expected, form.element_attributes 
  end
  
  def test_set_standard_attributes
    form = ActiveForm::compose :form, :action => '/item/edit', :title => 'My Form', :method => 'get', :enctype => 'multipart/form-data', 'accept-charset' => 'utf-8'
    assert_equal "/item/edit", form.action
    assert_equal 'My Form', form.title
    assert_equal 'get', form.method
    assert_equal 'multipart/form-data', form.enctype
    assert_equal 'utf-8', form.attributes['accept-charset']
    expected = {"title"=>"My Form", "enctype"=>"multipart/form-data", "action"=>"/item/edit", "method"=>"get", "accept-charset"=>"utf-8"}
    assert_equal expected, form.attributes
    expected = {"class"=>"active_form", "title"=>"My Form", "enctype"=>"multipart/form-data", "action"=>"/item/edit", "id"=>"form", "method"=>"get", "accept-charset"=>"utf-8"}
    assert_equal expected, form.element_attributes 
  end
  
  def test_standard_option_flags
    form = ActiveForm::compose :form
    [:frozen, :hidden, :disabled, :required, :multipart].each do |method|
      assert ActiveForm::Definition.element_option_flag_names.include?(method)
      assert form.respond_to?("#{method}") 
      assert form.respond_to?("#{method}=")
      assert form.respond_to?("#{method}?")
    end
  end
  
  def test_multipart_option_flag
    form = ActiveForm::compose :form, :multipart => false
    assert !form.multipart?
    expected = {"class"=>"active_form", "action"=>"#form", "id"=>"form", "method"=>"post"}
    assert_equal expected, form.element_attributes
    form = ActiveForm::compose :form, :multipart => true
    assert form.multipart?
    expected = {"class"=>"active_form", "action"=>"#form", "id"=>"form", "method"=>"post", "enctype"=>"multipart/form-data"}
    assert_equal expected, form.element_attributes
  end
  
  def test_render_label
    form = ActiveForm::compose :form, :label => 'My Element'
    assert_equal %|<span class="label">My Element</span>\n|, form.render_label
    form.hidden = true
    assert_equal %|<span class="hidden label">My Element</span>\n|, form.render_label
    form.hidden = false; form.required = true; form.frozen = true
    assert_equal %|<span class="inactive required label">My Element</span>\n|, form.render_label
  end
  
end