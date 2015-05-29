require_relative 'schema_types'

module Jimmy
  class Combination < Array

    attr_reader :condition, :domain

    # @param [Symbol] condition One of :one, :all, or :any
    def initialize(condition, domain)
      @condition = condition
      @domain = domain
    end

    def evaluate(types_proc)
      instance_exec &types_proc
    end

    def serialize
      {"#{condition}Of" => map(&:serialize)}
    end

    SchemaCreation.apply_to(self) { |schema| push schema }

  end
end
