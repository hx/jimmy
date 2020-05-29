# frozen_string_literal: true

require 'jimmy/schema/declaration/types'

module Jimmy
  # The +Macros+ module includes methods that can be called directly on the
  # +Jimmy+ module for quickly making common types of schemas.
  module Macros
    # Make a new schema. Shortcut for +Schema.new+.
    # @yieldparam schema [Schema] The new schema
    # @return [Schema] The new schema.
    def schema(&block)
      Schema.new &block
    end

    # @!method array
    #   Create a schema with 'type' => 'array'
    #   @return [Jimmy::Schema] The new schema.
    # @!method boolean
    #   Create a schema with 'type' => 'boolean'
    #   @return [Jimmy::Schema] The new schema.
    # @!method integer
    #   Create a schema with 'type' => 'integer'
    #   @return [Jimmy::Schema] The new schema.
    # @!method null
    #   Create a schema with 'type' => 'null'
    #   @return [Jimmy::Schema] The new schema.
    # @!method number
    #   Create a schema with 'type' => 'number'
    #   @return [Jimmy::Schema] The new schema.
    # @!method object
    #   Create a schema with 'type' => 'object'
    #   @return [Jimmy::Schema] The new schema.
    # @!method string
    #   Create a schema with 'type' => 'string'
    #   @return [Jimmy::Schema] The new schema.
    Schema::SIMPLE_TYPES.each do |type|
      module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{type}
          schema.#{type}
        end
      RUBY
    end

    # TODO: YARD
    Schema::FORMATS.each do |format|
      format = format.gsub('-', '_')
      module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{format}
          schema.#{format}
        end
      RUBY
    end

    # Make an object schema that does not allow additional properties. Any
    # properties given as arguments will be required.
    # @param [Hash{Symbol, String => Jimmy::Schema, nil}]
    #   required_properties
    # @yieldparam name [String] The name of a property that was given with a nil
    #   schema.
    # @yieldparam schema [Jimmy::Schema] A new schema created for a property
    #   that was given without one.
    # @return [Jimmy::Schema] The new schema.
    def struct(required_properties = {}, &block)
      object.additional_properties(false).tap do |s|
        s.require required_properties, &block if required_properties.any?
      end
    end

    # @see Schema#const
    def const(value)
      schema.const value
    end

    # @see Schema#ref
    def ref(uri)
      schema.ref uri
    end
  end
end
