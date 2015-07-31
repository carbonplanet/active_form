module ActiveForm::Mixins::JavascriptMethods
  
  EVENTS = [:onsubmit, :onreset, :onclick, :ondblclick, :onmousedown, :onmouseup, :onmouseover, 
            :onmousemove, :onmouseout, :onkeypress, :onkeydown, :onkeyup, :onblur, :onfocus, :onchange]

  EVENTS.each do |event|    
    define_method("#{event}") { self.javascript_events[event] }
    define_method("#{event}?") { !self.javascript_events[event].blank? }
    define_method("#{event}=") { |js| self.javascript_events[event] = js }   
    module_eval %{ def inline_#{event}; #{event}? ? "#{event}=\#{self.javascript_events[:#{event}].to_json}" : nil; end }    
    module_eval %{ def #{event}_event; self.javascript_events[:#{event}] = (yield(self.identifier)).to_s if block_given?; end }
  end
  
  def default_javascript
  end
  
  def internal_javascript(tag = false)
    @internal_js ||= JavascriptAttribute.new
    return @internal_js unless tag
    @internal_js.empty? ? nil : javascript_tag(@internal_js.to_s) 
  end
  
  def internal_javascript=(string_or_array)
    internal_javascript.replace(string_or_array)
  end
  
  def javascript_events
    @javascript_events ||= HashWithIndifferentAccess.new
  end
  
  def javascript(tag = false)
    @javascript_attribute ||= JavascriptAttribute.new.push(default_javascript).compact
    return @javascript_attribute unless tag
    @javascript_attribute.empty? ? nil : javascript_tag(@javascript_attribute.to_s) 
  end
  
  def javascript=(string_or_array)
    javascript.replace(string_or_array)
  end
  
  def javascript?
    !(javascript.blank? && javascript_events.empty? && internal_javascript.empty? && javascript_validation_code.blank?) || container?
  end
  
  def javascript_var
    "f#{self.element_type}_#{self.identifier}"
  end
  
  def script_tag
    element_javascript(true)
  end
  
  def element_javascript(tag = false)
    return '' unless javascript?
    elem_var = javascript_var
    js = (internal_javascript.empty? ? '' : "  #{internal_javascript};\n")    
    unless (jsvalidation = javascript_validation_code).blank?
      js << "  #{jsvalidation}\n"      
    end
    unless (jsvalidationdef = validation_javascript_definitions).blank?
      js << "#{jsvalidationdef.gsub(/^/, '  ')}\n"      
    end
    js << (javascript.blank? ? '' : "  #{javascript};\n")
    js << javascript_events.stringify_keys.keys.sort.inject('') do |ary, key| 
      ary << "  Event.observe(#{elem_var},'#{key.from(2)}',function(ev){ #{javascript_events[key]}; });\n"
    end unless javascript_events.empty?
    js << elements.inject('') do |ejs, elem| 
      if elem.javascript? && !(s = elem.element_javascript).match(/^(\s+)?$/)
        ejs << "#{s.gsub(/^/, '  ')}\n"
      end
      ejs
    end if container? 
    js << "  new Validation(#{elem_var}, #{options_for_javascript(client_side_options)});\n" if client_side? && container? && !contained? 
    return '' if js.match(/^(\s+)?$/)
    str = "var #{elem_var}=$('#{self.identifier}');if(#{elem_var}){\n#{js}}"    
    tag ? javascript_tag(str) : str
  end
  alias :js :element_javascript
  alias :script :element_javascript
  
  def inline_javascript
    self.javascript_events.inject([]) { |ary, (event, code)| ary << send("inline_#{event}") unless code.blank?; ary }.compact.sort.join(' ')
  end
  
  protected
  
  def javascript_tag(js)
    "<script type=\"text/javascript\" charset=\"utf-8\">//<![CDATA[\n#{js}\n//]]>\n</script>\n"
  end
  
  def escape_javascript(javascript)
    (javascript || '').gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
  end
  
  def options_for_javascript(options)
    '{' + options.map {|k, v| "#{k}:#{v}"}.sort.join(', ') + '}'
  end
  
end