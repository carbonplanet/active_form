ActiveForm::Validator::Base.create :digits do
  
  default_message "%s: should contain digits (0-9) only"
  
  def validate
    element.errors << advice[code] unless element.blank? || value.to_s =~ /^\d+$/
  end

end