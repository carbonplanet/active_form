module ActiveForm
  class Definition
  
    attr_accessor :model_instance
    
    def clear_validations!
      super
      model_instance.errors.clear if model_instance.respond_to?(:errors)
    end
    
    def validate_element
      super      
      code_lookup = ActiveRecord::Errors.default_error_messages.invert      
      if model_instance.respond_to?(:valid?) && model_instance.respond_to?(:errors)
        unless model_instance.valid?
          errors_on_base = [*model.instance.errors.on_base] rescue []
          errors_on_base.each { |msg| self.errors.add(msg, 'ar_base') unless msg.blank? }       
          model_instance.errors.each do |attr, msg| 
            if elem = self[attr]
              code = code_lookup.key?(msg) ? code_lookup[msg] : 'elem'
              msg = "%s: #{msg}" unless code == 'elem'
              elem.errors.add(elem.format_message(msg), "ar_#{code}")
            end
          end
        end
      end
    end
    
  end
end

module ActiveForm
  module Model
    
    def self.load(*args, &block)
      custom_type = args.first.kind_of?(Symbol) ? args.shift : nil
      instance = args.shift
      definition_name = "#{instance.class.name.underscore}"
      definitions = case instance
        when ActiveRecord::Base then
          if instance.new_record?
            ["create_#{definition_name}", definition_name]
          else
            ["update_#{definition_name}", definition_name]
          end
        else
          return nil
        end     
      args.unshift("#{definition_name}_form") if args.empty? || args.first.kind_of?(Hash)
      definitions.unshift("#{custom_type}_#{definition_name}") unless custom_type.nil?
      if name = definitions.detect { |name| ActiveForm::get(name) }
        Definition.new.build(name, instance, *args, &block)
      else
        AutoDefinition.new.build(definition_name, instance, *args, &block)
      end
    end
    
    def self.load!(*args, &block)
      form = load(*args, &block)
      form.submit_element
      form
    end
    
    def self.build(*args, &block)
      instance = args.shift
      return nil unless instance.kind_of?(ActiveRecord::Base)
      definition_name = "#{instance.class.name.underscore}"
      args.unshift("#{definition_name}_form") if args.empty? || args.first.kind_of?(Hash)
      AutoDefinition.new.build(definition_name, instance, *args, &block)
    end
    
    def self.build!(*args, &block)
      form = build(*args, &block)
      form.submit_element
      form
    end
    
    class Definition
      
      def initialize
        @now = Time.now
      end
      
      def build(name, instance, *args, &block)
        form = ActiveForm::build(name, *args, &block)        
        pk_column = instance.column_for_attribute(instance.class.primary_key)
        form.insert_element_at_top(self.class.primary_key_column(pk_column)) if !pk_column.nil? && form[instance.class.primary_key.to_sym].nil?
        instance.class.columns.each { |column| (elem = form[column.name]) ? elem.type_cast = column.type : nil }
        form = instance.new_record? ? prepare_new_record(form, instance) : prepare_record(form, instance)
        assign_validation(form, instance)
        form
      end
      
      def assign_validation(form, instance)
        # TODO reflect_on_validations here
      end
      
      def prepare_new_record(form, instance)
        prepare_record(form, instance)
        form.get_elements_of_type(:select_date, :select_time, :select_datetime).each { |elem| elem.value = @now if elem.blank? }
        instance.class.columns.each { |column| ((elem = form[column.name]) && !column.default.blank?) ? elem.type_cast = column.default : nil }
        form
      end
      
      def prepare_record(form, instance)
        form.update_values(ActiveForm::Values.new(instance.attributes))
        form.model_instance = instance
        form
      end
      
      def column_to_element(column, options = {})
        options[:default] = column.default unless column.default.blank?
        
        element = self.class.respond_to?("#{column.type}_column") ? self.class.send("#{column.type}_column", column, options) : self.class.string_column(column, options)
        element.label = column.human_name
        element
      end
      
      def association_column_to_element(assoc, column, options = {})
        options[:default] = column.default unless column.default.blank?
        
        element = self.class.respond_to?("#{assoc.macro}_column") ? self.class.send("#{assoc.macro}_column", assoc, column, options) : self.class.integer_column(column, options)
        element.label = column.human_name
        element
      end   
      
      def associations_lookup(instance)
        instance.class.reflect_on_all_associations.inject({}) do |lookup, assoc|
          if assoc.macro == :belongs_to
            lookup[assoc.primary_key_name] = assoc
          end
          lookup
        end
      end
      
      class << self
        
        def belongs_to_column(assoc, column, options = {})
          if assoc.klass.respond_to?(:dropdown_text_attr)
            ActiveForm::Element::build(:select_from_model, column.name, options.merge(:type_cast => :integer, :model => assoc.klass.to_s, :to_dropdown => true))
          else
            integer_column(column, options)
          end
        end
        
        def primary_key_column(column, options = {})
          ActiveForm::Element::build(:hidden, column.name, options.merge(:type_cast => :integer))
        end
      
        def string_column(column, options = {})
          type = column.name =~ /password/i ? :password : :text
          ActiveForm::Element::build(type, column.name, options.merge(:type_cast => :string))
        end
      
        def text_column(column, options = {})
          ActiveForm::Element::build(:textarea, column.name, options.merge(:type_cast => :text))
        end
      
        def integer_column(column, options = {})
          ActiveForm::Element::build(:text, column.name, options.merge(:type_cast => :integer))
        end
        alias :float_column :integer_column
      
        def date_column(column, options = {})
          ActiveForm::Element::build(:select_date, column.name, options.merge(:type_cast => :date))
        end
      
        def datetime_column(column, options = {})
          ActiveForm::Element::build(:select_datetime, column.name, options.merge(:type_cast => :time))
        end
        alias :timestamp_column :datetime_column
      
        def boolean_column(column, options = {})
          ActiveForm::Element::build(:text, column.name, options.merge(:type_cast => :boolean))
        end
      
      end
      
    end
    
    class AutoDefinition < Definition
      
      def build(name, instance, *args, &block)     
        assoc_lookup = associations_lookup(instance)
        assoc_lookup_keys = assoc_lookup.keys
        
        form = ActiveForm::compose(*args)  
        instance.class.columns.each do |column|
          if column.primary
            form << self.class.primary_key_column(column)
          elsif column.name =~ /(_id)$/ && assoc_lookup_keys.include?(column.name)
            form << association_column_to_element(assoc_lookup[column.name], column)
          else
            form << column_to_element(column)
          end
        end      
        form.instance_eval(&block) if block_given?
        form = instance.new_record? ? prepare_new_record(form, instance) : prepare_record(form, instance)
        assign_validation(form, instance)
        form
      end
      
    end
    
  end
end