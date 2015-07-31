require 'test_helper'

class TestSelectTimeElement < Test::Unit::TestCase
  
  def test_format
    form = ActiveForm::compose :form do |f|
      f.select_time_element :start, :format => [:hour, :minute, :second], :minute_increment => 5
    end
    assert_equal [:hour, :minute, :second], form[:start].collect(&:name) 
    form[:start].value = '13:52:05'
    
    expected = { "hour" => 13, "minute" => 50, "second" => 5 }
    assert_equal expected, form[:start].export_value
    
    form[:start].value = '13:52'
    expected = { "hour" => 13, "minute" => 50, "second" => 0 }
    assert_equal expected, form[:start].export_value
  end
  
  def test_assign_value_and_export_value
    form = ActiveForm::compose :form do |f|
      f.select_time_element :start, :minute_increment => 5
    end
    assert_equal [:hour, :minute], form[:start].collect(&:name)    
    expected = { "hour" => 13, "minute" => 50 }
    
    form[:start].value = { :hour => 13, :minute => 52 }
    assert_equal expected, form[:start].export_value    
    
    form[:start].value = Time.local(2004, 1, 1, 13, 52, 5)
    assert_equal expected, form[:start].export_value
    
    form[:start].value = '2004-01-01 13:52:05'
    assert_equal expected, form[:start].export_value
    
    form[:start].value = '13:52:05'
    assert_equal expected, form[:start].export_value
    
    form[:start].value = '13:52'
    assert_equal expected, form[:start].export_value
  end
  
  def test_default_value
    elem = ActiveForm::Element::SelectTime.new :time, :format => [:hour, :minute, :second]
    expected = {"hour"=>12, "minute"=>0, "second"=>0}
    assert_equal expected, elem.export_value
    
    elem = ActiveForm::Element::SelectTime.new :time, :format => [:hour, :minute, :second], :now => Time.local(2004, 1, 1, 13, 52, 5)
    expected = {"hour"=>13, "minute"=>52, "second"=>5}
    assert_equal expected, elem.value
    assert_equal expected, elem.export_value
  end
  
  def test_export_value_as_casted
    elem = ActiveForm::Element::SelectTime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :hash
    expected = {"month"=>8, "second"=>0, "minute"=>52, "hour"=>13, "day"=>14, "year"=>2007}
    assert_equal expected, elem.export_value
    
    elem = ActiveForm::Element::SelectTime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :array
    assert_equal [2007, 8, 14, 13, 52, 0], elem.export_value
    
    elem = ActiveForm::Element::SelectTime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :string
    assert_equal "2007-08-14 13:52:00", elem.export_value
    
    elem = ActiveForm::Element::SelectTime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :date
    assert_equal Time.local(2007, 8, 14, 13, 52, 0).to_date, elem.export_value
    
    elem = ActiveForm::Element::SelectTime.new :time, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :time
    assert_equal Time.local(2007, 8, 14, 13, 52, 0), elem.export_value
  end
  
  def test_update_from_params
    form = ActiveForm::compose :form do |f|
      f.select_time_element :start, :minute_increment => 5
    end
    form.update_from_params({ 'form' => { 'start' => { 'hour' => '9', 'minute' => '22' } } })
    expected = { 'hour' => 9, 'minute' => 20 }
    assert_equal expected, form[:start].export_value
    form.update_from_params({ 'form' => { 'start' => '2004-01-01 13:52:05' } })
    expected = { 'hour' => 13, 'minute' => 50 }
    assert_equal expected, form[:start].export_value  
    form.update_from_params({ 'form' => { 'start' => '13:52:05' } })
    expected = { 'hour' => 13, 'minute' => 50 }
    assert_equal expected, form[:start].export_value
  end
  
  def test_assign_with_now
    form = ActiveForm::compose :form do |f|
      f.select_time_element :start, :format => [:hour, :minute], :minute_increment => 5, :now => Time.local(2004, 1, 1, 13, 52, 5)
    end
    form[:start].value = { :hour => 10, :minute => 22 }
    expected = {"minute"=>20, "hour"=>10}
    assert_equal expected, form[:start].export_value
    
    form = ActiveForm::compose :form do |f|
      f.select_time_element :start, :format => [:hour, :minute, :second], :second_increment => 10, :now => Time.local(2004, 1, 1, 13, 52, 5)
    end
    form[:start].value = { :hour => 10, :minute => 22, :second => 28 }
    expected = {"second"=>30, "minute"=>22, "hour"=>10}
    assert_equal expected, form[:start].export_value   
    form[:start].value = Time.local(2004, 1, 1, 13, 52, 5)
    expected = {"second"=>10, "minute"=>52, "hour"=>13}
    assert_equal expected, form[:start].export_value 
  end
  
  def test_include_empty
    form = ActiveForm::compose :form do |f|
      f.select_time_element :start, :format => [:hour, :minute, :second]
    end
    assert_equal [false], form[:start].collect(&:include_empty?).uniq
    form[:start].include_empty = true
    assert_equal [true], form[:start].collect(&:include_empty?).uniq
  end
  
  def test_element_to_html
    form = ActiveForm::compose :form do |f|
      f.select_time_element :start, :format => [:hour, :minute, :second], :hour_increment => 4, :minute_increment => 20, :second_increment => 20
    end
    expected = %|<div class="active_select_time" id="form_start">
  <span class="elem_select_hour" id="elem_form_start_hour">
    <select class="elem_select_hour" id="form_start_hour" name="form[start][hour]">
      <option value="0">00</option>
      <option value="4">04</option>
      <option value="8">08</option>
      <option selected="selected" value="12">12</option>
      <option value="16">16</option>
      <option value="20">20</option>
    </select>
  </span>
  <span class="elem_select_minute" id="elem_form_start_minute">
    <select class="elem_select_minute" id="form_start_minute" name="form[start][minute]">
      <option selected="selected" value="0">00</option>
      <option value="20">20</option>
      <option value="40">40</option>
    </select>
  </span>
  <span class="elem_select_second" id="elem_form_start_second">
    <select class="elem_select_second" id="form_start_second" name="form[start][second]">
      <option selected="selected" value="0">00</option>
      <option value="20">20</option>
      <option value="40">40</option>
    </select>
  </span>
</div>\n|
    assert_equal expected, form[:start].to_html
  end
  
end