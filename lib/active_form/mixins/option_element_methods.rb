module ActiveForm::Mixins::OptionElementMethods
  
  def self.included(base)
    base.define_html_flags(:checked, false)
  end
  
  def options=(val)
    if val.kind_of?(Array)
      self.fallback_value = val.last
      self.checked_value = val.first
    else
      self.checked_value = val
    end
  end
  alias :option= :options=
  
  def checked_value=(value)
    @checked_value = value
  end
  
  def checked_value
    @checked_value ||= nil
  end
  
  def valid_option?(value)
    [self.checked_value, self.fallback_value].include?(value)
  end
  
  def checked?
    perform_check!
  end
  alias :active? :checked? 
  alias :selected? :checked?
  
  def checked
    self.html_flags[:checked]
  end
  
  def checked=(value)
    self.html_flags[:checked] = value.to_s.to_boolean
    self.element_value = (self.html_flags[:checked] ? self.checked_value : self.fallback_value)
    self.html_flags[:checked]
  end
  
  def perform_check!
    self.html_flags[:checked] = !self.blank? && self.element_value == self.checked_value
    self.element_value = (self.html_flags[:checked] ? self.checked_value : self.fallback_value)
    self.html_flags[:checked]
  end
  
  def required=(value)
    self.option_flags[:required] = value.to_s.to_boolean
    if self.option_flags[:required]
      req = proc { |v| v.element.errors.add(v.message, 'confirm') unless v.element.checked? }
      validates_with_proc :code => 'required', :proc => req
    else
      validators.delete_if { |v| v.code == 'required' }
    end
  end
  
end