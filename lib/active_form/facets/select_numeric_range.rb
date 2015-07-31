ActiveForm::Element::Select::create :select_numeric_range do
  
  attr_accessor :increment, :range, :subset
  
  def casting_filter(value)
    multiple? && value.respond_to?(:map) ? value.map { |val| normalize_value(val) } : normalize_value(value)
  end
  
  def element_value
    v = [*super].compact.map { |val| normalize_value(val) }.uniq
    multiple? ? v : v.first
  end
  alias :values :element_value
  alias :value :element_value
  
  def normalize_value(value)
    integer = value.respond_to?(:to_i) ? value.to_i : 0
    valid_opts = self.option_values
    incr = (self.increment || 1)  
    min_value = self.range.first  
    max_value = self.range.last
    min = min_value.nearest(incr)
    min = min + incr if min < min_value && incr > 1
    max = max_value.nearest(incr)
    max = max - incr if max > max_value && incr > 1  
    if valid_opts.include?(integer)
      val = integer
    else
      val = integer.nearest(incr)
      if val > min && val < max && !valid_opts.include?(val) 
        val = valid_opts.detect { |v| v >= integer } 
      end
    end
    (val > min_value ? (val > max_value ? max : val) : min)
  end
  
  def options
    opts = []
    opts << ActiveForm::Element::CollectionOption.new('--', :blank) if include_empty?
    option_range = self.subset.kind_of?(Array) ? self.subset & self.range.to_a : self.range
    if self.increment > 1 && self.range.kind_of?(Range)
      (option_range).step(self.increment) { |i| opts << ActiveForm::Element::CollectionOption.new(number_to_label(i), i) }
    else
      option_range.to_a.each { |i| opts << ActiveForm::Element::CollectionOption.new(number_to_label(i), i) }
    end
    opts
  end
  
  def number_to_label(i)
    i.zero_padded(2)
  end
  
  def update_options_and_attributes(hash)
    self.increment = hash.delete(:increment) || hash.delete('increment') || 1
    self.range = hash.delete(:range) || hash.delete('range') unless self.range.blank?
    super(hash)
  end
  
end