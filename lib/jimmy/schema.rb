# frozen_string_literal: true

require 'json'

require 'jimmy/json_hash'

module Jimmy
  # Represents a schema as defined by http://json-schema.org/draft-07/schema
  class Schema < JsonHash
    PROPERTIES = %w[
      title description default readOnly writeOnly examples
      multipleOf maximum exclusiveMaximum minimum exclusiveMinimum
      maxLength minLength pattern
      additionalItems items maxItems minItems uniqueItems contains
      maxProperties minProperties required additionalProperties
      definitions properties patternProperties dependencies propertyNames
      const enum type format
      contentMediaType contentEncoding
      if then else
      allOf anyOf oneOf
      not
    ].freeze

    # @yieldparam schema [self] The new schema
    def initialize(schema = {})
      @nothing = false
      case schema
      when *CASTABLE_CLASSES
        super({})
        apply_cast self, schema
      when Hash then super
      else raise TypeError, "Unexpected #{schema.class}"
      end
      yield self if block_given?
    end

    # Returns true when the schema will never validate against anything.
    # @return [true, false]
    def nothing?
      @nothing
    end

    # Returns true when the schema will validate against anything.
    # @return [true, false]
    def anything?
      !@nothing && empty?
    end

    def []=(key, value)
      @nothing = false

      case key
      when '$id' then @id = value # TODO: something, with this
      when '$ref' then ref value
      when '$schema'
        URI(value) == URI(SCHEMA) or
          raise ArgumentError, 'Unsupported JSON schema draft'
      when '$comment' then @comment = value # TODO: something, with this
      else super
      end
    end

    def inspect
      "#<#{self.class} #{super}>"
    end

    PROPERTY_SEQUENCE = PROPERTIES.each.with_index.to_h.freeze

    def sort_keys_by(key, _value) # :nodoc:
      PROPERTY_SEQUENCE.fetch(key) { raise KeyError, 'Not a valid schema key' }
    end
  end
end

require 'jimmy/schema/declaration'
require 'jimmy/schema/operators'
require 'jimmy/schema/json'
