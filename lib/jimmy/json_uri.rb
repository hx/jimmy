# frozen_string_literal: true

require 'jimmy/json/pointer'

module Jimmy
  # Wraps the URI class to provide additional functionality.
  class JsonURI
    # Take from the back of URI::RFC3986_Parser::RFC3986_URI
    FRAGMENT_ESCAPING = %r{[^!$&-.0-;=@-Z_a-z~/?]}.freeze

    def initialize(uri, container: false)
      @uri = ::URI.parse(uri.to_s)
      if container
        @uri.path += '/' unless @uri.path.end_with? '/'
      else
        @uri.fragment ||= ''
      end
    end

    def pointer
      Json::Pointer.new URI.decode_www_form_component(fragment)
    end

    def pointer=(value)
      # Loosely based on URI.encode_www_form_component
      fragment = Json::Pointer.new(value).to_s.dup
      fragment.force_encoding Encoding::ASCII_8BIT
      fragment.gsub!(FRAGMENT_ESCAPING) { |chr| '%%%02X' % chr.ord }
      fragment.force_encoding Encoding::US_ASCII
      self.fragment = fragment
    end

    undef to_s

    def inspect
      "#<#{self.class} #{self}>"
    end

    def ==(other)
      other.is_a?(self.class) && other.to_s == to_s
    end

    alias eql? ==

    def join(other)
      self.class.new(@uri + other.to_s)
    end

    alias + join

    def /(other)
      dup.tap { |uri| uri.pointer += other }
    end

    def dup
      self.class.new self
    end

    def hash
      [self.class, @uri].hash
    end

    def as_json(id: nil, **)
      return to_s unless id

      id = JsonURI.new(id)
      id.absolute? ? id.route_to(id + self).to_s : to_s
    end

    # @see URI::Generic#route_to
    # @param [JsonURI, URI, String] other
    # @return [JsonURI]
    def route_to(other)
      self.class.new(@uri.route_to other.to_s)
    end

    # @!method fragment
    #   @see URI::Generic#fragment
    #   @return [String]
    # @!method path
    #   @see URI::Generic#path
    #   @return [String]
    # @!method host
    #   @see URI::Generic#host
    #   @return [String]
    # @!method relative?
    #   @see URI::Generic#relative?
    #   @return [true, false]
    # @!method absolute?
    #   @see URI::Generic#absolute?
    #   @return [true, false]
    # @!method path=(value)
    #   @see URI::Generic#path=
    #   @param [String] value
    # @!method fragment=(value)
    #   @see URI::Generic#fragment=
    #   @param [String] value

    def respond_to_missing?(name, *)
      @uri.respond_to? name or super
    end

    def method_missing(symbol, *args, &block)
      if @uri.respond_to? symbol
        self.class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{symbol}(*args, &block)
            @uri.__send__ :#{symbol}, *args, &block
          end
        RUBY

        return __send__ symbol, *args, &block
      end
      super
    end
  end
end
