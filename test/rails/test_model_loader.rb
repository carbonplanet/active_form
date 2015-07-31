require 'test_helper'

class TestModelLoader < Test::Unit::TestCase
  
  fixtures :authors, :books, :categories, :categorizations, :publishers
  
  def setup
    ActiveForm::Definition.load_paths << File.join(File.dirname(__FILE__), '..', 'resources', 'models')
  end
  
  def test_load_model_form
    form = ActiveForm::Model::load!(Book.new)
    assert_kind_of ActiveForm::BookForm, form
    assert_equal [:id, :title, :isbn, :publication_date, :publisher_id, :submit], form.collect(&:name)
    assert_equal [:integer, :string, :string, :date, :integer, nil], form.collect(&:type_cast)
    assert_equal [:day, :month, :year], form[:publication_date].collect(&:name)
    assert_equal "", form[:title].value
    assert_equal 1, form[:publisher_id].value    
  end
  
  def test_load_model_for_record
    form = ActiveForm::Model::load(books(:awdr))
    assert_kind_of ActiveForm::BookForm, form
    assert_equal 1, form[:id].export_value
    assert_equal 'Agile Web Development with Rails', form[:title].export_value
    assert_equal '0-9766940-0-X', form[:isbn].export_value
    assert_equal '2005-08-01', form[:publication_date].export_value.to_s
    assert_equal 1, form[:publisher_id].export_value
  end
  
  def test_load_specific_form
    form = ActiveForm::Model::load(:register, publishers(:pragprog))
    assert_kind_of ActiveForm::RegisterPublisherForm, form
    assert_equal [:id, :name], form.collect(&:name)
    assert_equal 1, form[:id].export_value
    assert_equal 'The Pragmatic Programmers', form[:name].export_value
  end
  
  def test_difference_between_two_load_methods
    form = ActiveForm::Model::load(publishers(:pragprog))
    assert_equal [:id, :name, :created_at, :updated_at], form.collect(&:name)     
    form = ActiveForm::Model::load!(publishers(:pragprog))
    assert_equal [:id, :name, :created_at, :updated_at, :submit], form.collect(&:name) 
  end
  
  def test_validate_form_with_ar_validations
    form = ActiveForm::Model::load(Book.new)
    assert_kind_of ActiveForm::BookForm, form
    assert !form.validate
    assert_equal ["ar_blank", "ar_blank", "ar_invalid"], form.all_errors.collect(&:code)
    assert_equal ["Title: can't be blank", "Isbn: can't be blank", "Isbn: is invalid"], form.all_errors.collect(&:message)
    assert_equal ["Title: can't be blank", "Isbn: can't be blank"], form.initial_errors.collect(&:message)
    assert_equal 1, form[:title].errors.length
    assert_equal 2, form[:isbn].errors.length
  end
  
  def teardown
    ActiveForm::Definition.load_paths.clear
  end
  
end