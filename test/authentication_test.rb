ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openseek-api-gem'

class AuthenticationTest < Test::Unit::TestCase
  include Fairdom::OpenbisApi

  def setup
    @as_endpoint = 'https://openbis-api.fair-dom.org/openbis/openbis'
    @username = 'apiuser'
    @password = 'apiuser'
  end

  def test_successful_authentication
    au = Authentication.new(@username, @password, @as_endpoint)
    session_token = au.login
    assert_not_nil session_token['token']
  end

  def test_failed_authentication
    invalid_password = 'blabla'
    au = Authentication.new(@username, invalid_password, @as_endpoint)
    assert_raise OpenbisQueryException do
      au.login
    end
  end
end
