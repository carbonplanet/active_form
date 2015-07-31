ActiveForm::Validator::Base.create :format do
  
  default_message "%s: has an invalid format"
  
  attr_accessor :regexp
  
  def setup
    self.regexp = /.*/
  end
  
  def validate
    element.errors << advice[code] unless element.blank? || (self.regexp.kind_of?(Regexp) && value.to_s.match(self.regexp))
  end
  
end