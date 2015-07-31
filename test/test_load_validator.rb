require 'test_helper'

class TestLoadValidator < Test::Unit::TestCase
  
  def setup
    ActiveForm::Validator.load_paths << File.join(File.dirname(__FILE__), 'resources', 'validators')
  end
  
  def test_load_paths
    assert_equal 2, ActiveForm::Validator.load_paths.length
    assert File.directory?(ActiveForm::Validator.load_paths.first)
    assert File.directory?(ActiveForm::Validator.load_paths.last)
  end
  
  def test_assign_and_use_validator
    form = ActiveForm::compose :form do |f|
      f.text_element :elem_a, :label => 'A', :value => 'no foo' do |e|
        e.validates_as_required
        e.validates_as_foo
      end
    end
    assert_equal ["required", "foo"], form[:elem_a].validators.collect(&:code)
    assert !form.validate
    assert_equal ["A: should be foo-matic!"], form[:elem_a].errors.collect(&:msg)
  end
  
  def teardown
    ActiveForm::Validator.load_paths.delete_at(1)
  end
  
end