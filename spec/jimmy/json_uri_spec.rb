# frozen_string_literal: true

module Jimmy
  describe JsonURI do
    subject { described_class.new '' }

    describe 'with the :container option set' do
      it 'appends a slash when none is present' do
        expect(described_class.new('/foo', container: true).to_s).to eq '/foo/'
        expect(described_class.new('/foo/', container: true).to_s).to eq '/foo/'
      end
    end

    describe '#inspect' do
      it 'focuses on the URI' do
        expect(described_class.new('http://foo.com/bar#/baz').inspect)
          .to eq '#<Jimmy::JsonURI http://foo.com/bar#/baz>'
      end
    end

    it 'does not try to delegate unknown methods to its URI instance' do
      expect { subject.foobar }.to raise_error NoMethodError
    end

    describe '#as_json' do
      subject { described_class.new 'http://example.com/foo#' }

      it 'is complete when no id is given' do
        expect(subject.as_json).to eq 'http://example.com/foo#'
      end

      it 'is relative when an ID is given' do
        expect(subject.as_json id: 'http://example.com/foo/').to eq '../foo#'
      end
    end
  end
end
