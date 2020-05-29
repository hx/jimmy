# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  minimum_coverage line: 100, branch: 100
  add_filter '/spec/'
end

require 'jimmy'

FIXTURES = Pathname(__dir__) + 'fixtures'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
