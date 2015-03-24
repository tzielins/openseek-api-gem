ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openbis-api-gem'

class QueryTest < Test::Unit::TestCase

  include Fairdom::OpenbisApi

  def setup
    @endpoint = 'https://openbis-testing.fair-dom.org/openbis'
    @username = 'api-user'
    @password = 'api-user'
    @options = {
        :type=>"Experiment",
        :property=>"SEEK_STUDY_ID",
        :property_value=>"Study_1"
    }
  end

  def test_successful_authentication
    instance = Query.new(@username, @password, @endpoint)
    result = instance.query(@options)
    assert_not_nil result
  end

  def test_failed_authentication
    invalid_password = "blabla"
    instance = Query.new(@username, invalid_password, @endpoint)
    assert_raise OpenbisQueryException do
      instance.query(@options)
    end
  end

  def test_query
    instance = Query.new(@username, @password, @endpoint)
    result = instance.query(@options)

    first_result = result.first
    assert_equal(@type, first_result['@type'])

    properties = first_result["properties"]
    assert properties.keys.include?(@property)
    assert_equal(@property_value, properties[@property])
  end

  def test_query_no_result
    instance = Query.new(@username, @password, @endpoint)
    property_value = 'Some value'
    result = instance.query(@options)

    assert result.empty?
  end

  def test_invalid_type
    instance = Query.new(@username, @password, @endpoint)
    @options[:type]="SomeType"

    assert_raise OpenbisQueryException do
      instance.query(@options)
    end
  end

  def test_empty_parameter
    instance = Query.new(@username, @password, @endpoint)
    empty_property = ' '
    @options[:property]=' '

    assert_raise OpenbisQueryException do
      instance.query(@options)
    end
  end
end
