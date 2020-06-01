# frozen_string_literal: true

require_relative 'lib/jimmy/version'

Gem::Specification.new do |spec|
  spec.name    = 'jimmy'
  spec.version = Jimmy::VERSION
  spec.authors = ['Neil E. Pearson']
  spec.email   = ['neil@helium.net.au']

  spec.summary               = 'Jimmy the Gem'
  spec.description           = 'Jimmy the Gem'
  spec.homepage              = 'https://github.com/hx/jimmy'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.start_with? 'spec/' }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.license       = 'Apache License, Version 2.0'
end
