# frozen_string_literal: true

module Jimmy
  class Schema
    FORMATS = Set.new(
      %w[
        date-time
        date
        time
        email
        idn-email
        hostname
        idn-hostname
        ipv4
        ipv6
        uri
        uri-reference
        iri
        iri-reference
        uri-template
        json-pointer
        relative-json-pointer
        regex
      ]
    ).freeze

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

    # Set the pattern for a string value.
    # @param [Regexp] expression The pattern for a string value. Cannot include
    #   any options such as +/i+.
    # @return [self] self, for chaining
    def pattern(expression)
      valid_for 'string'
      assert_regexp expression
      set pattern: expression.source
    end

    # Set the format for a string value.
    # @param [String] format_name The named format for a string value.
    # @return [self] self, for chaining
    def format(format_name)
      valid_for 'string'
      assert_string format_name
      set format: format_name
    end

    # TODO: YARD
    FORMATS.each do |format|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{format.gsub '-', '_'}!
          string!
          format '#{format}'
        end
      RUBY
    end
  end
end
