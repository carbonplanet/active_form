ActiveForm::Element::Base::create :select do
  
  include ActiveForm::Mixins::CollectionElementMethods
  
  define_attributes :size
  define_html_flags :multiple
  define_option_flags :include_empty
  
  def selected_attr(option)
    (selected_value?(option) ? 'selected' : nil)
  end  

  def default_attributes
    attrs = Hash.new
    attrs[:disabled] = 'disabled' if disabled?
    super.merge(attrs)
  end
  
  def render_frozen(builder = create_builder)
    return builder.span('-', :class => 'blank') if formatted_value.blank?
    builder.text!(selected_option_label)
  end
  
  def render_element(builder = create_builder)
    builder.select(element_attributes) do
      options_to_render = options.uniq
      options_to_render.unshift(ActiveForm::Element::CollectionOption.new('--', :blank)) if include_empty?
      options_to_render.each do |opt|
        if opt.kind_of?(ActiveForm::Element::CollectionOptionGroup)
          builder.optgroup(:label => opt.label) do
            opt.options.uniq.each do |o|
              builder.option(o.label, { :value => o.value, :selected => selected_attr(o.value) })
            end
          end          
        else
          builder.option(opt.label, { :value => opt.value, :selected => selected_attr(opt.value) })
        end
      end
    end
  end
  
end
