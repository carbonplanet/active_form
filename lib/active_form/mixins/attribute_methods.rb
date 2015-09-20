module ActiveForm::Mixins::AttributeMethods

  def self.included(base)
    [:type].each { |m| base.send(:undef_method, m) rescue nil }
    base.send(:extend, ClassMethods)
  end

  def attributes
    @attributes ||= HashWithIndifferentAccess.new
  end

  def default_attributes
    { :id => identifier, :class => css }
  end

  def attribute_names
    [:style, :javascript, :title, :lang] + self.class.element_attribute_names.to_a
  end

  module ClassMethods

    def define_attributes(*attrs)
      attrs.push(:lang) unless self.element_attribute_names.include?(:lang)
      attrs.flatten.each do |attribute|
        self.element_attribute_names += [attribute.to_sym]
        define_method("#{attribute}=")  { |value| attributes[attribute] = value } unless method_defined?("#{attribute}=")
        define_method("#{attribute}")   { attributes[attribute] } unless method_defined?(attribute)
      end
    end

  end

end