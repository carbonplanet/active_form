class ActiveForm::Element::Base

  include ActiveForm::Mixins::CommonMethods
  include ActiveForm::Mixins::ElementMethods

  inheritable_set :element_attribute_names, :element_option_flag_names, :element_html_flag_names
  
  define_standard_option_flags
  
  define_attributes :title, :accesskey, :tabindex

  cattr_accessor :default_timezone
  @@default_timezone = :local

  def render_label(builder = create_builder)
    builder.label(label, label_attributes) if labelled?
  end
  alias :to_label :render_label
  
  def render_frozen(builder = create_builder)
    return builder.span('-', :class => 'blank') if formatted_value.blank?
    builder.text!(formatted_value)
  end
  
  def render_element(builder = create_builder)
    builder.span(label, { :id => identifier, :class => css })
  end

  def default_attributes
    { :name => element_name, :id => identifier, :class => css  }
  end
  
  def label_attributes
    { :for => identifier, :class => label_css }
  end
  
  def default_css_class
    "elem_#{element_type}"
  end
  
  def method_missing(method, *args, &block)   
    if (match = /^validates_(with_|within_|as_)?(.*)$/.match(method.to_s)) && ActiveForm::Validator::exists?(match.captures[1])
      define_validator(match.captures[1], *args, &block)
    else
      super
    end
  end
  
  def self.inherited(derivative)
    ActiveForm::Element::register(derivative) if derivative.kind_of?(ActiveForm::Element::Base)
    super
  end
  
  def self.create(definition_name, &block)
    class_name = type_classname(definition_name)
    if !ActiveForm::Element.const_defined?(class_name)
      ActiveForm::Element.const_set(class_name, Class.new(self))
      if klass = ActiveForm::Element.const_get(class_name)
        klass.module_eval(&block) if block_given?
        ActiveForm::Element::register(klass)
        return klass
      end
    end
    nil
  end
  
end