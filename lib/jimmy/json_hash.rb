# frozen_string_literal: true

require 'jimmy/collection'

module Jimmy
  # Represents a JSON object that is part of a JSON schema.
  class JsonHash < Collection
    def initialize(hash = {})
      super()
      @members = {}
      merge! hash
    end

    def []=(key, value)
      key, value = cast(key, value)
      @members[key] = value
      sort!
    end

    def fetch(key, *args, &block)
      @members.fetch cast_key(key), *args, &block
    end

    def merge!(hash)
      hash.each { |k, v| self[k] = v }
      self
    end

    def each(&block)
      return enum_for :each unless block

      @members.each do |key, value|
        if block.arity == 1
          yield value
        else
          yield key, value
        end
      end
    end

    def key?(key)
      @members.key? cast_key(key)
    end

    def keys
      @members.keys
    end

    # @param [Jimmy::JsonPointer, String] json_pointer
    # @return [Jimmy::Collection, nil]
    def get_fragment(json_pointer)
      json_pointer = JsonPointer.new(json_pointer)
      return self if json_pointer.empty?

      dig *json_pointer.to_a
    end

    protected

    def export_pairs(pairs)
      pairs.to_h
    end

    def sort!
      return unless respond_to? :sort_keys_by

      @members = @members.sort do |a, b|
        sort_keys_by(*a) <=> sort_keys_by(*b)
      end.to_h
    end

    def cast(key, value)
      [
        cast_key(key),
        cast_value(value)
      ]
    end

    def cast_key(key)
      key = key.to_s.gsub(/_(.)/) { $1.upcase } if key.is_a? Symbol

      unless key.is_a? String
        raise Error::WrongType, "Invalid hash key of type #{key.class}"
      end

      key.strip
    end
  end
end
