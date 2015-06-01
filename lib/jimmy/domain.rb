require 'uri'
require 'pathname'
require 'json'

require_relative 'schema_creation'

module Jimmy
  class Domain

    attr_reader :root, :types

    def initialize(root)
      @root = URI(root)
      @schemas = {}
      @types = {}
    end

    def domain
      self
    end

    def import(path)
      path = Pathname(path) unless path.is_a? Pathname

      types_path = path + 'types'
      glob types_path, path do |name, schema|
        @types[name.to_sym] = schema
      end

      glob path do |name, schema|
        next if name =~ %r`^(types|partials)/`
        @schemas[name] = schema
      end
    end

    def [](schema_name)
      @schemas[schema_name.to_s]
    end

    def export(path = nil)
      path = Pathname(path) if path.is_a? String
      raise 'Please specify an export directory' unless path.is_a?(Pathname) && (path.directory? || !path.exist?)
      path.mkpath
      @schemas.each { |name, schema| export_schema schema, path + "#{name.to_s}.json" }
    end

    private

    def glob(path, base_path = nil, &block)
      base_path ||= path
      Dir[path + '**/*.rb'].each do |full_path|
        full_path = Pathname(full_path)
        relative_path = full_path.relative_path_from(path)
        args = [relative_path.to_s[0..-4]]
        if block.arity == 2
          schema = instance_eval(full_path.read, full_path.to_s).schema
          schema.name = full_path.relative_path_from(base_path).to_s[0..-4]
          args << schema
        end
        yield *args
      end
    end

    def export_schema(schema, target_path)
      target_path.parent.mkpath
      target_path.write JSON.pretty_generate(schema.to_h)
    end

    SchemaCreation.apply_to self

  end
end
