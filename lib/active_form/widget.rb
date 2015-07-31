module ActiveForm::Widget
  
  include ActiveForm::Mixins::LoaderMethods
  
  class << self

    def element?(klass)
      klass.respond_to?(:element?) && klass.element?
    end

    # loader related

    def load_paths
      @@load_paths ||= [*base_load_paths]
    end

    def base_load_paths
      [ ::File.join(ActiveForm::BASE_PATH, 'widgets') ]
    end

    def instance(definition_name, klass, *args, &block)
      args.unshift(definition_name) if args.empty? || args.first.kind_of?(Hash)
      item = klass.new(*args)
      item.instance_eval(&block) if block_given?
      item
    end
    
    def create(definition_name, &block)
      ActiveForm::Widget::Base::create(definition_name, &block)
    end

    def register(elem_class)
      if element?(elem_class) && !self.methods.include?("#{elem_class.loadable_type}_element")
        self.module_eval("
          def #{elem_class.loadable_type}_widget(*args, &block)
            define_widget(:#{elem_class.loadable_type}, *args, &block)
          end")
      end
    end

  end

end