require 'resolv'

ActiveForm::Validator::Base.create :email do
  
  REGEX = /^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$/
  
  default_message "%s: is not a valid email address"
  
  attr_accessor :resolve
  
  def validate
    email = value.to_s
    element.errors << advice[code] unless email.blank? || (email =~ REGEX && (self.resolve ? resolve_address(email) : true))
  end

  private
  
  def resolve_address(email)
    hostname = email[(email =~ /@/)+1..email.length]
    valid = true
    begin
      Resolv::DNS.new.getresource(hostname, Resolv::DNS::Resource::IN::MX)
    rescue Resolv::ResolvError
      valid = false
    end
    return valid
  end

end