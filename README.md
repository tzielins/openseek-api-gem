[![Build Status](https://travis-ci.org/FAIRdom/openbis-api-gem.png?branch=master)](https://travis-ci.org/FAIRdom/openbis-api-gem)

[![Coverage Status](https://coveralls.io/repos/FAIRdom/openbis-api-gem/badge.svg)](https://coveralls.io/r/FAIRdom/openbis-api-gem)

[![Code Climate](https://codeclimate.com/github/FAIRdom/openbis-api-gem/badges/gpa.svg)](https://codeclimate.com/github/FAIRdom/openbis-api-gem)

## Installation

Java 1.8 (JRE) is required.

  gem "openbis-api-gem", :git=>"https://github.com/FAIRdom/openbis-api-gem.git"

## Usage

*   Use to query entities in Openbis, filtered on a property with a defined property value. 
*   Entity type is for example Experiment, Sample, DataSet.
*   Property is normally the SEEK_ID, which is used to map Openbis entity with SEEK entity.

    include Fairdom::OpenbisApi
    
    instance = Fairdom::OpenbisApi::Query.new(username, password, endpoint)
    
    json_result = instance.query(type, property, property_value)