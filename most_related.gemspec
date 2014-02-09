# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'most_related/version'

Gem::Specification.new do |spec|
  spec.name          = "most_related"
  spec.version       = MostRelated::VERSION
  spec.authors       = ["Jolyon Pawlyn"]
  spec.email         = ["jolyon.pawlyn@unboxedconsulting.com"]
  spec.description   = %q{Adds an instance method to a active record model that returns the most related models based on many to many associated models in common}
  spec.summary       = %q{Returns models that have the most many to many associated models in common}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "activerecord", "~> 4.0.0"
  spec.add_development_dependency "sqlite3"
end
