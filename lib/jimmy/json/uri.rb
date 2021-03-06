# frozen_string_literal: true

require 'jimmy/json/pointer'

module Jimmy
  module Json
    # Wraps the URI class to provide additional functionality.
    class URI
      # Take from the back of URI::RFC3986_Parser::RFC3986_URI
      FRAGMENT_ESCAPING = %r{[^!$&-.0-;=@-Z_a-z~/?]}.freeze

      # @param [String, URI, ::URI] uri
      # @param [true, false] container If true, a +/+ will be appended to the
      #   given +uri+ if it was omitted. Otherwise, a +#+ will be appended.
      def initialize(uri, container: false)
        @uri = ::URI.parse(uri.to_s)
        if container
          @uri.path += '/' unless @uri.path.end_with? '/'
        else
          @uri.fragment ||= ''
        end
      end

      # Get the fragment of this URI as a {Pointer}.
      # @return [Pointer]
      def pointer
        Pointer.new ::URI.decode_www_form_component(fragment)
      end

      # Set the fragment of this URI using a {Pointer}.
      # @param [String, Pointer, ::Array<String>] value
      def pointer=(value)
        # Loosely based on URI.encode_www_form_component
        fragment = Pointer.new(value).to_s.dup
        fragment.force_encoding Encoding::ASCII_8BIT
        fragment.gsub!(FRAGMENT_ESCAPING) { |chr| '%%%02X' % chr.ord }
        fragment.force_encoding Encoding::US_ASCII
        self.fragment = fragment
      end

      undef to_s

      # @see ::Object#inspect
      def inspect
        "#<#{self.class} #{self}>"
      end

      # Returns true if +other+ represents the same URI as self.
      # @param [URI] other
      def ==(other)
        other.is_a?(self.class) && other.to_s == to_s
      end

      alias eql? ==

      # @see ::URI#join
      def join(other)
        self.class.new(@uri + other.to_s)
      end

      alias + join

      # Return a new URI with the given pointer appended.
      # @param [Pointer, String, ::Array<String>] other
      def /(other)
        dup.tap { |uri| uri.pointer += other }
      end

      # @see ::Object#dup
      # @return [URI]
      def dup
        self.class.new self
      end

      # @api private
      def hash
        [self.class, @uri].hash
      end

      # Get this URI as a string. If +id+ is given, the string will be this URI
      # relative to the given URI.
      #
      #   uri = Jimmy::Json::URI.new('http://example.com/foo/bar#')
      #   uri.as_json(id: 'http://example.com/foo/')
      #   # => "bar#"
      # @param [URI, ::URI, String] id If not nil, the URI will be represented
      #   relative to +id+.
      def as_json(id: nil, **)
        return to_s unless id

        id = URI.new(id)
        id.absolute? ? id.route_to(id + self).to_s : to_s
      end

      # @see URI::Generic#route_to
      # @param [Json::URI, URI, String] other
      # @return [Json::URI]
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

      # @api private
      def respond_to_missing?(name, *)
        @uri.respond_to? name or super
      end

      # @api private
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
end
