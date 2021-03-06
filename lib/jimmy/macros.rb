# frozen_string_literal: true

require 'jimmy/declaration'

module Jimmy
  # The +Macros+ module includes methods that can be called directly on the
  # +Jimmy+ module for quickly making common types of schemas.
  module Macros
    include Declaration

    # Make a new schema. Shortcut for +Schema.new+.
    # @yieldparam schema [Schema] The new schema
    # @return [Schema] The new schema.
    def schema(&block)
      Schema.new &block
    end

    # Make a schema that never validates.
    # @return [Schema] The new schema.
    def nothing
      schema.nothing
    end

    # Make a schema that references another schema by URI.
    # @param [String, URI, Json::URI] uri
    # @return [Schema] The new schema.
    def ref(uri)
      schema.ref uri
    end

    private

    def get(*args, &block)
      {}.fetch(*args, &block)
    end
  end
end
