# frozen_string_literal: true

module Jimmy
  class Schema
    # Define the schema that must be valid if the +if+ schema is valid.
    # @param schema [Jimmy::Schema] The +then+ schema.
    # @return [self] self, for chaining
    def then(schema)
      set then: cast_schema(schema)
    end

    # Define the schema that must be valid if the +if+ schema is not valid.
    # @param schema [Jimmy::Schema] The +else+ schema.
    # @return [self] self, for chaining
    def else(schema)
      set else: cast_schema(schema)
    end
  end
end
