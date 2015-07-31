ActiveForm::Element::Input::create :submit do
  
  def default_attributes
    super.merge(:type => 'submit')
  end
  
  def element_attributes
    super.merge('value' => label)
  end
  
  def render_frozen(builder = create_builder)
    builder.span(label, :class => 'blank')
  end
  
  def labelled?
    false
  end
  
end