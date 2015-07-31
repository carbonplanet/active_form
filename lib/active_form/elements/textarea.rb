ActiveForm::Element::Base::create :textarea do
  
  define_attributes :rows, :cols
  
  def render_element(builder = create_builder)
    builder.textarea(formatted_value, element_attributes)
  end
  
  def default_attributes
    attrs = Hash.new
    attrs[:rows] = 20
    attrs[:cols] = 40
    attrs[:disabled] = 'disabled' if disabled?
    attrs[:readonly] = 'readonly' if readonly?
    super.merge(attrs)
  end
  
end