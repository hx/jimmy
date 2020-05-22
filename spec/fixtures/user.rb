# frozen_string_literal: true

struct(
  id:    string.length(8),
  email: string.email!,
  some:  /thing/
)
