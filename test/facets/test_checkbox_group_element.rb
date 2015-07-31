require 'test_helper'

class TestCheckboxGroupElement < Test::Unit::TestCase
  
  def test_multiple
    elem = ActiveForm::Element::CheckboxGroup.new :choices, :options => %w{ one two three four }
    assert elem.multiple?
  end
  
  def test_add_options
    elem = ActiveForm::Element::CheckboxGroup.new :choices, :options => %w{ one two three four }
    assert_equal ['one', 'two', 'three', 'four'], elem.options.collect(&:label)
    assert_equal ['one', 'two', 'three', 'four'], elem.options.collect(&:value)
    
    elem = ActiveForm::Element::CheckboxGroup.new :choices, :options => [ ['one', 1], ['two', 2], ['three', 3], ['four', 4] ]
    assert_equal ['one', 'two', 'three', 'four'], elem.options.collect(&:label)
    assert_equal [1, 2, 3, 4], elem.options.collect(&:value)
    
    elem.option('five', 5)
    assert_equal ['one', 'two', 'three', 'four', 'five'], elem.options.collect(&:label)
    assert_equal [1, 2, 3, 4, 5], elem.options.collect(&:value) 
  end
  
  def test_element_value
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => %w{ Barney Fred Wilma }, :value => "Fred"
    assert_equal ["Fred"], elem.element_value
    assert elem.selected?("Fred")
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => %w{ Barney Fred Wilma }, :selected => "Fred"
    assert_equal ["Fred"], elem.element_value
    assert elem.selected?("Fred")
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => %w{ Barney Fred Wilma }, :selected => ["Fred", "Wilma"]
    assert_equal ["Fred", "Wilma"], elem.element_value
    assert elem.selected?("Fred")
    assert elem.selected?("Wilma")
  end
  
  def test_default_value
    elem = ActiveForm::Element::CheckboxGroup.new :elem
    assert_equal [], elem.default_value
  end
  
  def test_fallback_value
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => ['this', 'that', 'other'], :default => 'no preference'
    assert_equal [], elem.value
    assert_equal [], elem.default_value
    assert_equal ['no preference'], elem.fallback_value
    assert_equal ['no preference'], elem.export_value
    elem.value = 'other'
    assert_equal ['other'], elem.export_value
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => ['red', 'green', 'blue'], :default => ['red', 'green']
    assert_equal [], elem.value
    assert_equal [], elem.default_value
    assert_equal ['red', 'green'], elem.fallback_value
    assert_equal ['red', 'green'], elem.export_value
    elem.value = 'blue'
    assert_equal ['blue'], elem.export_value 
  end
  
  def test_simple_group_options_multiple
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => %w{ Barney Fred Wilma }, :value => "Fred"
    assert_equal ["Barney", "Fred", "Wilma"], elem.options.collect(&:value)
    assert_equal ["Fred"], elem.element_value
    assert elem.selected?("Fred")
  end
  
  def test_normal_group_options_multiple
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => [["Barney", 1], ["Fred", 2], ["Wilma", 3]], :value => 3
    assert_equal [1, 2, 3], elem.options.collect(&:value)
    assert_equal [3], elem.element_value
    assert elem.selected?(3)
  end
  
  def test_group_options_multiple
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => [["Barney", 1], ["Fred", 2], ["Wilma", 3]], :value => [2, 3]
    assert_equal [1, 2, 3], elem.options.collect(&:value)
    assert_equal [2, 3], elem.element_value
    assert elem.selected?(2)
    assert elem.selected?(3)
  end
  
  def test_each_option_column
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => ('a'..'e'), :columns => 2
    result = []
    elem.each_option_column { |options| result << options.compact.collect(&:value) }
    assert_equal [["a", "b", "c"], ["d", "e"]], result
    elem.columns = 3
    result = []
    elem.each_option_column { |options| result << options.compact.collect(&:value) }
    assert_equal [["a", "b"], ["c", "d"], ["e"]], result
    elem.columns = 10
    result = []
    elem.each_option_column { |options| result << options.compact.collect(&:value) }
    assert_equal [["a"], ["b"], ["c"], ["d"], ["e"], [], [], [], [], [], [], []], result
  end
  
  def test_element_to_html
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :value => [2, 3]
    assert_equal [2, 3], elem.values
    assert elem.selected?(2)
    assert elem.selected?(3)
    
    expected = %|<fieldset class="elem_checkbox_group" id="elem">
  <span class="elem">
    <input class="elem_checkbox" id="elem_barney" name="elem[]" type="checkbox" value="1"/>
    <label for="elem_barney">Barney</label>
  </span>
  <span class="elem">
    <input checked="checked" class="elem_checkbox" id="elem_fred" name="elem[]" type="checkbox" value="2"/>
    <label for="elem_fred">Fred</label>
  </span>
  <span class="elem">
    <input checked="checked" class="elem_checkbox" id="elem_wilma" name="elem[]" type="checkbox" value="3"/>
    <label for="elem_wilma">Wilma</label>
  </span>
