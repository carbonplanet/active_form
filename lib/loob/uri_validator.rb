require 'net/http'
require 'uri'

module Loob
  class UriValidator
  
    # possible error statuses: 
    # :invalid_scheme
    # :invalid_host
    # :invalid_content_type
    # :invalid_format
    # :moved_permanently
    # :not_accessible
  
    DEFAULT_HTTP_OK_CODES = [
			Net::HTTPMovedPermanently,
			Net::HTTPOK,
			Net::HTTPCreated,
			Net::HTTPAccepted,
			Net::HTTPNonAuthoritativeInformation,
			Net::HTTPPartialContent,
			Net::HTTPFound,
			Net::HTTPTemporaryRedirect,
			Net::HTTPSeeOther
		].freeze
  
    attr_accessor :response_codes, :content_types, :schemes, :hosts, :port
    attr_reader :error
    
    class << self
    
      def valid_uri?(str, options = {})
        self.new(options).valid_uri?(str)
      end
      alias :valid_url? :valid_uri?
      
      def valid_domain?(str, options = {})
        self.new(options).valid_domain?(str)
      end
      
    end
    
    def initialize(options = {})
      self.schemes = options[:schemes] || []
      self.hosts = options[:hosts] || []
      self.content_types = options[:content_types] || []
      self.response_codes = options[:response_codes] || DEFAULT_HTTP_OK_CODES
      self.port = options[:port] || 80
    end
    
    [:response_codes, :content_types, :schemes, :hosts].each do |setter|
      self.module_eval("def #{setter}=(args); @#{setter} = [*args]; end") 
    end
    
    def valid_uri?(str)
      reset_error!
      begin
        moved_retry ||= false
				not_allowed_retry ||= false
        
        uri = URI.parse(str)
        uri.path = '/' if uri.path.length < 1        
        return set_error(:invalid_scheme) unless validate_scheme(uri)
        return set_error(:invalid_host) unless validate_host(uri)
        
        http = Net::HTTP.new(uri.host, (uri.scheme == 'https') ? 443 : port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        response = not_allowed_retry ? http.request_get(uri.path) {|r|} : http.request_head(uri.path)        
        raise unless validate_response_code(response)
        return set_error(:invalid_content_type) unless validate_content_type(response)      
      rescue URI::InvalidURIError
        return set_error(:invalid_format)
      rescue
        if response.is_a?(Net::HTTPMovedPermanently)
          unless moved_retry
            moved_retry = true
            str += '/' # In case webserver is just adding a /
            retry
          else
            return set_error(:moved_permanently)            
          end
        elsif response.is_a?(Net::HTTPMethodNotAllowed)
          unless not_allowed_retry # Retry with a GET 
            not_allowed_retry = true
            retry
          else
            return set_error(:not_accessible)
          end
        else       
          return set_error(:not_accessible)
        end
      end
      return true
    end
    alias :valid_url? :valid_uri?
    
    def valid_domain?(str)
      begin
        uri = URI.parse(str)
        return valid_uri?("#{uri.scheme || 'http'}://#{uri.host || str}/")
      rescue URI::InvalidURIError, URI::NameError
        return set_error(:invalid_format)
      end
    end
   
    private
    
    def reset_error!
      @error = nil
    end
    
    def set_error(code)
      @error = code
      false
    end
    
    def validate_scheme(uri)
      return true if schemes.empty?
      schemes.find { |match| match.kind_of?(Regexp) ? uri.scheme =~ match : uri.scheme.index(match) }
    end
    
    def validate_host(uri)
      return true if hosts.empty?
      hosts.find { |match| match.kind_of?(Regexp) ? uri.host =~ match : uri.host.index(match) }
    end
    
    def validate_response_code(response)
      response_codes.include?(response.class)
    end
    
    def validate_content_type(response)
      return true if content_types.empty?
      content_types.find { |match| match.kind_of?(Regexp) ? response['content-type'] =~ match : response['content-type'].index(match) }
    end
    
  end
end