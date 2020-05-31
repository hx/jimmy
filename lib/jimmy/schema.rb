# frozen_string_literal: true

require 'json'

require 'jimmy/json/hash'
require 'jimmy/declaration'

module Jimmy
  # Represents a schema as defined by http://json-schema.org/draft-07/schema
  class Schema < Json::Hash
    include Declaration

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
      else raise Error::WrongType, "Unexpected #{schema.class}"
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
          raise Error::BadArgument, 'Unsupported JSON schema draft'
      when '$comment' then @comment = value # TODO: something, with this
      else super
      end
    end

    def inspect
      "#<#{self.class} #{super}>"
    end

    # Turns the schema into a reference to another schema. Freezes the schema
    # so that no further changes can be made.
    # @param [Json::URI, URI, String] uri The URI of the JSON schema to
    #   reference.
    # @return [self]
    def ref(uri)
      assert empty? do
        'Reference schemas cannot have other properties: ' +
          keys.join(', ')
      end
      @members['$ref'] = Json::URI.new(uri)
      freeze
    end

    # Make the schema validate nothing (i.e. everything is invalid).
    # @return [self] self
    def nothing
      clear
      @nothing = true
      self
    end

    # Get the URI of the schema to which this schema refers, or nil if the
    # schema is not a reference.
    # @return [Json::URI, nil]
    def target
      self['$ref']
    end

    # Returns true if the schema refers to another schema.
    # @return [true, false]
    def ref?
      key? '$ref'
    end

    alias get fetch

    PROPERTY_SEQUENCE = PROPERTIES.each.with_index.to_h.freeze

    def sort_keys_by(key, _value) # :nodoc:
      PROPERTY_SEQUENCE.fetch(key) { raise KeyError, 'Not a valid schema key' }
    end

    protected

    def schema
      self
    end
  end
end

require 'jimmy/schema/operators'
require 'jimmy/schema/json'
require 'jimmy/schema/casting'
