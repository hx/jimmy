# frozen_string_literal: true

module Jimmy
  # Contains a helper function for preparing objects to be serialized as JSON.
  module Utils
    # TODO: find homes for all these functions

    # @return [Hash, Array, String, Numeric, true, false, nil]
    def as_json(object, index, path)
      case object
      when Hash
        object.to_h { |k, v| [k.to_s, as_json(v, index, "#{path}/#{k}")] }
      when Array, Set
        object.map.with_index { |v, i| as_json v, index, "#{path}/#{i}" }
      when URI then object.to_s
      when Schema then object.as_json index: index, path: path
      else
        object.respond_to?(:as_json) ? object.as_json : object
      end
    end

    # Iterate over any Hash, Array, or Set, yielding keys or indexes first, and
    # hash values or members second.
    # @param [Hash, Array, Set] enumerable The Hash, Array, or Set through which
    #   to iterate.
    # @yieldparam [Object] key Hash keys or array/set indexes.
    # @yieldparam [Object] value Hash values or array/set items.
    # @return [Enumerable] An enumerator if no block is given.
    def iterate(enumerable)
      if block_given?
        case enumerable
        when Hash       then enumerable.each            { |k, v| yield k, v }
        when Array, Set then enumerable.each.with_index { |v, i| yield i, v }
        else raise TypeError
        end
      end

      enum_for :iterate, enumerable
    end

    # Returns +true+ if +haystack+ contains +needle+ based on object equality
    # checking (using +Object#equal?+).
    # @param [Enumerable] haystack Any enumerable responding to +#any?+.
    # @param [Object] needle The required object.
    # @return [true, false]
    def contains_object?(haystack, needle)
      haystack.any? { |obj| obj.equal? needle }
    end

    def dig(obj, key, *rest)
      value =
        case obj
        when Hash, Array then obj[key]
        when Set then obj.to_a[key]
        when Schema then obj.dig(key)
        else return
        end
      rest.any? ? dig(value, *rest) : value
    end

    module_function :as_json, :iterate, :contains_object?, :dig
  end
end
