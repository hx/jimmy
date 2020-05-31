# frozen_string_literal: true

require 'jimmy/collection'

module Jimmy
  # Represents an array in a JSON schema.
  class JsonArray < Collection
    KEY_PATTERN = /\A(?:\d|[1-9]\d+)\z/.freeze

    def initialize(array = [])
      super()
      @members = []
      concat array
    end

    def concat(array)
      array = array.to_a if array.is_a? Set
      push *array
    end

    def push(*members)
      @members.concat members.map(&method(:cast_value))
    end

    alias << push

    def each(&block)
      return enum_for :each unless block

      if block.arity == 1
        @members.each { |member| yield member }
      else
        @members.each.with_index { |member, i| yield i, member }
      end
    end

    def length
      @members.length
    end

    def dig(key, *rest)
      key = key.to_i if key.is_a?(String) && key.match?(KEY_PATTERN)
      super key, *rest
    end

    def to_a
      @members.dup
    end

    alias count length
    alias size length

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
