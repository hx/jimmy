# frozen_string_literal: true

module Jimmy
  class Error < StandardError
    class InvalidSchemaPropertyValue < self; end
  end

  class ArgumentError < Error; end
  class LoadError < Error; end
  class NotImplementedError < Error; end
  class TypeError < Error; end
end
