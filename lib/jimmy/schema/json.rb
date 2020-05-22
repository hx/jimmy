# frozen_string_literal: true

require 'jimmy/utils'

module Jimmy
  class Schema # rubocop:disable Style/Documentation
    POINTER_SUBS = { '~0' => '~', '~1' => '/' }.freeze

    # Convert the schema to a JSON-serializable hash, compatible with most
    # validators. Use +#to_json+ to generate an actual JSON string.
    # @return [Hash, true, false] A JSON-serializable representation of the
    #   schema.
    def as_json(*, index: nil, path: '')
      return true if anything?
      return false if nothing?

      # TODO: JSON pointer escaping

      index&.each do |k, v|
        # Finds the object-identical schema, returning a reference to it
        # if this schema is not at the path to which the reference will be
        # created (i.e. avoiding self-reference)
        return Schema.new.ref('#' + k).as_json if equal?(v) && k != path
      end

      Utils.as_json @properties, index || index_sub_schemas, path
    end

    def to_json(**opts)
      ::JSON.generate as_json, **opts
    end

    # def relative_path_to(subschema)
    #   return URI.parse('#') if equal? subschema
    #
    #   # TODO: search subschemas of definitions
    #   get('definitions', nil)&.each do |name, schema|
    #     return URI.parse("#/definitions/#{name}") if schema.equal? subschema
    #   end
    # end

    def dig(key, *rest)
      return unless @properties.key? key

      obj = get(key)
      rest.any? ? Utils.dig(obj, *rest) : obj
    end

    alias [] dig

    def get_fragment(json_pointer)
      return self if json_pointer == ''

      assert_string json_pointer
      raise Error::InvalidJsonPointerPath unless json_pointer[0] == '/'

      _, *parts = json_pointer
        .split('/')
        .map { |str| str.gsub /~[01]/, POINTER_SUBS }

      dig *parts
    end

    def index_sub_schemas(parents = [])
      index = { '' => self }
      parents += [self]

      # TODO: JSON pointer escaping?

      @properties.each { |k, v| scan_to_index index, v, "/#{k}", parents }
      index
    end

    private

    def scan_to_index(index, obj, base, parents)
      case obj
      when Hash, Array, Set
        Utils.iterate obj do |k, v|
          scan_to_index index, v, "#{base}/#{k}", parents
        end
      when Schema
        # Only add to the index if the schema isn't already in it. This
        # creates a first-in-best-dressed pattern, whereby if a schema is
        # referenced twice, the first occurrence becomes the one that others
        # reference.
        return if obj.ref? || Utils.contains_object?(parents, obj) ||
                  Utils.contains_object?(index.values, obj)

        obj.index_sub_schemas(parents).each { |k, v| index[base + k] = v }
      end
    end
  end
end
