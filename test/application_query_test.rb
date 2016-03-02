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

    @options = {:entityType=>"Experiment",:queryType=>"PROPERTY",:property=>"SEEK_STUDY_ID",:propertyValue=>"Study_1"}
  end

  def test_query_property
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)
    experiments = result["experiments"]
    assert !experiments.empty?
  end

  def test_query_property_no_result
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    @options[:propertyValue] = 'Some_value'
    result = instance.query(@options)
    assert result.empty?
  end

  def test_unrecognized_type
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    invalid_type = 'SomeType'
    @options[:entityType] = 'Some_value'
    assert_raise OpenbisQueryException do
      instance.query(@options)
    end
  end

  def test_empty_property
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    @options[:property] = ''
    result = instance.query(@options)
    assert result.empty?
  end

  def test_any_property
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    @options[:property] = 'any_property'
    result = instance.query(@options)
    assert result.empty?
  end

  def test_query_perm_id_attribute
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    @options[:queryType]='ATTRIBUTE'
    @options[:attribute]='permId'
    @options[:attributeValue]='20151216143716562-2'
    result = instance.query(@options)
    experiments = result["experiments"]
    assert !experiments.empty?
  end
end
