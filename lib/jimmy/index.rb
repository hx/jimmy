# frozen_string_literal: true

require 'jimmy/schema'
require 'jimmy/schema_with_uri'

module Jimmy
  # Represents an in-memory collection of schemas
  class Index
    include Enumerable

    def initialize # rubocop:disable Style/DocumentationMethod
      @by_uri = {}
    end

    # @param [Json::URI, URI, String] uri
    # @return [Jimmy::SchemaWithURI, nil]
    def resolve(uri)
      uri = Json::URI.new(uri)
      raise Error::BadArgument, 'Cannot resolve relative URIs' if uri.relative?

      return @by_uri[uri] if @by_uri.key? uri
      return if uri.pointer.empty?

      resolve(uri / -1)&.resolve uri
    end

    alias [] resolve

    # @param [Json::URI, URI, String] uri
    # @param [Jimmy::Schema] schema
    # @return [self] self, for chaining
    def add(uri, schema)
      uri = Json::URI.new(uri)
      raise Error::BadArgument, 'Expected a schema' unless schema.is_a? Schema
      raise Error::BadArgument, 'Cannot index relative URIs' if uri.relative?

      push SchemaWithURI.new(uri, schema)
    end

    alias []= add

    # @param [Array<Jimmy::SchemaWithURI>] schemas_with_uris
    # @return [self]
    def push(*schemas_with_uris)
      schemas_with_uris.each do |schema_with_uri|
        unless schema_with_uri.is_a? SchemaWithURI
          raise Error::BadArgument, 'Expected a SchemaWithURI'
        end

        @by_uri[schema_with_uri.uri] = schema_with_uri
      end
      self
    end

    alias << push

    # @return [Array<Json::URI>]
    def uris
      @by_uri.keys
    end

    alias keys uris

    # @param [Json::URI, URI, String] uri
    # @return [true, false]
    def uri?(uri)
      !resolve(uri).nil?
    end

    alias key? uri?
    alias has_key? key?

    # @yieldparam [Jimmy::SchemaWithURI] schema_with_uri
    def each(&block)
      @by_uri.each_value &block
    end
  end
end
