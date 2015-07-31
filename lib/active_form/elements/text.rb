ActiveForm::Element::Input::create :text do
  
  define_attributes :maxlength, :size
  
  def default_attributes
    super.merge(:type => 'text', :size => 30)
  end
  
end