# frozen_string_literal: true

require 'jimmy/macros'
require 'jimmy/loaders/base'

module Jimmy
  module Loaders
    # Loads .rb files
    class Ruby < Base
      include Macros

      # @param [Pathname, string] file
      # @return [Jimmy::Schema]
      def load(file = source)
        file = Pathname(file)
        file = source.parent + file if file.relative?
        Jimmy::Schema(instance_eval file.read, file.to_s)
      end
    end
  end
end
