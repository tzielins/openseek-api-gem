ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openseek-api-gem'

class ApplicationServerQueryTest < Test::Unit::TestCase

  include Fairdom::OpenbisApi

  def setup
    @as_endpoint = 'https://openbis-api.fair-dom.org/openbis/openbis'
    username = 'apiuser'
    password = 'apiuser'
    @token = Authentication.new(username, password, @as_endpoint).login["token"]

    @entity_type = 'Experiment'
    @query_type = 'PROPERTY'
    @property = 'SEEK_STUDY_ID'
    @property_value = 'Study_1'

  end

  def test_query
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@entity_type, @query_type, @property, @property_value)
    experiments = result["experiments"]
    assert !experiments.empty?
  end

  def test_query_no_result
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    property_value = 'Some_value'
    result = instance.query(@entity_type, @query_type, @property, property_value)
    assert result.empty?
  end

  def test_unrecognized_type
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    invalid_type = 'SomeType'

    assert_raise OpenbisQueryException do
      instance.query(invalid_type, @query_type, @property, @property_value)
    end
  end

  def test_empty_property
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    empty_property = ''
    result = instance.query(@entity_type, @query_type, 'empty_property', @property_value)
    assert result.empty?
  end

  def test_any_property
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    any_property = 'any_property'
    result = instance.query(@entity_type, @query_type, any_property, @property_value)
    assert result.empty?
  end
end
