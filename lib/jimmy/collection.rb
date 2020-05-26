# frozen_string_literal: true

module Jimmy
  # Base class for +JsonHash+ and +JsonArray+.
  class Collection
    include Enumerable

    def to_json(**opts)
      ::JSON.generate as_json, **opts
    end

    def inspect
      to_json
    end

    def empty?
      @members.empty?
    end

    def freeze
      @members.freeze
      super
    end

    def [](key)
      @members[cast_key(key)]
    end

    def dig(key, *rest)
      obj = self[cast_key(key)]
      return obj if obj.nil? || rest.empty?

      obj.dig(*rest)
    end

    def as_json(id: '', index: {})
      return { '$ref' => index[object_id].to_s } if index.key? object_id

      index[object_id] = id = JsonURI.new(id)

      pairs = map do |key, value|
        if value.respond_to? :as_json
          value = value.as_json(id: id / key, index: index)
        end
        [key, value]
      end

      export_pairs pairs
    end

    def clear
      @members.clear
      self
    end

    protected

    def cast_value(value)
      case value
      when nil, true, false, Numeric, String, Collection then value
      when Hash then JsonHash.new(value)
      when Array, Set then JsonArray.new(value)
      else
        unless value.respond_to? :as_json
          raise TypeError, "Incompatible JSON type #{value.class}"
        end

        value.as_json
      end
    end
  end
end

require 'jimmy/json_array'
require 'jimmy/json_hash'
