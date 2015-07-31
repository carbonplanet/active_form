ActiveForm::Validator::Base.create :required do
  
  default_message "%s: can't be blank"
  
  def validate
    element.errors << advice[code] if element.blank?
  end
  
end