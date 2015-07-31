ActiveForm::Element::Input::create :file do
  
  define_attributes :size, :accept
  
  def default_attributes
    super.merge(:type => 'file')
  end
  
  def element_attributes
    attrs = super
    attrs.delete('value')
    attrs
  end
  
end