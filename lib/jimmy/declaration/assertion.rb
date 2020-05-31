# frozen_string_literal: true

require 'jimmy/error'

module Jimmy
  module Declaration
    BOOLEANS = Set.new([true, false]).freeze

    private

    def assert(condition = false)
      raise Error::InvalidSchemaPropertyValue, yield unless condition
    end

    def assert_numeric(value, minimum: -Float::INFINITY)
      assert(value.is_a? Numeric) { "Expected #{value.class} to be numeric" }
      assert(value >= minimum) { "Expected #{value} to be at least #{minimum}" }
    end

    def assert_string(value)
      assert(value.is_a? String) { "Expected #{value.class} to be a string" }
    end

    def assert_simple_type(value)
      assert_string value
      assert SIMPLE_TYPES.include?(value) do
        "Expected #{value.class} to be one of #{SIMPLE_TYPES.to_a.join ', '}"
      end
    end

    def assert_boolean(value)
      assert BOOLEANS.include? value do
        "Expected #{value.class} to be boolean"
      end
    end

    def assert_array(value, unique: false, minimum: 0)
      assert(value.is_a? Array) { "Expected #{value.class} to be an array" }
      assert(value.uniq == value) { 'Expected a unique array' } if unique
      assert value.length >= minimum do
        "Expected an array of at least #{minimum} item(s)"
      end
    end

    def assert_hash(value)
      assert(value.is_a? Hash) { "Expected #{value.class} to be a hash" }
    end

    def assert_range(value)
      assert(value.is_a? Range) { "Expected #{value.class} to be a range " }
    end

    def assert_regexp(value)
      assert value.is_a? Regexp do
        "Expected #{value.class} to be regular expression"
      end
      assert value.options.zero? do
        "Expected #{value.inspect} not to have any options"
      end
    end

    def valid_for(*types)
      assert type? *types do
        "The property is only valid for #{types.join ', '} schemas"
      end
    end

    # Returns true if one of the given types is an existing type.
    # @param [Array<String>] types The type or types to check.
    # @return [true, false]
    def type?(*types)
      types.each &method(:assert_simple_type)
      existing = get('type', nil)
      if existing.is_a? JsonArray
        (existing.to_a & types).any?
      else
        types.include? existing
      end
    end
  end
end