</fieldset>\n|
    assert_equal expected, elem.to_html
    
    elem.disabled = true
    elem.legend = true
    elem.value = 2
    expected = %|<fieldset class="elem_checkbox_group disabled" id="elem">
  <legend>Elem</legend>
  <span class="elem">
    <input class="elem_checkbox" disabled="disabled" id="elem_barney" name="elem[]" type="checkbox" value="1"/>
    <label for="elem_barney">Barney</label>
  </span>
  <span class="elem">
    <input checked="checked" class="elem_checkbox" disabled="disabled" id="elem_fred" name="elem[]" type="checkbox" value="2"/>
    <label for="elem_fred">Fred</label>
  </span>
  <span class="elem">
    <input class="elem_checkbox" disabled="disabled" id="elem_wilma" name="elem[]" type="checkbox" value="3"/>
    <label for="elem_wilma">Wilma</label>
  </span>
</fieldset>\n|
    assert_equal expected, elem.to_html
  end
  
  def test_element_to_html_in_columns
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :columns => 2, :options => ('a'..'c'), :value => 'b'
    expected = %|<fieldset class="elem_checkbox_group" id="elem">
  <div class="column column-1">
    <span class="elem">
      <input class="elem_checkbox" id="elem_a" name="elem[]" type="checkbox" value="a"/>
      <label for="elem_a">a</label>
    </span>
    <span class="elem">
      <input checked="checked" class="elem_checkbox" id="elem_b" name="elem[]" type="checkbox" value="b"/>
      <label for="elem_b">b</label>
    </span>
  </div>
  <div class="column column-2">
    <span class="elem">
      <input class="elem_checkbox" id="elem_c" name="elem[]" type="checkbox" value="c"/>
      <label for="elem_c">c</label>
    </span>
  </div>
</fieldset>\n|
    assert_equal expected, elem.to_html
    
    elem.render_empty = true
    expected = %|<fieldset class="elem_checkbox_group" id="elem">
  <div class="column column-1">
    <span class="elem">
      <input class="elem_checkbox" id="elem_a" name="elem[]" type="checkbox" value="a"/>
      <label for="elem_a">a</label>
    </span>
    <span class="elem">
      <input checked="checked" class="elem_checkbox" id="elem_b" name="elem[]" type="checkbox" value="b"/>
      <label for="elem_b">b</label>
    </span>
  </div>
  <div class="column column-2">
    <span class="elem">
      <input class="elem_checkbox" id="elem_c" name="elem[]" type="checkbox" value="c"/>
      <label for="elem_c">c</label>
    </span>
    <span class="empty-elem">
    </span>
  </div>
</fieldset>\n|
    assert_equal expected, elem.to_html
  end
    
  def test_element_to_html_options_group
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :value => 'Wilma', :legend => true do |e|
      e.option_group 'People' do |og|
        og.option 'Barney'
        og.option 'Fred'
        og.option 'Wilma'
      end
      e.option_group('Animals', ['Dino', 'Pluto'])
      e.option_group('Cartoons', [['Simpsons', 'si'], ['Cow&Chicken', 'cc']])
    end
    expected = %|<fieldset class="elem_checkbox_group" id="elem">
  <legend>Elem</legend>
  <fieldset class="options">
    <legend>People</legend>
    <span class="elem">
      <input class="elem_checkbox" id="elem_barney" name="elem[]" type="checkbox" value="Barney"/>
      <label for="elem_barney">Barney</label>
    </span>
    <span class="elem">
      <input class="elem_checkbox" id="elem_fred" name="elem[]" type="checkbox" value="Fred"/>
      <label for="elem_fred">Fred</label>
    </span>
    <span class="elem">
      <input checked="checked" class="elem_checkbox" id="elem_wilma" name="elem[]" type="checkbox" value="Wilma"/>
      <label for="elem_wilma">Wilma</label>
    </span>
  </fieldset>
  <fieldset class="options">
    <legend>Animals</legend>
    <span class="elem">
      <input class="elem_checkbox" id="elem_dino" name="elem[]" type="checkbox" value="Dino"/>
      <label for="elem_dino">Dino</label>
    </span>
    <span class="elem">
      <input class="elem_checkbox" id="elem_pluto" name="elem[]" type="checkbox" value="Pluto"/>
      <label for="elem_pluto">Pluto</label>
    </span>
  </fieldset>
  <fieldset class="options">
    <legend>Cartoons</legend>
    <span class="elem">
      <input class="elem_checkbox" id="elem_simpsons" name="elem[]" type="checkbox" value="si"/>
      <label for="elem_simpsons">Simpsons</label>
    </span>
    <span class="elem">
      <input class="elem_checkbox" id="elem_cow_chicken" name="elem[]" type="checkbox" value="cc"/>
      <label for="elem_cow_chicken">Cow&amp;Chicken</label>
    </span>
  </fieldset>
