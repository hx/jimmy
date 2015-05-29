require 'spec_helper'

SymbolArray = Jimmy::SymbolArray

describe SymbolArray do

  it 'is a subclass of Array' do
    expect(SymbolArray).to be_a Class
    expect(SymbolArray < Array).to be true
  end

  it 'can be converted to an array' do
    expect(SymbolArray.new.to_a.class).to be Array
  end

  it 'stringifies items on create' do
    expect(SymbolArray.new(['a', :b, 6]).to_a).to eq %w(a b 6)
  end

  it 'stringifies items on push and unshift' do
    array = SymbolArray.new
    array << :a
    array.push :b
    array.unshift :c
    expect(array.to_a).to eq %w(c a b)
  end

  describe 'subtraction' do

    let(:initial) { SymbolArray.new :a, :b, :c }

    example 'of a string' do
      expect(initial - 'a').to eq SymbolArray.new(:b, :c)
    end

    example 'of a string and a symbol' do
      expect(initial - :a - 'b').to eq SymbolArray.new(:c)
    end

    example 'of an array' do
      expect(initial - [:a, 'c']).to eq SymbolArray.new(:b)
    end

  end

  describe 'addition' do

    let(:initial) { SymbolArray.new :a }

    example 'of a string' do
      expect(initial + 'b').to eq SymbolArray.new('a', :b)
    end

    example 'of a mixture' do
      expect(initial + [:b, 'c'] + :d + 'e' + ['f']).to eq SymbolArray.new(%w[a b c d e f])
    end

  end

  describe 'pipe method (or: |)' do

    let(:initial) { SymbolArray.new :a, :b, :c }

    example 'with a string' do
      expect(initial | 'b').to eq SymbolArray.new(:a, :b, :c)
      expect(initial | 'd').to eq SymbolArray.new(:a, :b, :c, :d)
    end

    example 'with a symbol' do
      expect(initial | :b).to eq SymbolArray.new(:a, :b, :c)
      expect(initial | :d).to eq SymbolArray.new(:a, :b, :c, :d)
    end

    example 'with a mixed array' do
      expect(initial | ['a', :b]).to eq SymbolArray.new(:a, :b, :c)
      expect(initial | ['a', :b, 'e', :f]).to eq SymbolArray.new(:a, :b, :c, :e, :f)
      expect(initial | ['e', :f]).to eq SymbolArray.new(:a, :b, :c, :e, :f)
    end

  end

  describe 'ampersand method (and: &)' do

    let(:initial) { SymbolArray.new :a, :b, :c }

    example 'with a string' do
      expect(initial & 'b').to eq SymbolArray.new(:b)
      expect(initial & 'd').to eq SymbolArray.new()
    end

    example 'with a symbol' do
      expect(initial & :b).to eq SymbolArray.new(:b)
      expect(initial & :d).to eq SymbolArray.new()
    end

    example 'with a mixed array' do
      expect(initial & ['a', :b]).to eq SymbolArray.new(:a, :b)
      expect(initial & ['a', :b, 'e', :f]).to eq SymbolArray.new(:a, :b)
      expect(initial & ['e', :f]).to eq SymbolArray.new()
    end

  end

  describe 'uniqueness' do

    let(:initial) { SymbolArray.new :a, :c, :a, :b, :a, :c, :b }
    let(:unique) { SymbolArray.new :a, :c, :b }

    describe 'with #uniq' do
      it 'returns a new SymbolArray' do
        expect(initial.uniq).to be_a SymbolArray
        expect(initial.uniq).to eq unique
      end
    end

    describe 'with #uniq!' do
      it 'unique-ifies the object' do
        initial.uniq!
        expect(initial).to eq unique
      end
    end

  end

end
