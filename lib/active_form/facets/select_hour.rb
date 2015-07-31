ActiveForm::Element::SelectNumericRange::create :select_hour do
  
  def range
    (0..23)
  end
  
  def casting_filter(value)
    value = case value
      when Date then value.to_time.hour
      when Time then value.hour
      when Array, Range then value.to_a
      else value.to_i rescue 0
    end
    super(value)
  end
  
end