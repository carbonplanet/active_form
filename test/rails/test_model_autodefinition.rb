require 'test_helper'

class TestModelAutoDefinition < Test::Unit::TestCase
  
  fixtures :authors, :books, :categories, :categorizations, :publishers
  
  def test_model_instance_attribute
    book = books(:awdr)
    form = ActiveForm::Model::build(book)
    assert form.respond_to?(:model_instance)
    assert form.respond_to?(:model_instance=)
    assert_equal book, form.model_instance
  end
  
  def test_form_name_from_model
    form = ActiveForm::Model::build(Book.new)
    assert_equal :book_form, form.name 
  end
  
  def test_form_name_from_args
    form = ActiveForm::Model::build(Book.new, :myform)
    assert_equal :myform, form.name 
  end
  
  def test_new_record_values
    form = ActiveForm::Model::build(Book.new)
    assert_equal '', form[:title].export_value
    assert_equal '', form[:isbn].export_value
    assert_kind_of Date, form[:publication_date].export_value
    assert_equal 1, form[:publisher_id].export_value
    assert_kind_of Time, form[:created_at].export_value
    assert_kind_of Time, form[:updated_at].export_value
  end
  
  def test_date_defaults_to_now
    form = ActiveForm::Model::build(Book.new)
    now_date = Date.today.to_s
    assert_equal now_date, form[:publication_date].export_value.to_s
  end
  
  def test_time_defaults_to_now
    form = ActiveForm::Model::build(Book.new)
    now_time = Time.now.to_s.gsub(/(\d\d:\d\d):(\d\d)/, '\1:00')
    assert_equal now_time, form[:created_at].export_value.to_s
    assert_equal now_time, form[:updated_at].export_value.to_s
  end
  
  def test_override_time_defaults
    current_time = Time.local(2004, 1, 1, 13, 15, 5)
    current_time_string = current_time.to_s.gsub(/(\d\d:\d\d):(\d\d)/, '\1:00')
    assert_equal "Thu Jan 01 13:15:00 +0100 2004", current_time_string
    book = Book.new(:created_at => current_time)
    form = ActiveForm::Model::build(book)
    assert_equal current_time_string, form[:created_at].export_value.to_s
  end
  
  def test_difference_between_two_build_methods
    form = ActiveForm::Model::build(Book.new)
    assert_equal [:id, :title, :isbn, :publication_date, :publisher_id, :created_at, :updated_at], form.collect(&:name)
    form = ActiveForm::Model::build!(Book.new)
    assert_equal [:id, :title, :isbn, :publication_date, :publisher_id, :created_at, :updated_at, :submit], form.collect(&:name)
  end
  
  def test_form_elements_for_new_book
    form = ActiveForm::Model::build(Book.new)
    assert_kind_of ActiveForm::Definition, form
    form.submit_element
    assert_equal [:id, :title, :isbn, :publication_date, :publisher_id, :created_at, :updated_at, :submit], form.collect(&:name)
    assert_equal ["Id", "Title", "Isbn", "Publication date", "Publisher", "Created at", "Updated at", "Submit"], form.collect(&:label)
    assert_equal [:hidden, :text, :text, :select_date, :select_from_model, :select_datetime, :select_datetime, :submit], form.collect(&:element_type)
    assert_equal [:integer, :string, :string, :date, :integer, :time, :time, nil], form.collect(&:type_cast)
  end
  
  def test_form_elements_for_new_author
    form = ActiveForm::Model::build(Author.new)
    form.submit_element
    assert_equal [:id, :first_name, :last_name, :birth_date, :created_at, :updated_at, :submit], form.collect(&:name)
    assert_equal ["Id", "First name", "Last name", "Birth date", "Created at", "Updated at", "Submit"], form.collect(&:label)
    assert_equal [:hidden, :text, :text, :select_date, :select_datetime, :select_datetime, :submit], form.collect(&:element_type)
    assert_equal [:integer, :string, :string, :date, :time, :time, nil], form.collect(&:type_cast)
  end
  
  def test_form_elements_for_book
    form = ActiveForm::Model::build(books(:awdr))
    assert_equal 1, form[:id].export_value
    assert_equal 'Agile Web Development with Rails', form[:title].export_value
    assert_equal '0-9766940-0-X', form[:isbn].export_value
    assert_equal '2005-08-01', form[:publication_date].export_value.to_s
    assert_equal 1, form[:publisher_id].export_value
  end
  
  def test_validate_form_with_ar_validations
    form = ActiveForm::Model::build(Book.new)
    assert !form.validate
    assert_equal ["ar_blank", "ar_blank", "ar_invalid"], form.all_errors.collect(&:code)
    assert_equal ["Title: can't be blank", "Isbn: can't be blank", "Isbn: is invalid"], form.all_errors.collect(&:message)
    assert_equal ["Title: can't be blank", "Isbn: can't be blank"], form.initial_errors.collect(&:message)
    assert_equal 1, form[:title].errors.length
    assert_equal 2, form[:isbn].errors.length
  end
  
  def test_localization_of_ar_error_messages
    translations = { 
      'book_form_title_label' => 'Titel',
      'book_form_title_validates_ar_blank' => 'Geef een titel op',
      'book_form_isbn_label' => 'ISBN nummer',   
      'book_form_isbn_validates_ar_blank' => 'Geef het ISBN nummer',
      'book_form_isbn_validates_ar_invalid' => 'Onjuist ISBN nummer formaat'
    }
    form = ActiveForm::Model::build(Book.new)
    form.define_localizer { |formname, elemname, key| translations[ [formname, elemname, key].compact.join('_') ] }  
    assert !form.validate
    expected = ["Geef een titel op", "Geef het ISBN nummer", "Onjuist ISBN nummer formaat"]
    assert_equal expected, form.all_errors.collect(&:message)
  end
  
  def test_aggregations
    
  end
    
end