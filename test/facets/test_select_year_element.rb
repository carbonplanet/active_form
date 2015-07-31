require 'test_helper'

class TestSelectYearElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::SelectYear.new :year
    default_range = Range.new(Time.now.year - 5,  Time.now.year + 5)
    assert_equal [*default_range], elem.collect(&:value)
    assert_equal default_range.map(&:to_s), elem.collect(&:label)
    
    elem = ActiveForm::Element::SelectYear.new :year, :range => (2000..2010)
    default_range = Range.new(2000, 2010)
    assert_equal [*default_range], elem.collect(&:value)
    assert_equal default_range.map(&:to_s), elem.collect(&:label)
     
    elem = ActiveForm::Element::SelectYear.new :year, :range => (2000..2010), :increment => 5
    assert_equal [2000, 2005, 2010], elem.collect(&:value)
    assert_equal ['2000', '2005', '2010'], elem.collect(&:label)
  end
  
  def test_define_start_and_end_year
    elem = ActiveForm::Element::SelectYear.new :year, :start_year => 2000, :end_year => 2006
    range = Range.new(2000, 2006)
    assert_equal [*range], elem.collect(&:value)
    assert_equal range.map(&:to_s), elem.collect(&:label)    
  end
  
  def test_include_empty
    elem = ActiveForm::Element::SelectYear.new :year, :range => (2000..2010)
    assert_equal 2000, elem.options.first.value
    elem = ActiveForm::Element::SelectYear.new :year, :range => (2000..2010), :include_empty => true
    assert_equal :blank, elem.options.first.value
  end
  
  def test_assign_value
    elem = ActiveForm::Element::SelectYear.new :year, :value => 2006
    assert_equal 2006, elem.value
    elem = ActiveForm::Element::SelectYear.new :year, :value => Date.new(2004, 9, 22)
    assert_equal 2004, elem.value
    elem = ActiveForm::Element::SelectYear.new :year, :value => Time.local(2004, 9, 22, 13, 15, 5)
    assert_equal 2004, elem.value
  end
  
  def test_update_from_params
    form = ActiveForm::compose :form do |f|
      f.select_year_element :anno, :range => (2000..2010)
    end
    form.params = { 'form' => { 'anno' => '1996' } }
    assert_equal 2000, form[:anno].value
    form.params = { 'form' => { 'anno' => '2006' } }
    assert_equal 2006, form[:anno].value
    form.params = { 'form' => { 'anno' => '2012' } }
    assert_equal 2010, form[:anno].value
  end
  
  def test_out_of_range_value
    elem = ActiveForm::Element::SelectYear.new :year, :value => 2
    assert_equal Time.now.year - 5, elem.value                           
    elem = ActiveForm::Element::SelectYear.new :year, :value => 3000
    assert_equal Time.now.year + 5, elem.value    
    elem = ActiveForm::Element::SelectYear.new :year, :value => 1996, :range => (2000..2005)
    assert_equal 2000, elem.value                           
    elem = ActiveForm::Element::SelectYear.new :year, :value => 2006, :range => (2000..2005)
    assert_equal 2005, elem.value
  end
  
  def test_select_multiple
    elem = ActiveForm::Element::SelectYear.new :year, :multiple => true, :range => (2000..2005)
    elem.values = [1996, 2002, 2006]
    assert_equal [2000, 2002, 2005], elem.export_value
  end
  
end