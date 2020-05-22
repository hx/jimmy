# frozen_string_literal: true

module Jimmy
  class Schema # rubocop:disable Style/Documentation
    private

    # Cast the given value to a usable schema.
    # @param [Object] value
    # @return [Jimmy::Schema]
    def cast_schema(value)
      # TODO
      case value
      when true   then ANYTHING
      when false  then NOTHING
      when Regexp then Schema.new.string!.pattern(value)
      when Range  then Schema.new.number!.range(value)
      when Schema then value
      else
        assert { "Expected #{value.class} to be a schema" }
      end
    end

    def cast_hash_key(value)
      case value
      when Symbol
        value.to_s
      when Regexp
        assert_regexp value
        value.source
      else
        assert_string value
        value
      end
    end
  end
end
