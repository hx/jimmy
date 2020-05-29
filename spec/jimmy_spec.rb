# frozen_string_literal: true

describe Jimmy do
  it 'has a version number' do
    expect(Jimmy::VERSION).not_to be nil
  end

  it 'responds to things that Schema responds to' do
    expect(Jimmy).to respond_to :struct
    expect(Jimmy).not_to respond_to :trucked
    expect { Jimmy.trucked }.to raise_error NoMethodError
  end

  describe '#Schema' do
    it 'selectively casts to Schema' do
      x = Jimmy.null
      expect(Jimmy::Schema(x)).to be x
      expect(Jimmy::Schema(/foo/)).to eq Jimmy.string.pattern(/foo/)
    end
  end
end
