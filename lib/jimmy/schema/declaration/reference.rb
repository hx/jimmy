# frozen_string_literal: true

module Jimmy
  class Schema # rubocop:disable Style/Documentation
    # Turns the schema into a reference to another schema. Freezes the schema
    # so that no further changes can be made.
    # @param [URI, String] uri The URI of the JSON schema to reference.
    # @return [self]
    def ref(uri)
      assert @properties.empty? do
        'Reference schemas cannot have other properties: ' +
          @properties.keys.join(', ')
      end
      uri = URI.parse(uri) if uri.is_a? String
      set '$ref' => uri
      freeze
    end

    # Get the URI of the schema to which this schema refers, or nil if the
    # schema is not a reference.
    # @return [URI, nil]
    def uri
      @properties['$ref']
    end

    # Returns true if the schema refers to another schema.
    # @return [true, false]
    def ref?
      @properties.key? '$ref'
    end
  end
end
