module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Array #:nodoc:
      module Dropdown
        # Collects the contents of the array and creates a new array that can be easily used
        # with the <tt>select</tt> form helper method.
        #
        # == Options
        # * <tt>text</tt> - This is the attribute that will be used as the text/label for the option tag (defaults to name).
        # * <tt>value</tt> - This is the attribute that will be used to fill in the option's value parameter (defaults to id).
        #
        # === Example
        #
        #   >> @states = State.find(:all, :order => "id")
        #   >> @states.to_dropdown 
        #   => [["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]]
        def to_dropdown(text = "name", value = "id")
          self.collect { |x| [x.send(text.to_sym), x.send(value.to_sym)] }
        end
      end
    end
  end
end

class Array #:nodoc:
  include ActiveSupport::CoreExtensions::Array::Dropdown
end