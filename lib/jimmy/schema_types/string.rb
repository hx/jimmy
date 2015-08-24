module Jimmy
  class SchemaTypes::String < SchemaType
    register!

    trait :min_length
    trait :max_length
    trait(:pattern) { |regex| attrs[:pattern] = regex.is_a?(Regexp) ? regex.inspect.gsub(%r`^/|/[a-z]*$`, '') : regex }
    trait(:format) { |value| attrs[:format] = value.to_s.gsub('_', '-') }
    %i[
      date_time
      email
      hostname
      ipv4
      ipv6
      uri
    ].each { |k| trait(k) { format k } }
    trait(:enum) do |*values|
      attrs[:enum] ||= []
      attrs[:enum] |= values.flatten.map(&:to_s)
    end
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
    trait(Array) { |value| enum value }

    compile do |hash|
      hash.merge! camelize_attrs(%i[min_length max_length pattern enum format])
    end

  end
end
