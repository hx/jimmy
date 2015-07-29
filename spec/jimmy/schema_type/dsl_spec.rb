require 'spec_helper'
require 'ostruct'

module Jimmy
  describe SchemaType::DSL do

    let(:domain) { Domain.new 'http://somewhere.kom' }
    let(:schema) { Jimmy::Schema.new(:null, domain, {}) }
    let(:dsl) { schema.dsl }

    describe 'initializer' do
      subject { Jimmy::DSL.new(schema) }

      it 'creates a reference to the schema that owns it' do
        expect(dsl.schema).to be schema
      end
    end

    describe '#attrs' do
      subject { dsl.attrs }
      it 'references schema.attrs' do
        expect(subject).to be schema.attrs
      end
    end

    describe 'evaluate' do

      subject { dsl }

      let(:proc) { Proc.new { |*args| [self, args] } }

      it 'should evaluate the given proc bound to itself' do
        expect(dsl.evaluate(proc).first).to be dsl
      end

      it 'should pass arguments to the given proc' do
        expect(dsl.evaluate proc, 7, 8).to eq [dsl, [7, 8]]
      end

    end

  end
end
