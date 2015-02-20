require 'test/unit'
require 'openbis-api-gem'
require 'coveralls'
Coveralls.wear!

class QueryTest < Test::Unit::TestCase

  include Fairdom::OpenbisApi

  def setup
    @endpoint = 'https://openbis-testing.fair-dom.org/openbis'
    @username = 'api-user'
    @password = 'api-user'
    @type = 'Experiment'
    @property = 'SEEK_STUDY_ID'
    @property_value = 'Study_1'
  end

  def test_successful_authentication
    instance = Query.new(@username, @password, @endpoint)
    result = instance.query(@type, @property, @property_value)
    assert_not_nil result
  end

  def test_failed_authentication
    invalid_password = "blabla"
    instance = Query.new(@username, invalid_password, @endpoint)
    assert_raise OpenbisQueryException do
      instance.query(@type, @property, @property_value)
    end
  end

  def test_query
    instance = Query.new(@username, @password, @endpoint)
    result = instance.query(@type, @property, @property_value)

    first_result = result.first
    assert_equal(@type, first_result['@type'])

    properties = first_result["properties"]
    assert properties.keys.include?(@property)
    assert_equal(@property_value, properties[@property])
  end

  def test_query_no_result
    instance = Query.new(@username, @password, @endpoint)
    property_value = 'Some value'
    result = instance.query(@type, @property, property_value)

    assert result.empty?
  end

  def test_invalid_type
    instance = Query.new(@username, @password, @endpoint)
    invalid_type = 'SomeType'

    assert_raise OpenbisQueryException do
      instance.query(invalid_type, @property, @property_value)
    end
  end

  def test_empty_parameter
    instance = Query.new(@username, @password, @endpoint)
    empty_property = ' '

    assert_raise OpenbisQueryException do
      instance.query(@type, empty_property, @property_value)
    end
  end

end