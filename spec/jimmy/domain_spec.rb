# frozen_string_literal: true

module Jimmy
  describe Domain do
    let(:uri) { 'http://example.com' }

    subject { described_class.new uri }

    it 'has a URI' do
      expect(subject.uri).to be_a URI
      expect(subject.uri.to_s).to eq 'http://example.com/'
    end

    context 'with fixtures loaded' do
      before { subject.load_directory FIXTURES, suffix: '' }

      it 'has schemas' do
        user = subject['user']
        expect(user).to be_a DomainBoundSchema
        expect(user.uri).to eq URI('http://example.com/user#')
        expect(user.domain).to be subject
        expect(user.as_json['type']).to eq 'object'
      end

      it 'can resolve fragments of its children' do
        id = subject['user#/properties/id']
        expect(id).to be_a DomainBoundSchema
        expect(id.uri).to eq URI('http://example.com/user#/properties/id')
        expect(id.as_json['minLength']).to eq 8
      end
    end
  end
end
