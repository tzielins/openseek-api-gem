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

    @query_type = 'PROPERTY'
    @entity_type = 'DataSetFile'
    @property = 'SEEK_DATAFILE_ID'
    @property_value = 'DataFile_1'
  end

  def test_query
    instance = DataStoreQuery.new(@dss_endpoint, @token)
    result = instance.query(@entity_type, @query_type, @property, @property_value)
    assert !result["datasetfiles"].empty?
  end

  def test_query_no_result
    instance = DataStoreQuery.new(@dss_endpoint, @token)
    property_value = 'Some_value'
    result = instance.query(@entity_type, @query_type, @property, property_value)

    assert result.empty?
  end
end