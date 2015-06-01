require 'forwardable'

require_relative 'schema'

module Jimmy
  class SchemaType

    class << self

      def register!
        SchemaTypes.register self
      end

      def trait(name_or_type, &handler)
        case name_or_type
          when Symbol
            handler ||= proc { |value| attrs[name_or_type] = value }
            self::DSL.__send__ :define_method, name_or_type, handler
          when Class
            Schema.set_argument_handler self, name_or_type, handler
          else
            raise 'Trait must be a Symbol or a Class'
        end
      end

      def nested(&handler)
        SchemaTypes.nested_handlers[self] = handler
      end

      def compile(&handler)
        SchemaTypes.compilers[self] = handler
      end

    end

    class DSL
      extend Forwardable

      attr_reader :schema

      delegate %i(attrs domain) => :schema

      def initialize(schema)
        @schema = schema
      end

      def evaluate(proc, *args)
        instance_exec *args, &proc
      end

      def camelize_attrs(*args)
        included_args = args.flatten.reject { |arg| attrs[arg].nil? }
        included_args.map { |arg| [arg.to_s.gsub(/_([a-z])/) { $1.upcase }, attrs[arg]] }.to_h
      end

      def compile_schema(schema)
        schema.is_a?(Symbol) ? {'$ref' => "/types/#{schema}#"} : schema.compile
      end

      def include(*partial_names)
        partial_names.each { |name| instance_eval *domain.partials[name.to_s] }
      end

    end

  end
end
