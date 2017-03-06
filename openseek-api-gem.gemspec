# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'fairdom/openbis_api/versions'

Gem::Specification.new do |s|
  s.name        = "openseek-api-gem"
  s.version     = Fairdom::OpenbisApi::VERSION
  s.authors     = ["quyen"]
  s.email       = ["thucquyendn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{ruby gem to talk to openbis-api java}
  s.description = %q{ruby gem to talk to openbis-api java}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency("coveralls", ['>= 0'])
  s.add_development_dependency('rubocop', ['>= 0'])
  s.add_development_dependency('rubycritic', ['>= 0'])

  s.add_dependency("open4","1.3.0")
  s.add_dependency("rake","10.4.2")
end
