module ActiveForm 
  
  class Error 
    
    attr_accessor :code, :msg, :element
    
    def initialize(element, msg, code = 'default', params = [])
      msg = element.format_message(msg, code, params)
      self.element, self.msg, self.code = element, msg, code.to_s
    end
    
    alias :message :msg 
    
    def identifier
      self.code == 'required' ? code : "validate-#{code}"
    end
    
  end
   
  class Errors
    include Enumerable

    @@default_msg = 'A validation error occurred'

    attr_reader :element

    def initialize(element)
      @errors, @element = [], element
    end
    
    def add(msg = @@default_msg, error_code = 'default', params = [])      
      @errors << ActiveForm::Error.new(element, msg, error_code, params)
    end
    
    def <<(error)
      @errors << error if error.kind_of?(ActiveForm::Error)
    end
    
    def valid?
      errors.empty?
    end
    
    def first
      errors.first
    end
    
    def errors
      @errors ||= []
    end
    alias :all :errors
    
    def at(index)
      errors.at(index)
    end
    alias :[] :at
    
    def each(&block)
      @errors.each { |error| block.call(error) }
    end
    
    def clear
      @errors.clear
    end
    alias :reset :clear
    
    def length
      @errors.length
    end
    alias :size :length
      
  end
  
end