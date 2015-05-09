# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'most_related/version'

Gem::Specification.new do |spec|
  spec.name          = "most_related"
  spec.version       = MostRelated::VERSION
  spec.authors       = ["Jolyon Pawlyn"]
  spec.email         = ["jpawlyn@gmail.com"]
  spec.description   = %q{Adds an instance method to a active record model that returns the most related models based on associated models in common}
  spec.summary       = %q{Returns models that have the most associated models in common}
  spec.homepage      = "https://github.com/jpawlyn/most_related"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version     = '>= 1.9.3'
  spec.add_runtime_dependency 'activerecord', '~> 4.0', '>= 4.0.0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rspec', '~> 2.14', '>= 2.14.1'
  spec.add_development_dependency 'database_cleaner', '~>1.4'
  spec.add_development_dependency 'sqlite3', '~>1.3'
  spec.add_development_dependency 'mysql2', '~>0.3'
  spec.add_development_dependency 'pg', '~>0.18'
  spec.add_development_dependency 'byebug', '~>4.0'
end
