module Jimmy
  class SchemaTypes::Object < SchemaType
    register!

    trait :require do |*required_keys|
      if required_keys == [0]
        attrs[:required] = SymbolArray.new
      else
        attrs[:required] ||= SymbolArray.new
        attrs[:required] |= required_keys.flatten.map(&:to_s).uniq
      end
    end

    trait :all do
      SymbolArray.new(attrs[:properties].keys.select { |x| x.is_a? Symbol })
    end

    trait(:none) { 0 }

    trait(:allow_additional) { attrs[:additional_properties] = true }

    nested do |schema, property_name|
      (attrs[:properties] ||= {})[property_name] = schema
    end

    serialize do |hash|
      (attrs[:properties] || {}).each do |key, value|
        collection, key =
            if key.is_a? Regexp
              ['patternProperties', key.inspect.gsub(%r`^/|/[a-z]*$`, '')]
            else
              ['properties', key.to_s]
            end
        hash[collection] ||= {}
        hash[collection][key] = serialize_schema(value)
      end
      hash['required'] = (attrs[:required] || []).to_a
      hash['additionalProperties'] = !!attrs[:additional_properties]
    end

  end
end
