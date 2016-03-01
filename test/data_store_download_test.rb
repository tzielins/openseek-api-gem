ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openseek-api-gem'

class DataStoreDownloadTest < Test::Unit::TestCase

  include Fairdom::OpenbisApi

  def setup
    @dss_endpoint = 'https://openbis-api.fair-dom.org/datastore_server'
    username = 'apiuser'
    password = 'apiuser'
    @token = Authentication.new(username, password, @as_endpoint).login["token"]

    @dest_folder = File.dirname(__FILE__) + '/tmp/'
    unless File.exist?(@dest_folder)
      FileUtils.mkdir_p @dest_folder
    end
  end

  def test_download_file
    instance = DataStoreDownload.new(@dss_endpoint, @token)
    type = 'file'
    perm_id = '20160210130359377-22'
    source = "original/utf8.txt"
    dest = @dest_folder + 'utf8.txt'
    if File.exist?(dest)
      FileUtils.remove_file(dest)
    end
    result = instance.download(type, perm_id, source, dest)
    assert File.exist?(dest)
  end

  def test_download_folder
    instance = DataStoreDownload.new(@dss_endpoint, @token)
    type = "folder"
    perm_id = "20160215111736723-31"
    source = "original/DEFAULT"
    dest = @dest_folder
    if File.exist?(dest + source)
      FileUtils.remove_dir(dest + source)
    end
    result = instance.download(type, perm_id, source, dest)
    assert File.exist?(dest + source)
    assert File.exist?(dest + source + "/fairdom-logo-compact.svg")
    assert File.exist?(dest + source + "/Stanford_et_al-2015-Molecular_Systems_Biology.pdf")
  end

  def test_download_dataset_files
    instance = DataStoreDownload.new(@dss_endpoint, @token)
    type = "dataset"
    perm_id = "20151217153943290-5"
    source = "original"
    dest = @dest_folder
    if File.exist?(dest + source)
      FileUtils.remove_dir(dest + source)
    end
    result = instance.download(type, perm_id, source, dest)
    assert File.exist?(dest + source)
    assert File.exist?(dest + source + "/api-test")
  end
end