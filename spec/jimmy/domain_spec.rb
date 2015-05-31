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

  end

end
