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

    # TODO: More YARD

    def method_missing(name, *args, &block)
      return super unless Schema.new.respond_to? name

      Macros.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}(*args)
          schema = Schema.new
          schema.#{name} *args
          yield schema if block_given? && args.none?
          schema
        end
      RUBY

      __send__ name, *args, &block
    end

    def respond_to_missing?(name, *)
      Schema.new.respond_to? name or super
    end
  end
end
