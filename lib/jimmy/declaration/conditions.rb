# frozen_string_literal: true

module Jimmy
  module Declaration
    # Define the schema that determines whether the +then+ or +else+ schemas
    # must be valid.
    # @param schema [Schema] The +if+ schema.
    # @param then_schema [Schema] The +then+ schema.
    # @param else_schema [Schema] The +else+ schema.
    # @return [self] self, for chaining
    def if(schema, then_schema = nil, else_schema = nil)
      set(if: cast_schema(schema)).tap do |s|
        s.then then_schema unless then_schema.nil?
        s.else else_schema unless else_schema.nil?
      end
    end
  end
end
