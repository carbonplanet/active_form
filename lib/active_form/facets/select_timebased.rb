class ActiveForm::Element::SelectTimebased < ActiveForm::Element::Section    
  
  TIME_FORMAT = [:year, :month, :day, :hour, :minute, :second].freeze
  DEFAULT_VALUES = { :year => 2000, :month => 1, :day => 1, :hour => 12, :minute => 0, :second => 0 }.freeze
  VALUE_CALL_MAP = { :year => :year, :month => :month, :day => :day, :hour => :hour, :minute => :min, :second => :sec }.freeze
  
  def self.inherited(derivative)
    super
    derivative.class_inheritable_accessor :default_format
    derivative.class_inheritable_accessor :allowed_parts
    derivative.default_format = TIME_FORMAT
    derivative.allowed_parts = TIME_FORMAT
  end
  
  class_inheritable_accessor :default_format
  class_inheritable_accessor :allowed_parts
  self.default_format = TIME_FORMAT
  self.allowed_parts = TIME_FORMAT
  
  attr_reader :now
  attr_accessor :format
  attr_accessor :start_year, :end_year, :range
  
  attr_accessor :year_label, :month_label, :day_label
  attr_accessor :year_increment, :month_increment, :day_increment
  
  attr_accessor :hour_label, :minute_label, :second_label
  attr_accessor :hour_increment, :minute_increment, :second_increment
  
  def self.element_type
    :select_timebased
  end
    
  def now=(value)
    @now = case value
      when Date then value.to_time
      when Time then value
      else nil
    end
    update_values(default_element_values) if @now
    @now
  end
  
  def render_element(builder = create_builder)
    builder.div(element_attributes) { render_elements(builder) }
  end
  
  def include_empty=(bool = true)
    self.update_elements(:include_empty => bool)
  end
  alias :include_empty :include_empty=
  
  def update_from_params(params, force = false)
    super(casting_filter(params), force)
  end
    
  alias :original_export_value :export_value   
    
  def export_value(values = ActiveForm::Values.new)
    export_value_as(self.type_cast)
  end
  
  def export_value_as(type)
    cast_value_to(original_export_value, type)
  end
  
  def cast_value_to(value, type = :string)
    if [:date, :time, :hash, :array, :string, :yaml].include?(type)
      time_hash = default_element_values.merge(time_to_values(self.now, true)).merge(value)
      (self.class.allowed_parts - elements_format).each { |part| time_hash[part] = 0 }
      return time_hash if type == :hash
      time_array = TIME_FORMAT.collect { |part| time_hash[part] || 0 }
      return time_array if type == :array
      time = Time.send(ActiveForm::Element::Base.default_timezone, *time_array) rescue nil
      return time.to_date if type == :date && time.respond_to?(:to_date) 
      return time.to_formatted_s(:db) if type == :string && time.respond_to?(:to_formatted_s)
      return time.to_yaml if type == :yaml
      time
    else
      value
    end
  end
  
  def type_cast=(type = :string) 
    @type_cast = type.to_sym
  end
  
  def casting_filter(value)
    time = case value
      when Date then value.to_time
      when Time then value
      when String then self.class.string_to_time(value)
      when Hash then return ActiveForm::Values.new(value)
      else nil 
    end
    return default_element_values if time.nil?
    time_to_values(time)
  end
      
  def after_initialize
    elements_format.each do |part|
      if self.class.allowed_parts.include?(part)
        defaults = {}
        defaults[:label] = self.send("#{part}_label") rescue part.to_s
        defaults[:increment] = self.send("#{part}_increment") || 1 rescue 1 
        if part == :year
          defaults[:range] = self.range if self.range.kind_of?(Range) 
          defaults[:start_year] = self.start_year if self.start_year.kind_of?(Integer) 
          defaults[:end_year] = self.end_year if self.end_year.kind_of?(Integer)  
        end
        self.define_element("select_#{part}", "#{part}", defaults) do |e|
          e.define_element_wrapper do |builder, elem, render|
            builder.span(:id => "elem_#{elem.identifier}", :class => elem.css, :style => elem.style) { render.call(builder) }
          end
        end
      elsif !part.kind_of?(Symbol)
        self << part
      end
    end
    update_values(default_element_values)
  end
  
  private
  
  def elements_format
    (self.format || self.class.default_format)
  end
  
  def default_element_values
    (elements_format & self.class.allowed_parts).inject(ActiveForm::Values.new) do |values, part| 
      values[part] = default_value_for(part)
      values 
    end
  end
  
  def time_to_values(time, all = false)
    (all ? TIME_FORMAT : (elements_format & self.class.allowed_parts)).inject(ActiveForm::Values.new) do |values, part|
      values[part] = time.send(VALUE_CALL_MAP[part]) if time.respond_to?(VALUE_CALL_MAP[part])    
      values
    end   
  end
  
  def default_value_for(part)
    (now.kind_of?(Time) && now.respond_to?(VALUE_CALL_MAP[part]) ? now.send(VALUE_CALL_MAP[part]) : DEFAULT_VALUES[part].to_i) rescue 0
  end
  
end