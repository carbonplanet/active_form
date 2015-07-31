require 'test_helper'

class TestSelectElement < Test::Unit::TestCase
  
  def test_set_attributes
    [:title, :lang, :size].each do |attribute|
      assert ActiveForm::Element::Select.element_attribute_names.include?(attribute)
    end 
    elem = ActiveForm::Element::Select.new :elem, :size => 20
    expected = {"name"=>"elem", "class"=>"elem_select", "id"=>"elem", "size"=>20}
    assert_equal expected, elem.element_attributes
  end
  
  def test_multiple
    elem = ActiveForm::Element::Select.new :choices, :options => %w{ one two three four }
    assert !elem.multiple?
    
    elem = ActiveForm::Element::Select.new :choices, :options => %w{ one two three four }, :multiple => true
    assert elem.multiple?
  end
  
  def test_html_flags
    assert ActiveForm::Element::Select.element_html_flag_names.include?(:multiple)
    elem = ActiveForm::Element::Select.new :elem, :size => 20, :multiple => true, :disabled => true
    expected = {"name"=>"elem[]", "class"=>"elem_select disabled", "id"=>"elem", "size"=>20, "disabled"=>"disabled", "multiple"=>"multiple"}
    assert_equal expected, elem.element_attributes
  end
  
  def test_element_value
    elem = ActiveForm::Element::Select.new :elem, :options => %w{ Barney Fred Wilma }, :value => "Fred"
    assert_equal "Fred", elem.element_value
    assert elem.selected?("Fred")
    elem = ActiveForm::Element::Select.new :elem, :options => %w{ Barney Fred Wilma }, :selected => "Fred"
    assert_equal "Fred", elem.element_value
    assert elem.selected?("Fred")
  end
  
  def test_default_value
    elem = ActiveForm::Element::Select.new :elem
    assert_equal nil, elem.default_value
    elem = ActiveForm::Element::Select.new :elem, :multiple => true
    assert_equal [], elem.default_value
  end
  
  def test_fallback_value
    elem = ActiveForm::Element::Select.new :elem, :options => ['this', 'that', 'other'], :default => 'no preference'
    assert_equal nil, elem.value
    assert_equal nil, elem.default_value
    assert_equal 'no preference', elem.fallback_value
    assert_equal 'no preference', elem.export_value
    elem.value = 'other'
    assert_equal 'other', elem.export_value
    elem = ActiveForm::Element::Select.new :elem, :options => ['this', 'that', 'other'], :default => 'no preference', :multiple => true
    assert_equal [], elem.value
    assert_equal [], elem.default_value
    assert_equal ['no preference'], elem.fallback_value
    assert_equal ['no preference'], elem.export_value
    elem.value = 'other'
    assert_equal ['other'], elem.export_value
    elem = ActiveForm::Element::Select.new :elem, :options => ['red', 'green', 'blue'], :default => ['red', 'green'], :multiple => true
    assert_equal [], elem.value
    assert_equal [], elem.default_value
    assert_equal ['red', 'green'], elem.fallback_value
    assert_equal ['red', 'green'], elem.export_value
    elem.value = 'blue'
    assert_equal ['blue'], elem.export_value 
  end
  
  def test_set_select_options
    elem = ActiveForm::Element::Select.new :elem do |e|
      e << 'Barney'
      e << 'Fred'   
      e << ['Wilma', 3]
      e.option('Betty')
      e.option('Pebbles', 5)
    end
    assert_equal ["Barney", "Fred", 'Wilma', 'Betty', 'Pebbles'], elem.options.collect(&:label)
    assert_equal ["Barney", "Fred", 3, 'Betty', 5], elem.options.collect(&:value)
    elem = ActiveForm::Element::Select.new :elem do |e|
      e << 'Barney' << 'Fred' << 'Wilma'
    end
    assert_equal ["Barney", "Fred", 'Wilma'], elem.options.collect(&:label)
    assert_equal ["Barney", "Fred", 'Wilma'], elem.options.collect(&:value)
  end
  
  def test_simple_select_options
    elem = ActiveForm::Element::Select.new :elem, :options => %w{ Barney Fred Wilma }, :value => "Fred"
    assert_equal ["Barney", "Fred", "Wilma"], elem.options.collect(&:value)
    assert_equal "Fred", elem.element_value
    assert elem.selected?("Fred")
  end
  
  def test_normal_select_options
    elem = ActiveForm::Element::Select.new :elem, :options => [["Barney", 1], ["Fred", 2], ["Wilma", 3]], :value => 3
    assert_equal [1, 2, 3], elem.options.collect(&:value)
    assert_equal 3, elem.element_value
    assert elem.selected?(3)
  end
  
  def test_simple_select_options_multiple
    elem = ActiveForm::Element::Select.new :elem, :multiple => true, :options => %w{ Barney Fred Wilma }, :value => "Fred"
    assert_equal ["Barney", "Fred", "Wilma"], elem.options.collect(&:value)
    assert_equal ["Fred"], elem.element_value
    assert elem.selected?("Fred")
  end
  
  def test_normal_select_options_multiple
    elem = ActiveForm::Element::Select.new :elem, :multiple => true, :options => [["Barney", 1], ["Fred", 2], ["Wilma", 3]], :value => 3
    assert_equal [1, 2, 3], elem.options.collect(&:value)
    assert_equal [3], elem.element_value
    assert elem.selected?(3)
  end
  
  def test_select_options_multiple
    elem = ActiveForm::Element::Select.new :elem, :multiple => true, :options => [["Barney", 1], ["Fred", 2], ["Wilma", 3]], :value => [2, 3]
    assert_equal [1, 2, 3], elem.options.collect(&:value)
    assert_equal [2, 3], elem.element_value
    assert elem.selected?(2)
    assert elem.selected?(3)
  end
  
  def test_element_to_html
    elem = ActiveForm::Element::Select.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :selected => 2
    expected = %`<select class="elem_select" id="elem" name="elem">
  <option value="1">Barney</option>
  <option selected="selected" value="2">Fred</option>
  <option value="3">Wilma</option>
</select>\n`
    assert_equal expected, elem.to_html    
  end
  
  def test_element_to_html_multiple
    elem = ActiveForm::Element::Select.new :elem, :multiple => true, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :value => [2, 3]
    expected = %`<select class="elem_select" id="elem" multiple="multiple" name="elem[]">
  <option value="1">Barney</option>
  <option selected="selected" value="2">Fred</option>
  <option selected="selected" value="3">Wilma</option>
</select>\n`
    assert_equal expected, elem.to_html    
  end
  
  def test_element_to_html_options_group
    elem = ActiveForm::Element::Select.new :elem, :value => 'Wilma' do |e|
      e.option_group 'People' do |og|
        og.option 'Barney'
        og.option 'Fred'
        og.option 'Wilma'
      end
      e.option_group('Animals', ['Dino', 'Pluto'])
      e.option_group('Cartoons', [['Simpsons', 'si'], ['Cow&Chicken', 'cc']])
    end
    expected = %`<select class="elem_select" id="elem" name="elem">
  <optgroup label="People">
    <option value="Barney">Barney</option>
    <option value="Fred">Fred</option>
    <option selected="selected" value="Wilma">Wilma</option>
  </optgroup>
  <optgroup label="Animals">
    <option value="Dino">Dino</option>
    <option value="Pluto">Pluto</option>
  </optgroup>
  <optgroup label="Cartoons">
    <option value="si">Simpsons</option>
    <option value="cc">Cow&amp;Chicken</option>
  </optgroup>
</select>\n`
    assert_equal expected, elem.to_html   
  end
  
  def test_element_to_html_options_group_multiple
    elem = ActiveForm::Element::Select.new :elem, :multiple => true, :value => %w{ Wilma Dino } do |e|
      e.option_group 'People', ['Barney', 'Fred', 'Wilma']
      e.option_group('Animals', ['Dino', 'Pluto'])
      e.option_group('Cartoons', [['Simpsons', 'si'], ['Cow&Chicken', 'cc']])
    end
    expected = %`<select class="elem_select" id="elem" multiple="multiple" name="elem[]">
  <optgroup label="People">
    <option value="Barney">Barney</option>
    <option value="Fred">Fred</option>
    <option selected="selected" value="Wilma">Wilma</option>
  </optgroup>
  <optgroup label="Animals">
    <option selected="selected" value="Dino">Dino</option>
    <option value="Pluto">Pluto</option>
  </optgroup>
  <optgroup label="Cartoons">
    <option value="si">Simpsons</option>
    <option value="cc">Cow&amp;Chicken</option>
  </optgroup>
</select>\n`
    assert_equal expected, elem.to_html   
  end
  
  def test_render_frozen
    elem = ActiveForm::Element::Select.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :frozen => true
    assert_equal "<span class=\"blank\">-</span>\n", elem.to_html
    elem = ActiveForm::Element::Select.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :selected => 2, :frozen => true
    assert_equal 'Fred', elem.to_html
  end
  
  def test_render_frozen_multiple
    elem = ActiveForm::Element::Select.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :multiple => true, :frozen => true
    assert_equal "<span class=\"blank\">-</span>\n", elem.to_html
    elem = ActiveForm::Element::Select.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :selected => [2, 3], :multiple => true, :frozen => true
    assert_equal 'Fred, Wilma', elem.to_html
  end
  
  def test_reset_options
    elem = ActiveForm::Element::Select.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :add_empty => true
    assert_equal ["--", "Barney", "Fred", "Wilma"], elem.options.collect(&:label)
    elem.reset_options!
    assert_equal [], elem.options.collect(&:label)
  end
  
  def test_add_empty_option
    elem = ActiveForm::Element::Select.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :add_empty => true
    assert_equal ['--', :blank], [elem.options.first.label, elem.options.first.value]                       
    elem = ActiveForm::Element::Select.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :empty_option => 'choose a name:'
    assert_equal ['choose a name:', :blank], [elem.options.first.label, elem.options.first.value]           
    elem = ActiveForm::Element::Select.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :empty => 'choose a name:'
    assert_equal ['choose a name:', :blank], [elem.options.first.label, elem.options.first.value]
    elem = ActiveForm::Element::Select.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ] do |e|
      e.add_empty_option
    end
    assert_equal ['--', :blank], [elem.options.first.label, elem.options.first.value]
  end
  
  def test_no_initial_value
    form = ActiveForm::compose :myform do |f|
      f.select_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
    end
    assert_equal nil, form[:people].value
    form = ActiveForm::compose :myform do |f|
      f.select_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :multiple => true
    end
    assert_equal [], form[:people].value
  end
  
  def test_set_initial_value
    values = { :people => 2 }
    form = ActiveForm::compose :myform, :values => values do |f|
      f.select_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :multiple => true
    end
    assert_equal [2], form[:people].value
    assert_equal [2], form[:people].export_value
    form.values = { :people => [2, 3] }
    assert_equal [2, 3], form[:people].value
    assert_equal [2, 3], form[:people].export_value
    expected = { "people" => [2, 3] }
    assert_equal expected, form.export_values
  end
  
  def test_export_value
    form = ActiveForm::compose :myform do |f|
      f.select_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :multiple => true
    end
    form[:people].selected = [2, 3]
    expected = { "people" => [2, 3] }
    assert_equal expected, form.export_values
  end
  
  def test_update_from_params
    form = ActiveForm::compose :myform do |f|
      f.select_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
    end
    params = { :myform => { :people => [3] } }
    form.update_from_params(params)
    expected = { "people" => 3 }
    assert_equal expected, form.export_values
    
    form = ActiveForm::compose :myform do |f|
      f.select_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :multiple => true
    end
    params = { :myform => { :people => [3] } }
    form.update_from_params(params)
    expected = { "people" => [3] }
    assert_equal expected, form.export_values
  end
  
  def test_required_validation
    form = ActiveForm::compose :myform do |f|
      f.select_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :required => true
    end
    assert form[:people].blank?
    assert !form.validate
    assert_equal ["required"], form[:people].errors.collect(&:code)
    form[:people].value = 2
    assert form.validate
    form[:people].value = 7
    assert form[:people].blank?
    assert !form.validate
  end
  
  def test_option_count_validation
    form = ActiveForm::compose :myform do |f|
      f.select_element :alpha, :options => ('a'..'z'), :required => true
    end
    assert !form.validate
    assert_equal ["required"], form[:alpha].errors.collect(&:code)
    assert_equal ["Alpha: can't be blank"], form[:alpha].errors.collect(&:msg)
    form[:alpha].value = 'a'
    assert form.validate
    
    form = ActiveForm::compose :myform do |f|
      f.select_element :alpha, :options => ('a'..'z'), :required => 3, :multiple => true
    end
    assert !form.validate
    assert_equal ["required"], form[:alpha].errors.collect(&:code)
    assert_equal ["Alpha: you need to select 3 items"], form[:alpha].errors.collect(&:msg)
    form[:alpha].value = ['a', 'b', 'c']
    assert form.validate
    
    form = ActiveForm::compose :myform do |f|
      f.select_element :alpha, :options => ('a'..'z'), :required => 2..4, :multiple => true do |e|
        e.required_message = "%1$s: you need to select between %3$s and %4$s items"
      end
    end
    assert !form.validate
    assert_equal ["required"], form[:alpha].errors.collect(&:code)
    assert_equal ["Alpha: you need to select between 2 and 4 items"], form[:alpha].errors.collect(&:msg)
    form[:alpha].value = ['a']
    assert !form.validate
    form[:alpha].value = ['a', 'b']
    assert form.validate
    form[:alpha].value = ['a', 'b', 'c']
    assert form.validate
    form[:alpha].value = ['a', 'b', 'c', 'd']
    assert form.validate
    form[:alpha].value = ['a', 'b', 'c', 'd', 'e']
    assert !form.validate
  end
  
  def test_valid_option
    elem = ActiveForm::Element::Select.new :elem, :multiple => true do |e|
      e.option_group 'People', ['Barney', 'Fred', 'Wilma']
      e.option_group 'Animals', ['Dino', 'Pluto']
    end
    assert elem.valid_option?('Barney')
    assert elem.valid_option?('Dino')
    assert !elem.valid_option?('Pebbles')
  end
  
  def test_enumerable_methods
    form = ActiveForm::compose :myform do |f|
      f.select_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
    end
    assert_equal ["Barney", "Fred", "Wilma"], form[:people].option_labels
    assert_equal ["Barney", "Fred", "Wilma"], form[:people].collect(&:label)
    assert_equal [1, 2, 3], form[:people].option_values
    assert_equal [1, 2, 3], form[:people].collect(&:value)
  end
  
  def test_enumerable_methods_group
    elem = ActiveForm::Element::Select.new :elem, :multiple => true do |e|
      e.option_group 'People', ['Barney', 'Fred', 'Wilma']
      e.option_group 'Animals', ['Dino', 'Pluto']
    end
    assert_equal ["Barney", "Fred", "Wilma", "Dino", "Pluto"], elem.option_labels
    assert_equal ["Barney", "Fred", "Wilma", "Dino", "Pluto"], elem.option_values
    assert_equal ["People", "Animals"], elem.collect(&:label)
    assert_equal ["Barney", "Fred", "Wilma", "Dino", "Pluto"], elem.collect(&:options).flatten.collect(&:label)
  end
  
end