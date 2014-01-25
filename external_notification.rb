require 'net/http'

class ExternalNotification

  KNOWN_ENDPOINTS = {
    :laxarxa => lambda {
      endpoint_subpath = 'api/v1/import_embed_audio'
      return case RAILS_ENV
        when 'development'   then "http://localhost:3001/#{endpoint_subpath}"
        when 'preproduction' then "http://www.xal-laxarxa.gnuinepath.com/#{endpoint_subpath}"
        when 'production'    then "http://www.laxarxa.com/#{endpoint_subpath}" 
        else "http://www.laxarxa.com/#{endpoint_subpath}"
      end
    }.call
  } 

  def initialize
  end
  
  def send_to receiver
    response = request_to urlize( receiver )
    handle_response response
  end

  def with options = {}
    @request_type = :POST unless options.delete( :request_type ) == :GET
    @content      = block_given? ? yield.to_param : options.to_param
  
    self
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
      http.request request_object_for( url_object.path )
    end
  end

  def request_object_for path
    case @request_type
      when :GET  then Net::HTTP::Get.new( path )
      when :POST then Net::HTTP::Post.new( path )
      else Net::HTTP::Get.new( path )
    end
  end

end