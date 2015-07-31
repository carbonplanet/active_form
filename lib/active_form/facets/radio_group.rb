ActiveForm::Element::CollectionInput::create :radio_group do  
  
  def multiple?
    false
  end
  
  def input_element_type
    :radio
  end

end