module Jimmy
  class SchemaTypes::String < SchemaType
    register!

    trait :min_length
    trait :max_length
    trait(:pattern) { |regex| attrs[:pattern] = regex.is_a?(Regexp) ? regex.inspect.gsub(%r`^/|/[a-z]*$`, '') : regex }
    trait(Regexp) { |regex| pattern regex }
    trait(Range) { |value| attrs[:min_length], attrs[:max_length] = [value.first, value.last].sort }
    trait(Fixnum) { |value| min_length value; max_length value }
    trait(Array) { |value| attrs[:enum] = value.map(&:to_s) }

    compile do |hash|
      hash.merge! camelize_attrs(%i[min_length max_length pattern enum])
    end

  end
end
