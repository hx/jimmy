module Jimmy
  class TypeReference < Reference
    attr_reader :type

    def initialize(type)
      @type = type
    end

    def uri
      "/types/#{type}.json#"
    end
  end
end
