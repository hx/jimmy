# frozen_string_literal: true

require 'json'

require 'jimmy/schema/declaration'
require 'jimmy/schema/operators'
require 'jimmy/schema/json'

module Jimmy
  # Represents a schema as defined by http://json-schema.org/draft-07/schema
  class Schema
    # Import an existing JSON schema hash and represent it as an instance of
    # +Jimmy::Schema+.
    # @param [Hash, true, false] schema The plain schema to import.
    # @return [Jimmy::Schema]
    def self.from_json(schema)
      case schema
      when true then ANYTHING
      when false then NOTHING
      when Hash
        new.instance_exec do
          @properties = JSON.as_json(schema)
          freeze
        end
      else raise TypeError, "Unexpected #{schema.class}"
      end
    end

    # @yieldparam schema [self] The new schema
    def initialize
      @nothing = false
      @properties = {}
      yield self if block_given?
    end

    # @see Object#freeze
    def freeze
      @properties.freeze
      super
    end

    # A schema representing +true+.
    # @type [Schema]
    ANYTHING = new.freeze

    # A schema representing +false+.
    # @type [Schema]
    NOTHING = new.nothing!

    # Returns true when the schema will never validate against anything.
    # @return [true, false]
    def nothing?
      @nothing
    end

    # Returns true when the schema will validate against anything.
    # @return [true, false]
    def anything?
      !@nothing && @properties.empty?
    end

    def inspect
      "#<#{self.class} #{as_json.inspect}>"
    end
  end
end
