# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "openseek-api-gem/version"

Gem::Specification.new do |s|
  s.name        = "openseek-api-gem"
  s.version     = Openbis::Api::Gem::VERSION
  s.authors     = ["quyen"]
  s.email       = ["thucquyendn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{ruby gem to talk to openbis-api java}
  s.description = %q{ruby gem to talk to openbis-api java}

  s.rubyforge_project = "openseek-api-gem"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
