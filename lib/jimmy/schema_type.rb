require 'forwardable'

require_relative 'schema'

module Jimmy
  class SchemaType

    class << self

      def register!
        SchemaTypes.register self
      end

      def trait(*args, &handler)
        args.each do |name_or_type|
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
      include SchemaCreation::Referencing
      include SchemaCreation::MetadataMethods

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

      def include(*partial_names, **locals)
        partial_names.each do |name|
          with_locals locals do
            evaluate_partial domain.partials[name.to_s]
          end
        end
      end

      def definitions(&block)
        schema.definitions.evaluate &block
      end

      def define(type, *args, &block)
        definitions { __send__ type, *args, &block }
      end

      def data
        schema.data
      end

      def link(rel_and_href, &block)
        link = Link.new(schema, *rel_and_href.first)
        schema.links << link
        link.dsl.evaluate &block if block
      end

      def nullable
        schema.nullable = true
      end

      private

      # Minimize collisions with local scope (hence the weird name __args)
      def evaluate_partial(__args)
        instance_eval *__args
      end

    end

  end
end
