module ActiveForm::Mixins::CommonMethods
  
  def self.included(base)    
    base.send(:attr_reader, :name)
    base.send(:attr_writer, :label, :description)
    base.send(:attr_accessor, :group)
    
    base.send(:include, ActiveForm::Mixins::CssMethods)
    base.send(:include, ActiveForm::Mixins::JavascriptMethods)
    base.send(:include, ActiveForm::Mixins::ValidationMethods)
        
    base.send(:include, StubInstanceMethods)
    base.send(:extend, StubClassMethods)
    base.send(:extend, ClassMethods)
  end
  
  def initialize(*args, &block)
    setup
    initialize_element(*args, &block)
    after_initialize
  end
  
  def setup
    self.class.setup_method(self) if self.class.respond_to?(:setup_method)
  end
  
  def after_initialize
  end
  
  def rebuild!
    after_initialize
  end
  
  def definition?
    self.class.definition?
  end
  
  def element?
    self.class.element?
  end
  
  def container?
    self.class.container?
  end
  
  def group?
    self.class.group?
  end
  
  def is_element?(arg)
    arg.respond_to?(:element?) && arg.element?
  end
  
  def is_container?(arg)
    arg.respond_to?(:container?) && arg.container?
  end
  
  def blank?
    element_value.blank?
  end
  
  def option_flags
    @option_flags ||= HashWithIndifferentAccess.new
  end
  
  def option_flag_names
    self.class.element_option_flag_names
  end
  
  def option_flag_attributes
    Hash.new
  end
  
  def html_flags
    @html_flags ||= HashWithIndifferentAccess.new
  end
  
  def html_flag_names
    self.class.element_html_flag_names
  end
  
  def html_flag_attributes
    html_flag_names.inject({}) { |attrs, flag| attrs[flag.to_s] = flag.to_s if send("#{flag}?"); attrs } 
  end
  
  def render_input(builder = create_builder, wrapped = false)
    render_call(builder, wrapped).call
  end
  alias :to_input :render_input
  
  def to_html(builder = create_builder, &block)
    render_wrapper, wrapped = wrapper(&block)   
    render_wrapper.call(builder, self, render_call(builder, wrapped))
  end
  alias :to_s :to_html
  alias :to_element :to_html
  
  def render(builder = create_builder, &block)
    html = "<!--o" + "[ #{identifier} ]".center(64, '-') + "o-->\n"
    html << validation_advice.to_s
    html << to_html(builder, &block)
    html << script_tag
    html << "<!--x" + "[ #{identifier} ]".center(64, '-') + "x-->\n"
    html
  end
  
  def display(builder = create_builder, &block)
    puts render(builder, &block)
  end
  
  def render_call(builder = create_builder, wrapped = false)
    if wrapped
      lambda do
        skipclass = skip_css_class?
        skipstyle = skip_css_style?
        self.skip_css_class = true
        self.skip_css_style = true
        frozen? ? render_frozen(builder) : render_element(builder)
        self.skip_css_class = skipclass
        self.skip_css_style = skipstyle
      end
    else
      lambda do 
        frozen? ? render_frozen(builder) : render_element(builder) 
      end
    end
  end
  
  def wrapper(&block)
    if container? && !contained?
      wrapper_name, default_name = :container_wrapper,  :default_container_wrapper    
    else
      wrapper_name, default_name = :element_wrapper,    :default_element_wrapper  
    end
    wrapped, wrapper = [true,   block                                   ] if block_given?
    wrapped, wrapper = [true,   self.method_to_proc(wrapper_name)       ] if wrapper.nil? && self.respond_to?(wrapper_name)   
    wrapped, wrapper = [true,   self.class.method_to_proc(wrapper_name) ] if wrapper.nil? && self.class.respond_to?(wrapper_name) 
    wrapped, wrapper = [false,  self.class.method_to_proc(default_name) ] if wrapper.nil?
    [wrapper, wrapped]
  end

  def define_container_wrapper(prc = nil, &block)
    define_singleton_method(:container_wrapper, &(block_given? ? block : prc)) if container?
  end
  alias :container_wrapper= :define_container_wrapper

  def reset_container_wrapper
    undefine_singleton_method(:container_wrapper) rescue nil
  end

  def define_element_wrapper(prc = nil, &block)
    define_singleton_method(:element_wrapper, &(block_given? ? block : prc))
  end
  alias :element_wrapper= :define_element_wrapper
  
  def reset_element_wrapper
    undefine_singleton_method(:element_wrapper) rescue nil
  end
  
  def value_to_identifier(value)
    str = value.to_s.downcase.strip
    str.gsub!(/\s+/, '_')
    str.gsub!(/[\x00-\x1f]|[\xc0-\xfd][\x80-\xbf]+/) { "#{$&.unpack('U')[0]}" rescue '_' }
    str.gsub!(/[^a-z0-9_]/, ' ')
    str.gsub!(/^([\s_]+)/, '')
    str.gsub!(/([\s_]+)$/, '')
    str.gsub!(/\s+/, '_')
    str.gsub!(/_{2,}/, '_')
    str.strip
  end
  
  module ClassMethods
    
    def definition?
      self.kind_of?(ActiveForm::Definition)
    end
    
    def element?
      self.included_modules.include?(ActiveForm::Mixins::ElementMethods)
    end
  
    def container?
      self.included_modules.include?(ActiveForm::Mixins::ContainerMethods)
    end
    
    def group?
      false
    end
    
    def define_html_flags(*flags)
      skip_methods = (flags.last == false ? !flags.pop : false)
      flags.flatten.each do |flag|        
        self.element_html_flag_names += [flag.to_sym] 
        unless skip_methods
          define_method("#{flag}=")  { |value| self.html_flags[flag.to_sym] = value.to_s.to_boolean } unless instance_methods.include?("#{flag}=")
          define_method("#{flag}?")  { self.html_flags[flag.to_sym] == true } unless instance_methods.include?("#{flag}?")
          define_method("#{flag}")   { self.html_flags[flag.to_sym] } unless instance_methods.include?("#{flag}")
        end
      end
    end
    
    def define_option_flags(*flags)
      skip_methods = (flags.last == false ? !flags.pop : false)
      flags.flatten.each do |flag|        
        self.element_option_flag_names += [flag.to_sym] 
        unless skip_methods
          define_method("#{flag}=")  { |value| self.option_flags[flag.to_sym] = value.to_s.to_boolean } unless instance_methods.include?("#{flag}=")
          define_method("#{flag}?")  { self.option_flags[flag.to_sym] == true } unless instance_methods.include?("#{flag}?")
          define_method("#{flag}")   { self.option_flags[flag.to_sym] } unless instance_methods.include?("#{flag}")
        end
      end
    end
    
    def default_container_wrapper(builder, elem, render)
      render.call
    end
  
    def define_container_wrapper(prc = nil, &block)
      define_singleton_method(:container_wrapper, &(block_given? ? block : prc)) if container?
    end
    alias :container_wrapper= :define_container_wrapper
  
    def reset_container_wrapper
      undefine_singleton_method(:container_wrapper) rescue nil
    end
  
    def default_element_wrapper(builder, elem, render)
      render.call
    end
      
    def define_element_wrapper(prc = nil, &block)
      define_singleton_method(:element_wrapper, &(block_given? ? block : prc))
    end
    alias :element_wrapper= :define_element_wrapper
    
    def reset_element_wrapper
      undefine_singleton_method(:element_wrapper) rescue nil
    end
    
  end
  
  module StubInstanceMethods
    
    def label
      raise ActiveForm::StubException
    end
  
    def title
      raise ActiveForm::StubException
    end
  
    def description
      raise ActiveForm::StubException
    end
    
    def initialize_element(*args)
      raise ActiveForm::StubException
    end
    
    def initialize_properties      
    end
    
    def identifier
      raise ActiveForm::StubException
    end
    
    def element_name
      raise ActiveForm::StubException
    end
    
    def export_value
      raise ActiveForm::StubException
    end

    def element_value
      raise ActiveForm::StubException
    end
    
    def element_value=(value)
      raise ActiveForm::StubException
    end
    
    def label_attributes
      raise ActiveForm::StubException
    end
    
    def render_label(builder = create_builder)
      raise ActiveForm::StubException
    end
    
    def render_frozen(builder = create_builder)
      raise ActiveForm::StubException
    end
    
    def render_element(builder = create_builder)
      raise ActiveForm::StubException
    end
    
    def frozen?
      raise ActiveForm::StubException
    end
    
    def hidden?
      raise ActiveForm::StubException
    end
    
    def disabled?
      raise ActiveForm::StubException
    end
    
    def required?
      raise ActiveForm::StubException
    end
        
    def contained?
      raise ActiveForm::StubException
    end
    
    def localized?
      raise ActiveForm::StubException
    end
    
    def localize(*args)
      raise ActiveForm::StubException
    end
    
    def create_builder
      Builder::XhtmlMarkup.new(:indent => 2)
    end
    
  end
  
  module StubClassMethods
     
    def create(*args, &block)
      raise ActiveForm::StubException
    end
     
    def setup(prc = nil, &block)
      define_singleton_method(:setup_method, &(block_given? ? block : prc))
    end
    alias :setup_proc= :setup
    
    def reset_setup
      undefine_singleton_method(:setup_method) rescue nil
    end 
     
  end
  
end