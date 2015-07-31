class ActiveForm::Element::SelectTime < ActiveForm::Element::SelectTimebased  
 
  self.default_format = [:hour, :minute]
  self.allowed_parts = [:hour, :minute, :second]
 
  def self.element_type
    :select_time
  end
  
end