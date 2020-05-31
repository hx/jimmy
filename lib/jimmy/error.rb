# frozen_string_literal: true

module Jimmy
  class Error < StandardError
    class InvalidSchemaPropertyValue < self; end
    class WrongType < self; end
    class BadArgument < self; end
  end
end
