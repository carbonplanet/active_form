ActiveForm::Element::Input::create :radio do
  
  include ActiveForm::Mixins::OptionElementMethods
  
  def setup
    super
    self.checked_value = 1
  end
  
  def default_attributes
    super.merge(:type => 'radio')
  end
  
  def element_attributes
    super.merge('value' => checked_value)
  end
  
end