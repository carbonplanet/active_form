require 'test_helper'

class TestLoadDefinition < Test::Unit::TestCase
  
  def setup
    ActiveForm::Definition.load_paths << File.join(File.dirname(__FILE__), 'resources', 'forms')
  end
  
  def test_load_paths
    assert_equal 1, ActiveForm::Definition.load_paths.length
    assert File.directory?(ActiveForm::Definition.load_paths.first)
  end
  
  def test_load_and_build
    klass = ActiveForm::Definition::get(:demo)
    assert_equal ActiveForm::DemoForm, klass
    form = ActiveForm::Definition::build(:demo)
    assert_kind_of ActiveForm::DemoForm, form
  end
  
  def test_load_and_build_shortcuts
    klass = ActiveForm::get(:demo)
    assert_equal ActiveForm::DemoForm, klass
    form = ActiveForm::build(:demo)
    assert_kind_of ActiveForm::DemoForm, form
  end
  
  def test_build_to_html
    expected = %|<form action="#myform" class="active_form" id="myform" method="post">
  <input class="elem_text" id="myform_firstname" name="myform[firstname]" size="30" type="text"/>
  <input class="elem_text" id="myform_lastname" name="myform[lastname]" size="30" type="text"/>
  <input class="elem_submit" id="myform_submit" name="myform[submit]" type="submit" value="Submit"/>
</form>\n|
    assert_equal expected, ActiveForm::Definition::build(:demo, :myform).to_html
  end
  
  def test_append_definition_to_form
    form = ActiveForm::compose :form do |f|
      f << '<h3>One</h3>'
      f << ActiveForm::Definition::build(:demo, :one)
      f << '<h3>Two</h3>'
      f << ActiveForm::Definition::build(:demo, :two)
      f << '<hr />'
      f.remove_elements_of_type(:submit)
      f.submit_element
    end
    expected = %|<form action="#form" class="active_form" id="form" method="post">
<h3>One</h3>
  <input class="elem_text" id="form_one_firstname" name="form[one][firstname]" size="30" type="text"/>
  <input class="elem_text" id="form_one_lastname" name="form[one][lastname]" size="30" type="text"/>
<h3>Two</h3>
  <input class="elem_text" id="form_two_firstname" name="form[two][firstname]" size="30" type="text"/>
  <input class="elem_text" id="form_two_lastname" name="form[two][lastname]" size="30" type="text"/>
<hr />
  <input class="elem_submit" id="form_submit" name="form[submit]" type="submit" value="Submit"/>
</form>\n|
    assert_equal expected, form.to_html
  end
  
  def test_that_sections_are_not_loaded
    assert_equal nil, ActiveForm::Element::Section::get(:demo)
  end
  
  def teardown
    ActiveForm::Definition.load_paths.clear
  end
  
end