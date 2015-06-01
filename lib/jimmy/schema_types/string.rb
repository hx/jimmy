module Jimmy
  class SchemaTypes::String < SchemaType
    register!

    trait :min_length
    trait :max_length
    trait(:pattern) { |regex| attrs[:pattern] = regex.is_a?(Regexp) ? regex.inspect.gsub(%r`^/|/[a-z]*$`, '') : regex }
    trait(Regexp) { |regex| pattern regex }
    trait Range do |value|
      variation = value.exclude_end? ? 1 : 0
      if value.first < value.last
        attrs[:min_length] = value.first
        attrs[:max_length] = value.last - variation
      else
        attrs[:max_length] = value.first
        attrs[:min_length] = value.last + variation
      end
    end
    trait(Fixnum) { |value| min_length value; max_length value }
    trait(Array) { |value| attrs[:enum] = value.map(&:to_s) }

    compile do |hash|
      hash.merge! camelize_attrs(%i[min_length max_length pattern enum])
    end

  end
end
