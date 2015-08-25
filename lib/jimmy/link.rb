require 'forwardable'

module Jimmy
  class Link < Hash
    attr_reader :schema

    def initialize(schema, rel, href)
      @schema = schema
      merge! 'rel'  => rel.to_s,
             'href' => href.to_s
    end

    def dsl
      @dsl ||= DSL.new(self)
    end

    def schemas
      @schemas ||= {}
    end

    def domain
      schema.domain
    end

    def compile
      merge schemas.map { |k, v| [(k ? "#{k}Schema" : 'schema'), v.compile] }.to_h
    end

    def schema_creator
      @schema_creator ||= SchemaCreator.new(self)
    end

    class SchemaCreator < Hash
      include SchemaCreation::Referencing
      extend Forwardable
      delegate [:schema, :domain] => :@link

      def initialize(link)
        @link = link
      end

      def parent
        schema
      end

      SchemaCreation.apply_to(self) { |schema, prefix| @link.schemas[prefix] = schema }
    end

    class DSL
      attr_reader :link

      def initialize(link)
        @link = link
      end

      def domain
        link.domain
      end

      def title(value)
        link['title'] = value
      end

      def method(value)
        link['method'] = value.to_s.upcase
      end

      def evaluate(&block)
        instance_exec &block
      end

      def schema(*args, prefix: nil, **opts, &block)
        if args.empty? && opts.any?
          args = opts.shift
          type = args.shift
        else
          type = args.shift || :object
        end
        args.unshift type, prefix
        args << opts if opts.any?
        link.schema_creator.__send__ *args, &block
      end

      def target_schema(*args, **opts, &block)
        schema *args, **opts.merge(prefix: :target), &block
      end

      def set(**values)
        values.each { |k, v| link[k.to_s] = v }
      end
    end
  end
end
