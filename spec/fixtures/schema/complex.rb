object do
  object :nothingRequired do
    number :a, 123
    string :b, %w[alpha bravo charlie]
    require none
    allow_additional
  end

  object :someRequired, :allow_additional do
    boolean :a
    boolean :b

    boolean :dontRequireMe
    require all - :dontRequireMe
  end

  string :basicString
  string :withPattern, /^foobar/
  string :withMax, max_length: 5
  string(:withMin) { min_length 5 }
  string :withRange, 5..10

  array :nullsOrNumbers, 1..6 do
    null
    number 0..255, multiple_of: 5
  end

  number :numberWithEnum, 29, [4, 84]

  any_of :nullOrNumber do
    null
    integer < 13
  end

  uuid :uniqueId
  integer :sixToTwelve, 6..12

  require :withMax, 'withMin', [:withRange, 'basicString']
end
