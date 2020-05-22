# frozen_string_literal: true

module Jimmy
  class Error < StandardError
    class InvalidSchemaPropertyValue < self; end
    class InvalidJsonPointerPath < self; end
  end
end
