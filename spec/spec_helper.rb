$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jimmy'
require 'pathname'

SPEC_ROOT = Pathname(__FILE__).parent
GEM_ROOT = SPEC_ROOT.parent
