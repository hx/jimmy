# frozen_string_literal: true

module Jimmy
  module Json
    # Represents a JSON pointer per https://tools.ietf.org/html/rfc6901
    class Pointer
      ESCAPE   = [%r{[~/]}, { '~' => '~0', '/' => '~1' }.freeze].freeze
      UNESCAPE = [/~[01]/, ESCAPE.last.invert.freeze].freeze

      # @param [::Array<String>, Pointer, String] path A string starting with
      #   a +/+ and in JSON pointer format, or an array of parts of the pointer.
      def initialize(path)
        @path =
          case path
          when ::Array, Pointer then path.to_a
          when String then parse(path)
          else
            raise Error::WrongType, "Unexpected #{path.class}"
          end
      end

      # @return [Array<String>] The individual parts of the pointer.
      def to_a
        @path.dup
      end

      # Make a new pointer by appending +other+ to self.
      # @param [Pointer, Integer, String, ::Array<String>] other The pointer to
      #   append.
      # @return [Pointer]
      def join(other)
        if other.is_a? Integer
          return shed(-other) if other.negative?

          other = other.to_s
        end

        other = '/' + other if other.is_a?(String) && other[0] != '/'
        self.class.new(@path + self.class.new(other).to_a)
      end

      alias + join

      # Make a new pointer by removing +count+ parts from the end of self.
      # @param [Integer] count
      # @return [Pointer]
      def shed(count)
        unless count.is_a?(Integer) && !count.negative?
          raise Error::BadArgument, 'Expected a non-negative integer'
        end
        return dup if count.zero?
        raise Error::BadArgument, 'Out of range' if count > @path.length

        self.class.new @path[0..(-count - 1)]
      end

      alias - shed

      # Get the pointer as a string, either blank, or starting with a +/+.
      # @return [String]
      def to_s
        return '' if @path.empty?

        @path.map { |str| '/' + str.gsub(*ESCAPE) }.join
      end

      # Returns true if +other+ has the same string value as self.
      # @param [Pointer] other
      # @return [true, false]
      def ==(other)
        other.is_a?(self.class) && @path == other.to_a
      end

      # @see ::Object#inspect
      def inspect
        "#<#{self.class} #{self}>"
      end

      # Returns true if the pointer has no parts.
      # @return [true, false]
      def empty?
        @path.empty?
      end

      # Remove the last part of the pointer.
      # @return [String] The part that was removed.
      def shift
        @path.shift
      end

      # Return a new pointer with just the part of self that is not included
      # in +other+.
      #
      #   Jimmy::Json::Pointer.new('/foo/bar/baz').remove_prefix('/foo')
      #   # => #<Jimmy::Json::Pointer /bar/baz>
      # @param [String, Pointer, ::Array<String>] other
      def remove_prefix(other)
        tail = dup
        Pointer.new(other).to_a.each do |segment|
          return nil unless tail.shift == segment
        end
        tail
      end

      private

      def parse(path)
        return [] if path == ''
        return [''] if path == '/'

        unless path[0] == '/'
          raise Error::BadArgument, 'JSON pointers should start with /'
        end

        path[1..].split('/').map { |str| str.gsub *UNESCAPE }
      end
    end
  end
end
