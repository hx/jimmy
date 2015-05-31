module Jimmy
  class SchemaTypes::Array < SchemaType
    register!

    trait :min_items
    trait :max_items
    trait Range do |range|
      min, max = [range.first, range.last].sort
      min_items min
      max_items max
    end
    trait(Fixnum) { |value| min_items value; max_items value }

    nested do |schema|
      (attrs[:items] ||= []) << schema
    end

    compile do |hash|
      hash.merge! camelize_attrs(%i[min_items max_items])
      items = attrs[:items] || []
      if items.length > 1
        hash['items'] = {'anyOf' => items.map { |i| compile_schema i }}
      elsif items.length == 1
        hash['items'] = compile_schema(items.first)
      end
    end

  end
end
