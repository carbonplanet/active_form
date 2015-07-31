#!/usr/bin/env ruby
#
#  Created by Fabien Franzen on 2006-09-19.
#  Copyright (c) 2006. All rights reserved.

require 'erb'

require File.join(File.dirname(__FILE__), '../lib/active_form')

class String
  
  def word_truncate(length = 32, etc = '...')
    return '' if length == 0
    return self if self.length <= length
    fragment = self.slice(0, length)
    fragment.gsub!(/\s+(\S+)?$/, '')
    fragment.gsub!(/[,\.-_?!]$/, '')
    fragment.strip!
    return fragment << etc   
  end
  
end

ActiveForm::Definition.define_container_wrapper do |builder, elem, render|      
  builder.form(elem.element_attributes) {
    builder.table {
      builder.thead { builder.tr { builder.th(elem.label, :colspan => 2) } }
      builder.tbody { elem.render_elements(builder) }
    }
    builder << elem.script_tag
  }   
end

ActiveForm::Definition.define_element_wrapper do |builder, elem, render|
  style = StyleAttribute.new
  style << 'display: none' if elem.hidden?
  builder.tr { builder.td { builder.table(:style => style, &render) } }
end  

ActiveForm::Element::Base.define_element_wrapper do |builder, elem, render|
  builder.tr(:class => 'label') { builder.td(:colspan => 2) { elem.render_label(builder) } }
  builder.tr(:id => "elem_#{elem.identifier}", :class => elem.css, :style => elem.style) { builder.td(:class => 'elem', :colspan => 2, &render) }
end

ActiveForm::Element::Section.define_element_wrapper do |builder, elem, render|
  builder.tr(:class => 'header') { builder.td(:colspan => 2) { builder.h3(:onclick => "$('section-#{elem.identifier}').toggle()") { elem.render_label(builder) } } }
  builder.tr(:class => 'advice') { builder.td(:colspan => 2) { builder << elem.validation_advice } }
  builder.tr { builder.td { builder.div(:id => "section-#{elem.identifier}") { builder.table(:style => 'background: lightblue;', &render) } } }
end

side_by_side_wrap = proc do |builder, elem, render|
  builder.tr(:id => "elem-#{elem.identifier}") { 
    builder.td(:class => 'label') { elem.render_label(builder) }
    builder.td(:class => elem.css, :style => elem.style) { render.call }
  }
end

no_label_wrap = proc do |builder, elem, render|
  builder.tr(:id => "elem-#{elem.identifier}") { 
    builder.td(:class => elem.css, :style => elem.style, :colspan => 2) { render.call }
  }
end

form = ActiveForm::compose :myform, :client_side => true do |f|
  f.section :person, :label => 'Your details' do |s|
    s.text_element :first_name,   :required => true
    s.text_element :last_name,    :required => true
    s.password_element :password, :required => true
    s.password_element :password_confirm, :required => true
    s.select_element :country do |e|
      e.empty = 'choose a country:'
      e.options = [['Nederland', 'nl'], ['België', 'be']]   
      e.element_wrapper = side_by_side_wrap
    end
    s.submit_element, :label => 'Send', :element_wrapper => no_label_wrap    
    s.after_validation do |elem|
      elem.remove_element :password_confirm if elem.valid?
    end
  end
  f.section :message, :label => 'Your message' do |s|
    s.text_element :subject, :required => true, :element_wrapper => side_by_side_wrap
    s.textarea_element :message, :required => true, :rows => 5, :cols => 10 do |e|
      e.after_validation do |elem|
        elem.frozen_value = elem.formatted_value.word_truncate(32) if elem.valid?
      end
    end
    s.submit_element, :label => 'Send', :element_wrapper => no_label_wrap   
  end    
  f.after_validation do |elem|
    if elem.valid?
      remove_elements_of_type :submit, :button
      elem.freeze!
      # elem.disabled = true # try this instead of freeze! sometime
    else
      elem.css_style << 'border: 1px solid red'
    end
  end
end

# form.values[:person][:first_name] = 'Fabien'
# form.values[:person][:last_name] = 'Franzen'
# form.values[:person][:password] = form.values[:person][:password_confirm] = 'secret'
# form.values[:person][:country] = 'be'
# form.values[:message][:subject] = 'testing...'
# form.values[:message][:message] = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
# 
# form.validate

title = 'Sample 001'
html = ERB.new(File.read(File.join(File.dirname(__FILE__), 'layouts', 'default.rhtml')), nil, '-').result
File.open(File.join(File.dirname(__FILE__), 'html', "#{File.basename(__FILE__, '.rb')}.html"), 'w') { |file| file << html }