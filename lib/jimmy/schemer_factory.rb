# frozen_string_literal: true

module Jimmy # rubocop:disable Style/Documentation
  # Factory class for making +JSONSchemer::Schema::Base+ instances
  class SchemerFactory
    def self.available?
      defined? ::JSONSchemer
    end

    # @param [#as_json] schema
    # @param [Array<#resolve, 'net/http'>] resolvers
    # @param [true, false] cache_resolvers
    # @param [Hash] opts Options to be passed to +JSONSchemer+
    def initialize(schema, *resolvers, cache_resolvers: true, **opts)
      unless self.class.available?
        raise LoadError, 'Please add the json_schemer gem to your Gemfile'
      end

      @schema    = schema
      @resolvers = resolvers.map(&method(:cast_resolver))
      @options   = opts.dup

      return if @resolvers.empty?

      res = method(:resolve)
      res = JSONSchemer::CachedRefResolver.new(&res) if cache_resolvers
      @options[:ref_resolver] = res
    end

    def schemer
      @schemer ||= JSONSchemer.schema(@schema.as_json, **@options)
    end

    def resolve(uri)
      @resolvers.each do |resolver|
        return resolver.call(uri) unless resolver.respond_to? :resolve

        schema = resolver.resolve(uri)
        return schema.as_json if schema
      end
    end

    def cast_resolver(resolver)
      if resolver == 'net/http'
        return JSONSchemer::Schema::Base::NET_HTTP_REF_RESOLVER
      end

      unless resolver.respond_to? :resolve
        raise ArgumentError, 'Expected an object responding to :resolve'
      end

      resolver
    end
  end

  # @see {SchemerFactory#initialize}
  def self.schemer(*args, **opts)
    SchemerFactory.new(*args, **opts).schemer
  end
end
