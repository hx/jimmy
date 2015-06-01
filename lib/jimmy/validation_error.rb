require 'ostruct'

module Jimmy
  class ValidationError < StandardError

    attr_reader :schema, :data, :errors

    def initialize(schema, data, errors)
      @schema = schema
      @data   = data
      @errors = errors.map do |info|
        OpenStruct.new(
            property: info[:fragment][2..-1],
            message:  info[:message].gsub(/ in schema \S+$/, ''),
            aspect:   info[:failed_attribute]
        )
      end
    end
  end
end
