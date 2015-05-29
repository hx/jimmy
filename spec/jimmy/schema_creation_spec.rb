require 'spec_helper'

module Jimmy
  describe SchemaCreation do

    class SampleClass
      attr_reader :results
      def initialize
        @results = []
      end
      def domain
        @domain ||= Domain.new('http://sample.kom')
      end
    end

    SchemaCreation.apply_to SampleClass do |schema, some_arg|
      results << schema
      results << some_arg
    end

    let(:sample_instance) { SampleClass.new }

    before :each do
      sample_instance.domain.types[:even_positive] = sample_instance.domain.number minimum: 0, multiple_of: 2
    end

    it 'gives classes schema-creation methods' do
      sample_instance.string :this_arg, 3..6 do
        pattern /hello/
      end

      expect(sample_instance.results.length).to be 2
      expect(sample_instance.results.last).to be :this_arg

      created_schema = sample_instance.results.first
      expect(created_schema).to be_a Schema
      expect(created_schema.type).to be :string
      expect(created_schema.attrs).to eq min_length: 3, max_length: 6, pattern: 'hello'
    end

    it 'looks to the instance method :domain of the given class for resolving custom types' do
      sample_instance.even_positive :that_arg

      expect(sample_instance.results).to eq %i(even_positive that_arg)
    end

    it 'allows combinations' do
      sample_instance.all_of :switch_me do
        number > 20 < 85
        even_positive
      end

      expect(sample_instance.results.length).to be 2

      combo, arg = sample_instance.results
      expect(arg).to be :switch_me
      expect(combo).to be_a Combination
      expect(combo.condition).to be :all
      expect(combo.length).to be 2

      num, pos = combo.to_a
      expect(num).to be_a Schema
      expect(num.type).to be :number
      expect(num.attrs).to eq minimum: 20, maximum: 85, exclusive_minimum: true, exclusive_maximum: true
      expect(pos).to be :even_positive
    end

  end
end
