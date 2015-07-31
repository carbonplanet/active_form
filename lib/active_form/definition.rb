class ActiveForm::Definition

  undef :method
  
  include ActiveForm::Mixins::CommonMethods
  include ActiveForm::Mixins::ElementMethods
  include ActiveForm::Mixins::ContainerMethods
  
  inheritable_set :element_attribute_names, :element_option_flag_names, :element_html_flag_names
  
  define_standard_option_flags
  
  define_attributes :title, :action, :method, :target, :enctype, :accept, :"accept-charset"
  
  define_option_flags :multipart
  
  def initialize_element(*args)
    super
    self.action ||= "##{self.name}"
    self.method ||= 'post'    
  end
  
  def header(include_advice = false)
    html = "<!--o" + "[ #{identifier} ]".center(32, 'o') + "o-->\n"
    html << "<form #{element_attributes.as_attributes_string}>\n"
    html << validation_advice.to_s if include_advice
    html
  end
  
  def footer
    html = "</form>\n"
    html << script_tag
    html << "<!--x" + "[ #{identifier} ]".center(32, 'x') + "x-->\n"
    html
  end
  
  def render_label(builder = create_builder)
    builder.span(label, label_attributes)
  end
  alias :to_label :render_label
  
  def render_frozen(builder = create_builder)
    builder.form(element_attributes) { render_elements(builder) }
  end
  
  def render_element(builder = create_builder)
    if contained?
      render_elements(builder)
    else
      builder.form(element_attributes) { render_elements(builder) }
    end
  end
  
  def render_elements(builder = create_builder, &block)
    elements.each { |elem| elem.to_html(builder, &block) }
  end
  
  def default_attributes
    attrs = { :id => identifier, :class => css }
    attrs[:enctype] = 'multipart/form-data' if multipart?
    attrs
  end
  
  def label_attributes
    { :class => label_css }
  end
  
  def self.element_type
    :form
  end
  
end