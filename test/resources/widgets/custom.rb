ActiveForm::Widget::create :custom do |w|       
  
  w.text_element :firstname,  :title => 'First Name'
  w.text_element :lastname,   :title => 'Last Name'    

  def w.render_element(builder = create_builder)
    builder.table {
      builder.tr { builder.td { label_for_firstname(builder) }; builder.td { label_for_lastname(builder) } }
      builder.tr { builder.td { html_for_firstname(builder)  }; builder.td { html_for_lastname(builder)  } }
    }
  end

end