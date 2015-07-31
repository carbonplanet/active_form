ActiveForm::Element::Input::create :reset do
  
  def default_attributes
    super.merge(:type => 'reset')
  end
  
  def element_attributes
    super.merge('value' => label)
  end

  def labelled?
    false
  end
  
end