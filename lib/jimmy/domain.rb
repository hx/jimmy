# frozen_string_literal: true

require 'jimmy/domain_bound_schema'

module Jimmy
  # Represents a domain under which a group of schemas may be located. This
  # class can be used for loading and validating against directories of schema
  # files.
  class Domain
    attr_reader :uri

    # @param [URI, string] uri
    def initialize(uri)
      @uri = URI.parse(uri.to_s)
      @uri.path += '/' unless @uri.path[-1] == '/'
      @uri.freeze
      @schemas = {}
    end

    # Load a directory of files into the domain.
    # @param [Pathname, String] dir The root directory of files to load. Paths
    #   relative to this directory, without file extensions, will be given to
    #   each loaded schema under the domain's +uri+.
    # @param [String] glob_pattern The file pattern to glob within the
    #   +directory+.
    # @param [String] suffix The suffix to be appended to the path of each
    #   loaded schema
    # @return [self]
    def load_directory(dir, glob_pattern: '**/*.rb', suffix: '.json')
      dir = Pathname(dir) unless dir.is_a? Pathname
      raise ArgumentError, "#{dir} is not a directory" unless dir.directory?

      Dir[dir + glob_pattern].each do |path|
        load_file(
          path,
          as: basename(Pathname(path).relative_path_from(dir)) + suffix
        )
      end
      self
    end

    # Load a single file into the domain. The file's base name, without its
    # extension, will be used as the schema path, unless +as+ is specified.
    # @param [Pathname, String] path The path of the file to load.
    # @param [String, nil] as The path to assign to the loaded schema.
    # @return [self]
    def load_file(path, as: nil)
      path           = Pathname(path) unless path.is_a? Pathname
      name           = as || basename(path)
      @schemas[name] = Class
        .new { extend Jimmy::Macros }
        .class_eval(path.read, path.to_s)
        .freeze
      self
    end

    def get(uri)
      uri = @uri + uri
      uri.fragment ||= ''

      path = @uri.route_to(uri).tap { |u| u.fragment = nil }.to_s
      schema = @schemas[path] or return

      schema = schema.get_fragment(uri.fragment) or return

      DomainBoundSchema.new(self, uri, schema)
    end

    alias [] get

    private

    # Get the natural base name of the given path without its extension.
    # @param [Pathname] path
    def basename(path)
      path.basename.to_s.sub(/\.[^.]+\z/, '')
    end
  end
end
