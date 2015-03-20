# Test Item API
# All integration tests for the API

# include Test Helper
require File.expand_path '../../test_helper.rb', __FILE__

class TestItemAPI < Minitest::Test
  include Rack::Test::Methods

  def app
    @app ||= ZephirApi.new
  end
  
  def test_get_item
    # test id
    get '/item/test.123testitem'
    assert last_response.ok?
    # barcode id
    get '/item/test.39015012078393'
    assert last_response.ok?
    # ark id
    get '/item/test.ark:/13960/t1vd7kt4b'
    assert last_response.ok?
  end
  
  def test_get_item_content_negotiation
    # Test xml accept header.
    get '/item/test.ark:/13960/t1vd7kt4b', nil, {'HTTP_ACCEPT' => 'text/xml'}
    assert last_response.ok?
    xml_response = last_response.body
    # Test with xml extenstion.
    get '/item/test.ark:/13960/t1vd7kt4b.xml'
    assert_equal xml_response, last_response.body 
    # Test an *anything* accept header.
    get '/item/test.ark:/13960/t1vd7kt4b', nil, {'HTTP_ACCEPT' => '*/*'}
    assert_equal xml_response, last_response.body
    # Test json accept header returns different.
    get '/item/test.ark:/13960/t1vd7kt4b', nil, {'HTTP_ACCEPT' => 'application/json'}
    assert last_response.content_type, 'application/json' 
    json_response = last_response.body
    assert xml_response != json_response
    # Test with json extension.
    get '/item//test.ark:/13960/t1vd7kt4b.json'
    assert_equal json_response, last_response.body
    # Test override (json extension with xml accept headers).
    get '/item/test.ark:/13960/t1vd7kt4b.json', nil, {'HTTP_ACCEPT' => 'text/xml'}
    assert_equal json_response, last_response.body
  end
  
  def test_get_item_errors_conditions
    get '/item/test.123noitemfound'
    assert_equal 404, last_response.status
    get '/item/test.123noitemfound', nil, {'HTTP_ACCEPT' => 'application/json'}
    assert_equal '{"status":404, "message":"Not Found"}', last_response.body
    get '/item/test.thisitemhaswaytoomanycharacterstobeconsideredanacceptablehtid'
    assert_equal 422, last_response.status
  end
end