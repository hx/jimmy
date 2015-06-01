module Jimmy
  class Schema

    attr_reader :dsl, :attrs, :domain, :type
    attr_accessor :name

    @argument_handlers = Hash.new { |hash, key| hash[key] = {} }
    
    def self.set_argument_handler(schema_class, arg_class, handler)
      @argument_handlers[schema_class][arg_class] = handler
    end

    def self.argument_hander(schema_class, argument)
      handlers = {}
      until schema_class == SchemaType do
        handlers = (@argument_handlers[schema_class] || {}).merge(handlers)
        schema_class = schema_class.superclass
      end
      result = handlers.find { |k, _| argument.is_a? k }
      result && result.last
    end

    def compile
      compiler = nil
      schema_class = SchemaTypes[type]
      until schema_class == SchemaType do
        compiler ||= SchemaTypes.compilers[schema_class]
        schema_class = schema_class.superclass
      end
      {'type' => type.to_s}.tap do |hash|
        dsl.evaluate compiler, hash if compiler
      end
    end

    def url
      "#{domain.root}/#{name}.json#"
    end

    def to_h
      {'$schema' => 'http://json-schema.org/draft-04/schema#'}.tap do |hash|
        hash['id'] = url if name
        hash.merge! compile
      end
    end

    private

    def initialize(type, domain, *args, &block)
      @attrs  = {}
      @type   = type
      @domain = domain
      @dsl    = SchemaTypes.dsls[type].new(self)
      args.each do |arg|
        case arg
          when Symbol
            dsl.__send__ arg
          when Hash
            arg.each { |k, v| dsl.__send__ k, v }
          else
            handler = Schema.argument_hander(SchemaTypes[type], arg)
            raise "`#{type}` cannot handle arguments of type #{arg.class.name}" unless handler
            dsl.evaluate handler, arg
        end
      end
      dsl.evaluate block if block
    end

  end
end
