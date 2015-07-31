ActiveForm::Validator::Base.create :foo do
  
  default_message "%s: should be foo-matic!"
  
  def validate
    element.errors << advice[code] unless value =~ /^(foo|bar|baz|qux)+$/
  end
  
end