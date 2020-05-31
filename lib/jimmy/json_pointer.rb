# frozen_string_literal: true

module Jimmy
  # Represents a JSON pointer per https://tools.ietf.org/html/rfc6901
  class JsonPointer
    ESCAPE   = [%r{[~/]}, { '~' => '~0', '/' => '~1' }.freeze].freeze
    UNESCAPE = [/~[01]/, ESCAPE.last.invert.freeze].freeze

    def initialize(path)
      @path =
        case path
        when Array, JsonPointer then path.to_a
        when String then parse(path)
        else
          raise Error::WrongType, "Unexpected #{path.class}"
        end
    end

    def to_a
      @path.dup
    end

    def join(other)
      if other.is_a? Integer
        return shed(-other) if other.negative?

        other = other.to_s
      end

      other = '/' + other if other.is_a?(String) && other[0] != '/'
      self.class.new(@path + self.class.new(other).to_a)
    end

    alias + join

    def shed(count)
      unless count.is_a?(Integer) && !count.negative?
        raise Error::BadArgument, 'Expected a non-negative integer'
      end
      return dup if count.zero?
      raise Error::BadArgument, 'Out of range' if count > @path.length

      self.class.new @path[0..(-count - 1)]
    end

    alias - shed

    def to_s
      return '' if @path.empty?

      @path.map { |str| '/' + str.gsub(*ESCAPE) }.join
    end

    def ==(other)
      other.is_a?(self.class) && @path == other.to_a
    end

    def inspect
      "#<#{self.class} #{self}>"
    end

    def empty?
      @path.empty?
    end

    def shift
      @path.shift
    end

    def remove_prefix(other)
      tail = dup
      JsonPointer.new(other).to_a.each do |segment|
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
