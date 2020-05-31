# frozen_string_literal: true

module Jimmy
  module Json
    # Common methods for {Hash} and {Array}
    module Collection
      include Enumerable

      # Serialize the collection as JSON.
      def to_json(**opts)
        ::JSON.generate as_json, **opts
      end

      # @see Object#inspect
      def inspect
        to_json
      end

      # Returns true if the collection has no members.
      # @return [true, false]
      def empty?
        @members.empty?
      end

      # Freeze the collection.
      # @return [self]
      def freeze
        @members.freeze
        super
      end

      # Get the member of the collection assigned to the given key.
      def [](key)
        @members[cast_key(key)]
      end

      # @see Hash#dig
      def dig(key, *rest)
        obj = self[cast_key(key)]
        return obj if obj.nil? || rest.empty?

        obj.dig(*rest)
      end

      # Transform the collection into plain JSON-compatible objects.
      # @return [Hash, Array]
      def as_json(id: '', index: {})
        return index[object_id].as_json(id: id, index: {}) if index[object_id]

        id = Json::URI.new(id)
        index[object_id] = Jimmy.ref(id)

        pairs = map do |key, value|
          if value.respond_to? :as_json
            value = value.as_json(id: id / key, index: index)
          end
          [key, value]
        end

        export_pairs pairs
      end

      # Removes all members.
      # @return [self]
      def clear
        @members.clear
        self
      end

      protected

      def cast_value(value)
        case value
        when nil, true, false, Numeric, String, Collection then value
        when ::Hash then Hash.new(value)
        when ::Array, Set then Array.new(value)
        else
          unless value.respond_to? :as_json
            raise Error::WrongType, "Incompatible JSON type #{value.class}"
          end

          value.as_json
        end
      end
    end
  end
end

require 'jimmy/json/array'
require 'jimmy/json/hash'