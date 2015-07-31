ActiveForm::Element::Base::create :input do
  
  define_attributes :type, :value
  
  define_option_flags :autocomplete_off
  
  def render_element(builder = create_builder)
    builder.input(element_attributes)
  end
  
  def default_attributes
    attrs = Hash.new
    attrs[:disabled] = 'disabled' if disabled?
    attrs[:readonly] = 'readonly' if readonly?
    attrs[:autocomplete] = 'off' if autocomplete_off?
    super.merge(attrs)
  end

  def element_attributes
    super.merge('value' => formatted_value)
  end

end