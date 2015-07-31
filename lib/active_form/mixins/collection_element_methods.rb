module ActiveForm::Mixins::CollectionElementMethods
  
  def self.included(base)
    base.send(:include, Enumerable)
    
    base.send(:alias_method, :values, :element_value)
    base.send(:alias_method, :value, :element_value)
        
    base.send(:alias_method, :selected=, :element_value=)
    base.send(:alias_method, :update_from_params, :element_value=)
    base.send(:alias_method, :params=, :element_value=)  
    base.send(:alias_method, :initial_value=, :element_value=) 
    base.send(:alias_method, :update_value, :element_value=) 
    base.send(:alias_method, :values=, :element_value=)
    base.send(:alias_method, :value=, :element_value=) 
    base.send(:alias_method, :binding=, :element_value=)
    base.send(:alias_method, :bind_to, :element_value=)  
  end
  
  def each(&block)
    options.each(&block)
  end

  def recurse(&block)
    options.each do |option|
      if option.kind_of?(ActiveForm::Element::CollectionOptionGroup)
        option.options.each(&block)
      else
        block.call(option)     
      end
    end
  end

  def element_name
    elem_name = super
    elem_name << '[]' if multiple?
    elem_name
  end

  def element_value
    multiple? ? [*super].compact.flatten : [*super].compact.first
  end
   
  def element_value=(val)
    super(cast_value(multiple? ? [*val].compact.flatten : val.respond_to?(:compact) ? [*val].compact.first : val))
  end
  
  def default_value
    multiple? ? [] : super
  end
  
  def fallback_value=(value)
    if multiple?   
      @fallback_value = value.respond_to?(:to_a) ? value.to_a : [value].flatten
    else
      @fallback_value = [*value].compact.first
    end
  end
  
  def option_labels
    results = []
    self.recurse { |option| results << option.label }
    results
  end
  
  def option_values
    results = []
    self.recurse { |option| results << option.value }
    results
  end
  
  def valid_option?(value)
    (option_values + [*fallback_value] + [*default_value]).compact.include?(value)
  end
  
  def valid_value?
    raw_values = [*element_value]
    (raw_values & option_values).length == raw_values.length
  end
  
  def options
    @options ||= []
  end
 
  def options=(values)
    reset_options!
    add_options(values)
  end
  
  def add_options(values)
    values.each { |value| add_option(value) }
  end
  alias :append :add_options
 
  def add_option(value)
    if value.kind_of?(ActiveForm::Element::CollectionOption)
      self.options << value
    elsif (value.kind_of?(Array) || value.kind_of?(Set))
      self.options << ActiveForm::Element::CollectionOption.new(value.first, value.last)
    else
      self.options << ActiveForm::Element::CollectionOption.new(value, value)
    end
    self
  end
  alias :<< :add_option
  
  def option(label, value = nil)
    self << [label, (value || label)]
  end
  
  def reset_options!
    @options = []
  end
  
  def empty_option=(label = '--')
    add_empty_option(label)
  end
  alias :empty= :empty_option=
 
  def add_empty=(value)
    add_empty_option if value
  end
  
  def add_empty_option(label = '--', value = :blank)
    self.options.unshift(ActiveForm::Element::CollectionOption.new(label, value))
  end
  alias :add_empty :add_empty_option
  
  def add_optgroup(*args, &block)
    self.options << ActiveForm::Element::CollectionOptionGroup.new(*args, &block)    
  end
  alias :option_group :add_optgroup

  def select_first=(bool = true)
    self.element_value = option_values.first if bool
  end
  alias :select_first :select_first=

  def selected_value?(value)
    multiple? ? (element_value || []).include?(value) : element_value == value
  end
  alias :selected? :selected_value?
  
  def selected_option_label
    self.options.inject([]) { |ary, opt| ary << opt.label if selected_value?(opt.value); ary }.join(', ')
  end
  
  def blank?
    element_value.blank? || !valid_value?
  end
  
  def required=(value)
    if value.kind_of?(Numeric)
      min_required = value.kind_of?(Numeric) ? value.to_i : 0 
      max_required = min_required
    elsif value.respond_to?(:first) && value.respond_to?(:last)
      min_required = value.first.to_i
      max_required = value.last.to_i
    else
      min_required = 0
      max_required = 0
    end
    validate_with_count = (min_required > 0 || (min_required == 0 && max_required > 0)) 
    self.option_flags[:required] = value.to_s.to_boolean || validate_with_count
    if self.option_flags[:required]
      if validate_with_count
        validates_with_option_count :code => 'required', :range => (min_required..max_required)
      else
        validates_as_required
      end
    else
      validators.delete_if { |v| v.code == 'required' }
    end
  end
  
end

class ActiveForm::Element::CollectionOption
  
  attr_accessor :label, :value
  
  def initialize(label, value)
    @label, @value = label.to_s, value
  end
    
end

class ActiveForm::Element::CollectionOptionGroup
  
  include ActiveForm::Mixins::CollectionElementMethods
  
  attr_accessor :label
  
  def initialize(label, options = [], &block)
    @label = label.to_s
    self.options = options
    block.call(self) if block_given?
  end
  
  def value
    @options.collect(&:value)
  end
  
end
