ActiveForm::Validator::Base.create :alpha do
  
  default_message "%s: should contain alphabetical characters only"
  
  def validate
    element.errors << advice[code] unless element.blank? || value.to_s.match(/^[a-zA-Z]+$/)
  end

end