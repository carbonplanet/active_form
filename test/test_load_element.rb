require 'test_helper'

class TestLoadElement < Test::Unit::TestCase
  
  def setup
    ActiveForm::Element.load_paths << File.join(File.dirname(__FILE__), 'resources', 'elements')
  end
  
  def test_load_paths
    assert_equal 3, ActiveForm::Element.load_paths.length
    assert File.directory?(ActiveForm::Element.load_paths[0])
    assert File.directory?(ActiveForm::Element.load_paths[1])
    assert File.directory?(ActiveForm::Element.load_paths[2])
  end
  
  def test_load_and_build
    assert_equal ActiveForm::Element::Chunky, ActiveForm::Element::get(:chunky)
    elem = ActiveForm::Element::build(:chunky)
    assert_kind_of ActiveForm::Element::Chunky, elem
  end
  
  def test_add_form_elements
    form = ActiveForm::compose :form do |f|
      f.text_element :name
      f.chunky_element :why
    end
    assert_equal [:text, :chunky], form.collect(&:element_type)
    assert_equal %|<h1 class="elem_chunky" id="form_why">Chunky Bacon!</h1>\n|, form[:why].to_html
  end
  
  def teardown
    ActiveForm::Element.load_paths.delete_at(2)
  end
  
end