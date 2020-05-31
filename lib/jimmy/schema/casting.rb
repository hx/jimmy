# frozen_string_literal: true

module Jimmy
  class Schema
    private

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
