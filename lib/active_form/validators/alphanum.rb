ActiveForm::Validator::Base.create :alphanum do
  
  default_message "%s: should contain alphabetical characters or numbers only"
  
  def validate
    element.errors << advice[code] unless element.blank? || value.to_s.match(/^[a-zA-Z0-9]+$/)
  end
  
end