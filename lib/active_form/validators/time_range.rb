ActiveForm::Validator::Base.create :time_range do
  
  # format position 3 contains the minimum value
  # format position 4 contains the maximum value
  # format position 5 contains the actual value length (server side only)
  default_message "%1$s: specify a valid time or date between %3$s and %4$s"
  
  attr_accessor :range

  def setup
    self.range = (5.years.ago.beginning_of_year..6.years.from_now.beginning_of_year)
  end
  
  def validate 
    if self.range.respond_to?(:include?)
      element_value = element.export_value_as(self.range.first.kind_of?(Time) ? :time : :date)
      element.errors << advice[code] unless self.range.include?(element_value)
    end
  end

  def message_params
    first = self.range.first.to_s(:long) rescue Date.today.to_s(:long); last = self.range.last.to_s(:long) rescue Date.today.to_s(:long)
    [first, last, self.value_length]
  end
  
  # TODO
  def js_validation(validation_msg, code)   
  end
  
end