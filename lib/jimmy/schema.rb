module Jimmy
  class Schema
    JSON_SCHEMA_URI       = 'http://json-schema.org/draft-04/schema#'
    JSON_HYPER_SCHEMA_URI = 'http://json-schema.org/draft-04/hyper-schema#'

    attr_reader :dsl, :attrs, :domain, :type, :parent
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
        hash['definitions'] = definitions.compile unless definitions.empty?
        hash['links']       = links.map &:compile unless links.empty?
        hash.merge! data
        dsl.evaluate compiler, hash if compiler
      end
    end

    def url
      "#{domain.root}/#{name}.json#"
    end

    def definitions
      @definitions ||= Definitions.new(self)
    end

    def links
      @links ||= []
    end

    def data
      @data ||= {}
    end

    def hyper?
      links.any?
    end

    def schema_uri
      hyper? ? JSON_HYPER_SCHEMA_URI : JSON_SCHEMA_URI
    end

    def to_h
      {'$schema' => schema_uri}.tap do |h|
        h['id'] = url if name
        h.merge! compile
      end
    end

    def validate(data)
      errors = JSON::Validator.fully_validate(JSON::Validator.schema_for_uri(url).schema, data, errors_as_objects: true)
      raise ValidationError.new(self, data, errors) unless errors.empty?
    end

    def initialize(type, parent, locals, *args, &block)
      @attrs  = {}
      @type   = type
      @domain = parent.domain
      @dsl    = SchemaTypes.dsls[type].new(self)
      @parent = parent if parent.is_a? self.class
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
      if block
        if dsl.respond_to? :with_locals
          dsl.with_locals(locals) { dsl.evaluate block }
        else
          dsl.evaluate block
        end
      end
    end

  end
end
