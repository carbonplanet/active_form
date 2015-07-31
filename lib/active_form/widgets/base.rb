class ActiveForm::Widget::Base < ActiveForm::Element::Section
  
  def self.inherited(derivative)
    ActiveForm::Widget::register(derivative) if derivative.kind_of?(ActiveForm::Widget::Base)
    super
  end
  
  def self.create(definition_name, &block)
    class_name = type_classname(definition_name)
    if !ActiveForm::Widget.const_defined?(class_name)
      ActiveForm::Widget.const_set(class_name, Class.new(self))
      if klass = ActiveForm::Widget.const_get(class_name)
        klass.setup_proc = (block_given? ? block : prc) 
        return klass
      end
    end
    nil
  end
  
  def self.type_classname(type)
    type.to_s.camelize
  end
  
  def self.element_type
    "#{self.name.to_s.demodulize.underscore}_widget".to_sym
  end
  
end