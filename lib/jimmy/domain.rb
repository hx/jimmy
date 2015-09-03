require 'uri'
require 'pathname'
require 'json'
require 'json-schema'

require_relative 'schema_creation'

module Jimmy
  class Domain

    attr_reader :root, :types, :partials

    def initialize(root)
      @root     = URI(root)
      @schemas  = {}
      @types    = {}
      @partials = {}
      @import_paths = []
      @uri_formatter = -> _, name { @root + "#{name}.json#" }
    end

    def domain
      self
    end

    def import(path)
      path = Pathname(path) unless path.is_a? Pathname
      @import_paths << path unless @import_paths.include? path

      glob path, only: 'types' do |name, schema|
        @types[name.to_sym] = schema
      end

      glob path, only: 'partials' do |name|
        partial_path = path + 'partials' + "#{name}.rb"
        @partials[name] = [partial_path.read, partial_path.to_s]
      end

      glob path, ignore: %r`^(types|partials)/` do |name, schema|
        @schemas[name] = schema
      end
    end

    def autoload_type(name)
      # TODO: protect from circular dependency
      return if types.key? name
      @import_paths.each do |import_path|
        path = import_path + "types/#{name}.rb"
        if path.file?
          @types[name] = load_schema_from_path(path, name)
          return true
        end
      end
      false
    end

    def [](schema_name)
      @schemas[schema_name.to_s]
    end

    def export(path = nil, &serializer)
      path = Pathname(path) if path.is_a? String
      raise 'Please specify an export directory' unless path.is_a?(Pathname) && (path.directory? || !path.exist?)
      path.mkpath
      @schemas.each { |name, schema| export_schema schema, path +           "#{name.to_s}.json", &serializer }
      @types.each   { |name, schema| export_schema schema, path + 'types' + "#{name.to_s}.json", &serializer }
    end

    def uri_for(name)
      @uri_formatter.call root, name
    end

    def uri_format(&block)
      @uri_formatter = block
    end

    private

    def glob(base_path, only: '.', ignore: nil, &block)
      lookup_path = base_path + only
      Dir[lookup_path + '**/*.rb'].each do |full_path|
        full_path = Pathname(full_path)
        relative_path = full_path.relative_path_from(lookup_path)
        next if ignore === relative_path.to_s
        args = [relative_path.to_s[0..-4]]
        args << load_schema_from_path(full_path, full_path.relative_path_from(base_path).to_s[0..-4]) if block.arity == 2
        yield *args
      end
    end

    def load_schema_from_path(path, name)
      @schema_name = name
      instance_eval(path.read, path.to_s).schema.tap do |schema|
        schema.name = name.to_s
        JSON::Validator.add_schema JSON::Schema.new(schema.to_h, nil)
      end
    end

    def export_schema(schema, target_path)
      target_path.parent.mkpath
      target_path.write block_given? ? yield(schema.to_h) : JSON.pretty_generate(schema.to_h)
    end

    SchemaCreation.apply_to self

  end
end
