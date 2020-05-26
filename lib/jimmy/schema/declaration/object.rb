# frozen_string_literal: true

module Jimmy
  class Schema
    # Define a property for an object value.
    # @param [String, Symbol] name The name of the property.
    # @param [Jimmy::Schema] schema The schema for the property. If
    #   omitted, a new Schema will be created, and will be yielded if a block
    #   is given.
    # @param [true, false] required If true, +name+ will be added to the
    #   +required+ property.
    # @yieldparam schema [Jimmy::Schema] The schema being assigned.
    # @return [self] self, for chaining
    def property(name, schema = Schema.new, required: false, &block)
      valid_for 'object'
      collection = collection_for_property_key(name)
      assign_to_schema_hash collection, name, schema, &block
      require name if required
      self
    end

    # Define properties for an object value.
    # @param [Hash{String, Symbol => Jimmy::Schema, nil}] properties
    # @param [true, false] required If true, literal (non-pattern) properties
    #   will be added to the +required+ property.
    # @yieldparam name [String] The name of a property that was given with a nil
    #   schema.
    # @yieldparam schema [Jimmy::Schema] A new schema created for a property
    #   that was given without one.
    # @return [self] self, for chaining
    def properties(properties, required: false, &block)
      valid_for 'object'
      assert_hash properties
      groups = properties.group_by { |k, _| collection_for_property_key k }
      groups.each do |collection, pairs|
        batch_assign_to_schema_hash collection, pairs.to_h, &block
      end
      require *properties.keys if required
      self
    end

    # Designate the given properties as required for object values.
    # @param [Array<String, Symbol, Hash{String, Symbol => Jimmy::Schema, nil}>]
    #   properties Names of properties that are required, or hashes that can be
    #   passed to +#properties+, and whose keys will also be added to the
    #   +required+ property.
    # @yieldparam name [String] The name of a property that was given with a nil
    #   schema.
    # @yieldparam schema [Jimmy::Schema] A new schema created for a property
    #   that was given without one.
    # @return [self] self, for chaining
    def require(*properties, &block)
      properties.each do |name|
        if name.is_a? Hash
          self.properties name, required: true, &block
        else
          getset('required') { Set.new } << validate_property_name(name)
        end
      end
      self
    end

    # Require all properties that have been explicitly defined for object
    #   values.
    # @return [self] self, for chaining
    def require_all
      require *get('properties') { {} }.keys
    end

    # Set the schema for additional properties not matching those given to
    # +#require+, +#property+, and +#properties+. Pass +false+ to disallow
    # additional properties.
    # @param [Jimmy::Schema, true, false] schema
    # @return [self] self, for chaining
    def additional_properties(schema)
      set additionalProperties: cast_schema(schema)
    end

    private

    def collection_for_property_key(key)
      if key.is_a? Regexp
        'patternProperties'
      else
        'properties'
      end
    end

    def validate_property_name(name)
      name = cast_key(name)
      assert_string name
      return name unless get('additionalProperties', nil) == NOTHING

      names    = get('properties') { {} }.keys
      patterns = get('patternProperties') { {} }.keys
      assert names.include?(name) || patterns.any? { |p| p.match? name } do
        "Expected '#{name}' to be an existing property"
      end
      name
    end
  end
end
