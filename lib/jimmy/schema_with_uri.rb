# frozen_string_literal: true

module Jimmy
  # Represents a schema with a URI.
  class SchemaWithURI
    attr_reader :uri, :schema

    def initialize(uri, schema)
      @uri    = Json::URI.new(uri)
      @schema = schema
      freeze
    end

    def as_json(*)
      @schema.as_json id: @uri
    end

    def to_json(**opts)
      ::JSON.generate as_json, **opts
    end

    def ==(other)
      other.is_a?(self.class) && uri == other.uri && schema == other.schema
    end

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
