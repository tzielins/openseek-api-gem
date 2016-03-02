ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openseek-api-gem'

class DataStoreQueryTest < Test::Unit::TestCase

  include Fairdom::OpenbisApi

  def setup
    @dss_endpoint = 'https://openbis-api.fair-dom.org/datastore_server'
    username = 'apiuser'
    password = 'apiuser'
    @token = Authentication.new(username, password, @as_endpoint).login["token"]

    @options = {:entityType=>"DataSetFile",:queryType=>"PROPERTY",:property=>"SEEK_DATAFILE_ID",:propertyValue=>"DataFile_1"}
  end

  def test_query
    instance = DataStoreQuery.new(@dss_endpoint, @token)
    result = instance.query(@options)
    assert !result["datasetfiles"].empty?
  end

  def test_query_no_result
    instance = DataStoreQuery.new(@dss_endpoint, @token)
    @options[:propertyValue] = 'Some_value'
    result = instance.query(@options)
    assert result.empty?
  end
end