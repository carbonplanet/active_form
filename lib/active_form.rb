require 'rubygems'
require 'active_support'
require 'iconv'
require 'builder'
require 'yaml'
require 'parsedate'

module ActiveForm
  
  BASE_PATH = ::File.expand_path(File.join(File.dirname(__FILE__), 'active_form'))
  
  def self.compose(*args, &block)
    ActiveForm::Definition.new(*args, &block)
  end
  
  def self.create(definition_name, &block)
    ActiveForm::Definition::create(definition_name, &block)
  end
  
  def self.get(definition_name, &block)
    ActiveForm::Definition::get(definition_name, &block)
  end
  
  def self.build(definition_name, *args, &block)
    ActiveForm::Definition::build(definition_name, *args, &block)
  end
  
  def self.use_european_formatting
    ActiveForm::Element::SelectDate.default_format = [:day, :month, :year]
    ActiveForm::Element::SelectDatetime.default_format = [:day, :month, :year, :hour, :minute]
  end
  
  def self.use_american_formatting
    ActiveForm::Element::SelectDate.default_format = [:month, :day, :year]
    ActiveForm::Element::SelectDatetime.default_format = [:month, :day, :year, :hour, :minute]
  end
  
  module Element       
  end
  
  module Mixins
  end  
  
  class StubException < StandardError #:nodoc:
  end
  
  class ValidationException < StandardError #:nodoc:
  end
  
  class Values < ::HashWithIndifferentAccess    
  end
  
  def self.symbolize_name(name)
    return name if name.kind_of?(Symbol)
    name.to_s.downcase.strip.gsub(/[^-_\s[:alnum:]]/, '').squeeze(' ').tr(' ', '_').to_sym
  end
  
end

require File.join(File.dirname(__FILE__), 'active_form', 'core_extensions')

require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'common_methods')
require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'element_methods')
require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'collection_element_methods.rb')
require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'option_element_methods.rb')
require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'attribute_methods')
require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'container_methods')
require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'loader_methods')
require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'casting')

require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'javascript_methods')
require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'css_methods')

require File.join(File.dirname(__FILE__), 'active_form', 'errors')
require File.join(File.dirname(__FILE__), 'active_form', 'validator')
require File.join(File.dirname(__FILE__), 'active_form', 'validators', 'base')
require File.join(File.dirname(__FILE__), 'active_form', 'mixins', 'validation_methods')

require File.join(File.dirname(__FILE__), 'active_form', 'definition')

require File.join(File.dirname(__FILE__), 'active_form', 'element')
require File.join(File.dirname(__FILE__), 'active_form', 'elements', 'base')
require File.join(File.dirname(__FILE__), 'active_form', 'elements', 'section')

require File.join(File.dirname(__FILE__), 'active_form', 'widget')
require File.join(File.dirname(__FILE__), 'active_form', 'widgets', 'base')

if defined?(Merb::Plugins)
  
  Merb::Plugins.config[:active_form] = { } if Merb::Plugins.config[:active_form].nil?
  
  require File.join(File.dirname(__FILE__), 'merb', 'support')
  Merb::Plugins.add_rakefiles(File.join(File.dirname(__FILE__), 'merb',  'merbtasks'))
  
  Merb.push_path(:form,             Merb.root_path("app/forms"), nil)
  Merb.push_path(:form_view,        Merb.root_path("app/forms/views"), nil)
  
  Merb.push_path(:form_definition,  Merb.root_path("app/forms/definitions"))
  Merb.push_path(:form_section,     Merb.root_path("app/forms/sections"))
  Merb.push_path(:form_widget,      Merb.root_path("app/forms/widgets"))
  Merb.push_path(:form_element,     Merb.root_path("app/forms/elements"))
  Merb.push_path(:form_validator,   Merb.root_path("app/forms/validators"))
  
  class Merb::ActiveFormSetup < Merb::BootLoader

    after Merb::BootLoader::BeforeAppLoads

    def self.run
      ActiveForm::Definition.load_paths << Merb.dir_for(:form_definition)
      ActiveForm::Definition.load_paths << Merb.dir_for(:form_section)
      ActiveForm::Widget.load_paths     << Merb.dir_for(:form_widget)
      ActiveForm::Element.load_paths    << Merb.dir_for(:form_element)
      ActiveForm::Validator.load_paths  << Merb.dir_for(:form_validator)
    end

  end
  
end