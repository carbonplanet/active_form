require 'test_helper'

class TestLoadSectionElement < Test::Unit::TestCase
  
  def setup
    ActiveForm::Definition.load_paths << File.join(File.dirname(__FILE__), 'resources', 'forms')
    ActiveForm::Definition.load_paths << File.join(File.dirname(__FILE__), 'resources', 'sections')
  end
  
  def test_load_paths
    assert_equal 2, ActiveForm::Definition.load_paths.length
    assert File.directory?(ActiveForm::Definition.load_paths.first)
    assert File.directory?(ActiveForm::Definition.load_paths.last)
  end
  
  def test_load_and_build
    klass = ActiveForm::Element::Section::get(:demo)
    assert_equal ActiveForm::DemoSection, klass
    section = ActiveForm::Element::Section::build(:demo)
    assert_kind_of ActiveForm::DemoSection, section
  end
  
  def test_load_and_add_section_to_form
    form = ActiveForm::compose :form
    form.append_section [:demo, :personal]
    form << :foo
    form << :unknown
    assert_equal [:personal, :foo], form.collect(&:name)
       
    assert_kind_of ActiveForm::DemoSection, form[:personal]
    assert_kind_of ActiveForm::Element::Section, form[:personal]
    assert_equal [:firstname, :lastname], form[:personal].collect(&:name)

    assert_kind_of ActiveForm::FooSection, form[:foo]
    assert_kind_of ActiveForm::Element::Section, form[:foo]
    assert_equal [:title, :body], form[:foo].collect(&:name)
  end
  
  def teardown
    ActiveForm::Definition.load_paths.clear
  end
  
end