class ActiveForm::Element::SelectDate < ActiveForm::Element::SelectTimebased  
 
  self.default_format = [:month, :day, :year]
  self.allowed_parts = [:month, :day, :year]
  
  def self.element_type
    :select_date
  end
  
end