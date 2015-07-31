require 'test_helper'

ActiveForm::Element::Select::create :select_publisher do
  
  def options
    Publisher.find(:all, :order => 'id', :limit => 2).map { |item| ActiveForm::Element::CollectionOption.new(item.name, item.id) }
  end
  
end

class TestSelectFromModelElement < Test::Unit::TestCase
  
  fixtures :publishers
  
  def test_options_for_implicit_definition
    elem = ActiveForm::Element::SelectFromModel.new :publisher_id
    assert_equal 'Publisher', elem.model_class
    elem_options = elem.options
    assert_equal "O'Reilly", elem_options[0].label
    assert_equal 2, elem_options[0].value
    assert_equal "The Pragmatic Programmers", elem_options[1].label
    assert_equal 1, elem_options[1].value
  end

  def test_options_for_explicit_definition
    elem = ActiveForm::Element::SelectFromModel.new :published_by, :model => :publisher
    assert_equal 'Publisher', elem.model_class
    elem_options = elem.options
    assert_equal "O'Reilly", elem_options[0].label
    assert_equal 2, elem_options[0].value
  end

  def test_options_for_custom_find
    elem = ActiveForm::Element::SelectFromModel.new :publisher_id, :find => { :order => 'id', :limit => 2 }
    assert_equal 'Publisher', elem.model_class
    elem_options = elem.options 
    assert_equal "The Pragmatic Programmers", elem_options[0].label
    assert_equal 1, elem_options[0].value
    assert_equal "O'Reilly", elem_options[1].label
    assert_equal 2, elem_options[1].value
  end

  def test_options_with_to_dropdown
    elem = ActiveForm::Element::SelectFromModel.new :publisher_id, :to_dropdown => true
    elem_options = elem.options 
    assert_equal "The Pragmatic Programmers", elem_options[0].label
    assert_equal 1, elem_options[0].value
    assert_equal "O'Reilly", elem_options[1].label
    assert_equal 2, elem_options[1].value
  end

  def test_options_with_group_attr
    elem = ActiveForm::Element::SelectFromModel.new :publisher_id, :group_attr => 'id'
    elem_options = elem.options
    assert_kind_of ActiveForm::Element::CollectionOptionGroup, elem_options.first
    assert_equal "1", elem_options[0].label
    assert_equal "The Pragmatic Programmers", elem_options[0].options[0].label
    assert_equal 1, elem_options[0].options[0].value
  end
  
  def test_syntax_sugar
    form = ActiveForm::compose :book do |f| 
      f.select_from_publishers :publisher_id
    end
    elem_options = form[:publisher_id].options 
    assert_equal "The Pragmatic Programmers", elem_options[0].label
    assert_equal 1, elem_options[0].value
    assert_equal "O'Reilly", elem_options[1].label
    assert_equal 2, elem_options[1].value
  end

  def test_to_html
    form = ActiveForm::compose :book do |f|  
      f.select_publisher_element :publisher_id
    end
    assert_equal :select_publisher, form[:publisher_id].element_type
    expected = %|<form action="#book" class="active_form" id="book" method="post">
  <select class="elem_select_publisher" id="book_publisher_id" name="book[publisher_id]">
    <option value="1">The Pragmatic Programmers</option>
    <option value="2">O'Reilly</option>
  </select>
</form>\n|
    assert_equal expected, form.to_html
  end

end