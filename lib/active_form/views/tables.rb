# TODO work in progress

ActiveForm::Definition.define_container_wrapper do |builder, elem, render|      
  builder.form(elem.element_attributes) {
    builder.table {
      builder.thead { builder.tr { builder.th(elem.label, :colspan => 2) } }
      builder.tbody { elem.render_elements(builder) }
    }
    builder << elem.script_tag
  }   
end

ActiveForm::Definition.define_element_wrapper do |builder, elem, render|
  style = StyleAttribute.new
  style << 'display: none' if elem.hidden?
  builder.tr { builder.td { builder.table(:style => style, &render) } }
end  

ActiveForm::Element::Base.define_element_wrapper do |builder, elem, render|
  builder.tr(:class => 'label') { builder.td(:colspan => 2) { elem.render_label(builder) } }
  builder.tr(:id => "elem_#{elem.identifier}", :class => elem.css, :style => elem.style) { builder.td(:class => 'elem', :colspan => 2, &render) }
end

ActiveForm::Element::Section.define_element_wrapper do |builder, elem, render|
  builder.tr(:class => 'header') { builder.td(:colspan => 2) { builder.h3(:onclick => "$('section-#{elem.identifier}').toggle()") { elem.render_label(builder) } } }
  builder.tr(:class => 'advice') { builder.td(:colspan => 2) { builder << elem.validation_advice } }
  builder.tr { builder.td { builder.div(:id => "section-#{elem.identifier}") { builder.table(:style => 'background: lightblue;', &render) } } }
end