ActiveForm::Element::SelectNumericRange::create :select_minute do
  
  def range
    (0..59)
  end
  
  def casting_filter(value)
    value = case value
      when Date then value.to_time.min
      when Time then value.min
      when Array, Range then value.to_a
      else value.to_i rescue 0
    end
    super(value)
  end
  
end