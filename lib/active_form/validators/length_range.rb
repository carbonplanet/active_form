ActiveForm::Validator::Base.create :length_range do
  
  # format position 3 contains the minimum value
  # format position 4 contains the maximum value
  # format position 5 contains the actual value length (server side only)
  default_message "%1$s: length should be within %3$s and %4$s characters"
  
  attr_accessor :range

  def setup
    self.range = (0..1)
  end

  def validate
    length_range = self.range.respond_to?(:include?) ? self.range : []
    element.errors << advice[code] unless length_range.include?(self.value_length)
  end
  
  def message_params
    first = self.range.first rescue 0; last = self.range.last rescue 0
    [first, last, self.value_length]
  end
  
end