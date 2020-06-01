# frozen_string_literal: true

require 'jimmy/json/collection'
require 'jimmy/json/pointer'

module Jimmy
  module Json
    # Represents a JSON object that is part of a JSON schema.
    class Hash
      include Collection

      # @param [Hash, ::Hash] hash Items to be merged into the new hash.
      def initialize(hash = {})
        super()
        @members = {}
        merge! hash
      end

      # Set a value in the hash.
      # @param [String, Symbol] key The key to set
      # @param [Object] value The value to set
      def []=(key, value)
        key, value = cast(key, value)
        @members[key] = value
        sort!
      end

      # Fetch a value from the hash.
      # @param [String, Symbol] key Key of the item to fetch
      # @see ::Hash#fetch
      # @return [Object]
      def fetch(key, *args, &block)
        @members.fetch cast_key(key), *args, &block
      end

      # Merge values of another hash into this hash.
      # @param [Hash, ::Hash] hash
      # @return [self]
      def merge!(hash)
        hash.each { |k, v| self[k] = v }
        self
      end

      # Iterate over items in the hash. If a block with a single argument is
      # given, only values will be yielded. Otherwise, keys and values will be
      # yielded.
      # @yieldparam [String] key The key of each item.
      # @yieldparam [Object] member Each item.
      # @return [Enumerable, self] If no block is given, an {::Enumerable} is
      #   returned. Otherwise, +self+ is returned.
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

      # Returns true if the given key is assigned.
      # @param [String, Symbol] key The key to check.
      def key?(key)
        @members.key? cast_key(key)
      end

      # Get an array of all keys in the hash.
      # @return [Array<String>]
      def keys
        @members.keys
      end

      # Get the JSON fragment for the given pointer. Returns nil if the pointer
      # is unmatched.
      # @param [Jimmy::Json::Pointer, String] json_pointer
      # @return [Jimmy::Collection, nil]
      def get_fragment(json_pointer)
        json_pointer = Pointer.new(json_pointer)
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
end
