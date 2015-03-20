# == Zephir API
# This is a sinatra application for delivering Zephir Data (e.g. Item-Level Bibliographic Data)

# Set Default Environment Variables
ENV['RACK_ENV'] ||= 'development'
ENV['APP_ROOT'] ||= File.expand_path(File.dirname(__FILE__))

# Include Packages
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

# Setup Database
db_options = YAML.load(File.read('./config/database.yml'))
ActiveRecord::Base.establish_connection(db_options[ENV['RACK_ENV']])
# Create ORM class for Zephir database table (ActiveRecord loads schema from database)
class ZephirFiledata < ActiveRecord::Base; end

# Sinatra Application Class (Modular Style)
# All application code within this class
class ZephirApi < Sinatra::Base
  
  # == Modular Sinatra Extensions
  register Sinatra::RespondWith # Content Negotiation
  register Sinatra::Namespace # Namespaced Routes
  
  # == Constants
  HTID_REGEX = Regexp.compile(/^.{3,40}$/)
  
  # == Before Filters
  # Processing before application controllers, all paths
  before /.*/ do
    # Allow content negotiation override with suffix processing. We handle this before any other 
    # processing in order to have content negotiation for all routes.
    case
    when request.url.match(/.json$/)
      request.accept.clear
      request.accept.unshift(Sinatra::Request::AcceptEntry.new('application/json'))
      request.path_info = request.path_info.gsub(/.json$/,'')
    when request.url.match(/.xml$/)
      request.accept.unshift(Sinatra::Request::AcceptEntry.new('text/xml'))
      request.path_info = request.path_info.gsub(/.xml$/,'')
    end
  end
  
  # == Routes/Controllers
  # The application code to handle requests at a given http method and path (e.g. GET method at URL '/path')
  
  # @return [HTTPRedirect)]
  # GET Application redirect: No content, forward to API Documentation
  get '/' do
    redirect "#{request.script_name}/documentation", 303
  end
  
  # @return [HTML] API Documentation
  # GET API Documentation
  get '/documentation' do
    markdown sub_url(File.read('API.md'))
  end
  
  # @return [XML|JSON] Response message
  # GET Ping for service testing
  get '/ping' do
    # test a database call
    if ZephirFiledata.first.nil?
      raise Exception
    else
      # No exception, send success
      render_basic_response(200, 'Success')
    end
  end
  
  # API calls for Item data
  namespace '/item' do
    # @return [HTTPRedirect]
    # GET Items: No content, forward to API Documentation
    get '' do
      redirect "#{request.script_name}/documentation", 303
    end
    
    # @param [String] HTID for HathiTrust record
    # @return [XML|JSON] Zephir Record for HTID
    # GET Item-level bibliographic record 
    get '/*' do |id|
      if !HTID_REGEX.match(id)
        raise UnacceptableParameter
      end
      item = ZephirFiledata.find_by(:id => id)
      if item.nil?
        raise ActiveRecord::RecordNotFound
      else
        status 200
        respond_to do |f|
          f.xml do # will also catch */*
            # content_type 'text/xml'
            item.metadata
          end
          f.json do
            # content_type 'application/json'
            item.metadata_json
          end
        end
      end
    end
  end
  
  # == Error Handling
  # Custom error handling in Sinatra to render specfic responses and status codes
  error ActiveRecord::RecordNotFound do
    render_basic_response(404, 'Not Found')
  end

  # HTID given is not a valid format
  class UnacceptableParameter < Exception; end
  # @return [Response]
  # Handle an unacceptable parameter
  error UnacceptableParameter do
    render_basic_response(422, 'Unacceptable parameters')
  end
  
  # @return [Response]   
  # Handle an unknown exception
  error Exception do
    render_basic_response(500, 'Failure')
  end
  
  # @return [Response]
  # Handle a Sinatra route 404 as bad request
  not_found do
    render_basic_response(400, 'Bad Request')
  end

  # == Private Methods
  # Methods used internally by the application
  private
  # @param [String] Text for http://localhost substitution with current host
  # @return [String] Processed string with current host.
  # Swap generic localhost string with actual path for documentation
  def sub_url(text)
    text.gsub(/http:\/\/localhost\//,"#{request.base_url}#{request.script_name}/")
  end
  
  # @param [Status] Status code to be returned in headers and response
  # @param [Message] Message to be returned in response
  # @return [Response] Processed string with current host.
  # Render a basic response status and message depending on content negotiaton
  def render_basic_response(status_code, message)
    respond_to do |f|
      status status_code
      f.xml do # Will also catch */*.
        "<response><status>#{status_code}</status><message>#{message}</message></response>"
      end
      f.json do
        "{\"status\":#{status_code}, \"message\":\"#{message}\"}"
      end
    end
  end
end