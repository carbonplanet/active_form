# TODO work in progress

ActiveForm::Definition.define_container_wrapper do |builder, elem, render|      
  builder.form(elem.element_attributes) {
    builder.h3(elem.label)
    elem.render_elements(builder) 
    builder << elem.script_tag
  }   
end

# ActiveForm::Definition.define_element_wrapper do |builder, elem, render|
#   style = StyleAttribute.new
#   style << 'display: none' if elem.hidden?
#   builder.div(:style => style) {
#     builder.h4 { elem.render_label(builder) }
#     builder.div(:id => "sub-#{elem.identifier}", &render)
#   }
# end  

ActiveForm::Element::Base.define_element_wrapper do |builder, elem, render|
  builder.div(:id => "elem_#{elem.identifier}", :class => elem.css, :style => elem.style) {
    elem.render_label(builder)
    render.call(builder)
  }
end

ActiveForm::Element::Section.define_element_wrapper do |builder, elem, render|
  builder.div(:class => 'section') {
    builder.h4(elem.label, :id => "section-#{elem.identifier}-title")
    builder.div(:id => "section-#{elem.identifier}", &render)
  }
end
