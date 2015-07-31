ActiveForm::Element::SelectNumericRange::create :select_weekday do
  
  define_option_flags :use_short_day, :weekend_only, :weekdays_only
  
  def to_dayname
    multiple? ? element_value.map { |i| number_to_label(i) } : number_to_label(element_value)
  end
  
  def export_value
    exp_value = super
    if self.type_cast == :string
      to_dayname
    else
      exp_value
    end
  end 
  
  def range
    if weekend_only?
      [6, 0]
    elsif weekdays_only?
      (1..5)
    else
      (0..6)
    end
  end
  
  def casting_for_string
    [nil, nil]
  end
  
  def casting_filter(value)
    value = case value
      when Date, Time then value.wday
      when Array, Range then value.to_a
      else value.to_i rescue 0
    end
    super(value)
  end
  
  def number_to_label(day_number)
    day_names = use_short_day? ? Date::ABBR_DAYNAMES : Date::DAYNAMES rescue {}
    day_names[day_number]
  end
  
end