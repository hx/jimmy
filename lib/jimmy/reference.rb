module Jimmy
  class Reference
    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end

    def compile
      {'$ref' => uri}
    end
  end
end
