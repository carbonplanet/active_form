class ActiveForm::Element::Builder

  NIL_LAMBDA = lambda { |elem| }
  DEFAULT_HTML_BUILDER = lambda { |builder, elem| builder.div('') }

  include ActiveForm::Mixins::CommonMethods
  include ActiveForm::Mixins::ElementMethods

  inheritable_set :element_attribute_names, :element_option_flag_names, :element_html_flag_names

  def initialize_element(*args, &block)
    super(*args, &NIL_LAMBDA)
    define_html_builder(&block) if block_given?
  end

  def accept_block(&block)
    define_html_builder(&block) if block_given?
  end

  def element_value(export = false)
    @element_value ||= default_value
  end
  alias :values :element_value
  alias :value :element_value

  def element_value=(value)
    @element_value = value
  end
  alias :initial_value= :element_value=
  alias :values= :element_value=
  alias :value= :element_value=
  alias :binding= :element_value=
  alias :bind_to :element_value=
  alias :html= :element_value=

  def html_builder
    @html_builder ||= self.class.respond_to?(:html_builder_proc) ? self.class.method_to_proc(:html_builder_proc) : nil
  end

  def define_html_builder(prc = nil, &block)
    @html_builder = (block_given? ? block : prc)
  end
  alias :html :define_html_builder
  alias :html_builder= :define_html_builder

  def reset_html_builder
    @html_builder = nil
  end

  def render_label(builder = create_builder)
    element_name
  end

  def render_frozen(builder = create_builder)
    render_element(builder)
  end

  def render_element(builder = create_builder)
    if html_builder.respond_to?(:call)
      html_builder.call(builder, self)
    elsif !element_value.blank?
      builder << "#{element_value}\n"
    else
      DEFAULT_HTML_BUILDER.call(builder, self)
    end
  end

  def self.element_type
    :builder
  end

  def self.inherited(derivative)
    ActiveForm::Element::register(derivative) if derivative.kind_of?(ActiveForm::Element::Base)
    super
  end

  class << self

    def create(definition_name, &block)
      class_name = type_classname(definition_name)
      if !ActiveForm::Element.const_defined?(class_name, false)
        ActiveForm::Element.const_set(class_name, Class.new(self))
        if klass = ActiveForm::Element.const_get(class_name, false)
          klass.html_builder_proc = block if block_given?
          ActiveForm::Element::register(klass)
          return klass
        end
      end
      nil
    end

    def html_builder(prc = nil, &block)
      define_singleton_method(:html_builder_proc, &(block_given? ? block : prc))
    end
    alias :html_builder_proc= :html_builder

    def reset_html_builder
      undefine_singleton_method(:html_builder_proc) rescue nil
    end

  end

end