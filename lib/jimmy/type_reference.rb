module Jimmy
  class TypeReference < Reference
    attr_reader :type

    def initialize(type, *args)
      @type = type
      super "/types/#{type}.json#", *args
    end
  end
end
