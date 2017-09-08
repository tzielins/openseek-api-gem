ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openseek-api'

class DataStoreQueryTest < Test::Unit::TestCase
  include Fairdom::OpenbisApi

  def setup
    @dss_endpoint = 'https://openbis-api.fair-dom.org/datastore_server'
    @as_endpoint = 'https://openbis-api.fair-dom.org/openbis/openbis'
    username = 'apiuser'
    password = 'apiuser'
    @token = Authentication.new(username, password, @as_endpoint).login['token']

    @options = { entityType: 'DataSetFile', queryType: 'PROPERTY', property: 'SEEK_DATAFILE_ID', propertyValue: 'DataFile_1' }
  end

  def test_query
    instance = DataStoreQuery.new(@dss_endpoint, @token)
    result = instance.query(@options)
    assert !result['datasetfiles'].empty?
  end

  def test_query_permid_attribute
    instance = DataStoreQuery.new(@dss_endpoint, @token)
    @options[:queryType] = 'ATTRIBUTE'
    @options[:attribute] = 'DataSetPermID'
    @options[:attributeValue] = '20151217153943290-5'
    result = instance.query(@options)
    #puts result
    assert !result['datasetfiles'].empty?
  end

  def test_query_multiple_permid_attribute_values
    instance = DataStoreQuery.new(@dss_endpoint, @token)
    @options[:queryType] = 'ATTRIBUTE'
    @options[:attribute] = 'DataSetPermID'
    @options[:attributeValue] = '20151217153943290-5,20160210130359377-22'
    result = instance.query(@options)
    assert !result['datasetfiles'].empty?
  end

  def test_query_all_permid
    instance = DataStoreQuery.new(@dss_endpoint, @token)
    @options[:queryType] = 'ATTRIBUTE'
    @options[:attribute] = 'DataSetPermID'
    @options[:attributeValue] = ''
    result = instance.query(@options)
    assert !result['datasetfiles'].empty?
  end

  def test_query_no_result
    instance = DataStoreQuery.new(@dss_endpoint, @token)
    @options[:propertyValue] = 'Some_value'
    result = instance.query(@options)
    assert result.empty?
  end
end
