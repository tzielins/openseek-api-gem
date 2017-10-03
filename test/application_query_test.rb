ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openseek-api'

class ApplicationServerQueryTest < Test::Unit::TestCase
  include Fairdom::OpenbisApi

  def setup
    @as_endpoint = 'https://openbis-api.fair-dom.org/openbis/openbis'
    username = 'apiuser'
    password = 'apiuser'
    @token = Authentication.new(username, password, @as_endpoint).login['token']

    @options = { entityType: 'Experiment', queryType: 'PROPERTY', property: 'SEEK_STUDY_ID', propertyValue: 'Study_1' }
  end

  def test_query_property
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)
    experiments = result['experiments']
    refute experiments.empty?
  end

  def test_query_for_spaces
    @options = { entityType: 'Space', queryType: 'ATTRIBUTE', attribute: 'PermID', attributeValue: '' }
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)
    spaces = result['spaces']
    refute spaces.empty?
    assert_equal 2, spaces.count
    space = spaces[0]
    assert_equal 'API-SPACE', space['code']
    assert_equal 'use for testing openbis api integration', space['description'].strip
    experiments = space['experiments']
    assert_equal 1, experiments.size
    assert_equal ['20151216143716562-2'], experiments

    projects = space['projects']
    assert_equal ['20151216135152196-1'], projects

    datasets = space['datasets']
    assert_equal 9, datasets.size
    assert_includes datasets, '20160210130359377-22'

    space = spaces[1]
    assert_equal 'DEFAULT', space['code']
    assert_nil space['description']
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
    @options[:queryType] = 'ATTRIBUTE'
    @options[:attribute] = 'permId'
    @options[:attributeValue] = '20151216143716562-2'
    result = instance.query(@options)
    experiments = result['experiments']
    refute experiments.empty?
  end

  def test_query_multiple_perm_id_attribute_values
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    @options[:queryType] = 'ATTRIBUTE'
    @options[:attribute] = 'permId'
    @options[:attributeValue] = '20151216112932823-1,20151216143716562-2'
    result = instance.query(@options)
    experiments = result['experiments']
    refute experiments.empty?
  end

  def test_query_all_permid
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    @options[:queryType] = 'ATTRIBUTE'
    @options[:attribute] = 'PermID'
    @options[:attributeValue] = ''
    result = instance.query(@options)
    refute result['experiments'].empty?
  end

  def test_query_for_dataset_gives_rich_metadata
    @options = { entityType: 'DataSet', queryType: 'ATTRIBUTE', attribute: 'PermID', attributeValue: '20170907185702684-36' }
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    #puts result


    datasets = result['datasets']
    assert_equal 1, datasets.size

    dataset = datasets[0]
    assert_equal '20170907185702684-36', dataset['permId']
    assert_equal 'apiuser', dataset['registerator']

    params = dataset['properties']
    assert_not_nil params
    assert_equal 'TOMEK test set', params['NAME']

  end

  def test_query_for_dataset_can_retrive_sampleonly_dataset
    @options = { entityType: 'DataSet', queryType: 'ATTRIBUTE', attribute: 'PermID', attributeValue: '20171002172401546-38' }
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result


    datasets = result['datasets']
    assert_equal 1, datasets.size

    dataset = datasets[0]
    assert_equal '20171002172401546-38', dataset['permId']
    assert_equal 'apiuser', dataset['registerator']

    assert_nil dataset['experiment']
    assert_equal '20171002172111346-37', dataset['sample']
    params = dataset['properties']
    assert_not_nil params
    assert_equal 'DS One', params['NAME']

  end
end
