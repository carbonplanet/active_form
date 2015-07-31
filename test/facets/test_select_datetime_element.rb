require 'test_helper'

class TestSelectDatetimeElement < Test::Unit::TestCase
  
  def teardown
    ActiveForm::use_american_formatting
  end
  
  def test_format
    form = ActiveForm::compose :form do |f|
      f.select_datetime_element :start, :format => [:day, :month, :year, :hour, :minute, :second], :range => (2000..2010) do |e|
        e.now = Time.local(2007, 8, 14, 13, 52, 5)
      end
    end
    expected = {"start"=>{"month"=>8, "minute"=>52, "second"=>5, "hour"=>13, "day"=>14, "year"=>2007}}
    assert_equal expected, form.export_values
    assert_equal [:day, :month, :year, :hour, :minute, :second], form[:start].collect(&:name)
  end
  
  def test_european_formatting
    ActiveForm::use_european_formatting
    elem = ActiveForm::Element::SelectDatetime.new :date
    assert_equal [:day, :month, :year, :hour, :minute], elem.collect(&:name)
  end
  
  def test_american_formatting
    ActiveForm::use_american_formatting
    elem = ActiveForm::Element::SelectDatetime.new :date
    assert_equal [:month, :day, :year, :hour, :minute], elem.collect(&:name)
  end
    
  def test_append_any_unknown_parts_as_element
    form = ActiveForm::compose :form do |f|
      f.select_datetime_element :start, :format => ['date: ', :day, :month, :year, '&nbsp;time: ', :hour, :minute, :second], :range => (2000..2005)
    end
    assert_equal [:builder, :day, :month, :year, :builder, :hour, :minute, :second], form[:start].collect(&:name) 
  end
  
  def test_export_value_as_casted
    elem = ActiveForm::Element::SelectDatetime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :hash
    expected = {"month"=>8, "second"=>0, "minute"=>52, "hour"=>13, "day"=>14, "year"=>2007}
    assert_equal expected, elem.export_value
    
    elem = ActiveForm::Element::SelectDatetime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :array
    assert_equal [2007, 8, 14, 13, 52, 0], elem.export_value
    
    elem = ActiveForm::Element::SelectDatetime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :string
    assert_equal "2007-08-14 13:52:00", elem.export_value
    
    elem = ActiveForm::Element::SelectDatetime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :date
    assert_equal Time.local(2007, 8, 14, 13, 52, 0).to_date, elem.export_value
    
    elem = ActiveForm::Element::SelectDatetime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :time
    assert_equal Time.local(2007, 8, 14, 13, 52, 0), elem.export_value
    
    elem = ActiveForm::Element::SelectDatetime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :yaml
    assert_equal "--- 2007-08-14 13:52:00 +02:00\n", elem.export_value
  end
  
end