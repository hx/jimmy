# frozen_string_literal: true

module Jimmy
  module Declaration
    # Shortcut for +object.additional_properties(false)+.
    # @return [Jimmy::Schema]
    def struct
      object.additional_properties false
    end
  end
end
