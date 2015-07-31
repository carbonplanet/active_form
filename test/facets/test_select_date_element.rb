require 'test_helper'

class TestSelectDateElement < Test::Unit::TestCase
  
  def teardown
    ActiveForm::use_american_formatting
  end
  
  def test_format
    form = ActiveForm::compose :form do |f|
      f.select_date_element :start, :format => [:day, :month, :year], :range => (2000..2005)
    end
    assert_equal [:day, :month, :year], form[:start].collect(&:name) 
    range = Range.new(2000, 2005)
    assert_equal [*range], form[:start][:year].collect(&:value)
    assert_equal range.map(&:to_s), form[:start][:year].collect(&:label) 
  end
  
  def test_european_formatting
    ActiveForm::use_european_formatting
    elem = ActiveForm::Element::SelectDate.new :date
    assert_equal [:day, :month, :year], elem.collect(&:name)
  end
  
  def test_american_formatting
    ActiveForm::use_american_formatting
    elem = ActiveForm::Element::SelectDate.new :date
    assert_equal [:month, :day, :year], elem.collect(&:name)
  end
  
  def test_invalid_dates
    expected = {"month"=>1, "day"=>1, "year"=>2000}   
    elem = ActiveForm::Element::SelectDate.new :date, :start_year => 2000, :end_year => 2010
    elem.value = '34-11-2006'
    assert_equal expected, elem.export_value
    elem.value = '2-34-2006'
    assert_equal expected, elem.export_value
    elem.value = nil
    assert_equal expected, elem.export_value
    elem.value = ''
    assert_equal expected, elem.export_value
    elem.value = { :month => 24, :day => 2, :year => 2005 }
    expected = {"month"=>12, "day"=>2, "year"=>2005}  
    assert_equal expected, elem.export_value
  end
  
  def test_define_start_and_end_year
    elem = ActiveForm::Element::SelectDate.new :date, :start_year => 2000, :end_year => 2006
    range = Range.new(2000, 2006)
    assert_equal [*range], elem[:year].collect(&:value)
    assert_equal range.map(&:to_s), elem[:year].collect(&:label)    
  end
  
  def test_assign_value_and_export_value
    form = ActiveForm::compose :form do |f|
      f.select_date_element :start, :format => [:day, :month, :year], :range => (2005..2010)
    end
    expected = {"month"=>1, "day"=>1, "year"=>2005}
    assert_equal expected, form[:start].export_value 
    
    form[:start].value = { :day => 11, :month => 9 }
    expected = {"month"=>9, "day"=>11, "year"=>2005}
    assert_equal expected, form[:start].export_value 
    
    form[:start].value = { :day => 11, :month => 9, :year => 2008 }
    expected = {"month"=>9, "day"=>11, "year"=>2008}
    assert_equal expected, form[:start].export_value 
    
    form[:start].value = Time.local(2007, 8, 14, 13, 52, 5)
    expected = {"month"=>8, "day"=>14, "year"=>2007}
    assert_equal expected, form[:start].export_value
    
    form[:start].value = '2007-08-14 13:52:05'
    expected = {"month"=>8, "day"=>14, "year"=>2007}
    assert_equal expected, form[:start].export_value
    
    form[:start].value = '2007-08-14'
    expected = {"month"=>8, "day"=>14, "year"=>2007}
    assert_equal expected, form[:start].export_value
    
    form[:start].value = '14-08-2007'
    expected = {"month"=>8, "day"=>14, "year"=>2007}
    assert_equal expected, form[:start].export_value
  end
  
  def test_export_value_as_casted
    elem = ActiveForm::Element::SelectDate.new :date, :range => (2000..2010)
    elem.value = '2007-08-14'
    expected = {"month"=>8, "day"=>14, "year"=>2007}
    assert_equal expected, elem.export_value
    
    elem = ActiveForm::Element::SelectDate.new :date, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :hash
    expected = {"month"=>8, "second"=>5, "minute"=>52, "hour"=>13, "day"=>14, "year"=>2007}
    assert_equal expected, elem.export_value
    
    elem = ActiveForm::Element::SelectDate.new :date, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :array
    assert_equal [2007, 8, 14, 13, 52, 5], elem.export_value
    
    elem = ActiveForm::Element::SelectDate.new :date, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :string
    assert_equal "2007-08-14 13:52:05", elem.export_value
    
    elem = ActiveForm::Element::SelectDate.new :date, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :date
    assert_equal Time.local(2007, 8, 14, 13, 52, 5).to_date, elem.export_value
    
    elem = ActiveForm::Element::SelectDate.new :date, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010), :type_cast => :time
    assert_equal Time.local(2007, 8, 14, 13, 52, 5), elem.export_value
  end
  
  def test_default_value
    elem = ActiveForm::Element::SelectDate.new :date, :range => (2000..2010)
    expected = {"month"=>1, "day"=>1, "year"=>2000}
    assert_equal expected, elem.export_value
    
    elem = ActiveForm::Element::SelectDate.new :date, :now => Time.local(2007, 8, 14, 13, 52, 5), :range => (2000..2010)
    expected = {"month"=>8, "day"=>14, "year"=>2007}
    assert_equal expected, elem.value
    assert_equal expected, elem.export_value
  end
  
  def test_update_from_params
    form = ActiveForm::compose :form do |f|
      f.select_date_element :start, :range => (2000..2010)
    end
    expected = { 'month' => 9, 'day' => 22, 'year' => 2006 }
    form.update_from_params({ 'form' => { 'start' => { 'month' => '9', 'day' => '22', 'year' => '2006' } } })
    assert_equal expected, form[:start].export_value  
    form.update_from_params({ 'form' => { 'start' => '22-09-2006 13:52:05' } })
    assert_equal expected, form[:start].export_value  
    form.update_from_params({ 'form' => { 'start' => '22-09-2006' } })
    assert_equal expected, form[:start].export_value
    form.update_from_params({ 'form' => { 'start' => '2006/09/22' } })
    assert_equal expected, form[:start].export_value
  end
  
  def test_assign_with_now
    form = ActiveForm::compose :form do |f|
      f.select_date_element :start, :now => Time.local(2004, 12, 24, 13, 52, 5), :range => (2000..2010)
    end
    expected = {"month"=>12, "day"=>24, "year"=>2004}
    assert_equal expected, form[:start].export_value
  end

  def test_element_to_html
    form = ActiveForm::compose :form do |f|
      f.select_date_element :start, :format => [:day, :month, :year], :range => (2005..2006) do |e|
        e[:month].use_short_month = true
      end
    end
    expected = %|<div class="active_select_date" id="form_start">
  <span class="elem_select_day" id="elem_form_start_day">
    <select class="elem_select_day" id="form_start_day" name="form[start][day]">
      <option selected="selected" value="1">01</option>
      <option value="2">02</option>
      <option value="3">03</option>
      <option value="4">04</option>
      <option value="5">05</option>
      <option value="6">06</option>
      <option value="7">07</option>
      <option value="8">08</option>
      <option value="9">09</option>
      <option value="10">10</option>
      <option value="11">11</option>
      <option value="12">12</option>
      <option value="13">13</option>
      <option value="14">14</option>
      <option value="15">15</option>
      <option value="16">16</option>
      <option value="17">17</option>
      <option value="18">18</option>
      <option value="19">19</option>
      <option value="20">20</option>
      <option value="21">21</option>
      <option value="22">22</option>
      <option value="23">23</option>
      <option value="24">24</option>
      <option value="25">25</option>
      <option value="26">26</option>
      <option value="27">27</option>
      <option value="28">28</option>
      <option value="29">29</option>
      <option value="30">30</option>
      <option value="31">31</option>
    </select>
  </span>
  <span class="elem_select_month" id="elem_form_start_month">
    <select class="elem_select_month" id="form_start_month" name="form[start][month]">
      <option selected="selected" value="1">Jan</option>
      <option value="2">Feb</option>
      <option value="3">Mar</option>
      <option value="4">Apr</option>
      <option value="5">May</option>
      <option value="6">Jun</option>
      <option value="7">Jul</option>
      <option value="8">Aug</option>
      <option value="9">Sep</option>
      <option value="10">Oct</option>
      <option value="11">Nov</option>
      <option value="12">Dec</option>
    </select>
  </span>
  <span class="elem_select_year" id="elem_form_start_year">
    <select class="elem_select_year" id="form_start_year" name="form[start][year]">
      <option selected="selected" value="2005">2005</option>
      <option value="2006">2006</option>
    </select>
  </span>
</div>\n|
    assert_equal expected, form[:start].to_html
  end
  
end