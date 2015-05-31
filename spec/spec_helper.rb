$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jimmy'
require 'pathname'

SPEC_ROOT = Pathname(__FILE__).parent
GEM_ROOT = SPEC_ROOT.parent
TEMP_ROOT = SPEC_ROOT + 'tmp'

RSpec.configure do |config|

  # Setup and tear-down of temporary directory
  config.before { TEMP_ROOT.rmtree if TEMP_ROOT.exist?; TEMP_ROOT.mkpath }
  config.after { TEMP_ROOT.rmtree }
end
