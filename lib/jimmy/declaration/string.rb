# frozen_string_literal: true

module Jimmy
  module Declaration
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

    # Set the pattern for a string value.
    # @param [Regexp] expression The pattern for a string value. Cannot include
    #   any options such as +/i+.
    # @return [self] self, for chaining
    def pattern(expression)
      assert_regexp expression
      string
      set pattern: expression.source
    end

    # TODO: YARD
    FORMATS.each do |format|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{format.gsub '-', '_'}
          string
          format '#{format}'
        end
      RUBY
    end
  end
end
