ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'openseek-api'

class ApplicationServerQueryTest < Test::Unit::TestCase
  include Fairdom::OpenbisApi

  def setup
    @as_endpoint = 'https://openbis-api.fair-dom.org/openbis/openbis'
    @as_endpoint = 'https://127.0.0.1:8443/openbis/openbis'
    username = 'apiuser'
    password = 'apiuser'
    username = 'seek'
    password = 'seek'
    @token = Authentication.new(username, password, @as_endpoint).login['token']

    @options = { entityType: 'Experiment', queryType: 'PROPERTY', property: 'NAME', propertyValue: 'Low light diurnal' }
  end

  def local_setup
    @as_endpoint = 'https://127.0.0.1:8443/openbis/openbis'
    username = 'seek'
    password = 'seek'
    @token = Authentication.new(username, password, @as_endpoint).login['token']
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
    assert_equal 7, spaces.count
     space = spaces[0]
    # assert_equal 'API-SPACE', space['code']
    # assert_equal 'use for testing openbis api integration', space['description'].strip
    experiments = space['experiments']
    assert_equal 0, experiments.size
    # assert_equal ['20151216143716562-2'], experiments

    projects = space['projects']
    assert_equal 0, projects.size
    # assert_equal ['20151216135152196-1'], projects

    datasets = space['datasets']
    assert_equal 0, datasets.size
    #assert_includes datasets, '20160210130359377-22'

    # space = spaces[1]
    #assert_equal 'DEFAULT', space['code']
    # assert_nil space['description']
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
    @options[:attributeValue] = '20180418141729157-47'
    result = instance.query(@options)
    experiments = result['experiments']
    refute experiments.empty?
  end

  def test_query_multiple_perm_id_attribute_values
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    @options[:queryType] = 'ATTRIBUTE'
    @options[:attribute] = 'permId'
    @options[:attributeValue] = '20180424181519696-54,20180418141729157-47'
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
    @options = { entityType: 'DataSet', queryType: 'ATTRIBUTE', attribute: 'PermID', attributeValue: '20180424182903704-59' }
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    #puts result


    datasets = result['datasets']
    assert_equal 1, datasets.size

    dataset = datasets[0]
    assert_equal '20180424182903704-59', dataset['permId']
    # assert_equal 'apiuser', dataset['registerator']

    params = dataset['properties']
    assert_not_nil params
    assert_equal 'TOMEK test set', params['NAME']

  end

  def test_query_for_dataset_can_retrive_sampleonly_dataset
    puts 'no such test data'
    return
    @options = { entityType: 'DataSet', queryType: 'ATTRIBUTE', attribute: 'PermID', attributeValue: '20180418150033700-51' }
    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    puts result


    datasets = result['datasets']
    assert_equal 1, datasets.size

    dataset = datasets[0]
    assert_equal '20180418150033700-51', dataset['permId']
    assert_equal 'seek', dataset['registerator']

    assert_nil dataset['experiment']
    assert_equal '20171002172111346-37', dataset['sample']
    params = dataset['properties']
    assert_not_nil params
    assert_equal 'DS One', params['NAME']

  end


  def test_all_datasets_query

    @options = { entityType: 'DataSet', queryType: 'ALL' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result

    datasets = result['datasets']
    assert_equal 6, datasets.size
  end

  def test_all_samples_query

    @options = { entityType: 'Sample', queryType: 'ALL' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result

    samples = result['samples']
    assert_equal 16, samples.size
  end

  def test_all_spaces_query

    @options = { entityType: 'Space', queryType: 'ALL' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result

    spaces = result['spaces']
    assert_equal 7, spaces.size
  end

  def test_all_experiments_query
    local_setup
    @options = { entityType: 'Experiment', queryType: 'ALL' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    puts result.to_json

    experiments = result['experiments']
    assert_equal 24, experiments.size
  end

  def test_all_experimentstypes_query
      local_setup
      @options = { entityType: 'ExperimentType', queryType: 'ALL' }

      instance = ApplicationServerQuery.new(@as_endpoint, @token)
      result = instance.query(@options)

      puts result.to_json

      types = result['experimenttypes']
      assert_equal 6, types.size
  end

  def test_all_sampletypes_query

    @options = { entityType: 'SampleType', queryType: 'ALL' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result

    types = result['sampletypes']
    assert_equal 25, types.size
  end

  def test_all_datasetstypes_query

    @options = { entityType: 'DataSetType', queryType: 'ALL' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result

    types = result['datasettypes']
    assert_equal 6, types.size
  end




  def test_samples_with_type_query

    @options = { entityType: 'Sample', queryType: 'TYPE', typeCode: 'EXPERIMENTAL_STEP' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result

    samples = result['samples']
    assert_equal 8, samples.size

  end

  def test_datasets_with_type_query

    @options = { entityType: 'DataSet', queryType: 'TYPE', typeCode: 'RAW_DATA' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result

    sets = result['datasets']
    assert_equal 4, sets.size

  end



  def test_local_setup
    @token = nil

    local_setup
    assert_not_nil @token
  end





  def test_experimentstypes_with_code_query

    local_setup
    @options = { entityType: 'ExperimentType', queryType: "ATTRIBUTE", :attribute=>"CODE", :attributeValue=>"DEFAULT_EXPERIMENT" }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    puts result.to_json

    types = result['experimenttypes']
    assert_equal 1, types.size
  end


  def test_experiments_by_permi_id_query
    local_setup

    @options = { entityType: 'Experiment', queryType: 'ATTRIBUTE',
              attribute: 'PermID', attributeValue: '20180424181519696-54'}

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    puts result.to_json

    exps = result['experiments']
    assert_equal 1, exps.size


  end


  def test_experiments_with_type_query
    local_setup

    @options = { entityType: 'Experiment', queryType: 'TYPE', typeCode: 'DEFAULT_EXPERIMENT' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    puts result.to_json

    exps = result['experiments']
    assert_equal 3, exps.size

    @options = { entityType: 'Experiment', queryType: 'TYPE', typeCodes: 'DEFAULT_EXPERIMENT,MATERIALS' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result

    exps = result['experiments']
    assert_equal 15, exps.size

  end

  def test_type_by_semantic
    local_setup

    @options = { entityType: 'SampleType', queryType: 'SEMANTIC', predicateAccessionId: 'is_a', descriptorAccessionId: 'assay' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result

    sampleTypes = result['sampletypes']
    assert_equal 2, sampleTypes.size

  end

  def test_type_by_codes
    local_setup

    @options = { entityType: 'SampleType', queryType: 'ATTRIBUTE', attribute: 'CODE', attributeValue: 'EXPERIMENTAL_STEP' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result
    sampleTypes = result['sampletypes']
    assert_equal 1, sampleTypes.size

    @options = { entityType: 'SampleType', queryType: 'ATTRIBUTE', attribute: 'CODE', attributeValue: 'UNKNOWN' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result
    sampleTypes = result['sampletypes']
    assert_equal 1, sampleTypes.size

    @options = { entityType: 'SampleType', queryType: 'ATTRIBUTE', attribute: 'CODE', attributeValue: 'EXPERIMENTAL_STEP,UNKNOWN' }

    instance = ApplicationServerQuery.new(@as_endpoint, @token)
    result = instance.query(@options)

    # puts result
    sampleTypes = result['sampletypes']
    assert_equal 2, sampleTypes.size

  end

  def test_checking_sample_with_parent_and_children
    local_setup
    instance = ApplicationServerQuery.new(@as_endpoint, @token)

    @options[:entityType] = 'Sample'
    @options[:queryType] = 'ATTRIBUTE'
    @options[:attribute] = 'PermID'
    @options[:attributeValue] = '20180418145851124-48'
    result = instance.query(@options)

    assert_equal 1,result['samples'].size
    puts result['samples'][0]
  end
end
