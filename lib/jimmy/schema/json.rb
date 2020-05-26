# frozen_string_literal: true

require 'jimmy/json_pointer'

module Jimmy
  class Schema
    # The JSON Schema draft 7 schema URI
    SCHEMA = 'http://json-schema.org/draft-07/schema#'

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
        '$schema' => SCHEMA,
        '$id'     => id.to_s
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
