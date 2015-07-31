require 'test_helper'

ActiveForm::Validator::Base.create :special do
  
  default_message "%s: isn't all that great"
  
end

class TestValidation < Test::Unit::TestCase
  
  def test_create_and_build_validator
    assert_equal ActiveForm::Validator::Special, ActiveForm::Validator::get(:special)
    validator = ActiveForm::Validator::build(:special)
    assert_kind_of ActiveForm::Validator::Special, validator
    assert_equal "%s: isn't all that great", validator.message
    ActiveForm::Validator::get(:special).default_message = "%s: isn't so special"
    assert_equal "%s: isn't so special", validator.message
  end
  
  def test_validated
    form = ActiveForm::compose :form do |f|
      f.text_element :name
      f.text_element :language
      f.submit_element :send
    end
    assert !form.submitted?
    assert !form.validated?
    assert form.validate
     # coming from click on submit button
    form[:send].value = 'Send'
    assert form.submitted?
    assert form.validated?
    assert form.validate
  end
  
  def test_define_class_level_validation
    ActiveForm::Definition.define_validation do |form|
      form.each do |elem|
        elem.errors.add('%s is empty', 'empty') if elem.blank?
      end
    end
    
    ActiveForm::Element::Base.define_validation do |elem|
      elem.errors.add("%s can't be numeric", 'non-numeric') if elem.value.to_s.match(/^[0-9]+$/)
    end
    
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a
      f.text_element :elem_b
    end
    
    assert !form.validate
    assert_equal 2, form.element_errors.length
    assert_equal "Elem A is empty", form[:elem_a].errors.first.message
    assert_equal "Elem B is empty", form[:elem_b].errors.first.message
    
    form.params = { :form => { :elem_a => 'a', :elem_b => 'b' } }
        
    assert form.validate
    assert_equal 0, form.element_errors.length
    
    form.params = { :form => { :elem_a => 2 } }
        
    assert !form.validate
    assert_equal 1, form.element_errors.length
    assert_equal "Elem A can't be numeric", form[:elem_a].errors.first.message
        
    ActiveForm::Definition.reset_validation
    ActiveForm::Element::Base.reset_validation
  end
  
  def test_define_container_validation
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a
      f.text_element :elem_b
      
      f.define_validation do |elem|
        elem.errors.add('empty elements found', 'empty') if elem[:elem_a].blank? || elem[:elem_b].blank?
      end
    end
    assert !form.validate
    assert !form.valid?
    assert_equal 1, form.errors.length
    assert_equal 1, form.element_errors.length
    assert form.errors.collect(&:code).include?('empty')
    assert form.runtime_css_class.include?('validation-failed')
    assert form.label_css_class.include?('validation-failed')
    form[:elem_a].element_value = 'non-empty'
    form[:elem_b].element_value = 'non-empty'
    assert form.validate
    assert form.valid?
    assert_equal 0, form.element_errors.length
    assert !form.runtime_css_class.include?('validation-failed')
  end
  
  def test_define_validation_add_error_to_element
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a
      f.text_element :elem_b
      
      f.define_validation do |elem|    
        elem[:elem_a].errors.add('%s is empty', 'empty') if elem[:elem_a].blank?
        elem[:elem_b].errors.add('%s is empty', 'empty') if elem[:elem_b].blank?
      end
    end    
    assert !form.validate
    assert !form.valid?
    assert_equal 2, form.element_errors.length
    assert form.element_errors.collect(&:code).include?('empty')
    assert form.runtime_css_class.include?('validation-failed')
    assert !form[:elem_a].valid?
    assert form[:elem_a].runtime_css_class.include?('validation-failed')
    assert !form[:elem_b].valid?
    assert form[:elem_b].runtime_css_class.include?('validation-failed')
    form[:elem_a].element_value = 'non-empty'
    assert !form.validate
    assert !form.valid?
    assert_equal 1, form.element_errors.length
    assert form.runtime_css_class.include?('validation-failed')
    assert form[:elem_a].valid?
    assert !form[:elem_a].runtime_css_class.include?('validation-failed')
    assert !form[:elem_b].valid?
    assert form[:elem_b].runtime_css_class.include?('validation-failed')
    form[:elem_b].element_value = 'non-empty'
    assert form.validate
    assert form.valid?
    assert_equal 0, form.element_errors.length
    assert !form.runtime_css_class.include?('validation-failed')
  end
  
  def test_clear_validations
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a
      f.text_element :elem_b
      
      f.define_validation do |elem|    
        elem[:elem_a].errors.add('%s is empty', 'empty') if elem[:elem_a].blank?
        elem[:elem_b].errors.add('%s is empty', 'empty') if elem[:elem_b].blank?
      end
    end
    assert !(form.validate && form.valid?)
    assert_equal 2, form.element_errors.length
    form.clear_validations!
    assert_equal 0, form.element_errors.length
    assert !(form.validate && form.valid?)
    assert_equal 2, form.element_errors.length
  end
  
  def test_validation_exception
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a
      f.text_element :elem_b    
      f.define_validation do |elem|    
        elem[:elem_a].errors.add('%s is empty', 'empty') if elem[:elem_a].blank?
        elem[:elem_b].errors.add('%s is empty', 'empty') if elem[:elem_b].blank?
      end
    end
    assert_raises(ActiveForm::ValidationException) { form.validate! }
  end
  
  def test_define_element_validation
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a do |e|
        e.define_validation do |elem|    
          elem.errors.add('%s is empty', 'empty') if elem.blank?
          elem.errors.add('%s is not numeric', 'numeric') unless value.to_s.match(/^[0-9]+$/)
        end
      end
      f.text_element :elem_b       
    end   
    assert !form.validate
    assert_equal 0, form.errors.length
    assert_equal 2, form.element_errors.length
    assert_equal ['empty', 'numeric'], form.element_errors.collect(&:code)
    assert_equal 1, form.initial_errors.length
    assert_equal ['empty'], form.initial_errors.collect(&:code)
    assert_equal 2, form[:elem_a].element_errors.length
    assert_equal ['empty', 'numeric'], form[:elem_a].element_errors.collect(&:code)
    assert_equal 1, form[:elem_a].initial_errors.length
    assert_equal ['empty'], form[:elem_a].initial_errors.collect(&:code)
  end
  
  def test_create_proc_validator
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a do |e|
        e.validates_with_proc :msg => '%s: proc validation failed' do |v|
          v.element.errors.add(v.message) unless v.value == 123
        end
      end
    end
    assert !form.validate
    assert_equal 'Elem A: proc validation failed', form[:elem_a].errors.first.message
    form[:elem_a].element_value = 123
    assert form.validate
  end
  
  def test_assign_proc_validator
    one_two_three = lambda { |v| v.element.errors.add(v.message, v.code) unless v.value == 123 }
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a do |e|
        e.validates_with_proc :msg => '%s: proc validation failed', :proc => one_two_three
      end
    end
    assert !form.validate
    assert_equal 'Elem A: proc validation failed', form[:elem_a].errors.first.message
    form[:elem_a].element_value = 123
    assert form.validate
  end
  
  def test_validation_messages
    flunker = lambda { |v| v.element.errors.add(v.message, v.code) }
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a, :label => 'Result', :value => 'foo' do |e|
        e.validates_with_proc :msg => '%s: flunked test (value=%s)', :proc => flunker
        e.validates_with_proc :msg => 'value "%2$s" incorrect for %1$s-field', :proc => flunker
      end
    end
    assert !form.validate
    assert_equal 'Result: flunked test (value=foo)', form[:elem_a].errors[0].message
    assert_equal 'value "foo" incorrect for Result-field', form[:elem_a].errors[1].message
  end
  
  def test_localized_validation_messages
    translations = { 
      'form_elem_a_label' => 'Resultaat',
      'form_elem_a_validates_one' => 'een: advies voor %s-veld', 
      'form_elem_a_validates_two' => 'twee: advies voor %s-veld' 
    }
      
    flunker = lambda { |v| v.element.errors.add(v.message, v.code) }
    form = ActiveForm::compose :form do |f|
      f.define_localizer { |formname, elemname, key| translations[ [formname, elemname, key].compact.join('_') ] }            
      f.text_element :elem_a, :label => 'Result', :value => 'foo' do |e|
        e.validates_with_proc :code => 'one', :msg => '%s: flunked test (%s)', :proc => flunker
        e.validates_with_proc :code => 'two', :msg => 'value "%2$s" incorrect for %1$s', :proc => flunker
      end
    end
    assert !form.validate
    assert_equal 'een: advies voor Resultaat-veld', form[:elem_a].errors[0].message
    assert_equal 'twee: advies voor Resultaat-veld', form[:elem_a].errors[1].message
  end
  
  def test_errors_enumerable
    flunker = lambda { |v| v.element.errors.add(v.message, v.code) }
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a, :label => 'A', :value => 'foo' do |e|
        e.validates_with_proc :code => 'test-code', :proc => flunker
      end
    end
    assert !form.validate
    assert_equal ["A: validation failed"], form[:elem_a].errors.collect(&:msg)
    assert_equal ['test-code'], form[:elem_a].errors.collect(&:code)
    assert_equal ["%s: validation failed"], form[:elem_a].validators_by_type('test-code').collect(&:message)
  end
  
  def test_validate_group
    flunker = lambda { |v| v.element.errors.add(v.message, v.code) }
    form = ActiveForm::compose :form do |f|
      f.section :section do |s|
        s.validates_with_proc :msg => '%s: cannot be blank' do |v|
          v.element.each do |elem|
            elem.errors.add(v.message, 'blank') if elem.blank?
            # ... add more validations here if needed
          end
        end          
        s.text_element :elem_b, :label => 'B' do |e|
          e.validates_with_proc :code => 'test-code', :proc => flunker
        end
        s.text_element :elem_c, :label => 'C'
      end
    end
    form[:section].define_element_at_top :text, :elem_a, :label => 'A'
    assert_equal ['A', 'B', 'C'], form[:section].collect(&:label)
    assert !form.validate
    assert_equal ["A: cannot be blank", "B: validation failed", "B: cannot be blank", "C: cannot be blank"], form.all_errors.collect(&:message)
    assert_equal ["A: cannot be blank", "B: validation failed", "C: cannot be blank"], form.initial_errors.collect(&:message)
    assert_equal form.all_errors, form[:section].all_errors
  end
  
  def test_each_error
    flunker = lambda { |v| v.element.errors.add(v.message, v.code) }
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a, :label => 'A', :value => 'foo' do |e|
        e.validates_with_proc :proc => flunker
      end
      f.section :section do |s|
        s.text_element :elem_b, :label => 'B', :value => 'foo' do |e|
          e.validates_with_proc :proc => flunker
          e.validates_with_proc :proc => flunker, :msg => '%s failed'
        end
      end
    end
    assert !form.validate
    expected = ['A: validation failed', 'B: validation failed', 'B failed']
    check = []
    form.each_error { |e| check << e.message }
    assert_equal expected, check   
    assert_equal 3, check.length
    expected = ['A: validation failed']
    check = []
    form[:elem_a].each_error { |e| check << e.message }
    assert_equal expected, check 
    assert_equal 1, check.length
    expected = ['B: validation failed', 'B failed']
    check = []
    form[:section].each_error { |e| check << e.message }
    assert_equal expected, check 
    assert_equal 2, check.length
  end
  
  def test_every_error
    flunker = lambda { |v| v.element.errors.add(v.message, v.code) }
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a, :label => 'A', :value => 'foo' do |e|
        e.validates_with_proc :proc => flunker
      end
      f.section :section do |s|
        s.text_element :elem_b, :label => 'B', :value => 'foo' do |e|
          e.validates_with_proc :proc => flunker
          e.validates_with_proc :proc => flunker, :msg => '%s failed'
        end
      end
    end
    assert !form.validate
    expected = ['A: validation failed', 'B: validation failed']
    check = []
    form.every_error { |e| check << e.message }
    assert_equal expected, check   
    assert_equal 2, check.length
    expected = ['A: validation failed']
    check = []
    form[:elem_a].every_error { |e| check << e.message }
    assert_equal expected, check 
    assert_equal 1, check.length
    expected = ['B: validation failed']
    check = []
    form[:section].every_error { |e| check << e.message }
    assert_equal expected, check 
    assert_equal 1, check.length
  end
  
  def test_add_custom_javascript_validation
    form = ActiveForm::compose :form, :client_side => true do |f|
      f.javascript_validation do |elem, code, params|
        params[:name] = 'custom'
        params[:msg] = 'Not valid'
        code << "return Validation.get('IsEmpty').test(v) || /^[a-zA-Z]+$/.test(v)"
      end
      f.text_element :elem_a, :label => 'A' do |e|
        e.css_class << 'validate-custom'
      end
      f.text_element :elem_b, :label => 'B' do |e|
        e.css_class << 'validate-custom'
      end
    end
    expected = %`var fform_form=$('form');if(fform_form){
  Validation.add('validate-custom', "Not valid", function (v) {
  return Validation.get('IsEmpty').test(v) || /^[a-zA-Z]+$/.test(v)
});
  new Validation(fform_form, {stopOnFirst:false, useTitles:true});
}`
    assert_equal expected, form.element_javascript
    assert form[:elem_a].css_class.include?('elem_text')
    assert form[:elem_a].css_class.include?('validate-custom')
    assert form[:elem_b].css_class.include?('elem_text')
    assert form[:elem_b].css_class.include?('validate-custom')
  end
  
  def test_custom_javascript_element_validation
    form = ActiveForm::compose :form, :client_side => true do |f|
      f.text_element :elem_a, :label => 'A' do |e|
        e.javascript_validation do |elem, code, params|
          code << "return Validation.get('IsEmpty').test(v) || /^[a-zA-Z]+$/.test(v)"
        end
      end
      f.text_element :elem_b, :label => 'B' do |e|
        e.javascript_validation do |elem, code, params|
          params[:name] = 'reusable'
          params[:msg] = 'Not valid'
          code << "return Validation.get('IsEmpty').test(v) || /^[a-zA-Z]+$/.test(v)"
        end
      end
    end
    expected = %`Validation.add('validate-form-elem-a', "A: validation failed", function (v) {
  return Validation.get('IsEmpty').test(v) || /^[a-zA-Z]+$/.test(v)
});`
    assert_equal expected, form[:elem_a].javascript_validation_code
    expected = %`Validation.add('validate-reusable', "Not valid", function (v) {
  return Validation.get('IsEmpty').test(v) || /^[a-zA-Z]+$/.test(v)
});`
    assert_equal expected, form[:elem_b].javascript_validation_code
    expected = %`var fform_form=$('form');if(fform_form){
  var ftext_form_elem_a=$('form_elem_a');if(ftext_form_elem_a){
    Validation.add('validate-form-elem-a', "A: validation failed", function (v) {
    return Validation.get('IsEmpty').test(v) || /^[a-zA-Z]+$/.test(v)
  });
  }
  var ftext_form_elem_b=$('form_elem_b');if(ftext_form_elem_b){
    Validation.add('validate-reusable', "Not valid", function (v) {
    return Validation.get('IsEmpty').test(v) || /^[a-zA-Z]+$/.test(v)
  });
  }
  new Validation(fform_form, {stopOnFirst:false, useTitles:true});
}`
    assert_equal expected, form.element_javascript    
    assert form[:elem_a].css_class.include?("validate-form-elem-a")
    assert form[:elem_b].css_class.include?("validate-reusable")
  end
   
  def test_gather_validation_advice
    form = ActiveForm::compose :form, :client_side => true do |f|
      f.text_element :elem_a, :label => 'A' do |e|
        e.validates_as_required
        e.validates_as_number
      end      
      f.text_element :elem_b, :label => 'B' do |e|
        e.validates_as_required
        e.validates_as_alpha
      end 
      f.text_element :elem_c, :label => 'C' do |e|
        e.validates_as_required
      end 
    end
    expected = %`var fform_form=$('form');if(fform_form){
  new Validation(fform_form, {stopOnFirst:false, useTitles:true});
}`
    assert_equal expected, form.element_javascript 
    assert form[:elem_a].css.include?('elem_text')
    assert form[:elem_a].css.include?('required')
    assert form[:elem_a].css.include?('validate-number')
    assert form[:elem_b].css.include?('elem_text')
    assert form[:elem_b].css.include?('required')  
    assert form[:elem_b].css.include?('validate-alpha')  
    assert form[:elem_c].css.include?('elem_text')
    assert form[:elem_c].css.include?('required')
    
    assert_equal ["A: can't be blank", "A: should be numeric"], form[:elem_a].gather_validation_advice.collect(&:message)
    assert_equal ["B: can't be blank", "B: should contain alphabetical characters only"], form[:elem_b].gather_validation_advice.collect(&:message)
    assert_equal ["C: can't be blank"], form[:elem_c].gather_validation_advice.collect(&:message)
        
    expected =  [ ["form_elem_a", "A: can't be blank"], ["form_elem_a", "A: should be numeric"], 
                  ["form_elem_b", "B: can't be blank"], ["form_elem_b", "B: should contain alphabetical characters only"], 
                  ["form_elem_c", "C: can't be blank"]
                ]    
    assert_equal expected, form.gather_validation_advice.collect { |adv| [adv.element.identifier, adv.message] }

    assert !form.validate
    params = { :form => { :elem_a => '123', :elem_b => 'abcde', :elem_c => 'fghi' } }
    form.update_from_params(params)     
    assert form.validate
  end
  
  def test_gather_nested_elements_validation_advice
    form = ActiveForm::compose :form, :client_side => true do |f|
      f.text_element :elem_a, :label => 'A' do |e|
        e.validates_as_required
        e.validates_as_number
      end
      f.section :section do |s|
        s.text_element :elem_b, :label => 'B' do |e|
          e.validates_as_required
          e.validates_as_alpha
        end 
        s.text_element :elem_c, :label => 'C' do |e|
          e.validates_as_required
        end
      end         
    end    
    assert form[:elem_a].css.include?('elem_text')
    assert form[:elem_a].css.include?('required')
    assert form[:elem_a].css.include?('validate-number')
    assert form[:section][:elem_b].css.include?('elem_text')
    assert form[:section][:elem_b].css.include?('required')  
    assert form[:section][:elem_b].css.include?('validate-alpha')  
    assert form[:section][:elem_c].css.include?('elem_text')
    assert form[:section][:elem_c].css.include?('required')
       
    assert_equal ["A: can't be blank", "A: should be numeric"], form[:elem_a].gather_validation_advice.collect(&:message)
    assert_equal ["B: can't be blank", "B: should contain alphabetical characters only"], form[:section][:elem_b].gather_validation_advice.collect(&:message)
    assert_equal ["C: can't be blank"], form[:section][:elem_c].gather_validation_advice.collect(&:message)
        
    expected =  [ ["form_elem_a", "A: can't be blank"], ["form_elem_a", "A: should be numeric"], 
                  ["form_section_elem_b", "B: can't be blank"], ["form_section_elem_b", "B: should contain alphabetical characters only"], 
                  ["form_section_elem_c", "C: can't be blank"]
                ]                    
    assert_equal expected, form.gather_validation_advice.collect { |adv| [adv.element.identifier, adv.message] }
  end
  
  def test_validation_css_class
    form = ActiveForm::compose :form, :client_side => true do |f|
      f.text_element :elem_a, :label => 'A', :required => true do |e|
        e.validates_as_number
      end
    end
    assert_equal ["required", "validate-number"], form[:elem_a].validation_css_class
    assert_equal ["required", "validate-number"], form[:elem_a].runtime_css_class
  end
  
  def test_server_side_validation_advice
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a, :label => 'A' do |e|
        e.validates_as_required
        e.validates_as_number
      end      
      f.text_element :elem_b, :label => 'B' do |e|
        e.validates_as_required
        e.validates_as_alpha
      end
    end    
    assert_equal '', form[:elem_a].server_side_validation_advice
    assert_equal '', form[:elem_b].server_side_validation_advice
    assert !form.validate
    expected = %`<div class="validation-advice advice-required" id="advice-required-form_elem_a">A: can't be blank</div>\n`    
    assert_equal expected, form[:elem_a].server_side_validation_advice
    expected = %`<div class="validation-advice advice-required" id="advice-required-form_elem_b">B: can't be blank</div>\n`   
    assert_equal expected, form[:elem_b].server_side_validation_advice
    expected = %`<div class="validation-advice advice-required" id="advice-required-form_elem_a">A: can't be blank</div>
<div class="validation-advice advice-required" id="advice-required-form_elem_b">B: can't be blank</div>\n`
    assert_equal expected, form.server_side_validation_advice
    expected = %`<div class="validation-advice advice-required" id="advice-required-form_elem_a">A: can't be blank</div>
<div class="validation-advice advice-required" id="advice-required-form_elem_b">B: can't be blank</div>\n`
    assert_equal expected, form.all_server_side_validation_advice
  end
  
  def test_client_side_validation_advice
    form = ActiveForm::compose :form, :client_side => true do |f|
      f.text_element :elem_a, :label => 'A' do |e|
        e.validates_as_required
        e.validates_as_number
      end      
      f.text_element :elem_b, :label => 'B' do |e|
        e.validates_as_required
        e.validates_as_alpha
      end
    end    
    expected = %`<div class="validation-advice advice-required" id="advice-required-form_elem_a" style="display: none">A: can't be blank</div>
<div class="validation-advice advice-number" id="advice-validate-number-form_elem_a" style="display: none">A: should be numeric</div>\n`
    assert_equal expected, form[:elem_a].client_side_validation_advice
    expected = %`<div class="validation-advice advice-required" id="advice-required-form_elem_b" style="display: none">B: can't be blank</div>
<div class="validation-advice advice-alpha" id="advice-validate-alpha-form_elem_b" style="display: none">B: should contain alphabetical characters only</div>\n`
    assert_equal expected, form[:elem_b].client_side_validation_advice     
    expected = %`<div class="validation-advice advice-required" id="advice-required-form_elem_a" style="display: none">A: can't be blank</div>
<div class="validation-advice advice-number" id="advice-validate-number-form_elem_a" style="display: none">A: should be numeric</div>
<div class="validation-advice advice-required" id="advice-required-form_elem_b" style="display: none">B: can't be blank</div>
<div class="validation-advice advice-alpha" id="advice-validate-alpha-form_elem_b" style="display: none">B: should contain alphabetical characters only</div>\n`
    assert_equal expected, form.client_side_validation_advice
  end
  
  def test_validation_advice   
    form = ActiveForm::compose :form, :client_side => true do |f|     
      f.text_element :elem_a, :label => 'A' do |e|
        e.validates_as_required :msg => '%s: should not be left blank'
        e.validates_as_number   :msg => '%s: numeric values only'
      end      
      f.text_element :elem_b, :label => 'B' do |e|
        e.validates_as_required :msg => '%s: should not be left blank'
        e.validates_as_alpha    :msg => '%s: letter characters only please'
      end
    end
    expected = %`<div class="validation-advice advice-required" id="advice-required-form_elem_a" style="display: none">A: should not be left blank</div>
<div class="validation-advice advice-number" id="advice-validate-number-form_elem_a" style="display: none">A: numeric values only</div>
<div class="validation-advice advice-required" id="advice-required-form_elem_b" style="display: none">B: should not be left blank</div>
<div class="validation-advice advice-alpha" id="advice-validate-alpha-form_elem_b" style="display: none">B: letter characters only please</div>\n`
    assert_equal expected, form.validation_advice
  end
  
  def test_localized_validation_advice   
    translations = {
      'form_elem_a_label' => 'Foo',
      'form_elem_a_validates_required' => '%s: mag niet leeg zijn', 
      'form_elem_a_validates_number' => '%s: dit moet een nummer zijn', 
      'form_elem_b_label' => 'Bar',
      'form_elem_b_validates_required' => '%s: mag niet leeg zijn', 
      'form_elem_b_validates_alpha' => '%s: mag alleen letters bevatten' 
    }    
    form = ActiveForm::compose :form, :client_side => true do |f| 
      f.define_localizer { |formname, elemname, key| translations[ [formname, elemname, key].compact.join('_') ] }       
      f.text_element :elem_a, :label => 'A' do |e|
        e.validates_as_required
        e.validates_as_number   
      end      
      f.text_element :elem_b, :label => 'B' do |e|
        e.validates_as_required
        e.validates_as_alpha   
      end
    end
    expected = %`<div class="validation-advice advice-required" id="advice-required-form_elem_a" style="display: none">Foo: mag niet leeg zijn</div>
<div class="validation-advice advice-number" id="advice-validate-number-form_elem_a" style="display: none">Foo: dit moet een nummer zijn</div>
<div class="validation-advice advice-required" id="advice-required-form_elem_b" style="display: none">Bar: mag niet leeg zijn</div>
<div class="validation-advice advice-alpha" id="advice-validate-alpha-form_elem_b" style="display: none">Bar: mag alleen letters bevatten</div>\n`
    assert_equal expected, form.validation_advice
  end
  
  def test_javascript_validator_definition
    form = ActiveForm::compose :form, :client_side => true do |f|
      f.text_element :elem_a, :label => 'A' do |e|
        e.validates_as_sample
      end
      f.submit_element :label => 'Validate'      
    end   
    assert form[:elem_a].css.include?('validate-sample')
    expected = %`Validation.add('validate-sample', "value needs to be identical to 'sample'", function (v) {
  return Validation.get('IsEmpty').test(v) || /^sample$/i.test(v);
});`
    assert_equal expected, form.validation_javascript_definitions
    expected = %`var fform_form=$('form');if(fform_form){
  Validation.add('validate-sample', "value needs to be identical to 'sample'", function (v) {
    return Validation.get('IsEmpty').test(v) || /^sample$/i.test(v);
  });
  new Validation(fform_form, {stopOnFirst:false, useTitles:true});
}`
    assert_equal expected, form.js
    assert_equal ["sample"], form[:elem_a].validators.collect(&:code)
  end
  
  def test_validates_as_required_alternative
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a, :required => true
    end
    assert form[:elem_a].css.include?('required')
    assert_equal ["required"], form[:elem_a].validators.collect(&:code)
    form[:elem_a].required = false
    assert_equal [], form[:elem_a].validators.collect(&:code)
  end
  
  def test_mixed_validations
    is_blank = lambda { |v| v.element.errors.add(v.message, v.code) if v.value.blank? }    
    form = ActiveForm::compose :form, :client_side => true do |f|
      f.text_element :elem_a, :label => 'A' do |e|
        e.validates_as_required
        e.validates_as_number
        e.validates_with_proc :code => 'test-code', :proc => is_blank, :msg => '%s: is_blank proc validation failed'
        e.define_validation { |elem| elem.errors.add('%s is empty', 'empty') if elem.blank? }
      end     
    end 
    expected = ["A: can't be blank", "A: should be numeric"]
    assert_equal expected, form.gather_validation_advice.collect(&:message)    
    assert !form.validate    
    expected = ["A: can't be blank", "A: is_blank proc validation failed", "A is empty"]
    assert_equal expected, form.all_errors.collect(&:message) 
    form[:elem_a].value = '1234'
    assert form.validate   
  end
  
  def test_after_validation_callback    
    ActiveForm::Element::Base.define_element_wrapper do |builder, elem, render|
      builder.div(:id => "elem_#{elem.identifier}", :class => elem.css, :style => elem.style) do 
        elem.frozen? ? builder.span(elem.label, elem.label_attributes) : elem.render_label(builder)
        builder.br
        render.call
      end
    end
    
    form = ActiveForm::compose :myform do |f|
      f.text_element :first_name, :required => true
      f.text_element :last_name, :required => true do |e|
        e.after_validation do |elem|
          elem.value += ' (OK)' if elem.valid?
        end
      end
      f.password_element :password, :required => true
      f.password_element :password_confirm, :required => true
      f.after_validation do |elem|
        if elem.valid?
          elem.remove_elements(:password, :password_confirm)
          elem.freeze!
        end
      end
    end
    assert !form.validate
    expected = %`<!--o---------------------------[ myform ]---------------------------o-->
<div class="validation-advice advice-required" id="advice-required-myform_first_name">First Name: can't be blank</div>
<div class="validation-advice advice-required" id="advice-required-myform_last_name">Last Name: can't be blank</div>
<div class="validation-advice advice-required" id="advice-required-myform_password">Password: can't be blank</div>
<div class="validation-advice advice-required" id="advice-required-myform_password_confirm">Password Confirm: can't be blank</div>
<form action="#myform" class="active_form validation-failed" id="myform" method="post">
  <div class="elem_text required validation-failed" id="elem_myform_first_name">
    <label class="required validation-failed" for="myform_first_name">First Name</label>
    <br/>
    <input class="required" id="myform_first_name" name="myform[first_name]" size="30" type="text"/>
  </div>
  <div class="elem_text required validation-failed" id="elem_myform_last_name">
    <label class="required validation-failed" for="myform_last_name">Last Name</label>
    <br/>
    <input class="required" id="myform_last_name" name="myform[last_name]" size="30" type="text"/>
  </div>
  <div class="elem_password required validation-failed" id="elem_myform_password">
    <label class="required validation-failed" for="myform_password">Password</label>
    <br/>
    <input class="required" id="myform_password" name="myform[password]" size="30" type="password"/>
  </div>
  <div class="elem_password required validation-failed" id="elem_myform_password_confirm">
    <label class="required validation-failed" for="myform_password_confirm">Password Confirm</label>
    <br/>
    <input class="required" id="myform_password_confirm" name="myform[password_confirm]" size="30" type="password"/>
  </div>
</form>
<!--x---------------------------[ myform ]---------------------------x-->\n`
    assert_equal expected, form.render    
    form.values[:first_name] = 'Fabien'
    form.values[:last_name] = 'Franzen'
    form.values[:password] = form.values[:password_confirm] = 'secret'
    assert form.validate
    assert_equal 'Franzen (OK)', form[:last_name].value
    
    expected = %`<!--o---------------------------[ myform ]---------------------------o-->
<form action="#myform" class="active_form frozen" id="myform" method="post">
  <div class="elem_text frozen required" id="elem_myform_first_name">
    <span class="inactive required" for="myform_first_name">First Name</span>
    <br/>
Fabien  </div>
  <div class="elem_text frozen required" id="elem_myform_last_name">
    <span class="inactive required" for="myform_last_name">Last Name</span>
    <br/>
Franzen (OK)  </div>
</form>
<!--x---------------------------[ myform ]---------------------------x-->\n`
    assert_equal expected, form.render   
    ActiveForm::Element::Base.reset_element_wrapper
  end
  
end