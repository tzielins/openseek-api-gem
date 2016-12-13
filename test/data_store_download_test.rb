ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openseek-api-gem'

class DataStoreDownloadTest < Test::Unit::TestCase
  include Fairdom::OpenbisApi

  def setup
    @dss_endpoint = 'https://openbis-api.fair-dom.org/datastore_server'
    @as_endpoint = 'https://openbis-api.fair-dom.org/openbis/openbis'
    username = 'apiuser'
    password = 'apiuser'
    @token = Authentication.new(username, password, @as_endpoint).login['token']

    @dest_folder = File.dirname(__FILE__) + '/tmp/'
    FileUtils.mkdir_p @dest_folder unless File.exist?(@dest_folder)
  end

  def test_download_file
    instance = DataStoreDownload.new(@dss_endpoint, @token)
    dest = @dest_folder + 'utf8.txt'
    options = { downloadType: 'file', permID: '20160210130359377-22', source: 'original/utf8.txt', dest: dest }
    FileUtils.remove_file(dest) if File.exist?(dest)
    result = instance.download(options)
    assert File.exist?(dest)
  end

  def test_download_file_with_space_in_name
    instance = DataStoreDownload.new(@dss_endpoint, @token)
    dest = @dest_folder + 'Genes List Nature Paper Test.docx'
    options = { downloadType: 'file', permID: '20160322172551664-35', source: 'original/Genes List Nature Paper Test.docx', dest: dest }
    FileUtils.remove_file(dest) if File.exist?(dest)
    result = instance.download(options)
    assert File.exist?(dest)
  end

  def test_download_folder
    instance = DataStoreDownload.new(@dss_endpoint, @token)
    source = 'original/DEFAULT'
    dest = @dest_folder
    options = { downloadType: 'folder', permID: '20160215111736723-31', source: source, dest: dest }
    FileUtils.remove_dir(dest + source) if File.exist?(dest + source)
    result = instance.download(options)
    assert File.exist?(dest + source)
    assert File.exist?(dest + source + '/fairdom-logo-compact.svg')
    assert File.exist?(dest + source + '/Stanford_et_al-2015-Molecular_Systems_Biology.pdf')
  end

  def test_download_dataset_files
    instance = DataStoreDownload.new(@dss_endpoint, @token)
    source = 'original'
    dest = @dest_folder
    options = { downloadType: 'dataset', permID: '20151217153943290-5', source: source, dest: dest }
    FileUtils.remove_dir(dest + source) if File.exist?(dest + source)
    result = instance.download(options)
    assert File.exist?(dest + source)
    assert File.exist?(dest + source + '/api-test')
  end
end
