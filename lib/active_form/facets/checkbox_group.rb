ActiveForm::Element::CollectionInput::create :checkbox_group do  
  
  def multiple?
    true
  end
  
  def input_element_type
    :checkbox
  end

end