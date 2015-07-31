module ActiveForm::Mixins::CssMethods #:nodoc:
 
  def default_css_class
    "active_#{element_type}"
  end
  
  def runtime_css_class
    cclass = CssAttribute.new
    cclass << 'frozen'              if frozen?
    cclass << 'hidden'              if hidden?
    cclass << 'disabled'            if disabled?
    cclass << 'readonly'            if readonly?
    cclass << 'required'            if required?
    cclass << 'validation-failed'   unless valid?  
    cclass << validation_css_class  if !container? && client_side? 
    cclass
  end
  
  def label_css_class
    cclass = CssAttribute.new
    cclass << 'inactive'            if readonly? || disabled? || frozen?
    cclass << 'hidden'              if hidden?
    cclass << 'required'            if required?
    cclass << 'validation-failed'   unless valid?
    cclass << 'label'               if container?
    cclass
  end
  
  def label_css
    label_css_class.to_s
  end
  
  def element_class
    (css_class.dup << runtime_css_class << default_css_class).to_s
  end
  alias :css :element_class
  
  def css_class
    @css_class_attribute ||= CssAttribute.new.push(default_css_class)
  end
  
  def css_class=(string_or_array)
    css_class.replace(string_or_array)
  end
  alias :class= :css_class=
  
  def default_css_style
    ""
  end
  
  def runtime_css_style
    cstyle = StyleAttribute.new
    cstyle << 'display: none' if hidden?
  end
  
  def element_style
    (css_style.dup << runtime_css_style).to_s
  end
  alias :style :element_style
  
  def css_style
    @css_style_attribute ||= StyleAttribute.new.push(default_css_style)
  end
    
  def css_style=(string_or_array)
    css_style.replace(string_or_array)
  end
  alias :style= :css_style=
    
end