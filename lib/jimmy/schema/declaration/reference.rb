# frozen_string_literal: true

module Jimmy
  class Schema
    # Turns the schema into a reference to another schema. Freezes the schema
    # so that no further changes can be made.
    # @param [JsonURI, URI, String] uri The URI of the JSON schema to reference.
    # @return [self]
    def ref(uri)
      assert empty? do
        'Reference schemas cannot have other properties: ' +
          keys.join(', ')
      end
      @members['$ref'] = JsonURI.new(uri)
      freeze
    end

    # Get the URI of the schema to which this schema refers, or nil if the
    # schema is not a reference.
    # @return [JsonURI, nil]
    def target
      self['$ref']
    end

    # Returns true if the schema refers to another schema.
    # @return [true, false]
    def ref?
      key? '$ref'
    end
  end
end
