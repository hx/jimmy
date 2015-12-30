$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jimmy'
require 'pathname'
require 'diff_matcher'

SPEC_ROOT = Pathname(__FILE__).parent
GEM_ROOT = SPEC_ROOT.parent
TEMP_ROOT = SPEC_ROOT + 'tmp'

RSpec.configure do |config|

  # Setup and tear-down of temporary directory
  config.before { TEMP_ROOT.rmtree if TEMP_ROOT.exist?; TEMP_ROOT.mkpath }
  config.after { TEMP_ROOT.rmtree }
end

class Hash
  def deep_stringify_keys
    map { |k, v| [k.to_s, v.respond_to?(:deep_stringify_keys) ? v.deep_stringify_keys : v] }.to_h
  end
end

class Array
  def deep_stringify_keys
    map { |v| v.respond_to?(:deep_stringify_keys) ? v.deep_stringify_keys : v }
  end
end

RSpec::Matchers.define :eq_json do |expected|
  match do |actual|
    a, b = prepare_input(actual)
    a == b
  end

  private

  def prepare_input(actual)
    {a: expected, b: actual}.deep_stringify_keys.values
  end

  def diff(actual)
    DiffMatcher.difference(
        *prepare_input(actual),
        quiet:         true,
        color_enabled: RSpec.configuration.color_enabled?
    )
  end

  description { "as JSON matches #{expected.to_json}" }

  failure_message do |actual|
    "The given #{actual.class.name} as JSON should match #{expected.to_json}\nDiff:\n\n#{diff actual}\n"
  end

end
