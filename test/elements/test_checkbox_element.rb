require 'test_helper'

class TestCheckboxElement < Test::Unit::TestCase
  
  def test_standard_values
    elem = ActiveForm::Element::Checkbox.new :elem
    assert_equal nil, elem.fallback_value
    assert_equal 1, elem.checked_value
    assert_equal nil, elem.export_value
    elem.checked = true
    assert_equal 1, elem.export_value
    expected = %|<input checked="checked" class="elem_checkbox" id="elem" name="elem" type="checkbox" value="1"/>\n|
    assert_equal expected, elem.to_html 
  end
  
  def test_element_to_html    
    elem = ActiveForm::Element::Checkbox.new :elem, :option => 'yes'
    assert !elem.checked?
    assert_equal nil, elem.value
    expected = %|<input class="elem_checkbox" id="elem" name="elem" type="checkbox" value="yes"/>\n|
    assert_equal expected, elem.to_html  
    
    elem = ActiveForm::Element::Checkbox.new :elem, :option => 'yes', :checked => true
    assert elem.checked?
    assert_equal 'yes', elem.value
    expected = %|<input checked="checked" class="elem_checkbox" id="elem" name="elem" type="checkbox" value="yes"/>\n|
    assert_equal expected, elem.to_html   
  end
  
  def test_set_options
    elem = ActiveForm::Element::Checkbox.new :elem, :options => ['yes', 'no']
    assert !elem.checked?
    expected = %|<input class="elem_checkbox" id="elem" name="elem" type="checkbox" value="yes"/>\n|
    assert_equal expected, elem.to_html  
    
    elem.value = 'yes'
    assert elem.checked?
    expected = %|<input checked="checked" class="elem_checkbox" id="elem" name="elem" type="checkbox" value="yes"/>\n|
    assert_equal expected, elem.to_html  
  end 
  
  def test_unknown_value
    elem = ActiveForm::Element::Checkbox.new :elem, :option => 'yes'
    elem.value = 'unknown'
    assert !elem.checked?
    assert_equal nil, elem.element_value
    
    elem.value = 'yes' 
    assert elem.checked?
    assert_equal 'yes', elem.element_value
    
    elem = ActiveForm::Element::Checkbox.new :elem, :options => ['yes', 'no']
    elem.value = 'unknown'
    assert !elem.checked?
    assert_equal 'no', elem.element_value
    
    elem.value = 'yes'
    assert elem.checked?
    assert_equal 'yes', elem.element_value
  end
  
  def test_set_checked
    elem = ActiveForm::Element::Checkbox.new :elem, :options => ['yes', 'no'], :checked => true
    assert elem.checked?
    assert_equal 'yes', elem.checked_value
    assert_equal 'no', elem.fallback_value
    assert_equal 'yes', elem.export_value
    assert_equal 'yes', elem.element_value
    
    elem.checked = false 
    assert !elem.checked?
    assert_equal 'yes', elem.checked_value
    assert_equal 'no', elem.fallback_value
    assert_equal 'no', elem.export_value
    assert_equal 'no', elem.element_value 
    
    elem.checked = true
    assert elem.checked?
    assert_equal 'yes', elem.checked_value
    assert_equal 'no', elem.fallback_value
    assert_equal 'yes', elem.export_value
    assert_equal 'yes', elem.element_value 
  end
  
  def test_on_off_value
    elem = ActiveForm::Element::Checkbox.new :elem, :options => ['yes', 'no']
    assert !elem.checked?
    assert_equal 'yes', elem.checked_value
    assert_equal 'no', elem.fallback_value
    assert_equal 'no', elem.export_value
    assert_equal 'no', elem.element_value    
    
    elem.update_from_params('yes')
    assert elem.checked?
    assert_equal 'yes', elem.element_value
    
    elem.update_from_params('no')
    assert !elem.checked?
    assert_equal 'no', elem.element_value
    
    elem.update_from_params(nil)
    assert !elem.checked?
    assert_equal 'no', elem.element_value
  end
  
  def test_update_from_params
    form = ActiveForm::compose :myform do |f|
      f.text_element :first_name
      f.text_element :last_name
      f.checkbox_element :confirm, :options => ['yes', 'no'], :value => 'yes'
      f.submit_element :send
    end  
    assert form[:confirm].checked?
    
    params = { :myform => { :first_name => 'Fred', :last_name => 'Flintstone', :confirm => 'yes' } }   
    form.update_from_params(params)
    assert form[:confirm].checked?
    
    params = { :myform => { :first_name => 'Fred', :last_name => 'Flintstone', :confirm => 'no' } }   
    form.update_from_params(params)
    assert !form[:confirm].checked?
    form[:confirm].checked = true
    
    params = { :myform => { :first_name => 'Fred', :last_name => 'Flintstone', :confirm => nil } }   
    form.update_from_params(params)
    assert !form[:confirm].checked?
    form[:confirm].checked = true
    
    params = { :myform => { :first_name => 'Fred', :last_name => 'Flintstone', :confirm => nil } }   
    form.update_from_params(params)
    assert !form[:confirm].checked?
    form[:confirm].checked = true
    
    params = { :myform => { :first_name => 'Fred', :last_name => 'Flintstone' } } 
    form.update_from_params(params)
    assert !form[:confirm].checked?
  end
  
  def test_if_checked
    elem = ActiveForm::Element::Checkbox.new :elem, :option => 'yes'
    assert_equal 'yes', elem.checked_value
    assert_equal nil, elem.fallback_value
    assert_equal nil, elem.export_value
    assert_equal nil, elem.element_value 
    assert !elem.active?
    assert !elem.checked?
    assert !elem.selected?
    
    elem.update_from_params('yes')
    assert elem.active?
    assert elem.checked?
    assert elem.selected?
    assert_equal 'yes', elem.element_value
    
    elem.update_from_params('no')
    assert !elem.checked?
    assert_equal nil, elem.element_value
    
    elem.update_from_params(nil)
    assert !elem.checked?
    assert_equal nil, elem.element_value 
  end
  
  def test_required_validation
    form = ActiveForm::compose :myform do |f|
      f.text_element :first_name
      f.text_element :last_name
      f.checkbox_element :confirm, :options => ['yes', 'no'], :required => true
      f.submit_element :send
    end
    
    assert_equal 0, form[:confirm].element_errors.length
    assert_equal '', form[:confirm].validation_advice
    
    validator = form[:confirm].validators.detect { |v| v.code == 'required' }
    assert_kind_of ActiveForm::Validator::Proc, validator
    assert !form.validate
    expected = %|<div class="validation-advice advice-confirm" id="advice-validate-confirm-myform_confirm">Confirm: validation failed</div>\n|
    assert_equal expected, form[:confirm].validation_advice
     
    form[:confirm].value = 'no'
    assert !form.validate
    assert_equal expected, form[:confirm].validation_advice
    
    form[:confirm].value = 'yes'
    assert form.validate
    assert_equal '', form[:confirm].validation_advice
    
    form[:confirm].required_message = 'you need to confirm this'
    assert_equal 'you need to confirm this', validator.message
    
    form[:confirm].required = false
    validator = form[:confirm].validators.detect { |v| v.code == 'required' }
    assert_equal nil, validator
  end
  
  def test_set_values_beforehand
    person = { :first_name => 'Fred', :last_name => 'Flintstone', :confirm => 'yes' }
    
    form = ActiveForm::compose :myform, :values => person do |f|
      f.text_element :first_name, :required => true
      f.text_element :last_name, :required => true
      f.checkbox_element :confirm, :options => ['yes', 'no'], :required => true
      f.submit_element :send
    end
    
    assert form[:confirm].checked?
    expected = %|<input checked="checked" class="elem_checkbox required" id="myform_confirm" name="myform[confirm]" type="checkbox" value="yes"/>\n|
    assert_equal expected, form[:confirm].to_html
  end
  
    def test_add_multiple_radio_elements
    form = ActiveForm::compose :myform do |f|
      f.checkbox_element :elem_a, :option => 'A', :group => :choice
      f.checkbox_element :elem_b, :option => 'B', :group => :choice, :checked => true
    end
    assert !form[:elem_a].checked?
    assert form[:elem_b].checked?
    
    assert_equal 'A', form[:elem_a].checked_value
    assert_equal 'B', form[:elem_b].checked_value
    
    assert_equal 'myform[choice][]', form[:elem_a].element_name
    assert_equal 'myform[choice][]', form[:elem_b].element_name
    
    assert_equal 'myform_elem_a', form[:elem_a].identifier
    assert_equal 'myform_elem_b', form[:elem_b].identifier
    
    expected = { "choice" => ["B"] }
    assert_equal expected, form.export_values 
  end
  
end