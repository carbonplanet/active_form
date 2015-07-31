ActiveForm::Validator::Base.create :set do
  
  # format position 3 contains the allowed values
  default_message "%1$s: invalid value"
  
  attr_accessor :set

  def setup
    self.set = []
  end

  def validate
    value_set = self.set.respond_to?(:include?) ? self.set : []
    element.errors << advice[code] unless value_set.include?(self.value)
  end
  
  def message_params
    [ [*self.set].join(', ') ]
  end
  
end