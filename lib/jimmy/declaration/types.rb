# frozen_string_literal: true

module Jimmy
  module Declaration
    # Acceptable values for +#type+.
    SIMPLE_TYPES =
      Set.new(%w[array boolean integer null number object string]).freeze

    # Set the type(s) of the schema.
    # @param [String, Array<String>] types The type(s) of the schema.
    # @return [self] self, for chaining
    def type(*types)
      types = types.flatten
      types.each &method(:assert_simple_type)
      assert_array types, unique: true, minimum: 1
      types = Array(get('type') { [] }) | types.flatten
      types = types.first if types.one?
      set type: types
    end

    alias types type

    # @!method array
    #   Add 'array' to the schema types.
    #   @return [Jimmy::Schema] self, for chaining
    # @!method boolean
    #   Add 'boolean' to the schema types.
    #   @return [Jimmy::Schema] self, for chaining
    # @!method integer
    #   Add 'integer' to the schema types.
    #   @return [Jimmy::Schema] self, for chaining
    # @!method null
    #   Add 'null' to the schema types.
    #   @return [Jimmy::Schema] self, for chaining
    # @!method number
    #   Add 'number' to the schema types.
    #   @return [Jimmy::Schema] self, for chaining
    # @!method object
    #   Add 'object' to the schema types.
    #   @return [Jimmy::Schema] self, for chaining
    # @!method string
    #   Add 'string' to the schema types.
    #   @return [Jimmy::Schema] self, for chaining
    SIMPLE_TYPES.each do |type|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{type}
          type '#{type}'
        end
      RUBY
    end

    alias nullable null
  end
end
