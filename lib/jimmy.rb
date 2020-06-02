# frozen_string_literal: true

require 'jimmy/error'
require 'jimmy/version'
require 'jimmy/schema'
require 'jimmy/macros'
require 'jimmy/file_map'
require 'jimmy/json/uri'

# Jimmy makes declaring and validating against JSON schemas a piece of cake.
module Jimmy
  ROOT = Pathname(__dir__).parent

  extend Macros

  # @see SchemerFactory#initialize
  def self.schemer(*args, **opts)
    SchemerFactory.new(*args, **opts).schemer
  end

  # Passes +schema+ to +Schema.new+, unless it is already a {Schema}, in which
  # case it is returned unmodified.
  # @param [Schema, Object] schema
  # @return [Schema]
  def self.Schema(schema) # rubocop:disable Naming/MethodName
    schema.is_a?(Schema) ? schema : Schema.new(schema)
  end
end
