# frozen_string_literal: true

module Jimmy
  class Schema
    # Set whether the array value is required to have unique items.
    # @param [true, false] unique Whether the array value should have unique
    #   items.
    # @return [self] self, for chaining
    def unique_items(unique = true)
      valid_for 'array'
      assert_boolean unique
      set uniqueItems: unique
    end

    alias unique unique_items

    # Set the maximum items for an array value.
    # @param [Numeric] count The maximum items for an array value.
    # @return [self] self, for chaining
    def max_items(count)
      valid_for 'array'
      assert_numeric count, minimum: 0
      set maxItems: count
    end

    # Set the minimum items for an array value.
    # @param [Numeric] count The minimum items for an array value.
    # @return [self] self, for chaining
    def min_items(count)
      valid_for 'array'
      assert_numeric count, minimum: 0
      set minItems: count
    end

    # Set the minimum and maximum items for an array value, using a range.
    # @param [Range, Integer] range The minimum and maximum items for an array
    #   value. If an integer is given, it is taken to be both.
    # @return [self] self, for chaining
    def count(range)
      range = range..range if range.is_a?(Integer)
      assert_range range
      min_items range.min
      max_items range.max unless range.end.nil?
      self
    end

    # Set the schema or schemas for validating items in an array value.
    # @param [Jimmy::Schema, Array<Jimmy::Schema>] schema_or_schemas A schema
    #   or array of schemas for validating items in an array value. If an
    #   array of schemas is given, the first schema will apply to the first
    #   item, and so on.
    # @param [Jimmy::Schema, nil] rest_schema The schema to apply to items with
    #   indexes greater than the length of the first argument. Only applicable
    #   when an array is given for the first argument.
    # @return [self] self, for chaining
    def items(schema_or_schemas, rest_schema = nil)
      if schema_or_schemas.is_a? Array
        item *schema_or_schemas
        set additionalItems: cast_schema(rest_schema) if rest_schema
      else
        match_all_items schema_or_schemas, rest_schema
      end
      self
    end

    # Add a single-item schema, or several, to the +items+ array. Only valid
    # if a match-all schema has not been set.
    # @param [Array<Jimmy::Schema>] single_item_schemas One or more schemas
    #   to add to the existing +items+ array.
    # @return [self] self, for chaining
    def item(*single_item_schemas)
      valid_for 'array'
      assert_array(single_item_schemas, minimum: 1)
      existing = getset('items') { [] }
      assert !existing.is_a?(Schema) do
        'Cannot add individual item schemas after adding a match-all schema'
      end
      single_item_schemas.each do |schema|
        existing << cast_schema(schema)
      end
      self
    end

    private

    def match_all_items(schema, rest_schema)
      valid_for 'array'
      assert(rest_schema.nil?) do
        'You cannot specify an additional items schema when using a '\
          'match-all schema'
      end
      set items: cast_schema(schema)
    end
  end
end
