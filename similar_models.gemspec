# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'similar_models/version'

Gem::Specification.new do |spec|
  spec.name          = "similar_models"
  spec.version       = SimilarModels::VERSION
  spec.authors       = ["Jolyon Pawlyn"]
  spec.email         = ["jpawlyn@gmail.com"]
  spec.description   = %q{Adds a `similar_#{model_name.plural}` instance and class method to an active record model and returns models based on associated models in common ordered by most in common first}
  spec.summary       = %q{Returns models that have associated models in common ordered by most in common first}
  spec.homepage      = "https://github.com/jpawlyn/similar_models"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version     = '>= 3.1'
  spec.add_runtime_dependency     'activerecord', '>= 7.2'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'database_cleaner', '~>1.5'
  spec.add_development_dependency 'sqlite3', '~>2.6'
  spec.add_development_dependency 'mysql2', '~>0.5'
  spec.add_development_dependency 'pg', '~>1.5'
  spec.add_development_dependency 'debug', '~>1.0'
end
