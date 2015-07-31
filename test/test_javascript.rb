require 'test_helper'

class TestJavascript < Test::Unit::TestCase
  
  def test_javascript_attribute_append
    js = JavascriptAttribute.new
    js << 'one' << 'two; three'
    assert_equal ["one", "two", "three"], js
    js << ["four", "five", "six"]
    assert_equal ["one", "two", "three", "four", "five", "six"], js
  end
  
  def test_javascript_attribute_write
    js = JavascriptAttribute.new
    js.write do |s|
      s << "window.console.log('first message')"
      s << "window.console.log('second message')"
    end
    assert_equal "window.console.log('first message');window.console.log('second message')", js.to_s
  end
  
  def test_javascript_attribute_replace
    js = JavascriptAttribute.new
    js << 'one' << 'two; three'
    assert_equal ["one", "two", "three"], js
    assert_equal 'one;two;three', js.to_s
    assert_equal 'one;two;three', js.join
    js.replace('four;five;six')
    assert_equal ["four", "five", "six"], js
    js.replace(["one", "two", "three"])
    assert_equal ["one", "two", "three"], js
    assert_equal 'one;two;three', js.to_s
    js.replace("four", "five", "six")
    assert_equal ["four", "five", "six"], js
 end
 
 def test_javascript_attribute_add_and_remove   
    js = JavascriptAttribute.new
    js += 'one'
    assert_equal ["one"], js
    js += 'two; three'
    assert_equal ["one", "two", "three"], js
    js += ['four', 'five', 'six']
    assert_equal ["one", "two", "three", "four", "five", "six"], js
    js -= 'two'
    assert_equal ["one", "three", "four", "five", "six"], js
    js -= 'one; three'
    assert_equal ["four", "five", "six"], js
    js -= ["four", "six"]
    assert_equal ["five"], js
  end
  
  def test_javascript_attribute
    element = ActiveForm::Element::ExtendedSample.new(:test)
    element.javascript = "window.console.log('created element')"
    element.javascript << "window.console.info('more info')"
    element.javascript += "return false"
    assert_equal "window.console.log('created element');window.console.info('more info');return false", element.javascript.to_s
  end
  
  def test_javascript_handler_methods
    element = ActiveForm::Element::ExtendedSample.new(:test)
    ActiveForm::Mixins::JavascriptMethods::EVENTS.each do |event|
      assert element.respond_to?("#{event}")
      assert element.respond_to?("#{event}=")
      assert element.respond_to?("#{event}_event")
      assert element.respond_to?("#{event}?")
    end   
  end
  
  def test_javascript_code_for_element
    element = ActiveForm::Element::ExtendedSample.new(:test)
    element.javascript = "window.console.log('created element')"
    assert_equal 1, element.javascript.length
    assert_equal "window.console.log('created element')", element.javascript.to_s
    expected = %|var fextended_sample_test=$('test');if(fextended_sample_test){
  window.console.log('created element');
}|  
    assert_equal expected, element.element_javascript
  end
  
  def test_javascript_inline_event_code
    element = ActiveForm::Element::ExtendedSample.new(:test)
    element.onclick = "alert('you clicked me!')"
    element.onfocus_event do |identifier|
      # get RJS-like functionality in here!
      assert_equal element.identifier, identifier
      "window.console.log('created #{identifier}')"
    end
    assert element.javascript?
    assert element.onclick?
    assert element.onfocus?
    assert !element.onchange?
    assert_equal "alert('you clicked me!')", element.onclick   
    assert_equal %|onclick="alert('you clicked me!')"|, element.inline_onclick    
    assert_equal "window.console.log('created test')", element.onfocus
    assert_equal %|onfocus="window.console.log('created test')"|, element.inline_onfocus
    assert_equal %|onclick="alert('you clicked me!')" onfocus="window.console.log('created test')"|, element.inline_javascript
  end
  
  def test_javascript_event_code_for_element
    element = ActiveForm::Element::ExtendedSample.new(:test)
    element.onclick = "alert('you clicked me!')"
    element.onfocus_event do |identifier|
      "window.console.log('created #{identifier}')"
    end
    assert_equal [], element.javascript
    assert_equal nil, element.javascript(true)
    expected = %|var fextended_sample_test=$('test');if(fextended_sample_test){
  Event.observe(fextended_sample_test,'click',function(ev){ alert('you clicked me!'); });
  Event.observe(fextended_sample_test,'focus',function(ev){ window.console.log('created test'); });
}|
    assert_equal expected, element.element_javascript
    expected = %|<script type="text/javascript" charset="utf-8">//<![CDATA[
