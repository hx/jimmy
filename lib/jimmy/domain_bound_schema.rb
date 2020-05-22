# frozen_string_literal: true

module Jimmy
  # Represents a schema that has a named assignment to a domain.
  class DomainBoundSchema
    # The JSON Schema draft 7.0 schema URI
    SCHEMA = 'http://json-schema.org/draft-07/schema#'

    attr_reader :domain, :uri, :schema

    def initialize(domain, uri, schema)
      @domain = domain
      @uri    = uri
      @schema = schema
      freeze
    end

    def as_json(*)
      {
        '$schema' => SCHEMA,
        '$id'     => @uri.to_s
      }.merge(schema.as_json)
    end
  end
end
