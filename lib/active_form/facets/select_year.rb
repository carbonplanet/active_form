ActiveForm::Element::SelectNumericRange::create :select_year do
  
  def range
    @range ||= Range.new(Time.now.year - 5,  Time.now.year + 5)
  end
  
  def start_year=(int)
    @range = Range.new(int.to_i, self.range.last)
  end
  
  def end_year=(int)
    @range = Range.new(self.range.first, int.to_i)
  end
  
  def casting_filter(value)
    value = case value
      when Date, Time then value.year
      when Array, Range then value.to_a
      else value.to_i rescue 0
    end
    super(value)
  end
  
end