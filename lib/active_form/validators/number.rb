ActiveForm::Validator::Base.create :number do
  
  default_message "%s: should be numeric"
  
  def validate
    element.errors << advice[code] unless element.blank? || value.to_s.match(/^[0-9\.,]+$/)
  end
  
end