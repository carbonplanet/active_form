class ActiveForm::Validator::Base

  attr_reader   :element
  attr_accessor :msg, :code

  def initialize(*args, &block)
    setup
    props = args.last.is_a?(Hash) ? args.pop : {}
    register_element(args.shift) if is_element?(args.first)
    self.code = self.class.to_s.demodulize.underscore
    props.each { |prop, value| send("#{prop}=", value) if respond_to?("#{prop}=") }
    yield self if block_given?
  end

  alias :name :code

  def setup
  end

  def identifier
    self.code == 'required' ? code : "validate-#{code}"
  end

  def javascript_definition
    self.class.javascript_definition(identifier)
  end

  def advice
    { code => ActiveForm::Error.new(element, message, code, message_params) }
  end

  def validate
    element.errors << advice[code]
  end

  def register_element(elem)
    @element = elem
  end

  def code=(str)
    @code = str.to_s
  end

  def message
    self.msg || self.class.message
  end

  def message=(str)
    self.msg = str
  end

  def message_params
    []
  end

  def label
    element.label
  end

  def value
    element.element_value
  end

  def value_length
    str = self.value.to_s
    charlength = str.respond_to?(:chars) ? str.chars.length : str.length
  end

  def collection_length
    [*self.value].delete_if { |v| v.blank? }.length
  end

  def is_element?(arg)
    arg.respond_to?(:element?) && arg.element?
  end

  def js_validation(validation_msg, code)
  end

  class << self

    def javascript_validation(msg = 'validation failed', jscode = '')
      self.javascript_validation_code = { :msg => msg, :jscode => yield(jscode) }
    end

    def javascript_definition(identifier)
      return nil if self.javascript_validation_code.blank?
      %|Validation.add('#{identifier}', "#{self.javascript_validation_code[:msg]}", function (v) {\n  #{self.javascript_validation_code[:jscode]}\n});|
    end

    def message
      self.default_msg ||= '%s: validation failure'
    end

    def default_message=(str)
      self.default_msg = str
    end
    alias :default_message :default_message=

    def inherited(derivative)
      ActiveForm::Validator::register(derivative) if derivative.kind_of?(ActiveForm::Validator::Base)
      derivative.class_inheritable_accessor :default_msg
      derivative.class_inheritable_accessor :javascript_validation_code
      super
    end

    def create(definition_name, &block)
      class_name = name_to_class_name(definition_name)
      if !ActiveForm::Validator.const_defined?(class_name, false)
        ActiveForm::Validator.const_set(class_name, Class.new(self))
        if klass = ActiveForm::Validator.const_get(class_name, false)
          klass.module_eval(&block) if block_given?
          ActiveForm::Validator::register(klass)
          return klass
        end
      end
      nil
    end

    def loadable_type
      self.name.to_s.demodulize.underscore.to_sym
    end

    private

    def name_to_class_name(definition_name)
      Inflector::camelize("#{definition_name}")
    end

  end

end