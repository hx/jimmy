module Jimmy
  class SchemaTypes::Number < SchemaType
    register!

    trait :multiple_of
    trait :minimum
    trait :maximum
    trait(:<) { |value| maximum value; attrs[:exclusive_maximum] = true; self }
    trait(:<=) { |value| maximum value; attrs[:exclusive_maximum] = nil; self }
    trait(:>) { |value| minimum value; attrs[:exclusive_minimum] = true; self }
    trait(:>=) { |value| minimum value; attrs[:exclusive_minimum] = nil; self }
    trait(:enum) do |*values|
      attrs[:enum] ||= []
      attrs[:enum] |= values.flatten
    end
    trait(Numeric, Array) { |value| enum value }
    trait(Range) do |range|
      if range.first <= range.last
        minimum range.first
        maximum range.last
        attrs[:exclusive_maximum] ||= range.exclude_end? || nil
      else
        minimum range.last
        maximum range.first
        attrs[:exclusive_minimum] ||= range.exclude_end? || nil
      end
    end

    compile do |hash|
      hash.merge! camelize_attrs(%i[minimum maximum exclusive_minimum exclusive_maximum multiple_of enum])
    end

  end
end
