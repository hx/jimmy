# frozen_string_literal: true

module Jimmy
  module Declaration
    # Set the +anyOf+ value for the schema.
    # @param [Array<Jimmy::Schema>] schemas The schemas to set as the value of
    #   +anyOf+.
    # @return [self] self, for chaining
    def any_of(*schemas)
      set_composite 'anyOf', schemas.flatten
    end

    # Set the +allOf+ value for the schema.
    # @param [Array<Jimmy::Schema>] schemas The schemas to set as the value of
    #   +allOf+.
    # @return [self] self, for chaining
    def all_of(*schemas)
      set_composite 'allOf', schemas.flatten
    end

    # Set the +oneOf+ value for the schema.
    # @param [Array<Jimmy::Schema>] schemas The schemas to set as the value of
    #   +oneOf+.
    # @return [self] self, for chaining
    def one_of(*schemas)
      set_composite 'oneOf', schemas.flatten
    end

    private

    # @return [self]
    def set_composite(name, schemas)
      assert_array schemas, minimum: 1
      schemas = schemas.map(&method(:cast_schema))
      assert schemas.none? { |s| s.anything? || s.nothing? } do
        'Absolutes make no sense in composites'
      end
      set name => schemas
    end
  end
end
