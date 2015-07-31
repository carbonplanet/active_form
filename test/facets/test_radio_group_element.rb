require 'test_helper'

class TestRadioGroupElement < Test::Unit::TestCase
  
  def test_multiple
    elem = ActiveForm::Element::RadioGroup.new :choices, :options => %w{ one two three four }
    assert !elem.multiple?
  end
  
  def test_element_value
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => %w{ Barney Fred Wilma }, :value => "Fred"
    assert_equal "Fred", elem.element_value
    assert elem.selected?("Fred")
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => %w{ Barney Fred Wilma }, :selected => "Fred"
    assert_equal "Fred", elem.element_value
    assert elem.selected?("Fred")
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => %w{ Barney Fred Wilma }, :selected => ["Fred", "Wilma"]
    assert_equal "Fred", elem.element_value
    assert elem.selected?("Fred")
  end
  
  def test_default_value
    elem = ActiveForm::Element::RadioGroup.new :elem
    assert_equal nil, elem.default_value
  end
  
  def test_fallback_value
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => ['this', 'that', 'other'], :default => 'no preference'
    assert_equal nil, elem.value
    assert_equal nil, elem.default_value
    assert_equal 'no preference', elem.fallback_value
    assert_equal 'no preference', elem.export_value
    elem.value = 'other'
    assert_equal 'other', elem.export_value
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => ['red', 'green', 'blue'], :default => ['red', 'green']
    assert_equal nil, elem.value
    assert_equal nil, elem.default_value
    assert_equal 'red', elem.fallback_value
    assert_equal 'red', elem.export_value
    elem.value = 'blue'
    assert_equal 'blue', elem.export_value 
  end  
  
  def test_simple_group_options_multiple
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => %w{ Barney Fred Wilma }, :value => "Fred"
    assert_equal ["Barney", "Fred", "Wilma"], elem.options.collect(&:value)
    assert_equal "Fred", elem.element_value
    assert elem.selected?("Fred")
  end
  
  def test_normal_group_options_multiple
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => [["Barney", 1], ["Fred", 2], ["Wilma", 3]], :value => 3
    assert_equal [1, 2, 3], elem.options.collect(&:value)
    assert_equal 3, elem.element_value
    assert elem.selected?(3)
  end
  
  def test_element_to_html
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :value => 2
    assert_equal 2, elem.value
    assert elem.selected?(2)
    
    expected = %|<fieldset class="elem_radio_group" id="elem">
  <span class="elem">
    <input class="elem_radio" id="elem_barney" name="elem" type="radio" value="1"/>
    <label for="elem_barney">Barney</label>
  </span>
  <span class="elem">
    <input checked="checked" class="elem_radio" id="elem_fred" name="elem" type="radio" value="2"/>
    <label for="elem_fred">Fred</label>
  </span>
  <span class="elem">
    <input class="elem_radio" id="elem_wilma" name="elem" type="radio" value="3"/>
    <label for="elem_wilma">Wilma</label>
  </span>
</fieldset>\n|
    assert_equal expected, elem.to_html
    
    elem.disabled = true
    elem.legend = true
    elem.value = 2 
    expected = %|<fieldset class="elem_radio_group disabled" id="elem">
  <legend>Elem</legend>
  <span class="elem">
    <input class="elem_radio" disabled="disabled" id="elem_barney" name="elem" type="radio" value="1"/>
    <label for="elem_barney">Barney</label>
  </span>
  <span class="elem">
    <input checked="checked" class="elem_radio" disabled="disabled" id="elem_fred" name="elem" type="radio" value="2"/>
    <label for="elem_fred">Fred</label>
  </span>
  <span class="elem">
    <input class="elem_radio" disabled="disabled" id="elem_wilma" name="elem" type="radio" value="3"/>
    <label for="elem_wilma">Wilma</label>
  </span>
</fieldset>\n|
    assert_equal expected, elem.to_html
  end
  
  def test_element_to_html_in_columns
    elem = ActiveForm::Element::RadioGroup.new :elem, :columns => 2, :options => ('a'..'c'), :value => 'b'
    expected = %|<fieldset class="elem_radio_group" id="elem">
  <div class="column column-1">
    <span class="elem">
      <input class="elem_radio" id="elem_a" name="elem" type="radio" value="a"/>
      <label for="elem_a">a</label>
    </span>
    <span class="elem">
      <input checked="checked" class="elem_radio" id="elem_b" name="elem" type="radio" value="b"/>
      <label for="elem_b">b</label>
    </span>
  </div>
  <div class="column column-2">
    <span class="elem">
      <input class="elem_radio" id="elem_c" name="elem" type="radio" value="c"/>
      <label for="elem_c">c</label>
    </span>
  </div>
</fieldset>\n|
    assert_equal expected, elem.to_html
    
    elem.render_empty = true
    expected = %|<fieldset class="elem_radio_group" id="elem">
  <div class="column column-1">
    <span class="elem">
      <input class="elem_radio" id="elem_a" name="elem" type="radio" value="a"/>
      <label for="elem_a">a</label>
    </span>
    <span class="elem">
      <input checked="checked" class="elem_radio" id="elem_b" name="elem" type="radio" value="b"/>
      <label for="elem_b">b</label>
    </span>
  </div>
  <div class="column column-2">
    <span class="elem">
      <input class="elem_radio" id="elem_c" name="elem" type="radio" value="c"/>
      <label for="elem_c">c</label>
    </span>
    <span class="empty-elem">
    </span>
  </div>
