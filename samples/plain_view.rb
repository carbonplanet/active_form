#!/usr/bin/env ruby
#
#  Created by Fabien Franzen on 2006-09-19.
#  Copyright (c) 2006. All rights reserved.

require 'erb'

require File.join(File.dirname(__FILE__), '../lib/active_form')
require File.join(ActiveForm::BASE_PATH, '/views/plain.rb')

ActiveForm::Definition.create :sample do |f|
  
  f.client_side = true  
  
  f.section :person, :label => 'Your details' do |s|
    s.text_element :first_name,   :required => true
    s.text_element :last_name,    :required => true
    s.password_element :password, :required => true
    s.password_element :password_confirm, :required => true
    s.select_element :country do |e|
      e.empty = 'choose a country:'
      e.options = [['Nederland', 'nl'], ['België', 'be']]
    end
    s.submit_element :label => 'Send'  
    s.after_validation do |elem|
      elem.remove_element :password_confirm if elem.valid?
    end
  end
  
  f.section :message, :label => 'Your message' do |s|
    s.text_element :subject, :required => true
    s.textarea_element :message, :required => true, :rows => 5, :cols => 10
    s.submit_element :label => 'Send'  
  end    
  
  f.after_validation do |elem|
    if elem.valid?
      remove_elements_of_type :submit, :button
      elem.disabled = true
    end
  end
  
end

form = ActiveForm::Definition.build :sample, :my_form, :label => 'Plain View Sample'

# form.values[:person][:first_name] = 'Fabien'
# form.values[:person][:last_name] = 'Franzen'
# form.values[:person][:password] = form.values[:person][:password_confirm] = 'secret'
# form.values[:person][:country] = 'be'
# form.values[:message][:subject] = 'testing...'
# form.values[:message][:message] = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
# 
# form.validate

title = 'Plain View Sample'
html = ERB.new(File.read(File.join(File.dirname(__FILE__), 'layouts', 'plain.rhtml')), nil, '-').result
File.open(File.join(File.dirname(__FILE__), 'html', "#{File.basename(__FILE__, '.rb')}.html"), 'w') { |file| file << html }