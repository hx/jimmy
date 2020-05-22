# frozen_string_literal: true

module Jimmy
  class Schema # rubocop:disable Style/Documentation
    def ==(other)
      return false unless other.is_a? Schema

      other.as_json == as_json
    end

    # Get the opposite of this schema, by wrapping it in a new schema's +not+
    # property.
    #
    # If this schema's only property is +not+, its value will instead
    # be returned. Therefore:
    #
    #   schema.negated.negated == schema
    #
    # Since +#!+ is an alias for +#negated+, this also works:
    #
    #   !!schema == schema
    #
    # Schemas matching absolutes +ANYTHING+ or +NOTHING+ will return the
    # opposite absolute.
    # @return [Jimmy::Schema]
    def negated
      return ANYTHING if nothing?
      return NOTHING if anything?
      return get('not') if @properties.keys == ['not']

      Schema.new.not self
    end

    # Combine this schema with another schema using an +allOf+ schema. If this
    # schema's only property is +allOf+, its items will be flattened into the
    # new schema.
    #
    # Since +#&+ is an alias of +#and+, the following two statements are
    # equivalent:
    #
    #   schema.and(other)
    #   schema & other
    # @param [Jimmy::Schema] other The other schema.
    # @return [Jimmy::Schema] The new schema.
    def and(other)
      make_new_composite 'allOf', other
    end

    # Combine this schema with another schema using an +anyOf+ schema. If this
    # schema's only property is +anyOf+, its items will be flattened into the
    # new schema.
    #
    # Since +#|+ is an alias of +#or+, the following two statements are
    # equivalent:
    #
    #   schema.or(other)
    #   schema | other
    # @param [Jimmy::Schema] other The other schema.
    # @return [Jimmy::Schema] The new schema.
    def or(other)
      make_new_composite 'anyOf', other
    end

    # Combine this schema with another schema using a +oneOf+ schema. If this
    # schema's only property is +oneOf+, its items will be flattened into the
    # new schema.
    #
    # Since +#^+ is an alias of +#xor+, the following two statements are
    # equivalent:
    #
    #   schema.xor(other)
    #   schema ^ other
    # @param [Jimmy::Schema] other The other schema.
    # @return [Jimmy::Schema] The new schema.
    def xor(other)
      make_new_composite 'oneOf', other
    end

    alias & and
    alias | or
    alias ^ xor
    alias ! negated

    private

    def make_new_composite(name, other)
      return self if other == self

      this = @properties.keys == [name] ? get(name) : [self]
      Schema.new.instance_exec { set_composite name, [*this, other] }
    end
  end
end
