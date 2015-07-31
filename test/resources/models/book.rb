ActiveForm::Definition::create :book do |f|
  
  f.text_element :title
  f.text_element :isbn
  f.select_date_element :publication_date, :format => [:day, :month, :year], :range => (2005..2010)
  f.select_from_model_element :publisher_id        

end