# frozen_string_literal: true

module Jimmy
  # Represents a schema with a URI.
  class SchemaWithURI
    # @return [Json::URI]
    attr_reader :uri
    # @return [Schema]
    attr_reader :schema

    # @param [URI, String, Json::URI] uri
    # @param [Schema] schema
    def initialize(uri, schema)
      @uri    = Json::URI.new(uri)
      @schema = schema
      freeze
    end

    # @return [Hash{String => Object}]
    def as_json(*)
      @schema.as_json id: @uri
    end

    # @return [String]
    def to_json(**opts)
      ::JSON.generate as_json, **opts
    end

    # Returns true if +other+ has a matching URI and Schema.
    # @param [SchemaWithURI] other
    # @return [true, false]
    def ==(other)
      other.is_a?(self.class) && uri == other.uri && schema == other.schema
    end

    # Attempt to resolve URI using {#schema}. This will only succeed if +uri+
    # represents a fragment of {#schema}.
    # @raise [Error::BadArgument] Raised if the URI is outside {#uri}.
    # @param [String, URI, Json::URI] uri
    # @return [SchemaWithURI, nil]
    def resolve(uri)
      uri = Json::URI.new(uri)
      raise Error::BadArgument, 'Cannot resolve relative URIs' if uri.relative?
      raise Error::BadArgument, 'Wrong URI base' unless uri + '#' == @uri + '#'

      pointer = uri.pointer.remove_prefix(@uri.pointer) or return

      return unless (fragment = @schema.get_fragment(pointer))

      self.class.new uri, fragment
    end
  end
end
