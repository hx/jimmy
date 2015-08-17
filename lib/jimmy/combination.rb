require_relative 'schema_types'

module Jimmy
  class Combination < Array
    include SchemaCreation::Referencing

    attr_reader :condition, :schema

    # @param [Symbol] condition One of :one, :all, or :any
    def initialize(condition, schema)
      @condition = condition
      @schema = schema
    end

    def domain
      schema.domain
    end

    def evaluate(types_proc)
      instance_exec &types_proc
    end

    def compile
      data.merge "#{condition}Of" => map(&:compile)
    end

    def data
      @data ||= {}
    end

    SchemaCreation.apply_to(self) { |schema| push schema }

  end
end
