ActiveForm::Element::Base::create :chunky do
  
  def render_element(builder = create_builder)
    builder.h1('Chunky Bacon!', element_attributes)
  end
  
  def default_attributes
    { :id => identifier, :class => css  }
  end
  
end