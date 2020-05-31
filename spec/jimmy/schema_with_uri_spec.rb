# frozen_string_literal: true

module Jimmy
  describe SchemaWithURI do
    let(:schema) { Schema.new }
    let(:uri) { JsonURI.new 'http://foo#' }

    subject { described_class.new uri, schema }

    describe '#to_json' do
      it 'makes a JSON string' do
        expect(subject.to_json).to eq <<~JSON.strip
          {"$id":"http://foo#","$schema":"#{Schema::SCHEMA}"}
        JSON
      end
    end

    describe '#resolve' do
      it 'rejects relative URIs' do
        expect { subject.resolve '/foo' }
          .to raise_error Error::BadArgument, /relative URIs/
      end

      it 'rejects URIs that do not match its own' do
        expect { subject.resolve 'http://bar#' }
          .to raise_error Error::BadArgument, /Wrong URI base/
      end
    end
  end
end
