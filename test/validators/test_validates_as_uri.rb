require 'test_helper'

class TestValidatesAsUri < Test::Unit::TestCase
  
  def test_validator_defaults
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_uri
    end
    assert elem.validate
    elem.value = 'http://www.loobmedia.com/placeholder/background.gif'
    assert elem.validate
    
    elem.value = 'loobmedia.com'
    assert !elem.validate
    assert_equal ["Mystring: is not a valid location"], elem.errors.collect(&:message)
    assert_equal ["Mystring: is not a valid location"], elem.gather_validation_advice.collect(&:message)
  end
  
  def test_validator_options
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_uri :schemes => 'http', :hosts => [/^(www\.)?loob/], :content_types => 'text/'
    end
    assert_equal ['http'], elem.validators.first.uri_validator.schemes
    assert_equal [/^(www\.)?loob/], elem.validators.first.uri_validator.hosts
    assert_equal ['text/'], elem.validators.first.uri_validator.content_types
    
    elem.value = 'http://loobmedia.com'
    assert elem.validate
    elem.value = 'http://www.loobmedia.com'
    assert elem.validate
    elem.value = 'http://www.loob.be'
    assert elem.validate
      
    elem.value = 'http://www.loobmedia.com/placeholder/background.gif'
    assert !elem.validate
    assert_equal ["Mystring: is not a valid location"], elem.errors.collect(&:message)
    
    elem.value = 'http://www.atelierfabien.be'
    assert !elem.validate
    assert_equal ["Mystring: is not a valid location"], elem.errors.collect(&:message)
  end  
  
  def test_validator_options_with_block
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_uri do |v|
        v.schemes = 'http'
        v.hosts = [/^(www\.)?loob/]
        v.content_types = 'text/'
      end
    end
    assert_equal ['http'], elem.validators.first.uri_validator.schemes
    assert_equal [/^(www\.)?loob/], elem.validators.first.uri_validator.hosts
    assert_equal ['text/'], elem.validators.first.uri_validator.content_types   
  end
  
  def test_validator_message
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_uri :msg => "%1$s: is not a valid location (%3$s)"
    end
    elem.value = 'loobmedia.com'
    assert !elem.validate
    assert_equal ["Mystring: is not a valid location (Not Accessible)"], elem.errors.collect(&:message)
  end  
  
  def test_set_validation_messages
    elem = ActiveForm::Element::build(:text, :mystring) do |e|
      e.validates_as_uri :msg => "%1$s: is not a valid url", :schemes => 'http', :hosts => [/^(www\.)?loob/], :content_types => 'text/' do |v|
        v.messages[:invalid_scheme] = '%s: only HTTP requests are accepted'
        v.messages[:invalid_host] = '%s: only urls starting with `loob` are accepted'
        v.messages[:invalid_content_type] = '%s: only text content accepted'
      end
    end
    
    assert_equal ["invalid_content_type", "invalid_host", "invalid_scheme", "uri"], elem.gather_validation_advice.collect(&:code)
    
    assert_equal [
      "Mystring: only text content accepted", 
      "Mystring: only urls starting with `loob` are accepted", 
      "Mystring: only HTTP requests are accepted", 
      "Mystring: is not a valid url"], elem.gather_validation_advice.collect(&:message)
    
    elem.value = 'http://www.loobmedia.com'
    assert elem.validate  
    
    elem.value = 'ftp://www.loobmedia.com'
    assert !elem.validate 
    assert_equal ["Mystring: only HTTP requests are accepted"], elem.errors.collect(&:message)  
     
    elem.value = 'http://www.loobmedia.com/placeholder/background.gif'
    assert !elem.validate
    assert_equal ["Mystring: only text content accepted"], elem.errors.collect(&:message)    
    elem.value = 'http://www.atelierfabien.be'
    assert !elem.validate
    assert_equal ["Mystring: only urls starting with `loob` are accepted"], elem.errors.collect(&:message) 
  end
  
  def test_localized_validation_messages
    translations = { 
      'form_elem_a_label' => 'Link',
      'form_elem_a_validates_uri' => '%s: geef een geldige en actieve url',
      'form_elem_a_validates_invalid_scheme' => '%s: enkel HTTP-locaties worden geaccepteerd', 
      'form_elem_a_validates_invalid_host' => '%s: alleen loob hosts worden geaccepteerd',
      'form_elem_a_validates_invalid_content_type' => '%s: alleen tekst data wordt geaccepteerd'
    }
    
    form = ActiveForm::compose :form do |f|
      f.define_localizer { |formname, elemname, key| translations[ [formname, elemname, key].compact.join('_') ] }            
      f.text_element :elem_a, :label => 'URL' do |e|
        e.validates_as_uri :msg => "%1$s: is not a valid url", :schemes => 'http', :hosts => [/^(www\.)?loob/], :content_types => 'text/' do |v|
          v.messages[:invalid_scheme] = '%s: only HTTP requests are accepted'
          v.messages[:invalid_host] = '%s: only urls starting with `loob` are accepted'
          v.messages[:invalid_content_type] = '%s: only text content accepted'
        end
      end
    end
    
    assert_equal [
      "Link: alleen tekst data wordt geaccepteerd",
      "Link: alleen loob hosts worden geaccepteerd",
      "Link: enkel HTTP-locaties worden geaccepteerd",
      "Link: geef een geldige en actieve url"], form[:elem_a].gather_validation_advice.collect(&:message)
    
    form[:elem_a].value = 'http://www.loobmedia.com/placeholder/background.gif'
    assert !form.validate
    assert_equal 'Link: alleen tekst data wordt geaccepteerd', form[:elem_a].errors[0].message
  end
  
end