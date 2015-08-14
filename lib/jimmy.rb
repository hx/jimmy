require 'pathname'
require 'jimmy/version'

module Jimmy
    ROOT = Pathname(__FILE__).parent.parent
end

require_relative 'jimmy/symbol_array'

require_relative 'jimmy/domain'
require_relative 'jimmy/schema'
require_relative 'jimmy/reference'
require_relative 'jimmy/type_reference'
require_relative 'jimmy/schema_creation'
require_relative 'jimmy/schema_types'
require_relative 'jimmy/schema_type'
require_relative 'jimmy/combination'
require_relative 'jimmy/validation_error'
require_relative 'jimmy/definitions'
