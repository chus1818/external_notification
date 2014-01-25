require 'net/http'
require_relative 'constant_store'

class ExternalNotification

  extend ConstantStore

  constant_stores :known_endpoints, :as => :hash

  def initialize endpoints = nil
    @request_type = :GET

    when_valid endpoints do 
      self.class.const_set( 'KNOWN_ENDPOINTS', endpoints )
    end
  end

  def with options = {}
    if block_given? or options[ :params ]
      @request_type = :POST unless options.delete( :request_type ) == :GET
      @content = block_given? ? yield.to_param : options[:params].to_param
    end
  
    self
  end
  
  def send_to receiver
    response = request_to urlize( receiver )
    handle_response response
  end

private

  def handle_response response
    response
  end

  def urlize receiver
    base_uri   = KNOWN_ENDPOINTS[receiver.to_sym] || receiver
    uri_string = @content ? ( base_uri + "?#{@content}" ) : base_uri
    
    URI.parse uri_string
  end

  def request_to url_object
    Net::HTTP.start( url_object.host, url_object.port ) do |http|
      http.request request_object_for( url_object.to_s )
    end
  end

  def request_object_for path
    case @request_type
      when :GET  then Net::HTTP::Get.new( path )
      when :POST then post_request( path )
      else Net::HTTP::Get.new( path )
    end
  end

  def post_request path
    request = Net::HTTP::Post.new( path )
    request.body = ""
    request
  end

end