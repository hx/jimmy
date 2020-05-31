# frozen_string_literal: true

module Jimmy
  module Declaration
    private

    CASTS = {
      TrueClass  => ->(s, _) { s },
      FalseClass => ->(s, _) { s.nothing },
      Regexp     => ->(s, v) { s.string.pattern v },
      Range      => ->(s, v) { s.number.range v }
    }.freeze

    CASTABLE_CLASSES = CASTS.keys.freeze

    # Cast the given value to a usable schema.
    # @param [Object] value
    # @return [Jimmy::Schema]
    def cast_schema(value)
      # TODO
      case value
      when *CASTABLE_CLASSES then apply_cast(Schema.new, value)
      when Schema then value
      else
        assert { "Expected #{value.class} to be a schema" }
      end
    end

    def apply_cast(schema, value)
      CASTS.each do |klass, proc|
        return proc.call schema, value if value.is_a? klass
      end
    end
  end
end
