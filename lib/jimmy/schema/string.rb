module Jimmy
  class Schema
    # Set the maximum length for a string value.
    # @param [Numeric] length The maximum length for a string value.
    # @return [self] self, for chaining
    def max_length(length)
      valid_for 'string'
      assert_numeric length, minimum: 0
      set maxLength: length
    end

    # Set the minimum length for a string value.
    # @param [Numeric] length The minimum length for a string value.
    # @return [self] self, for chaining
    def min_length(length)
      valid_for 'string'
      assert_numeric length, minimum: 0
      set minLength: length
    end

    # Set the minimum and maximum length for a string value, using a range.
    # @param [Range, Integer] range The minimum and maximum length for a string
    #   value. If an integer is given, it is taken to be both.
    # @return [self] self, for chaining
    def length(range)
      range = range..range if range.is_a?(Integer)
      assert_range range
      min_length range.min
      max_length range.max unless range.end.nil?
      self
    end

    # Set the format for a string value.
    # @param [String] format_name The named format for a string value.
    # @return [self] self, for chaining
    def format(format_name)
      valid_for 'string'
      assert_string format_name
      set format: format_name
    end
  end
end
