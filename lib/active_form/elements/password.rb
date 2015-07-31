ActiveForm::Element::Input::create :password do
  
  def default_attributes
    super.merge(:type => 'password', :size => 30)
  end
  
  def render_frozen(builder = create_builder)
    return builder.span('-', :class => 'blank') if formatted_value.blank?
    builder << formatted_value.gsub(/./, '&#8226;')
  end
  
end