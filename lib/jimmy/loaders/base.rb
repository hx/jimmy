# frozen_string_literal: true

module Jimmy
  module Loaders
    # Base class for all file loaders
    # @abstract
    class Base
      # Load the given file. Intended to be used by a {Jimmy::FileMap}.
      # @api private
      # @param [Pathname, String] file Path of the file to load
      def self.call(file)
        new(file).load
      end

      # The source file to be loaded.
      # @return Pathname
      attr_reader :source

      # @param [Pathname] source The source file to load.
      def initialize(source)
        @source = Pathname(source)
      end

      # @return [Jimmy::Schema]
      def load
        raise NotImplementedError, "Please implement #load on #{self.class}"
      end
    end
  end
end
