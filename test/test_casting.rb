require 'test_helper'

class TestCasting < Test::Unit::TestCase
  
  def test_type_casting
    form = ActiveForm::compose :form do |f|
      f.text_element :string   , :type_cast => :string    , :value => 123
      f.text_element :text     , :type_cast => :text      , :value => 123
      f.text_element :integer  , :type_cast => :integer   , :value => 123
    end
    assert_equal :string, form[:string].type_cast
    assert_equal :text, form[:text].type_cast
    assert_equal :integer, form[:integer].type_cast
  end
  
  def test_cast_raw_element_value    
    form = ActiveForm::compose :form do |f|
      f.text_element :string   , :type_cast => :string    , :value => 123
      f.text_element :text     , :type_cast => :text      , :value => 123
      f.text_element :integer  , :type_cast => :integer   , :value => 123
      f.text_element :float    , :type_cast => :float     , :value => 123
      f.text_element :array    , :type_cast => :array     , :value => 123
      f.text_element :datetime , :type_cast => :datetime  , :value => '2004-01-01 13:15:05'
      f.text_element :timestamp, :type_cast => :timestamp , :value => '2004-01-01 13:15:05'
      f.text_element :time     , :type_cast => :time      , :value => '13:15:05'
      f.text_element :date     , :type_cast => :date      , :value => '2004-01-01'
      f.text_element :boolean  , :type_cast => :boolean   , :value => 'f'   
    end
    assert_equal '123',   form[:string].element_value
    assert_equal '123',   form[:text].element_value
    assert_equal 123,     form[:integer].element_value
    assert_equal 123.0,   form[:float].element_value
    assert_equal [123],   form[:array].element_value
    assert_equal false,   form[:boolean].element_value
    assert_kind_of Time, form[:time].element_value
    assert_equal Date.new(2004, 1, 1), form[:date].element_value
    assert_equal Time.local(2004, 1, 1, 13, 15, 5), form[:datetime].element_value
    assert_equal Time.local(2004, 1, 1, 13, 15, 5), form[:timestamp].element_value
  end  
  
  def test_cast_native_element_value    
    form = ActiveForm::compose :form do |f|
      f.text_element :string    , :type_cast => :string    , :value => 'abc'
      f.text_element :text      , :type_cast => :text      , :value => 'abc'
      f.text_element :integer   , :type_cast => :integer   , :value => 123
      f.text_element :float     , :type_cast => :float     , :value => 123.0
      f.text_element :array     , :type_cast => :array     , :value => [1, 2, 3]
      f.text_element :datetime  , :type_cast => :datetime  , :value => Time.local(2004, 1, 1, 13, 15, 5)
      f.text_element :timestamp , :type_cast => :timestamp , :value => Time.local(2004, 1, 1, 13, 15, 5)
      f.text_element :time      , :type_cast => :time      , :value => Time.now
      f.text_element :date      , :type_cast => :date      , :value => Date.new(2004, 1, 1)
      f.text_element :boolean   , :type_cast => :boolean   , :value => true
    end                         
    assert_equal 'abc',   form[:string].element_value
    assert_equal 'abc',   form[:text].element_value
    assert_equal 123,     form[:integer].element_value
    assert_equal 123.0,   form[:float].element_value
    assert_equal [1, 2, 3],   form[:array].element_value
    assert_equal true,   form[:boolean].element_value
    assert_kind_of Time, form[:time].element_value
    assert_equal Date.new(2004, 1, 1), form[:date].element_value
    assert_equal Time.local(2004, 1, 1, 13, 15, 5), form[:datetime].element_value
    assert_equal Time.local(2004, 1, 1, 13, 15, 5), form[:timestamp].element_value
  end 
  
  def test_cast_to_yaml
    form = ActiveForm::compose :form do |f|
      f.text_element :string, :type_cast => :yaml, :value => "--- 2007-08-14 13:52:00 +02:00\n"
    end
    assert_equal Time.local(2007, 8, 14, 13, 52, 0), form[:string].element_value
    assert_equal "--- 2007-08-14 13:52:00 +02:00\n", form[:string].formatted_value
    
    form = ActiveForm::compose :form do |f|
      f.text_element :string, :type_cast => :yaml, :value => Time.local(2007, 8, 14, 13, 52, 0)
    end
    assert_equal Time.local(2007, 8, 14, 13, 52, 0), form[:string].element_value
    assert_equal "--- 2007-08-14 13:52:00 +02:00\n", form[:string].formatted_value
  end
  
  def test_set_value
    form = ActiveForm::compose :form do |f|
      f.text_element :integer, :type_cast => :integer
    end
    form[:integer].value = 123
    assert_equal 123, form[:integer].value
    form[:integer].value = '123'
    assert_equal 123, form[:integer].value
  end
  
  def test_update_value
    form = ActiveForm::compose :form do |f|
      f.text_element :integer  , :type_cast => :integer
      f.text_element :datetime , :type_cast => :datetime   
    end
    form.update_values(:datetime => Time.local(2004, 1, 1, 13, 15, 5), :integer => 123)
    
    expected = { 'datetime' => Time.local(2004, 1, 1, 13, 15, 5), 'integer' => 123 }
    assert_equal expected, form.export_values
    
    assert_equal 123,   form[:integer].element_value
    assert_equal '123', form[:integer].formatted_value
    
    assert_equal Time.local(2004, 1, 1, 13, 15, 5), form[:datetime].element_value
    assert_equal 'January 01, 2004 13:15', form[:datetime].formatted_value
  end
  
  def test_update_from_params
    form = ActiveForm::compose :form do |f|
      f.text_element :integer  , :type_cast => :integer
      f.text_element :datetime , :type_cast => :datetime
    end
    form.update_from_params('form' => { 'datetime' => '2004-01-01 13:15:05', 'integer' => '123' })
    
    expected = { 'datetime' => Time.local(2004, 1, 1, 13, 15, 5), 'integer' => 123 }
    assert_equal expected, form.export_values
    
    assert_equal 123,   form[:integer].element_value
    assert_equal '123', form[:integer].formatted_value
        
    assert_equal Time.local(2004, 1, 1, 13, 15, 5), form[:datetime].element_value
    assert_equal 'January 01, 2004 13:15', form[:datetime].formatted_value   
  end
  
end