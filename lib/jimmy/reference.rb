module Jimmy
  class Reference
    include SchemaCreation::MetadataMethods
    attr_reader :uri, :data

    def initialize(uri, nullable = false, *args, **opts, &block)
      @uri      = uri
      @nullable = nullable
      @data     = {}
      args.each { |arg| __send__ arg }
      opts.each { |arg| __send__ *arg }
      instance_exec &block if block
    end

    def compile
      data.merge(nullable? ?
        {
            'anyOf' => [
                {'type' => 'null'},
                ref_hash
            ]
        } :
        ref_hash
      )
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
