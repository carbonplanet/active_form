require 'test_helper'

ActiveForm::Element::Builder::create :some_snippet do |builder, elem|

  builder.h1('A preset element')
  builder.p('Just an example of what you can do...')
  
end

class TestBuilderElement < Test::Unit::TestCase
  
  def test_element_to_html
    elem = ActiveForm::Element::Builder.new :elem, :html => 'raw html string'
    assert_equal %|raw html string\n|, elem.to_html
    
    elem = ActiveForm::Element::Builder.new :elem do |builder, e|
      builder.div('built with block')
    end
    assert_equal %|<div>built with block</div>\n|, elem.to_html
    
    elem = ActiveForm::Element::Builder.new :elem, :html => 'raw html string and builder block' do |builder, e|
      builder.div(e.value)
    end
    assert_equal %|<div>raw html string and builder block</div>\n|, elem.to_html   
  end
  
  def test_build_html
    form = ActiveForm::compose :form do |f|
      f.html :named do |builder, e|
        builder.h1('My Pretty form')
        builder.dl {
          e.container.get_elements_of_type(:text).each do |e|
            builder.dt(e.label)
            builder.dd(e.value)
          end
        }
      end
      f.text_element :name
      f.text_element :city
      f.html { |builder, e| builder.hr }
    end
    form.values = { :name => 'Fred', :city => 'Bedrock' }
    expected = %|<form action="#form" class="active_form" id="form" method="post">
  <h1>My Pretty form</h1>
  <dl>
    <dt>Name</dt>
    <dd>Fred</dd>
    <dt>City</dt>
    <dd>Bedrock</dd>
  </dl>
  <input class="elem_text" id="form_name" name="form[name]" size="30" type="text" value="Fred"/>
  <input class="elem_text" id="form_city" name="form[city]" size="30" type="text" value="Bedrock"/>
  <hr/>
</form>\n|
    assert_equal expected, form.to_html
  end
  
  def test_add_raw_string
    form = ActiveForm::compose :form
    form << '<h1>My Form</h1>'
    form.text_element :name
    form << '<hr />'
    expected = %|<form action="#form" class="active_form" id="form" method="post">
<h1>My Form</h1>
  <input class="elem_text" id="form_name" name="form[name]" size="30" type="text"/>
<hr />
</form>\n|
    assert_equal expected, form.to_html
  end
  
  def test_add_predefined_html_snippet_element
    form = ActiveForm::compose :form
    form.some_snippet_element
    expected = %|<form action="#form" class="active_form" id="form" method="post">
  <h1>A preset element</h1>
  <p>Just an example of what you can do...</p>
</form>\n|
    assert_equal expected, form.to_html
  end
  
end