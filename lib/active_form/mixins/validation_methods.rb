module ActiveForm::Mixins::ValidationMethods
  
  def self.included(base)    
    base.send(:extend, ClassMethods)
  end
  
  def define_validator(type, *args, &block)
    args.unshift(self)
    validator = ActiveForm::Validator::build(type, *args, &block)
    validators << validator
    validator
  end
  
  def format_message(msg = @@default_msg, error_code = 'default', params = [])
    msg = (localize(name, "validates_#{error_code}") || msg) if localized?
    mparams = message_params + params
    sprintf(msg || '', *mparams)
  end
  
  def message_params
    [label, element_value]
  end
  
  def get_validation_advice_wrapper
    if respond_to?(:advice_wrapper)
      method_to_proc(:advice_wrapper)
    elsif self.class.respond_to?(:advice_wrapper)
      self.class.method_to_proc(:advice_wrapper)
    else
      self.class.method_to_proc(:default_validation_advice_wrapper)
    end
  end
  
  def validators_by_type(*types)
    types.map(&:to_s)
    self.validators.find_all { |v| types.include?(v.code) }
  end
  
  def required_message=(str)
    validator = self.validators_by_type('required').first
    validator.message = str unless validator.nil?
  end
  
  def validation_advice(builder = create_builder)
    str = server_side_validation_advice(builder)
    str << client_side_validation_advice(builder) if client_side?
    str 
  end
  
  def server_side_validation_advice(builder = create_builder, first_only = true)
    element_errors(first_only).inject('') do |str, error|
      attrs = { :id => "advice-#{error.identifier}-#{error.element.identifier}", :class => "validation-advice advice-#{error.code}" }
      get_validation_advice_wrapper.call(builder, error, attrs)
    end
  end
  
  def all_server_side_validation_advice(builder = create_builder)
    server_side_validation_advice(builder, false)
  end
  
  def client_side_validation_advice(builder = create_builder)
    gather_validation_advice.each do |adv|
      attrs = { :id => "advice-#{adv.identifier}-#{adv.element.identifier}", :style => 'display: none', :class => "validation-advice advice-#{adv.code}" }
      get_validation_advice_wrapper.call(builder, adv, attrs)
    end
    builder.target!
  end
  
  def gather_validation_advice    
    adv = validators.inject([]) { |ary, v| v.advice.keys.sort.inject(ary) { |a, key| a << v.advice[key] unless v.advice[key].blank? } }
    each { |elem| adv += elem.gather_validation_advice } if container?
    adv.compact    
  end
  
  def validation_css_class
    css = validators.inject(CssAttribute.new) { |cs, v| cs << "#{v.identifier}" }
    each { |elem| css += elem.validation_css_class } if container?
    css.compact  
  end
  
  def validation_javascript_definitions
    js = validators.inject([]) { |ary, v| ary << v.javascript_definition }.compact.join("\n")
    each { |elem| js += elem.validation_javascript_definitions } if container?
    js
  end
  
  def client_side?
    client_side == true || (contained? && container.client_side?)
  end
  
  def client_side_options
    @client_js_options ||= { :stopOnFirst => false, :useTitles => true }
  end
  
  def client_side
    @client_side_validation ||= false
  end
  
  def client_side=(value)
    @client_side_validation = value.to_s.to_boolean
  end

  def validators
    @validators ||= []
  end
  
  def errors
    @errors ||= ActiveForm::Errors.new(self)
  end
  
  def element_errors(first_only = false)
    elem_errors = first_only ? [errors.first] : errors.all
    elements.each { |elem| elem_errors += elem.element_errors(first_only) } if container?
    elem_errors.compact
  end
  alias :all_errors :element_errors
  alias :validation_errors :element_errors
  
  def initial_errors
    element_errors(true)
  end
  
  def each_error(&block)   
    element_errors.each(&block)
  end
  
  def every_error(&block)   
    element_errors(true).each(&block)   
  end
  alias :every_initial_error :every_error
  
  def reset_errors!
    errors.reset
  end
  
  def valid?
    initial_errors.empty?
  end
  
  def validate
    perform_validation && valid?
  end
  
  def validate!
    return true if validate  
    raise ActiveForm::ValidationException 
  end
  
  def perform_validation
    reset_errors!     
    each { |elem| elem.perform_validation } if container?
    validators.each(&:validate)
    validate_element
    after_validation_callback(self) if respond_to?(:after_validation_callback)
    return true # so you can write perform_validation && valid?
  end
  
  def clear_validations!
    reset_errors!
    recurse(&:clear_validations!) if container?
  end
  
  def validate_element
    internal_validation(self) if respond_to?(:internal_validation)
    validation_handler(self) if respond_to?(:validation_handler)
    self.class.validation_handler(self) if self.class.respond_to?(:validation_handler)
  end
  
  def define_validation(prc = nil, &block)
    define_singleton_method(:validation_handler, &(block_given? ? block : prc))
  end
  alias :validation= :define_validation
  alias :validation :define_validation
  
  def reset_validation
    undefine_singleton_method(:validation_handler) rescue nil
  end
  
  def javascript_validation_code
    return nil unless respond_to?(:js_validation_generator) || self.class.respond_to?(:js_validation_generator)
    vparams = { :name => identifier.dasherize, :msg => "#{label}: validation failed" }
    code = JavascriptAttribute.new
    js_validation_generator(self, code, vparams) if respond_to?(:js_validation_generator)
    self.class.js_validation_generator(self, code, vparams) if self.class.respond_to?(:js_validation_generator)
    return nil if code.empty? 
    class_name = "validate-#{vparams[:name]}"
    css_class << class_name unless container? || css_class.include?(class_name)
    %|Validation.add('#{class_name}', "#{vparams[:msg]}", function (v) {\n  #{code}\n});|
  end
  
  def javascript_validation(prc = nil, &block)
    define_singleton_method(:js_validation_generator, &(block_given? ? block : prc))
  end
  alias :javascript_validation= :javascript_validation
  
  def reset_javascript_validation
    undefine_singleton_method(:js_validation_generator) rescue nil
  end
  
  def validation_advice_wrapper(prc = nil, &block)
    define_singleton_method(:advice_wrapper, &(block_given? ? block : prc))
  end
  alias :javascript_validation= :javascript_validation
  
  def reset_validation_advice_wrapper
    undefine_singleton_method(:advice_wrapper) rescue nil
  end
  
  def after_validation(prc = nil, &block)
    define_singleton_method(:after_validation_callback, &(block_given? ? block : prc))
  end
  alias :after_validation_callback= :after_validation

  def reset_after_validation_callback
    undefine_singleton_method(:after_validation_callback) rescue nil
  end

  module ClassMethods
    
    def define_validation(prc = nil, &block)
      define_singleton_method(:validation_handler, &(block_given? ? block : prc))
    end
    alias :validation= :define_validation
    
    def reset_validation
      undefine_singleton_method(:validation_handler) rescue nil
    end
    
    def javascript_validation(prc = nil, &block)
      define_singleton_method(:js_validation_generator, &(block_given? ? block : prc))
    end
    alias :javascript_validation= :javascript_validation
  
    def reset_javascript_validation
      undefine_singleton_method(:js_validation_generator) rescue nil
    end
    
    def default_validation_advice_wrapper(builder, error, attrs)
      builder.div(error.message, attrs)
    end
    
    def validation_advice_wrapper(prc = nil, &block)
      define_singleton_method(:advice_wrapper, &(block_given? ? block : prc))
    end
    alias :javascript_validation= :javascript_validation
  
    def reset_validation_advice_wrapper
      undefine_singleton_method(:advice_wrapper) rescue nil
    end
    
  end
  
end