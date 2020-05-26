# frozen_string_literal: true

require 'jimmy/loaders/base'

module Jimmy
  module Loaders
    # Loads a plain .json file
    class JSON < Base
      # @return [Jimmy::Schema]
      def load
        Schema.new ::JSON.parse(source.read)
      end
    end
  end
end
