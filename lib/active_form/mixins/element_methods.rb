module ActiveForm::Mixins::ElementMethods

  def self.included(base)
    base.send(:include, ActiveForm::Mixins::AttributeMethods)  
    base.send(:extend, ActiveForm::Mixins::ElementMethods::ClassMethods)  
    base.send(:include, ActiveForm::Mixins::Casting)  
    base.send(:attr_reader, :container)
    base.send(:attr_accessor, :name)
  end
  
  def initialize_element(*args)
    attributes = args.last.is_a?(Hash) ? args.pop : {} 
    container = args.shift if is_container?(args.first)
    args.unshift(element_type) unless args.first.kind_of?(String) || args.first.kind_of?(Symbol)
    raise ArgumentError if args.empty?
    self.name = ActiveForm::symbolize_name(args.first)
    self.label = self.name.to_s.titleize      
    register_container(container) if is_container?(container)     
    initialize_properties   
    update_options_and_attributes(attributes)
    yield self if block_given?
  end
   
  def register_container(container) 
    return ArgumentError unless is_container?(container)
    @container = container
    revert_value unless container.bound_value?(self.name)
    define_localizer(container.localizer) if self.container? && container.localized?
  end
  alias :container= :register_container
  
  def accept_block(&block)
    self.instance_eval(&block)
  end
  
  def identifier
    self.contained? ? "#{container.identifier}_#{self.name}" : "#{self.name}"
  end
  
  def element_name
    elem_name = self.contained? ? "#{container.element_name}[#{self.group || self.name}]" : "#{self.group || self.name}"
    elem_name << '[]' unless self.group.blank?
    elem_name
  end
  
  def element_type
    self.class.element_type
  end
  
  def label
    return (localize(name, 'label') || @label) if localized?
    @label
  end
  
  def title
    return (localize(name, 'title') || attributes[:title]) if localized?
    attributes[:title]
  end
  
  def description
    return (localize(name, 'description') || @description) if localized?
    @description
  end

  def element_binding
    element_value
  end

  def element_binding_key
    self.name
  end

  def default_value
    nil
  end

  def fallback_value
    @fallback_value || default_value
  end

  def fallback_value=(value)
    @fallback_value = value
  end
  alias :default= :fallback_value=

  def export_value
    blank? ? cast_value(fallback_value || default_value) : element_value
  end
  
  def frozen_value
    @frozen_value.blank? ? freeze_value(element_value) : @frozen_value
  end
  
  def frozen_value=(value)
    @frozen_value = value
  end
  
  def formatted_value
    return frozen_value if frozen? && !frozen_value.blank? 
    format_value(element_value)
  end
   
  def element_value(export = false)
    return export_value if export
    if self.contained?
      revert_value unless container.bound_value?(element_binding_key)
      container.get_bound_value(element_binding_key)
    else
      @element_value ||= default_value
    end   
  end
  alias :values :element_value
  alias :value :element_value
  
  def element_value=(value, force = false)
    value = cast_value(value)
    if self.contained?
      container.set_bound_value(element_binding_key, value)
    else
      @element_value = value
    end    
  end
  
  alias :update_from_params :element_value=
  alias :params= :element_value=
  
  alias :initial_value= :element_value= 
  alias :update_value :element_value=
  
  alias :values= :element_value=
  alias :value= :element_value=
  
  alias :binding= :element_value=
  alias :bind_to :element_value=
  
  def revert_value
    if self.contained?
      container.set_bound_value(element_binding_key, default_value)
    else
      @element_value = default_value   
    end 
  end
 
  def element_attributes
    attrs = attribute_names.inject(default_attributes) do |hash, attribute|
      value = send(attribute) rescue nil
      hash[attribute] = value unless value.blank?
      hash
    end
    final = attrs.merge(attributes).merge(html_flag_attributes).merge(option_flag_attributes).stringify_keys.delete_blanks
    if skip_css_class? && !(vcss = validation_css_class.to_s).blank?
      final['class'] = vcss
    end
    final.delete('style') if skip_css_style?
    final
  end
  
  def update_options_and_attributes(hash)
    last_pass_options = ['options', 'option', 'multiple', 'binding', 'initial_value', 'fallback_value', 'checked']
    ordered_options = [*self.class.element_html_flag_names] + [*self.class.element_attribute_names]
    ordered_options.map!(&:to_s)
    hash.stringify_keys!
    self.type_cast = hash.delete('type_cast') if hash.key?('type_cast')
    hash['fallback_value'] = hash.delete('default') if hash.key?('default')
    hash['initial_value'] = hash.delete('values') if hash.key?('values')
    hash['initial_value'] = hash.delete('value') if hash.key?('value')   
    (((hash.keys & ordered_options) - last_pass_options) + (last_pass_options & hash.keys)).each do |option|
      send("#{option}=", hash[option]) rescue nil
      hash.delete(option)
    end
    hash.each { |option, value| send("#{option}=", value) rescue nil } 
  end
  alias :update :update_options_and_attributes
  
  def freeze_element
    self.frozen = true
  end
  alias :freeze! :freeze_element
  
  def hide_element
    self.hidden = true
  end
  alias :hide! :hide_element
  
  # stub implementations:
  
  def render_frozen(builder = create_builder)
    raise ActiveForm::StubException
  end
  
  def render_element(builder = create_builder)
    raise ActiveForm::StubException
  end
  
  def contained?
    @container ||= nil
    (@container && @container.container?) || false
  end
  
  def labelled?
    true
  end
  
  def hidden?
    (option_flags[:hidden] == true)
  end
  
  def frozen?
    (option_flags[:frozen] == true) || (contained? && container.frozen?)
  end
  
  def disabled?
    (option_flags[:disabled] == true) || (contained? && container.disabled?)
  end
  
  def readonly?
    (option_flags[:readonly] == true) || (contained? && container.readonly?)
  end
  
  def required=(value)
    self.option_flags[:required] = value.to_s.to_boolean
    if self.option_flags[:required]
      validates_as_required
    else
      validators.delete_if { |v| v.code == 'required' }
    end
  end
  
  def required?
    (option_flags[:required] == true) || (contained? && container.required?)
  end
  
  def localized?
    contained? && container.localized?
  end
  
  def localize(*args)
    container.localizer.call(container.identifier, *args) if localized?  
  end
  
  def format_value(value)
    if self.respond_to?(:formatting_filter)
      self.formatting_filter(element_value).to_s rescue element_value
    elsif self.class.respond_to?(:formatting_filter)
      self.class.formatting_filter(element_value).to_s rescue element_value
    else
      element_value.to_s
    end
  end
  
  def define_formatting_filter(prc = nil, &block)
    define_singleton_method(:formatting_filter, &(block_given? ? block : prc))
  end
  alias :formatting_filter= :define_formatting_filter
  
  def reset_formatting_filter
    define_singleton_method(:formatting_filter) rescue nil
  end
  
  def freeze_value(value)
    if self.respond_to?(:freeze_filter)
      self.freeze_filter(element_value).to_s rescue element_value
    elsif self.class.respond_to?(:freeze_filter)
      self.class.freeze_filter(element_value).to_s rescue element_value
    else
      element_value.to_s
    end
  end
  
  def define_freeze_filter(prc = nil, &block)
    define_singleton_method(:freeze_filter, &(block_given? ? block : prc))
  end
  alias :freeze_filter= :define_freeze_filter
  
  def reset_freeze_filter
    define_singleton_method(:freeze_filter) rescue nil
  end
  
  module ClassMethods
        
    def element_type
      self.name.to_s.demodulize.underscore.to_sym
    end
    alias :loadable_type :element_type
    
    def type_classname(definition_name)
      "#{definition_name}".camelize
    end
    
    def define_standard_option_flags
      define_option_flags(:frozen, :hidden, :disabled, :readonly, :required, :skip_css_class, :skip_css_style)   
    end
    
    def define_formatting_filter(prc = nil, &block)
      define_singleton_method(:formatting_filter, &(block_given? ? block : prc))
    end
    alias :formatting_filter= :define_formatting_filter
  
    def reset_formatting_filter
      define_singleton_method(:formatting_filter) rescue nil
    end
    
    def define_freeze_filter(prc = nil, &block)
      define_singleton_method(:freeze_filter, &(block_given? ? block : prc))
    end
    alias :freeze_filter= :define_freeze_filter
  
    def reset_freeze_filter
      define_singleton_method(:freeze_filter) rescue nil
    end

  end
  
end