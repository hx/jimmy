# frozen_string_literal: true

require 'jimmy/json/collection'

module Jimmy
  module Json
    # Represents an array in a JSON schema.
    class Array
      include Collection

      KEY_PATTERN = /\A(?:\d|[1-9]\d+)\z/.freeze

      # @param [Array, ::Array, Set] array Items to be included in the array.
      def initialize(array = [])
        super()
        @members = []
        concat array
      end

      # Append items in +array+ to self.
      # @param [Array, ::Array, Set] array
      # @return [self]
      def concat(array)
        array = array.to_a if array.is_a? Set
        push *array
      end

      # Add one or more items to self.
      # @param [Array] members Things to add.
      # @return [self]
      def push(*members)
        @members.concat members.map(&method(:cast_value))
        self
      end

      alias << push

      # Assign a member to the array at the given index.
      # @param [Integer] index
      # @param [Object] value
      def []=(index, value)
        @members[index] = cast_value(value)
      end

      # Iterate over items in the array. If a block with a single argument is
      # given, only values will be yielded. Otherwise, indexes and values will
      # be yielded.
      # @yieldparam [Integer] index The index of each item.
      # @yieldparam [Object] member Each item.
      # @return [Enumerable, self] If no block is given, an {::Enumerable} is
      #   returned. Otherwise, +self+ is returned.
      def each(&block)
        return enum_for :each unless block

        if block.arity == 1
          @members.each { |member| yield member }
        else
          @members.each.with_index { |member, i| yield i, member }
        end
        self
      end

      # @return [Integer] The length of the array.
      def length
        @members.length
      end

      # Dig into the array.
      # @param [Integer] key Index of the item to be dug or returned.
      # @param [Array<String, Integer>] rest Keys or indexes to be passed to
      #   resolved hashes/arrays.
      def dig(key, *rest)
        key = key.to_i if key.is_a?(String) && key.match?(KEY_PATTERN)
        super key, *rest
      end

      # @return [Array] Get a regular array.
      def to_a
        @members.dup
      end

      alias count length
      alias size length

      # Returns true if the array contains the given +obj+.
      # @param [Object] obj
      # @return [true, false]
      def include?(obj)
        @members.include? obj
      end

      protected

      def export_pairs(pairs)
        pairs.map &:last
      end

      def cast_key(key)
        unless key.is_a? Integer
          raise Error::WrongType, "Invalid array index of type #{key.class}"
        end

        key
      end
    end
  end
end
