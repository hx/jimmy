require 'spec_helper'

describe Jimmy::Domain do

  subject { Jimmy::Domain.new('https://example.kom') }

  it 'has a root_uri' do
    expect(subject.root).to be_a URI
    expect(subject.root.to_s).to eq 'https://example.kom'
  end

  context 'with an imported schema set' do

    before { subject.import SPEC_ROOT + 'fixtures/schema' }

    it 'provides access to each schema' do
      expect(subject[:complex]).to be_a Jimmy::Schema
    end

    it 'allows access by symbol or string' do
      expect(subject[:complex]).to be subject['complex']
    end

    describe '#export' do
      it 'exports compiled schemas' do
        subject.export TEMP_ROOT
        complex_path = TEMP_ROOT + 'complex.json'
        expect(complex_path).to exist
        expect(JSON.parse complex_path.read).to eq subject[:complex].to_h
      end

      it 'expects a path as its first argument' do
        expect { subject.export }.to raise_error /Please specify an export directory/
      end
    end

  end

end
