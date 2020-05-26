# frozen_string_literal: true

module Jimmy
  class Schema
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

    def cast_key(key)
      case key
      when Regexp
        assert_regexp key
        super key.source
      else
        super
      end
    end
  end
end
