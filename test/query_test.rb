ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openbis-api-gem'

class ApplicationServerQueryTest < Test::Unit::TestCase

  include Fairdom::OpenbisApi

  def setup
    @as_endpoint = 'https://openbis-testing.fair-dom.org/openbis/openbis'
    @dss_endpoint = 'https://openbis-testing.fair-dom.org:444/datastore_server'
    @username = 'api-user'
    @password = 'api-user'
    @type = 'Experiment'
    @property = 'SEEK_STUDY_ID'
    @property_value = 'Study_1'
  end

  def test_successful_authentication
    instance = ApplicationServerQuery.new(@username, @password, @as_endpoint, @dss_endpoint)
    result = instance.query(@type, @property, @property_value)
    assert_not_nil result
  end

  def test_failed_authentication
    invalid_password = "blabla"
    instance = ApplicationServerQuery.new(@username, invalid_password, @as_endpoint, @dss_endpoint)
    assert_raise OpenbisQueryException do
      instance.query(@type, @property, @property_value)
    end
  end

  def test_query
    instance = ApplicationServerQuery.new(@username, @password, @as_endpoint, @dss_endpoint)
    result = instance.query(@type, @property, @property_value)

    first_result = result["objects"].first
    assert(first_result['@type'].include?(@type))

    properties = first_result["properties"]
    assert properties.keys.include?(@property)
    assert_equal(@property_value, properties[@property])
  end

  def test_query_no_result
    instance = ApplicationServerQuery.new(@username, @password, @as_endpoint, @dss_endpoint)
    property_value = 'Some value'
    result = instance.query(@type, @property, property_value)

    assert_equal 0, result["totalCount"]
  end

  def test_invalid_type
    instance = ApplicationServerQuery.new(@username, @password, @as_endpoint, @dss_endpoint)
    invalid_type = 'SomeType'

    assert_raise OpenbisQueryException do
      instance.query(invalid_type, @property, @property_value)
    end
  end

  def test_empty_parameter
    instance = ApplicationServerQuery.new(@username, @password, @as_endpoint, @dss_endpoint)
    empty_property = ' '

    assert_raise OpenbisQueryException do
      instance.query(@type, empty_property, @property_value)
    end
  end
end