var fextended_sample_test=$('test');if(fextended_sample_test){
  Event.observe(fextended_sample_test,'click',function(ev){ alert('you clicked me!'); });
  Event.observe(fextended_sample_test,'focus',function(ev){ window.console.log('created test'); });
}
//]]>
</script>\n|
    assert_equal expected, element.element_javascript(true)
  end
  
  def test_javascript_combined_code_for_element
    element = ActiveForm::Element::ExtendedSample.new(:test)
    element.javascript = "window.console.log('created element')"
    element.onfocus = "window.console.log('focus on test element')"
    assert_equal "window.console.log('created element')", element.javascript.to_s
    expected = %|var fextended_sample_test=$('test');if(fextended_sample_test){
  window.console.log('created element');
  Event.observe(fextended_sample_test,'focus',function(ev){ window.console.log('focus on test element'); });
}|
    assert_equal expected, element.element_javascript
    expected = %|<script type="text/javascript" charset="utf-8">//<![CDATA[
var fextended_sample_test=$('test');if(fextended_sample_test){
  window.console.log('created element');
  Event.observe(fextended_sample_test,'focus',function(ev){ window.console.log('focus on test element'); });
}
//]]>
</script>\n|
    assert_equal expected, element.element_javascript(true)
  end
  
  def test_javascript_code_for_container
    form = ActiveForm::compose :form do |f|
      f.javascript += "window.console.log('created form')"
      f.javascript += "alert('testing')"
      f.onsubmit = "Var.serialize(this)"
      f.onreset  = "window.console.log('reset form')"
      f.text_element :elem_a
      f.text_element :elem_b
    end
    assert_equal "window.console.log('created form');alert('testing')", form.javascript.to_s
    expected = %|var fform_form=$('form');if(fform_form){
  window.console.log('created form');alert('testing');
  Event.observe(fform_form,'reset',function(ev){ window.console.log('reset form'); });
  Event.observe(fform_form,'submit',function(ev){ Var.serialize(this); });
}|
    assert_equal expected, form.element_javascript   
  end
  
  def test_javascript_code_for_container_and_elements
    form = ActiveForm::compose :form do |f|
      f.javascript += "window.console.log('created form')"
      f.javascript += "alert('testing')"
      f.onsubmit = "Var.serialize(this)"
      f.onreset  = "window.console.log('reset form')"
      f.text_element :elem_a do |e|
        e.onfocus = "window.console.log('focussed on elem_a')"
      end
      f.text_element :elem_b do |e|
        e.onfocus = "window.console.log('focussed on elem_b')"
      end
    end
    assert_equal "window.console.log('created form');alert('testing')", form.javascript.to_s
    expected = %|var fform_form=$('form');if(fform_form){
  window.console.log('created form');alert('testing');
  Event.observe(fform_form,'reset',function(ev){ window.console.log('reset form'); });
  Event.observe(fform_form,'submit',function(ev){ Var.serialize(this); });
  var ftext_form_elem_a=$('form_elem_a');if(ftext_form_elem_a){
    Event.observe(ftext_form_elem_a,'focus',function(ev){ window.console.log('focussed on elem_a'); });
  }
  var ftext_form_elem_b=$('form_elem_b');if(ftext_form_elem_b){
    Event.observe(ftext_form_elem_b,'focus',function(ev){ window.console.log('focussed on elem_b'); });
  }
}|
    assert_equal expected, form.element_javascript 
  end
  
  def test_javascript_code_for_nested_elements
    form = ActiveForm::compose :form do |f|
      f.javascript = "loadForm(#{f.javascript_var})"
      f.onsubmit = "window.console.log('form')"
      f.section :section do |s|
        s.onmouseover = "window.console.log('section')"
        s.text_element :element do |e|
          e.onblur = "window.console.log('element')"         
        end
        s.section :nested do |n|
          n.javascript = "window.console.log('nested section')"
          n.text_element :nested_element do |ne|
            ne.onfocus = "window.console.log('nested element')"
          end
        end
      end
    end
    expected = %|var fform_form=$('form');if(fform_form){
  loadForm(fform_form);
  Event.observe(fform_form,'submit',function(ev){ window.console.log('form'); });
  var fsection_form_section=$('form_section');if(fsection_form_section){
    Event.observe(fsection_form_section,'mouseover',function(ev){ window.console.log('section'); });
    var ftext_form_section_element=$('form_section_element');if(ftext_form_section_element){
      Event.observe(ftext_form_section_element,'blur',function(ev){ window.console.log('element'); });
    }
    var fsection_form_section_nested=$('form_section_nested');if(fsection_form_section_nested){
      window.console.log('nested section');
      var ftext_form_section_nested_nested_element=$('form_section_nested_nested_element');if(ftext_form_section_nested_nested_element){
        Event.observe(ftext_form_section_nested_nested_element,'focus',function(ev){ window.console.log('nested element'); });
      }
    }
  }
}|
    assert_equal expected, form.element_javascript
    expected = %|var fsection_form_section_nested=$('form_section_nested');if(fsection_form_section_nested){
  window.console.log('nested section');
  var ftext_form_section_nested_nested_element=$('form_section_nested_nested_element');if(ftext_form_section_nested_nested_element){
    Event.observe(ftext_form_section_nested_nested_element,'focus',function(ev){ window.console.log('nested element'); });
  }
}|
    assert_equal expected, form[:section][:nested].element_javascript
    assert_equal %|onfocus="window.console.log('nested element')"|, form[:section][:nested][:nested_element].inline_javascript
  end
  
end