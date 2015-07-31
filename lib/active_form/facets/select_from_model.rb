# In case you need a specific select for a model you could also do:
#   
#   ActiveForm::Element::Select::create :select_country do
#     
#     def options
#       Model.find(:all).map { |item| ActiveForm::Element::CollectionOption.new(item.name, item.id) }
#     end
#     
#   end

ActiveForm::Element::Select::create :select_from_model do

  attr_accessor :model, :find_options, :label_attr, :value_attr, :group_attr

  define_option_flags :to_dropdown

  def model_class
    (@model || self.name.to_s.sub(/_id$/, '')).to_s.classify
  end
  
  def label_attr
    @label_attr ||= :name
  end
  
  def value_attr
    @value_attr ||= :id
  end
  
  def find_options
    @find_options ||= { :select => "#{label_attr}, #{value_attr}", :order => "#{label_attr}, #{value_attr}" }
  end
  
  alias :find= :find_options=
    
  def options
    opts = []
    opts << ActiveForm::Element::CollectionOption.new('--', :blank) if include_empty?
    model = self.model_class.constantize rescue nil
    return opts unless !model.nil? && model < ActiveRecord::Base 
    if model.respond_to?(:to_dropdown) && to_dropdown?
      model.to_dropdown.each { |(label, value)| opts << ActiveForm::Element::CollectionOption.new(label, value) }
    else 
      items = model.find(:all, find_options)
      if !group_attr.nil? && items.first.respond_to?(group_attr)
        attrib = group_attr.to_sym
        items.group_by { |item| item.send(attrib) }.each do |label, values| 
          opts << ActiveForm::Element::CollectionOptionGroup.new(label) do |g|
            values.each { |item| g << ActiveForm::Element::CollectionOption.new(item.send(label_attr), item.send(value_attr)) }
          end      
        end
      else
        items.each do |item|
          opts << ActiveForm::Element::CollectionOption.new(item.send(label_attr), item.send(value_attr))        
        end
      end
    end
    opts
  end

end