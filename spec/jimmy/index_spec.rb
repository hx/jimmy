# frozen_string_literal: true

module Jimmy
  describe Index do
    it 'does not allow resolution of relative URIs' do
      expect { subject.resolve '/foo' }
        .to raise_error /Cannot resolve relative/
    end

    it 'can resolve partial schemas' do
      schema = Jimmy.schema.define('baz', Jimmy.boolean)
      subject['http://foo/bar'] = schema
      expect(subject.resolve('http://foo/bar#/definitions/baz').schema)
        .to eq Jimmy.boolean
    end

    it 'returns nil when partials are not found' do
      subject['http://foo/bar'] = Jimmy.struct.require(foo: true)
      expect(subject.resolve 'http://foo/bar#/properties/foo').not_to be nil
      expect(subject.resolve 'http://foo/bar#/properties/bar').to be nil
      expect(subject.resolve 'http://foo/baz#/properties/bar').to be nil
    end

    it 'rejects non-schemas' do
      expect { subject.add 'http://foo', true }
        .to raise_error 'Expected a schema'
    end

    it 'rejects relative URIs' do
      expect { subject.add '/foo', Schema.new }
        .to raise_error 'Cannot index relative URIs'
    end

    it 'rejects bad values on push' do
      expect { subject << Schema.new }
        .to raise_error 'Expected a SchemaWithURI'
    end

    it 'is enumerable' do
      subject['http://foo/bar'] = Schema.new
      expect(subject.each).to be_an Enumerator
      expect(subject.each.to_a)
        .to eq [SchemaWithURI.new('http://foo/bar', Schema.new)]
    end
  end
end
