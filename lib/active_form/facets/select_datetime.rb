class ActiveForm::Element::SelectDatetime < ActiveForm::Element::SelectTimebased  
 
  self.default_format = [:month, :day, :year, :hour, :minute]
  self.allowed_parts = [:month, :day, :year, :hour, :minute, :second]
  
  def self.element_type
    :select_datetime
  end
  
end