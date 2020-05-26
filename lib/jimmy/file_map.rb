# frozen_string_literal: true

require 'jimmy/index'
require 'jimmy/loaders/ruby'
require 'jimmy/loaders/json'
require 'jimmy/schema_with_uri'
require 'jimmy/schemer_factory'

module Jimmy
  # Maps a directory of files to schemas with URIs.
  class FileMap
    DEFAULT_LOADERS = {
      'rb'   => Loaders::Ruby,
      'json' => Loaders::JSON
    }.freeze

    # @param [Pathname, String] base_dir
    # @param [JsonURI, URI, String] base_uri
    # @param [true, false] live
    # @param [Hash{String => #call}] loaders
    # @param [String] suffix
    def initialize(
      base_dir,
      base_uri = nil,
      live:    false,
      loaders: DEFAULT_LOADERS,
      suffix:  ''
    )
      @dir = Pathname(base_dir).realpath
      unless @dir.directory? && @dir.readable?
        raise ArgumentError, 'Expected a readable directory'
      end

      base_uri ||= uri_for_dir
      @uri = JsonURI.new(base_uri.to_s, container: true)

      @live    = live
      @loaders = loaders
      @suffix  = suffix

      index unless live
    end

    # @param [JsonURI, URI, String] uri
    # @return [Jimmy::SchemaWithURI, nil]
    def resolve(uri)
      uri          = make_child_uri(uri)
      absolute_uri = @uri + uri

      return index.resolve(absolute_uri) unless live?

      schema = load_file(path_for_uri uri)&.get_fragment(uri.fragment)
      schema && SchemaWithURI.new(absolute_uri, schema)
    end

    alias [] resolve

    # @return [Jimmy::Index]
    def index
      return @index if @index

      index = build_index
      @index = index unless live?

      index
    end

    def live?
      @live
    end

    private

    def load_file(file_base)
      @loaders.each do |ext, loader|
        file = Pathname("#{file_base}.#{ext}")
        next unless file.file?
        return loader.call(file) if file.readable?

        warn "Jimmy cannot read #{file}"
      end
      nil
    end

    def uri_for_dir
      JsonURI.new 'file://' + fs_to_rfc3968(@dir)
    end

    def path_for_uri(uri)
      path  = uri.path[0..(-@suffix.length - 1)]
      parts = path.split('/').map(&URI.method(:decode_www_form_component))
      @dir.join(*parts)
    end

    def make_child_uri(uri)
      uri = @uri.route_to(@uri + uri)

      unless uri.host.nil? && !uri.path.match?(%r{\A(\.\.|/)})
        raise ArgumentError, 'The given URI is outside this FileMap'
      end

      uri.path += @suffix unless uri.path.end_with? @suffix
      uri
    end

    def build_index
      index = Index.new

      Dir[@dir + "**/*.{#{@loaders.keys.join ','}}"].sort.each do |file|
        relative_uri = relative_uri_for_file(file)
        uri          = @uri + relative_uri

        index[uri] = @loaders.fetch(File.extname(file)[1..]).call(file)
      end

      index
    end

    def relative_uri_for_file(file)
      path = Pathname(file)
        .relative_path_from(@dir)
        .to_s
        .sub(/\.[^.]+\z/, '')

      JsonURI.new fs_to_rfc3968(path) + @suffix
    end

    def fs_to_rfc3968(path)
      path
        .to_s
        .split(File::SEPARATOR)
        .map { |p| URI.encode_www_form_component p.sub(/:\z/, '') }
        .join('/')
    end
  end
end
