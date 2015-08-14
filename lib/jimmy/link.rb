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

      def schema(type = nil, &block)
        link.schemas[type] = Schema.new(:object, domain, {}, &block)
      end

      def set(**values)
        values.each { |k, v| link[k.to_s] = v }
      end
    end
  end
end
