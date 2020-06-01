# frozen_string_literal: true

module Jimmy
  module Declaration
    def struct
      object.additional_properties false
    end
  end
end
