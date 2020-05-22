# frozen_string_literal: true

module Jimmy
  # Represents a schema reference
  class Reference
    # The URI of the reference.
    # @return [URI]
    attr_reader :uri

    def initialize(uri)
      uri = URI.parse(uri) unless uri.is_a? URI
      @uri = uri
    end

    def as_json(*)
      { '$ref' => uri.to_s }
    end
  end
end
