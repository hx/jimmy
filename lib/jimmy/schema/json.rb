# frozen_string_literal: true

module Jimmy
  class Schema
    # The JSON Schema draft 7 schema URI
    SCHEMA = 'http://json-schema.org/draft-07/schema#'

    # Get the schema as a plain Hash. Given an +id+, the +$id+ and +$schema+
    # keys will also be set.
    # @param [JsonURI, URI, String] id
    # @return [Hash, true, false]
    def as_json(id: '', index: nil)
      id = JsonURI.new(id)

      if index.nil? && id.absolute?
        return top_level_json(id) { super index: {}, id: id }
      end

      return true if anything?
      return false if nothing?

      super index: index || {}, id: id
    end

    private

    def top_level_json(id)
      hash = {
        '$id'     => id.to_s,
        '$schema' => SCHEMA
      }
      if nothing?
        hash['not'] = true
      else
        hash.merge! yield
      end
      hash
    end
  end
end
