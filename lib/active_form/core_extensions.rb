require 'builder/xchar'

module Builder
  class XhtmlMarkup < XmlMarkup
   
   def _insert_attributes(attrs, order=[])
     attributes = attrs.respond_to?(:delete_blanks) ? attrs.delete_blanks : attrs
     attributes.stringify_keys!   if attributes.respond_to?(:stringify_keys)
     order = attributes.keys.sort if attributes.respond_to?(:stringify_keys) && order.empty?
     super(attributes, order)
   end
       
  end
end

class Class

  def inheritable_set(*syms)
    class_inheritable_accessor(*syms)
    syms.each { |sym| self.send("#{sym}=", Set.new) }  
  end
 
end

class Object
  
  def define_singleton_method(name, &block)
    (class<<self;self;end).send(:define_method, name, &block)
  end
  
  def undefine_singleton_method(name)
    (class<<self;self;end).send(:remove_method, name)
  end
  
  alias :method_to_proc :method
  
end

class String
  
  def to_boolean
    ['1', 'y', 'yes', 'j', 'on', 'true', 't'].include?(self.downcase)
  end
  
end

unless Object.const_defined?('Loob') && Loob.const_defined?('Supplements')
  class Numeric #:nodoc:   
  
    TO_DECIMAL_SEPERATOR = :comma
  
    def nearest(factor = 10)
      (self.to_f/factor.to_f).round * factor
    end
  
    def zero_padded(padding = 3)
      return "%0#{padding}d" % self.abs
    end
  
    def to_s_decimal(decimal_seperator = TO_DECIMAL_SEPERATOR)
      str = self.to_s
      str.gsub!(/\.(\d+)(\s|$)/, ',\1') if (decimal_seperator == :comma && str =~ /\.(\d+)(\s|$)/)
      str
    end
  
  end
end

class Hash
 
  # define these methods for any value holder you want to bind
 
  def as_attributes_string
    attributes = self.delete_blanks.stringify_keys
    parts = attributes.keys.sort.inject([]) do |attrs, k|
      v = attributes[k].to_s.to_xs.gsub(%r{"}, '&quot;')
      attrs << "#{k}=\"#{v}\""
      attrs
    end
    parts.join(' ')
  end
 
  def bound_value(*args)
    self[args[0]] = args[1] if args.length == 2
    self[args[0]]
  end 
  
  def bound_value?(key)
    self.key?(key)
  end
  
  # utility methods
 
  def delete_blanks
    self.inject({}) do |hash,(key, value)|
      if value == :blank
        hash[key] = ''
      else
        hash[key] = value unless (value.blank? || value == false)
      end
      hash
    end
  end
  
  def delete_blanks!
    replace delete_blanks
  end
  
end

class Appendable < Array
  
  class_inheritable_accessor :delimiter
  self.delimiter = ''
  
  def write
    yield self if block_given?
  end
  alias :define :write
  
  def replace(*args)
    super(value_to_array(args))
  end
  
  def <<(string_or_array)
    replacement = Array.new(self)
    value_to_array(string_or_array).each do |value|   
      replacement << value unless replacement.include?(value)
    end
    self.replace(replacement)
    self
  end
  
  def +(string_or_array)
    self << value_to_array(string_or_array)
  end
  
  def -(string_or_array)
    remove = value_to_array(string_or_array)
    self.reject! { |v| remove.include?(v) }
  end
  
  def join(delimiter = self.class.delimiter)
    super(delimiter)
  end
  alias :to_s :join
  
  private
  
  def value_to_array(string_or_array)
    case string_or_array      
      when Array  then string_or_array.flatten.collect { |v| split_string_with_delimiter(v) }.flatten
      else split_string_with_delimiter(string_or_array) 
    end
  end
  
  def split_string_with_delimiter(string)
    string.to_s.split(self.class.delimiter).collect(&:strip).reject(&:blank?)
  end
  
end

class JavascriptAttribute < Appendable
  
  self.delimiter = ';'
  
end

class StyleAttribute < Appendable
  
  self.delimiter = ';'
  
end

class CssAttribute < Appendable
  
  self.delimiter = ' '
  
end