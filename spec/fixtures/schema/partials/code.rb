uuid :id
object :references do
  one_of :code do
    null
    number [specifically]
  end
end
