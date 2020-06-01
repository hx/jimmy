# frozen_string_literal: true

module Jimmy
  # Factory class for making +JSONSchemer::Schema::Base+ instances
  class SchemerFactory
    # Returns true if the +json_schemer+ gem is loaded.
    # @return [true, false]
    def self.available?
      defined? ::JSONSchemer
    end

    # @param [Schema, #as_json] schema
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

    # Get an instance of {JSONSchemer::Schema::Base} that can be used to
    # validate JSON documents against the given {Schema}.
    # @return [JSONSchemer::Schema::Base]
    def schemer
      @schemer ||= JSONSchemer.schema(@schema.as_json, **@options)
    end

    # @param [String, URI, Json::URI] uri
    # @return [Hash{String => Object}, nil]
    def resolve(uri)
      @resolvers.each do |resolver|
        return resolver.call(uri) unless resolver.respond_to? :resolve

        schema = resolver.resolve(uri)
        return schema.as_json if schema
      end
      nil
    end

    private

    def cast_resolver(resolver)
      if resolver == 'net/http'
        return JSONSchemer::Schema::Base::NET_HTTP_REF_RESOLVER
      end

      unless resolver.respond_to? :resolve
        raise Error::BadArgument, 'Expected an object responding to :resolve'
      end

      resolver
    end
  end
end
