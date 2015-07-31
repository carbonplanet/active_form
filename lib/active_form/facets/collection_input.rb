ActiveForm::Element::Base::create :collection_input do  
  
  include ActiveForm::Mixins::CollectionElementMethods
  
  attr_accessor :columns
  
  define_option_flags :legend, :render_empty
  
  def self.group?
    true
  end
  
  def multiple?
    true
  end

  def input_element_type
    :text
  end
  
  def in_columns?
    self.columns.to_i > 1
  end

  def each_option_column(&block)
    return self.options unless in_columns? && block_given?
    cols = self.columns.to_i
    partitioned_options = options
    options.length.modulo(cols).times { partitioned_options << nil }
    partitioned_options.in_groups_of(options.length/cols, &block)
  end

  def selected_attr(option)
    (selected_value?(option) ? 'checked' : nil)
  end
  
  def default_attributes
    { :id => identifier, :class => css  }
  end
  
  def input_element_attributes
    attrs = { :type => input_element_type, :class => "elem_#{input_element_type}", :name => self.element_name }
    attrs[:disabled] = 'disabled' if disabled?
    attrs
  end

  def render_frozen(builder = create_builder)
    return builder.span('-', :class => 'blank') if formatted_value.blank?
    builder.text!(selected_option_label)
  end

  def render_element(builder = create_builder)
    if in_columns?
      colcount = 0
      builder.fieldset(element_attributes) do
        builder.legend(label) if legend?
        each_option_column do |col|
          colcount += 1
          builder.div(:class => "column column-#{colcount}") {
            col.each { |opt| render_collection_element(opt, builder) }
          }
        end
      end
    else
      builder.fieldset(element_attributes) do
        builder.legend(label) if legend?
        options.each { |opt| render_collection_element(opt, builder) }
      end 
    end
  end

  def render_collection_element(option, builder = create_builder)
    if option.kind_of?(ActiveForm::Element::CollectionOptionGroup)
      builder.fieldset(:class => 'options') do
        builder.legend(option.label) if legend?
        option.options.each { |opt| render_collection_element(opt, builder) }
      end
    else
      render_input_element(option, builder)
    end
  end

  def render_input_element(option, builder = create_builder) 
    unless option.nil? && !render_empty?
      class_name = option.nil? ? 'empty-elem' : 'elem' 
      builder.span(:class => class_name) { 
        unless option.nil?
          id = "#{self.identifier}_#{value_to_identifier(option.label)}"          
          builder.input(input_element_attributes.merge(:id => id, :value => option.value, :checked => selected_attr(option.value)))
          builder.label(option.label, :for => id)
        end 
      }
    end
  end

end