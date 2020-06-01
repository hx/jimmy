# frozen_string_literal: true

module Jimmy
  module Declaration
    # Set the number of which the value should be a multiple.
    # @param [Numeric] number The number to set as the multipleOf value
    # @return [self] self, for chaining
    def multiple_of(number)
      valid_for 'number', 'integer'
      assert_numeric number
      assert(number.positive?) { "Expected #{number} to be positive" }
      set multipleOf: number
    end

    # Set minimum and maximum by providing a range.
    # @param [Range] range The range to use for minimum and maximum values.
    # @return [self] self, for chaining
    def range(range)
      assert_range range
      schema do |s|
        s.type range.begin.is_a?(Integer) ? 'integer' : 'number'
        s.minimum range.begin
        s.maximum range.end, exclusive: range.exclude_end? unless range.end.nil?
      end
    end
  end
end
