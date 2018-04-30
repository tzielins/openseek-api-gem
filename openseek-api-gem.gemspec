# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'fairdom/openbis_api/versions'

Gem::Specification.new do |spec|
  spec.name        = 'openseek-api'
  spec.version     = Fairdom::OpenbisApi::VERSION
  spec.authors     = ['Stuart Owen', 'Quyen Nguyen', 'Tomasz Zielinski']
  spec.email       = ['thucquyendn@gmail.com']
  spec.homepage    = 'https://github.com/fairdom/openseek-api-gem'
  spec.summary     = 'ruby gem to talk to openbis-api java libaries, for use within SEEK4Science'
  spec.description = 'ruby gem to talk to openbis-api java libaries, for use within SEEK4Science'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # runtime dependencies
  spec.add_dependency('terrapin', ['>= 0'])

  # development dependencies
  spec.add_development_dependency('coveralls', ['>= 0'])
  spec.add_development_dependency('rubocop', ['>= 0'])
  spec.add_development_dependency('rubycritic', ['>= 0'])
  spec.add_development_dependency('rake', ['~> 10.0'])
  spec.add_development_dependency('test-unit')

end
