require 'forwardable'

require_relative 'schema_type'
require_relative 'schema_creation'

module Jimmy
  module SchemaTypes

    @types = {}
    @dsls = {}
    @nested_handlers = {}
    @compilers = {}

    class << self
      extend Forwardable

      delegate %i[each keys values key?] => :@types

      attr_reader :dsls, :nested_handlers, :compilers

      def [](type_name)
        @types[type_name]
      end

      def register(type_class)
        type_name = type_class.name[/\w+$/].downcase.to_sym
        dsl_class = Class.new(type_class.superclass::DSL)
        type_class.const_set :DSL, dsl_class
        @dsls[type_name] = dsl_class
        @types[type_name] = type_class
      end

    end

    Dir[ROOT + 'lib/jimmy/schema_types/*.rb'].each do |path|
      require path
    end

    nested_handlers.each { |klass, handler| SchemaCreation.apply_to klass::DSL, &handler }

  end
end
