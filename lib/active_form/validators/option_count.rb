ActiveForm::Validator::Base.create :option_count do
  
  # format position 3 contains the minimum value
  # format position 4 contains the maximum value
  # format position 5 contains the actual value length (server side only)
  default_message "%1$s: you need to select %3$s items"
  
  attr_accessor :range
  
  def setup
    self.range = (0..1)
  end
  
  def validate
    length_range = self.range.respond_to?(:include?) ? self.range : []
    element.errors << advice[code] unless length_range.include?(self.collection_length)
  end
  
  def message_params
    first = self.range.first rescue 0; last = self.range.last rescue 0
    [first, last, collection_length]
  end
  
end