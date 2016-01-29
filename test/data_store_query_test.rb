ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openbis-api-gem'

class DataStoreQueryTest < Test::Unit::TestCase

  include Fairdom::OpenbisApi

  def setup
    @as_endpoint = 'https://openbis-api.fair-dom.org/openbis/openbis'
    @dss_endpoint = 'https://openbis-api.fair-dom.org:444/datastore_server'
    @username = 'api-user'
    @password = 'api-user'
    @type = 'DataSetFile'
    @property = 'SEEK_DATAFILE_ID'
    @property_value = 'DataFile_1'
  end

  def test_query
    instance = DataStoreQuery.new(@username, @password, @as_endpoint, @dss_endpoint)
    result = instance.query(@type, @property, @property_value)

    first_result = result["objects"].first
    assert(first_result['@type'].include?(@type))

    assert_equal 3, result["totalCount"]

    root_folder = result["objects"].first
    original_folder = result["objects"][1]
    file = result["objects"].last

    assert root_folder["isDirectory"]
    assert original_folder["isDirectory"]
    assert !file["isDirectory"]

    assert_equal "", root_folder["path"]
    assert_equal "original", original_folder["path"]
    assert_equal "original/api-test", file["path"]

    assert_equal "20151217153943290-5", root_folder["permId"]["dataSetId"]["permId"]
    assert_equal "20151217153943290-5", original_folder["permId"]["dataSetId"]["permId"]
    assert_equal "20151217153943290-5", file["permId"]["dataSetId"]["permId"]

    filesize = 25
    assert_equal filesize, file["fileLength"]
  end

  def test_query_no_result
    instance = DataStoreQuery.new(@username, @password, @as_endpoint, @dss_endpoint)
    property_value = 'Some value'
    result = instance.query(@type, @property, property_value)

    assert_equal 0, result["totalCount"]
  end
end