</fieldset>\n|
    assert_equal expected, elem.to_html
  end
    
  def test_element_to_html_options_group
    elem = ActiveForm::Element::RadioGroup.new :elem, :value => 'Wilma', :legend => true do |e|
      e.option_group 'People' do |og|
        og.option 'Barney'
        og.option 'Fred'
        og.option 'Wilma'
      end
      e.option_group('Animals', ['Dino', 'Pluto'])
      e.option_group('Cartoons', [['Simpsons', 'si'], ['Cow&Chicken', 'cc']])
    end
    expected = %|<fieldset class="elem_radio_group" id="elem">
  <legend>Elem</legend>
  <fieldset class="options">
    <legend>People</legend>
    <span class="elem">
      <input class="elem_radio" id="elem_barney" name="elem" type="radio" value="Barney"/>
      <label for="elem_barney">Barney</label>
    </span>
    <span class="elem">
      <input class="elem_radio" id="elem_fred" name="elem" type="radio" value="Fred"/>
      <label for="elem_fred">Fred</label>
    </span>
    <span class="elem">
      <input checked="checked" class="elem_radio" id="elem_wilma" name="elem" type="radio" value="Wilma"/>
      <label for="elem_wilma">Wilma</label>
    </span>
  </fieldset>
  <fieldset class="options">
    <legend>Animals</legend>
    <span class="elem">
      <input class="elem_radio" id="elem_dino" name="elem" type="radio" value="Dino"/>
      <label for="elem_dino">Dino</label>
    </span>
    <span class="elem">
      <input class="elem_radio" id="elem_pluto" name="elem" type="radio" value="Pluto"/>
      <label for="elem_pluto">Pluto</label>
    </span>
  </fieldset>
  <fieldset class="options">
    <legend>Cartoons</legend>
    <span class="elem">
      <input class="elem_radio" id="elem_simpsons" name="elem" type="radio" value="si"/>
      <label for="elem_simpsons">Simpsons</label>
    </span>
    <span class="elem">
      <input class="elem_radio" id="elem_cow_chicken" name="elem" type="radio" value="cc"/>
      <label for="elem_cow_chicken">Cow&amp;Chicken</label>
    </span>
  </fieldset>
</fieldset>\n|
    assert_equal expected, elem.to_html
  end

  def test_render_within_form
    form = ActiveForm::compose :myform do |f|
      f.radio_group_element :person, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
    end
    expected = %|<form action="#myform" class="active_form" id="myform" method="post">
  <fieldset class="elem_radio_group" id="myform_person">
    <span class="elem">
      <input class="elem_radio" id="myform_person_1" name="myform[person]" type="radio" value="1"/>
      <label for="myform_person_1">Barney</label>
    </span>
    <span class="elem">
      <input class="elem_radio" id="myform_person_2" name="myform[person]" type="radio" value="2"/>
      <label for="myform_person_2">Fred</label>
    </span>
    <span class="elem">
      <input class="elem_radio" id="myform_person_3" name="myform[person]" type="radio" value="3"/>
      <label for="myform_person_3">Wilma</label>
    </span>
  </fieldset>
</form>\n|
  end

  def test_render_frozen
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :frozen => true
    assert_equal "<span class=\"blank\">-</span>\n", elem.to_html
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :selected => 2, :frozen => true
    assert_equal 'Fred', elem.to_html
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :values => [2, 3], :frozen => true
    assert_equal 'Fred', elem.to_html
  end

  def test_reset_options
    elem = ActiveForm::Element::RadioGroup.new :elem, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :add_empty => true
    assert_equal ["--", "Barney", "Fred", "Wilma"], elem.options.collect(&:label)
    elem.reset_options!
    assert_equal [], elem.options.collect(&:label)
  end
  
  def test_set_initial_value
    values = { :person => 2 }
    form = ActiveForm::compose :myform, :values => values do |f|
      f.radio_group_element :person, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
    end
    assert_equal 2, form[:person].value
    assert_equal 2, form[:person].export_value
    form.values = { :person => 3 }
    assert_equal 3, form[:person].value
    assert_equal 3, form[:person].export_value
    expected = { "person" => 3 }
    assert_equal expected, form.export_values
  end
  
  def test_export_value
    form = ActiveForm::compose :myform do |f|
      f.radio_group_element :person, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
    end
    form[:person].selected = 3
    expected = { "person" => 3 }
    assert_equal expected, form.export_values
  end
  
  def test_update_from_params
    form = ActiveForm::compose :myform do |f|
      f.radio_group_element :person, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ]
    end
    params = { :myform => { :person => 3 } }
    form.update_from_params(params)
    expected = { "person" => 3 }
    assert_equal expected, form.export_values
  end
  
  def test_required_validation
    form = ActiveForm::compose :myform do |f|
      f.radio_group_element :people, :options => [ ['Barney', 1], ['Fred', 2], ["Wilma", 3] ], :required => true
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
    # remember: you can't have multiple values for radio group
    form = ActiveForm::compose :myform do |f|
      f.radio_group_element :alpha, :options => ('a'..'z'), :required => true
    end
    assert !form.validate
    assert_equal ["required"], form[:alpha].errors.collect(&:code)
    assert_equal ["Alpha: can't be blank"], form[:alpha].errors.collect(&:msg)
    form[:alpha].value = 'a'
    assert form.validate
    
    form = ActiveForm::compose :myform do |f|
      f.radio_group_element :alpha, :options => ('a'..'z'), :required => 1
    end
    assert !form.validate
    assert_equal ["required"], form[:alpha].errors.collect(&:code)
    assert_equal ["Alpha: you need to select 1 items"], form[:alpha].errors.collect(&:msg)
    form[:alpha].value = 'a'
    assert form.validate
  end
  
  def test_select_first
    form = ActiveForm::compose :myform do |f|
      f.radio_group_element :alpha, :options => ('a'..'z'), :select_first => true
    end
    assert_equal 'a', form[:alpha].value
  end

end