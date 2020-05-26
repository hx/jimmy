# frozen_string_literal: true

require 'jimmy/error'
require 'jimmy/version'
require 'jimmy/schema'
require 'jimmy/macros'
require 'jimmy/file_map'
require 'jimmy/json_uri'

# Jimmy makes declaring and validating against JSON schemas a piece of cake.
module Jimmy
  ROOT = Pathname(__dir__).parent

  extend Macros
end
