ActiveForm::Element::Input::create :image do
  
  def default_attributes
    super.merge(:type => 'image')
  end
  
end