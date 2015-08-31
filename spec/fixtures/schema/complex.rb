object do
  title 'Complex'
  description 'This is a complex schema example'

  set foo: 'bar'

  definitions do
    object :subSchema do
      string :id
    end
    object :anotherSchema do
      string :name
    end
  end

  define :object, :inlineSubSchema do
    integer :id
  end

  subSchema :instanceOfSubSchema
  ref :instanceOfAnother, definition(:anotherSchema)
  ref :instanceOfInlineSubSchema, '/complex#/definitions/inlineSubSchema'

  include :code, specifically: 7

  link relation: 'uri'
  link relation: 'address' do
    title 'A link'
    method :patch
    schema do
      integer :id
    end
    target_schema do
      string :result
      allow_additional
    end
    set this: 'to_that'
  end
  link something: 'to_this' do
    schema :subSchema
    target_schema ref: 'this_reference'
  end

  object :nothingRequired do
    description 'Nothing required'
    number :a, 123
    string :b, %w[alpha bravo charlie]
    require none
    allow_additional
  end

  object :someRequired, :allow_additional do
    nullable
    boolean :a
    boolean :b

    boolean :dontRequireMe
    require all - :dontRequireMe
  end

  string :basicString
  string :withTitle, title: 'String with title'
  string :withPattern, /^foobar/
  string :withMax, max_length: 5
  string(:withMin) { min_length 5 }
  string :withRange, 5..10

  string :withFormat, format: 'ipv4'
  string :withFormatShortcut, :ipv6

  array :nullsOrNumbers, 1..6, :unique do
    null
    ref '/here'
    subSchema
    number 0..255, multiple_of: 5
  end

  number :numberWithEnum, 29, [4, 84]

  any_of :nullOrNumber do
    description 'Null or number'
    null
    integer < 13
  end

  uuid :uniqueId
  integer :sixToTwelve, 6..12

  object_array :objectArray, :nullable, min_items: 3 do
    string :id, format: 'uuid'
    require all
  end

  require :withMax, 'withMin', [:withRange, 'basicString']
end
