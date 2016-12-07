# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jimmy/version'

Gem::Specification.new do |spec|
  spec.name          = 'jimmy'
  spec.version       = Jimmy::VERSION
  spec.authors       = ['Neil E. Pearson']
  spec.email         = ['neil.pearson@orionvm.com']

  spec.summary       = 'Jimmy the JSON Schema DSL'
  spec.description   = 'Jimmy makes it a snap to compose detailed JSON schema documents.'
  spec.homepage      = 'https://github.com/hx/jimmy'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.license       = 'Apache License, Version 2.0'

  spec.add_dependency 'json-schema', '~> 2.5'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'diff_matcher', '~> 2.7'
end
