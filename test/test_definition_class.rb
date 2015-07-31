require 'test_helper'

# create ActiveForm::ContactForm < ActiveForm::Definition
ActiveForm::Definition::create :contact do |f|       
  
  f.text_element :firstname,  :title => 'Your firstname'
  f.text_element :lastname,   :title => 'Your familyname'
  f.text_element :country
  f.submit_element              

end

ActiveForm::Definition::create :test do |f|
  f.text_element :firstname
  f.text_element :lastname
  f.submit_element             
end

class ActiveForm::CustomDefinition < ActiveForm::Definition
  
  def do_something_special
  end
  
end

# create ActiveForm::CustomForm < ActiveForm::CustomDefinition
ActiveForm::CustomDefinition::create :custom do |f|
  
  f.text_element :firstname
  f.text_element :lastname
  f.submit_element
  
end

class TestDefinitionClass < Test::Unit::TestCase
  
  def test_create_definition
    definition = ActiveForm::Definition.create :sample do |f|
      f.text_element :firstname
      f.text_element :lastname
      f.submit_element             
    end
    assert_equal ActiveForm::SampleForm, definition
    assert_equal ActiveForm::SampleForm, ActiveForm::Definition.get(:sample)
    assert_kind_of ActiveForm::SampleForm, definition.new(:test)
  end
  
  def test_recreate_created_class
    definition = ActiveForm::Definition.create :contact
    assert_equal nil, definition
  end
  
  def test_get_and_modify_class
    assert_equal ActiveForm::TestForm, ActiveForm::Definition.modify(:test)
    ActiveForm::Definition.get(:test) do |f|
      
      f.define_validation do |form|
        form.errors.add('please give your family name', 'empty') if form[:lastname].blank?   
      end
      
    end
    form = ActiveForm::Definition.build(:test)
    form.validate   
    expected = ["please give your family name"]
    assert_equal expected, form.all_errors.collect(&:message)
  end
  
  def test_get_and_build
    assert_equal ActiveForm::ContactForm, ActiveForm::Definition.get(:contact)
    form = ActiveForm::Definition.build(:contact)
    assert_kind_of ActiveForm::ContactForm, form
    assert_equal :contact, form.name
    form = ActiveForm::Definition.build(:contact, :my_form)
    assert_kind_of ActiveForm::ContactForm, form
    assert_equal :my_form, form.name
  end
  
  def test_build_with_block
    form = ActiveForm::Definition.build(:contact) do |f|
      f.define_element_at(-2, :textarea, :comment) do |e|
        e.label = 'Your comment'
      end
    end
    assert_kind_of ActiveForm::ContactForm, form
    assert_kind_of ActiveForm::Definition, form
    assert_equal :contact, form.name   
    assert_equal [:firstname, :lastname, :country, :comment, :submit], form.collect(&:name)
    assert_equal 'Your comment', form[:comment].label
  end
  
  def test_localization_of_prebuild_form
    translations = {
      'firstname_title' => 'Uw voornaam',
      'firstname_label' => 'Voornaam',
      'lastname_label' => 'Achternaam',
      'country_label' => nil
    }   
    form = ActiveForm::Definition.build(:contact)
    form.define_localizer { |formname, elemname, key| translations[ [elemname, key].compact.join('_') ] }   
    assert form.localized? 
    assert_equal 'Uw voornaam', form[:firstname].title
    assert_equal 'Voornaam', form[:firstname].label
    assert_equal 'Achternaam', form[:lastname].label
    assert_equal 'Your familyname', form[:lastname].title
    assert_equal 'Country', form[:country].label
  end
  
  def test_subclassed_definition
    assert_equal ActiveForm::CustomForm, ActiveForm::CustomDefinition.get(:custom)
    assert_equal ActiveForm::CustomForm, ActiveForm::Definition.get(:custom)
    form = ActiveForm::Definition.build(:custom)
    assert_kind_of ActiveForm::CustomDefinition, form
    assert_kind_of ActiveForm::CustomForm, form
    assert_kind_of ActiveForm::Definition, form    
    assert form.respond_to?(:do_something_special)    
  end
  
end