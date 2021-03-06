# frozen_string_literal: true

module Jimmy
  class Schema
    # Set the minimum value.
    # @param [Numeric] number The minimum numeric value.
    # @param [true, false] exclusive Whether the value is included in the
    #   minimum.
    # @return [self] self, for chaining
    def minimum(number, exclusive: false)
      set_numeric_boundary 'minimum', number, exclusive
    end

    # Set the exclusive minimum value.
    # @param [Numeric] number The exclusive minimum numeric value.
    # @return [self] self, for chaining
    def exclusive_minimum(number)
      minimum number, exclusive: true
    end

    # Set the maximum value.
    # @param [Numeric] number The maximum numeric value.
    # @param [true, false] exclusive Whether the value is included in the
    #   maximum.
    # @return [self] self, for chaining
    def maximum(number, exclusive: false)
      set_numeric_boundary 'maximum', number, exclusive
    end

    # Set the exclusive maximum value.
    # @param [Numeric] number The exclusive maximum numeric value.
    # @return [self] self, for chaining
    def exclusive_maximum(number)
      maximum number, exclusive: true
    end

    private

    def set_numeric_boundary(name, number, exclusive)
      valid_for 'number', 'integer'
      assert_numeric number
      assert_boolean exclusive
      name = 'exclusive' + name[0].upcase + name[1..] if exclusive
      set name => number
    end
  end
end
