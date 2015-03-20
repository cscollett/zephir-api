# Test Item API
# All integration tests for the API

# include Test Helper
require File.expand_path '../../test_helper.rb', __FILE__

class TestAPI < Minitest::Test
  include Rack::Test::Methods

  def app
    @app ||= ZephirApi.new
  end

  def test_get_ping
    # Test ping and content negotiation.
    get '/ping'
    assert last_response.ok?
    assert_equal '<response><status>200</status><message>Success</message></response>', last_response.body
    get '/ping', nil, {'HTTP_ACCEPT' => 'application/json'}
    assert last_response.ok?
    assert_equal '{"status":200, "message":"Success"}', last_response.body
  end
  
  def test_get_documentation
    # Test API readme file rendering/forwarding.
    get '/documentation'
    assert last_response.ok?
    get '/'
    assert_equal last_response.status, 303
    get '/item'
    assert_equal last_response.status, 303
  end
  
  def test_errors
    get '/bad_request'
    assert_equal last_response.status, 400
  end
end