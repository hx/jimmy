module Jimmy
  class SchemaCreation

    @handlers = {}

    class << self

      attr_reader :handlers

      def apply_to(klass, &handler)
        @handlers[klass] = handler
        %i(one all any).each do |condition|
          klass.__send__ :define_method, :"#{condition}_of" do |*args, &inner_block|
            Combination.new(condition, schema).tap do |combo|
              combo.with_locals(locals) { combo.evaluate inner_block }
              instance_exec combo, *args, &handler
            end
          end
        end
        klass.include DefiningMethods
      end
    end

    module MetadataMethods
      def set(**values)
        values.each { |k, v| data[k.to_s] = v }
      end

      %i[title description default].each { |k| define_method(k) { |v| set k => v } }
    end

    module Referencing
      def method_missing(name, *args, &block)
        if schema.definitions[name]
          ref *args, definition(name)
        else
          super
        end
      end

      def respond_to_missing?(name, *)
        schema.definitions.key?(name) || super
      end

      def definition(id)
        "/#{schema.name}#/definitions/#{id}"
      end

      def ref(*args, uri)
        handler = SchemaCreation.handlers[self.class]
        instance_exec(Reference.new(uri), *args, &handler) if handler
      end
    end

    module DefiningMethods
      include MetadataMethods

      def locals
        @locals ||= {}
      end

      def with_locals(**locals)
        locals.each_key do |key|
          raise "Local '#{key}' conflicts with an existing DSL method" if reserved? key
        end
        original = locals
        @locals = original.merge(locals)
        yield.tap { @locals = original }
      end

      def respond_to_missing?(method, *)
        locals.key?(method) || reserved?(method, false) || super
      end

      def method_missing(method, *args, &block)
        return locals[method] if locals.key?(method)

        if SchemaTypes.key? method
          handler = SchemaCreation.handlers[self.class]
          self.class.__send__ :define_method, method do |*inner_args, &inner_block|
            handler_args = handler && inner_args.shift(handler.arity - 1)
            child_schema = Schema.new(
                method,
                respond_to?(:schema) ? schema : domain
            )
            child_schema.name = @schema_name if is_a? Domain
            child_schema.setup *inner_args, **locals, &inner_block
            instance_exec child_schema, *handler_args, &handler if handler
            child_schema.dsl
          end
          return __send__ method, *args, &block
        end

        domain.autoload_type method

        if domain.types.key? method
          return instance_exec TypeReference.new(method, args.include?(:nullable)), *args, &SchemaCreation.handlers[self.class]
        end

        if kind_of_array?(method)
          return array(*args) { __send__ method[0..-7], &block }
        end

        super method, *args, &block
      end

      private

      def reserved?(key, all = true)
        domain.autoload_type key
        (all && respond_to?(key)) || SchemaTypes.key?(key) || domain.types.key?(key) || kind_of_array?(key)
      end

      def kind_of_array?(key)
        key =~ /^(\w+)_array$/ && reserved?($1.to_sym)
      end

    end

  end
end
