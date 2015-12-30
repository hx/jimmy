module Jimmy
  class Reference
    attr_reader :uri

    def initialize(uri, nullable = false)
      @uri      = uri
      @nullable = nullable
    end

    def compile
      if nullable?
        {
            'anyOf' => [
                {'type' => 'null'},
                ref_hash
            ]
        }
      else
        ref_hash
      end
    end

    def nullable?
      @nullable
    end

    private

    def ref_hash
      {'$ref' => uri}
    end
  end
end
