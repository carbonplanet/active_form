basedir = File.expand_path(File.dirname(__FILE__))

require 'rubygems'
gem 'activerecord'
require 'activerecord'
require 'test/unit'
require 'active_record/fixtures'

require basedir + '/../lib/active_form'
require basedir + '/../lib/rails/support'

ActiveRecord::Base.configurations['test'] = { :adapter  => 'sqlite3', :database => ':memory:' }
ActiveRecord::Base.establish_connection 'test'
ActiveRecord::Base.default_timezone = :utc
load basedir + "/fixtures/schema.rb"

Test::Unit::TestCase::fixture_path = basedir + "/fixtures/"
Test::Unit::TestCase::use_transactional_fixtures = true
Test::Unit::TestCase::use_instantiated_fixtures = false
$:.unshift Test::Unit::TestCase::fixture_path

class ActiveForm::Element::Sample < ActiveForm::Element::Base
  
  define_attributes :foo, :bar
  define_html_flags :flipped
  define_option_flags :closed
  
end

class ActiveForm::Element::ExtendedSample < ActiveForm::Element::Sample
  
  define_attributes :baz
  define_html_flags :flopped
  
end

class ActiveForm::Element::ExtendedSample < ActiveForm::Element::Sample
  
  define_html_flags :rotated
  
end

class CustomValueObject
  
  attr_accessor :value
  
  def initialize
    @value = HashWithIndifferentAccess.new
  end
  
  def bound_value(*args)
    @value[args[0]] = args[1] if args.length == 2
    @value[args[0]]
  end 
  
  def bound_value?(key)
    @value.key?(key)
  end
  
end

class ActiveForm::Validator::Sample < ActiveForm::Validator::Base
  
  default_message "%s: value needs to be identical to 'sample'"
  
  javascript_validation("value needs to be identical to 'sample'") do |code|
    code << %`return Validation.get('IsEmpty').test(v) || /^sample$/i.test(v);`
  end
  
  def validate
    element.errors << advice[code] unless value =~ /^sample$/i
  end
  
end