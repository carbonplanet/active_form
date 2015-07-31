module ActiveForm::Mixins::LoaderMethods
  
  def self.included(base)
    base.send(:extend, ActiveForm::Mixins::LoaderMethods::ClassMethods)
  end  
  
  class NotFoundException < StandardError #:nodoc:
  end
  
  module ClassMethods
    
    def register(elem_class)
      raise ActiveForm::StubException  
    end

    def instance(klass, *args, &block)
      raise ActiveForm::StubException  
    end

    def build(definition_name, *args, &block)
      if klass = self.get(definition_name) 
        return instance(definition_name, klass, *args, &block)
      end
      nil
    end
  
    def get(type, &block)
      load(type) rescue nil unless loaded?(type)
      klass = self.const_get(type_classname(type)) rescue nil
      klass.module_eval(&block) if klass && block_given?
      klass
    end
    alias :modify :get
  
    def load(type)
      self.load_paths.reverse.each do |dir|
        loadable_file = ::File.join(dir, "#{type_filename(type)}.rb")
        require loadable_file if ::File.exists?(loadable_file)
      end
      raise NotFoundException unless self.loaded?(type)
      true
    end

    def exists?(type)
      load(type) rescue nil unless loaded?(type)
      loaded?(type)
    end

    def loaded?(type)
      self.const_defined?(type_classname(type))
    end

    def type_filename(type)
      type.to_s.camelize.underscore
    end

    def type_classname(type)
      type.to_s.camelize
    end
  
    def const_missing(type)
      begin
        load(type) && get(type)        
      rescue NotFoundException
      rescue  
        super
      end
    end
    
  end
  
end