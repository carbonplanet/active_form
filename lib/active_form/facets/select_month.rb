ActiveForm::Element::SelectNumericRange::create :select_month do
  
  define_option_flags :use_short_month, :add_month_numbers, :use_month_numbers
  
  def to_monthname
    multiple? ? element_value.map { |i| number_to_label(i) } : number_to_label(element_value)
  end
  
  def export_value
    exp_value = super
    if self.type_cast == :string
      to_monthname
    else
      exp_value
    end
  end 
  
  def range
    (1..12)
  end
  
  def casting_for_string
    [nil, nil]
  end
  
  def casting_filter(value)
    value = case value
      when Date, Time then value.month
      when Array, Range then value.to_a
      else value.to_i rescue 0
    end
    super(value)
  end
  
  def number_to_label(month_number)
    month_names = use_short_month? ? Date::ABBR_MONTHNAMES : Date::MONTHNAMES rescue {}
    if use_month_numbers? || month_names.empty?
      month_number.zero_padded(2)
    elsif add_month_numbers?
      month_number.zero_padded(2) + ' - ' + month_names[month_number]
    else
      month_names[month_number]
    end
  end
  
end