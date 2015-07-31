module ActiveForm::Validator
  
  include ActiveForm::Mixins::LoaderMethods
  
  class NoElemException < StandardError #:nodoc:
  end

  class MismatchException < StandardError #:nodoc:
  end
  
  class << self  
  
    def validator?(klass)
      klass < ActiveForm::Validator::Base
    end  
 
    # loader related
  
    def load_paths
      @@load_paths ||= [*base_load_paths]
    end

    def base_load_paths
      [::File.join(ActiveForm::BASE_PATH, 'validators')]
    end
    
    def instance(definition_name, klass, *args, &block)
      item = klass.new(*args, &block)
      item
    end
  
    def create(definition_name, &block)
      ActiveForm::Validator::Base::create(definition_name, &block)
    end 
  
    def register(elem_class)
      if validator?(elem_class) && !self.methods.include?("validates_#{elem_class.loadable_type}")       
        self.module_eval("
          def validates_#{elem_class.loadable_type}(*args, &block)
            define_validator(:#{elem_class.loadable_type}, *args, &block)
          end")
      end
    end

  end

end