ActiveForm::Element::SelectNumericRange::create :select_day do
  
  def range
    (1..31)
  end
  
  def casting_filter(value)
    value = case value
      when Date then value.mday
      when Time then value.day
      when Array, Range then value.to_a
      else value.to_i rescue 0
    end
    super(value)
  end
    
end