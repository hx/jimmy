# frozen_string_literal: true

require 'jimmy/schema/assertion'
require 'jimmy/schema/casting'
require 'jimmy/schema/declaration/array'
require 'jimmy/schema/declaration/number'
require 'jimmy/schema/declaration/object'
require 'jimmy/schema/declaration/string'
require 'jimmy/schema/declaration/types'
require 'jimmy/schema/declaration/composites'
require 'jimmy/schema/declaration/reference'

module Jimmy
  class Schema
    # Set the title of the schema.
    # @param [String] title The title of the schema.
    # @return [self] self, for chaining
    def title(title)
      assert_string title
      set title: title
    end

    # Set the description of the schema.
    # @param [String] description The description of the schema.
    # @return [self] self, for chaining
    def description(description)
      assert_string description
      set description: description
    end

    # Set the default value for the schema.
    # @param [Object] default The default value for the schema.
    # @return [self] self, for chaining
    def default(default)
      set default: default
    end

    # Set whether the schema is read-only.
    # @param [true, false] is_read_only
    # @return [self] self, for chaining
    def read_only(is_read_only = true)
      assert_boolean is_read_only
      set readOnly: is_read_only
    end

    # Set whether the schema is write-only.
    # @param [true, false] is_write_only
    # @return [self] self, for chaining
    def write_only(is_write_only = true)
      assert_boolean is_write_only
      set writeOnly: is_write_only
    end

    # Set a constant value that will be expected to match exactly.
    # @param [Object] constant_value The value that will be expected to match
    #   exactly.
    # @return [self] self, for chaining
    def const(constant_value)
      set const: constant_value
    end

    # Set an enum value for the schema.
    # @param [Array] allowed_values The allowed values in the enum.
    # @return [self] self, for chaining
    def enum(allowed_values)
      assert_array allowed_values, minimum: 1, unique: true
      set enum: allowed_values
    end

    # Add examples to the schema
    # @param [Array] examples One or more examples to add to the schema.
    # @return [self] self, for chaining
    def examples(*examples)
      getset('examples') { [] }.concat examples
      self
    end

    alias example examples

    # Add a schema to this schema's +definitions+ property.
    # @param [String] name The name of the schema definition.
    # @param [Jimmy::Schema] schema
    # @yieldparam schema [Jimmy::Schema] The defined schema.
    # @return [self] self, for chaining
    def define(name, schema = Schema.new, &block)
      assign_to_schema_hash 'definitions', name, schema, &block
    end

    # Add definitions to the schema's +definitions+ property.
    # @param [Hash{String => Jimmy::Schema, nil}] definitions Definitions to be
    #   added to the schema's +definitions+ property.
    # @yieldparam name [String] The name of a definition that was given a nil
    #   schema.
    # @yieldparam schema [Jimmy::Schema] A new schema created in place of a
    #   nil hash value.
    # @return [self] self, for chaining
    def definitions(definitions, &block)
      batch_assign_to_schema_hash 'definitions', definitions, &block
    end

    # Define the schema that this schema must not match.
    # @param schema [Jimmy::Schema] The schema that must not match.
    # @return [self] self, for chaining
    def not(schema)
      # TODO: combine more nots into an anyOf
      set not: cast_schema(schema)
    end

    # Make the schema validate nothing (i.e. everything is invalid).
    # @return [self] self
    def nothing
      clear
      @nothing = true
      self
    end

    private

    # @return [self]
    def set(props)
      # Trigger a FrozenError on self instead of the properties hash
      @a = 1 if frozen?
      props.each { |k, v| self[k.to_s] = v }
      self
    end

    alias get fetch

    def getset(name)
      set name => yield unless key? name
      get name
    end

    def assign_to_schema_hash(property_name, key, schema)
      property_name = cast_key(property_name)
      key           = cast_key(key)
      hash          = getset(property_name) { {} }
      assert !hash.key?(key) do
        "Property '#{property_name}' already has a member '#{key}'"
      end
      schema = cast_schema(schema)
      yield schema if block_given?
      hash[key] = schema
      self
    end

    def batch_assign_to_schema_hash(property_name, hash)
      assert_hash hash
      hash.each do |name, schema|
        name = cast_key(name)
        if schema.nil? && block_given?
          schema = Schema.new
          yield name, schema
        end
        assign_to_schema_hash property_name, name, schema
      end
      self
    end
  end
end
