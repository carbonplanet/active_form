# Copyright (c) 2006 DeLynn Berry
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    # Specify this act if you want to your model be used easily with the <tt>select</tt> form helper. By default the
    # plugin assumes you want to use the <tt>id</tt> attribute for the option's value and the <tt>name</tt> attribute for
    # the option's text.
    #
    # Example:
    #
    #   class State < ActiveRecord::Base
    #     acts_as_dropdown
    #   end
    #
    #   State.to_dropdown   # => [["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]]
    #
    # The <tt>value</tt>, <tt>text</tt>, <tt>conditions</tt>, and <tt>order</tt> can also be altered from the default configuration
    # by using the options hash.
    #
    # Example:
    #
    #   class State < ActiveRecord::Base
    #     acts_as_dropdown :text => "abbreviation", :conditions => "id < 4"
    #   end
    #
    #   State.to_dropdown   # => [["AL", 1], ["AK", 2], ["AZ", 3], ["CA", 4]]
    #
    # The class method <tt>to_dropdown</tt> can also alter the default class configuration using the same options hash.
    #
    # Example:
    #
    #   class State < ActiveRecord::Base
    #     acts_as_dropdown :text => "abbreviation", :conditions => "id < 4"
    #   end
    #
    #   State.to_dropdown :text => "name", :conditions => nil   # => [["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]]
    #
    # See ActiveRecord::Acts::Dropdown::ClassMethods#acts_as_dropdown for configuration options
    module Dropdown
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        # == Configuration options
        #
        # * <tt>text</tt> - This is the class attribute that will be used as the text/label for the option tag (defaults to name).
        # * <tt>value</tt> - This is the class attribute that will be used to fill in the option's value parameter (defaults to id).
        # * <tt>conditions</tt> - This is the conditions string that will be used when executing the <tt>find</tt> method on the object (defaults to nil).
        # * <tt>order</tt> - This is the order string that will be used when executing the <tt>find</tt> method on the object (defaults to the <tt>value</tt> attribute).
        def acts_as_dropdown(options = {})
          cattr_accessor :dropdown_text_attr, :dropdown_value_attr, :conditions_string, :order_string

          self.dropdown_text_attr   = options[:text] || "name"
          self.dropdown_value_attr  = options[:value] || "id"
          self.conditions_string    = options[:conditions] || nil
          self.order_string         = options[:order] || self.dropdown_value_attr.to_s
        end
        
        # === Example:
        #
        #   class State < ActiveRecord::Base
        #     acts_as_dropdown
        #   end
        #
        #   >> State.to_dropdown
        #   => [["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]]
        #
        # The <tt>value</tt>, <tt>text</tt>, <tt>conditions</tt>, and <tt>order</tt> can also be altered from the default configuration
        # by using the options hash.
        #
        # === Example:
        #
        #   class State < ActiveRecord::Base
        #     acts_as_dropdown :text => "abbreviation", :conditions => "id < 4"
        #   end
        #
        #   >> State.to_dropdown 
        #   => [["AL", 1], ["AK", 2], ["AZ", 3], ["CA", 4]]
        #
        # The class method <tt>to_dropdown</tt> can also alter the default class configuration using the same options hash.
        #
        # === Example:
        #
        #   class State < ActiveRecord::Base
        #     acts_as_dropdown :text => "abbreviation", :conditions => "id < 4"
        #   end
        #
        #   >> State.to_dropdown :text => "name", :conditions => nil
        #   => [["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]]
        def to_dropdown(options = {})
          acts_as_dropdown(options) unless options.empty?
          find(:all, :conditions => self.conditions_string, :order => self.order_string).to_dropdown(self.dropdown_text_attr.to_sym, self.dropdown_value_attr.to_sym)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Dropdown)