# frozen_string_literal: true

struct(
  id:    ref('/uuid#'),
  email: string.email!,
  age:   13..
)
