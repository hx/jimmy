require 'forwardable'

module Jimmy
  class Definitions
    extend Forwardable
    delegate %i[empty? key? map] => :@values
    
    attr_reader :schema

    def initialize(schema)
      @schema = schema
      @values = {}
    end

    def evaluate(&block)
      instance_exec &block
    end

    def domain
      schema.domain
    end

    def compile
      map { |k, v| [k.to_s, v.compile] }.to_h
    end

    def data
      schema.data
    end

    def [](key)
      @values[key] || (schema.parent && schema.parent.definitions[key])
    end

    SchemaCreation.apply_to(self) { |schema, name| @values[name] = schema }
  end
end