</fieldset>\n|
    assert_equal expected, elem.to_html
  end

  def test_render_within_form
    form = ActiveForm::compose :myform do |f|
      f.checkbox_group_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
    end
    expected = %|<form action="#myform" class="active_form" id="myform" method="post">
  <fieldset class="elem_checkbox_group" id="myform_people">
    <span class="elem">
      <input class="elem_checkbox" id="myform_people_barney" name="myform[people][]" type="checkbox" value="1"/>
      <label for="myform_people_barney">Barney</label>
    </span>
    <span class="elem">
      <input class="elem_checkbox" id="myform_people_fred" name="myform[people][]" type="checkbox" value="2"/>
      <label for="myform_people_fred">Fred</label>
    </span>
    <span class="elem">
      <input class="elem_checkbox" id="myform_people_wilma" name="myform[people][]" type="checkbox" value="3"/>
      <label for="myform_people_wilma">Wilma</label>
    </span>
  </fieldset>
</form>\n|
  end

  def test_render_frozen
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :frozen => true
    assert_equal "<span class=\"blank\">-</span>\n", elem.to_html
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :selected => 2, :frozen => true
    assert_equal 'Fred', elem.to_html
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :values => [2, 3], :frozen => true
    assert_equal 'Fred, Wilma', elem.to_html
  end

  def test_reset_options
    elem = ActiveForm::Element::CheckboxGroup.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :add_empty => true
    assert_equal ["--", "Barney", "Fred", "Wilma"], elem.options.collect(&:label)
    elem.reset_options!
    assert_equal [], elem.options.collect(&:label)
  end
  
  def test_set_initial_value
    values = { :people => 2 }
    form = ActiveForm::compose :myform, :values => values do |f|
      f.checkbox_group_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
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
      f.checkbox_group_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
    end
    form[:people].selected = [2, 3]
    expected = { "people" => [2, 3] }
    assert_equal expected, form.export_values
  end
  
  def test_update_from_params
    form = ActiveForm::compose :myform do |f|
      f.checkbox_group_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
    end
    params = { :myform => { :people => [3] } }
    form.update_from_params(params)
    expected = { "people" => [3] }
    assert_equal expected, form.export_values
  end
  
  def test_required_validation
    form = ActiveForm::compose :myform do |f|
      f.checkbox_group_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :required => true
    end
    assert form[:people].blank?
    assert !form.validate
    assert_equal ["required"], form[:people].errors.collect(&:code)
    form[:people].value = 2
    assert form.validate
    form[:people].value = [6, 7]
    assert form[:people].blank?
    assert !form.validate
  end
  
  def test_option_count_validation
    form = ActiveForm::compose :myform do |f|
      f.checkbox_group_element :alpha, :options => ('a'..'z'), :required => true
    end
    assert !form.validate
    assert_equal ["required"], form[:alpha].errors.collect(&:code)
    assert_equal ["Alpha: can't be blank"], form[:alpha].errors.collect(&:msg)
    form[:alpha].value = 'a'
    assert form.validate
    
    form = ActiveForm::compose :myform do |f|
      f.checkbox_group_element :alpha, :options => ('a'..'z'), :required => 3
    end
    assert !form.validate
    assert_equal ["required"], form[:alpha].errors.collect(&:code)
    assert_equal ["Alpha: you need to select 3 items"], form[:alpha].errors.collect(&:msg)
    form[:alpha].value = ['a', 'b', 'c']
    assert form.validate
    
    form = ActiveForm::compose :myform do |f|
      f.checkbox_group_element :alpha, :options => ('a'..'z'), :required => 2..4 do |e|
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
  
  def test_option_count_validation_with_zero_minimum
    form = ActiveForm::compose :myform do |f|
      f.checkbox_group_element :alpha, :options => ('a'..'z'), :required => [0, 2] do |e|
        e.required_message = "%1$s: you shouldn't select more than two items"
      end
    end
    assert_equal ["Alpha: you shouldn't select more than two items"], form[:alpha].gather_validation_advice.collect(&:msg)
    form.values[:alpha] = []
    assert form.validate 
    form.values[:alpha] = ['a']
    assert form.validate 
    form.values[:alpha] = ['a', 'b', 'c']
    assert !form.validate
    assert_equal ["Alpha: you shouldn't select more than two items"], form[:alpha].errors.collect(&:msg) 
  end
  
  def test_option_count_validation_with_custom_message
    form = ActiveForm::compose :myform do |f|
      f.checkbox_group_element :alpha, :options => ('a'..'z'), :value => ['a'], :required => [2, 8] do |e|
        e.required_message = "%1$s: you need to select between %3$s and %4$s items (you selected %5$s)"
      end
    end
    assert !form.validate
    assert_equal ["Alpha: you need to select between 2 and 8 items (you selected 1)"], form[:alpha].errors.collect(&:msg) 
  end
  
end