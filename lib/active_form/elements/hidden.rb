ActiveForm::Element::Input::create :hidden do
  
  define_attributes :type, :value
  
  def default_attributes
    { :name => element_name, :id => identifier, :type => 'hidden' }
  end
  
end