ActiveForm::Element::Input::create :button do

  def default_attributes
    super.merge(:type => 'button')
  end
  
  def element_attributes
    super.merge('value' => label)
  end

  def labelled?
    false
  end
  
end