require 'test_helper'

class TestSectionElement < Test::Unit::TestCase
  
  def test_standard_attributes
    assert ActiveForm::Element::Section.element_attribute_names.include?(:title)
    assert ActiveForm::Element::Section.element_attribute_names.include?(:lang)
    elem = ActiveForm::Element::Section.new :elem
    assert elem.respond_to?(:title=)
    assert elem.respond_to?(:style=)
    assert elem.respond_to?(:class=)
    assert elem.respond_to?(:lang=)
    assert_equal Hash.new, elem.attributes
    expected = {"class"=>"active_section", "id"=>"elem"}
    assert_equal expected, elem.element_attributes
  end
  
  def test_set_standard_attributes
    elem = ActiveForm::Element::Section.new :section, :title => 'My Element', :lang => 'nl-nl'
    expected = {"title"=>"My Element", "lang"=>"nl-nl"}
    assert_equal expected, elem.attributes
    expected = {"id"=>"section", "class"=>"active_section", "title"=>"My Element", "lang"=>"nl-nl"}
    assert_equal expected, elem.element_attributes
  end
  
  def test_standard_option_flags
    section = ActiveForm::Element::Section.new :section
    [:frozen, :hidden, :disabled, :readonly, :required].each do |method|
      assert ActiveForm::Element::Section.element_option_flag_names.include?(method)
      assert section.respond_to?("#{method}") 
      assert section.respond_to?("#{method}=")
      assert section.respond_to?("#{method}?")
    end
  end
  
  def test_render_label
    section = ActiveForm::Element::Section.new :section, :label => 'My Section'
    assert_equal %|<span class="label">My Section</span>\n|, section.render_label
    section.hidden = true
    assert_equal %|<span class="hidden label">My Section</span>\n|, section.render_label
    section.hidden = false; section.required = true; section.frozen = true
    assert_equal %|<span class="inactive required label">My Section</span>\n|, section.render_label
  end
  
end

ActiveForm::Element::Section::create :person_name do |s|       
  
  s.text_element :firstname,  :title => 'First Name'
  s.text_element :lastname,   :title => 'Last Name'           

end

ActiveForm::Element::Section::create :message do |s|       
  
  s.text_element :subject
  s.textarea_element :message        

end

class TestSectionElementClass < Test::Unit::TestCase
  
  def test_get_and_build_group
    assert_equal ActiveForm::PersonNameSection, ActiveForm::Element::Section.get(:person_name)
    section = ActiveForm::Element::Section.build(:person_name)
    assert_kind_of ActiveForm::PersonNameSection, section
    assert_equal [:firstname, :lastname], section.collect(&:name)
  end
  
  def test_append_section_to_form
    form = ActiveForm::compose :form
    form << ActiveForm::Element::Section.build(:person_name, :person)
    form << ActiveForm::Element::Section.build(:message)
    form << ActiveForm::Element::Submit.new(:send)
    assert_equal [:person, :message, :send], form.collect(&:name)
    assert_equal [:firstname, :lastname], form[:person].collect(&:name)
    assert_equal [:subject, :message], form[:message].collect(&:name)
  end
  
  def test_append_and_use_section_binding
    items = []
    items << { :id => 1, :firstname => 'Fred', :lastname => 'Flintstone' }
    items << { :id => 2, :firstname => 'Barney', :lastname => 'Rubble' }
    
    person_wrapper = proc do |builder, elem, render|
      builder.fieldset(:class => 'section') {
        builder.legend(elem.label, :class => 'section')
        builder.div(:id => "section-#{elem.identifier}", &render)
      }
    end
    
    form = ActiveForm::compose :form
    form.section :people do |s|
      items.each do |item|
        element_id = "person_#{item[:id]}"
        s.append_section [:person_name, element_id, { :label => "#{item[:firstname]} #{item[:lastname]}", :element_wrapper => person_wrapper }]
        s[element_id].values = item # do this here, so the container has been registered to the item's group
      end   
    end
    
    assert_equal [:person_1, :person_2], form[:people].collect(&:name)
    form.values['people']['person_1']['firstname'] = 'Wilma'
    assert_equal 'Wilma', form[:people][:person_1][:firstname].value
    
    expected = [{"firstname"=>"Wilma", "id"=>1, "lastname"=>"Flintstone"}, {"firstname"=>"Barney", "id"=>2, "lastname"=>"Rubble"}]
    assert_equal expected, form[:people].collect { |person| person.values }  
    
    expected = %|<form action="#form" class="active_form" id="form" method="post">
  <fieldset class="section">
    <legend class="section">Fred Flintstone</legend>
    <div id="section-form_people_person_1">
      <input class="elem_text" id="form_people_person_1_firstname" name="form[people][person_1][firstname]" size="30" title="First Name" type="text" value="Wilma"/>
      <input class="elem_text" id="form_people_person_1_lastname" name="form[people][person_1][lastname]" size="30" title="Last Name" type="text" value="Flintstone"/>
    </div>
  </fieldset>
  <fieldset class="section">
    <legend class="section">Barney Rubble</legend>
    <div id="section-form_people_person_2">
      <input class="elem_text" id="form_people_person_2_firstname" name="form[people][person_2][firstname]" size="30" title="First Name" type="text" value="Barney"/>
      <input class="elem_text" id="form_people_person_2_lastname" name="form[people][person_2][lastname]" size="30" title="Last Name" type="text" value="Rubble"/>
    </div>
  </fieldset>
</form>\n|
    assert_equal expected, form.to_html
  end
  
  def test_append_section
    form = ActiveForm::compose :form
    form.append_section :person_name
    form.append_section :message
    form.submit_element :send
    assert_equal [:person_name, :message, :send], form.collect(&:name)
    assert_equal [:firstname, :lastname], form[:person_name].collect(&:name)
  end
  
  def test_append_sections
    form = ActiveForm::compose :form
    form.append_sections :person_name, :message
    form.submit_element :send
    assert_equal [:person_name, :message, :send], form.collect(&:name)
    assert_equal [:firstname, :lastname], form[:person_name].collect(&:name)
  end
  
  def test_append_sections_using_array_syntax
    form = ActiveForm::compose :form
    form.append_sections [:person_name, :name], [:message, :email, { :label => "E-Mail" }]
    form.submit_element :send
    assert_equal [:name, :email, :send], form.collect(&:name)
    assert_equal ['Name', 'E-Mail', 'Send'], form.collect(&:label)
    assert_equal [:firstname, :lastname], form[:name].collect(&:name)
  end
  
  def test_append_section_using_concat_syntax
    form = ActiveForm::compose :form
    form << :person_name
    form << :message
    form.submit_element :send
    assert_equal [:person_name, :message, :send], form.collect(&:name)
    assert_equal [:firstname, :lastname], form[:person_name].collect(&:name)
  end
  
end