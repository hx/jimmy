module Jimmy
  class SymbolArray < Array

    def initialize(*args)
      super args.flatten.map(&:to_s)
    end

    %i(<< push unshift).each do |method|
      define_method(method) { |*args| super *args.map(&:to_s) }
    end

    %i(+ - | &).each do |method|
      define_method(method) { |*args| SymbolArray.new(super args.flatten.map(&:to_s)) }
    end

  end
end
