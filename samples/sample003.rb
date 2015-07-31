#!/usr/bin/env ruby
#
#  Created by Fabien Franzen on 2006-09-19.
#  Copyright (c) 2006. All rights reserved.

require 'erb'

require File.join(File.dirname(__FILE__), '../lib/active_form')

ActiveForm::Definition.create :sample_003 do |f|
 
  f.text_element :first_name,   :required => true
  f.text_element :last_name,    :required => true
  f.submit_element :label => 'Send'
  
  f.after_validation do |elem|
    elem.freeze! if elem.valid?
  end
  
end

form = ActiveForm::Definition.build :sample_003, :my_form, :label => 'Example form 002'

# form.values[:first_name] = 'Fabien'
# form.values[:last_name] = 'Franzen'
# form.validate

title = 'Sample 003'
html = ERB.new(File.read(File.join(File.dirname(__FILE__), 'layouts', 'sample003.rhtml')), nil, '-').result
File.open(File.join(File.dirname(__FILE__), 'html', "#{File.basename(__FILE__, '.rb')}.html"), 'w') { |file| file << html }