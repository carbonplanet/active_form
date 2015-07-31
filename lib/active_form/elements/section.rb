class ActiveForm::Element::Section
  
  include ActiveForm::Mixins::CommonMethods
  include ActiveForm::Mixins::ElementMethods
  include ActiveForm::Mixins::ContainerMethods
 
  inheritable_set :element_attribute_names, :element_option_flag_names, :element_html_flag_names
  
  define_standard_option_flags
  
  define_attributes :title
  
  def render_label(builder = create_builder)
    builder.span(label, label_attributes)
  end
  
  def render_frozen(builder = create_builder)
    render_element(builder)
  end
  
  def render_element(builder = create_builder)
    render_elements(builder)
  end
  
  def render_elements(builder = create_builder, &block)
    elements.each { |elem| elem.to_html(builder, &block) }
  end
  
  def label_attributes
    { :class => label_css }
  end
  
  def self.element_type
    :section
  end
  
end