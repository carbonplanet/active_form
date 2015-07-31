require 'loob/uri_validator'

ActiveForm::Validator::Base.create :uri do
  
  attr_accessor :messages
  # possible error statuses: 
  # :invalid_scheme
  # :invalid_host
  # :invalid_content_type
  # :invalid_format
  # :moved_permanently
  # :not_accessible
  
  # format position 3 contains the validation error status (server side only)
  default_message "%s: is not a valid location"
  
  attr_reader :uri_validator
  
  delegate :response_codes, :content_types, :schemes, :hosts, :port, :to => :uri_validator
  delegate :response_codes=, :content_types=, :schemes=, :hosts=, :port=, :to => :uri_validator
  
  def initialize(*args, &block) 
    @uri_validator = Loob::UriValidator.new
    setup # trigger setup after creation
    props = args.last.is_a?(Hash) ? args.pop : {}
    register_element(args.shift) if is_element?(args.first)
    self.code = self.class.to_s.demodulize.underscore
    props.each { |prop, value| send("#{prop}=", value) if respond_to?("#{prop}=") } 
    self.messages = {}
    self.messages.default = self.message     
    yield self if block_given?
  end
 
  def validate
    unless value.blank? || uri_validator.valid_uri?(value)
      element.errors << advice[uri_validator.error.to_s]
    end
  end

  def advice
    list = {}
    list.default = ActiveForm::Error.new(element, messages[:default], code, message_params)
    list[code] = list.default
    [:invalid_scheme, :invalid_host, :invalid_content_type, :invalid_format, :moved_permanently, :not_accessible].each do |mkey|
      list[mkey.to_s] = ActiveForm::Error.new(element, messages[mkey], mkey.to_s, message_params) if messages.key?(mkey)
    end
    list
  end

  def message_params
    [uri_validator.error.to_s.titleize || 'OK']
  end

end