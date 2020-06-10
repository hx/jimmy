# frozen_string_literal: true

module Jimmy
  describe Json::Array do
    describe '#each' do
      it 'can iterate over just its members' do
        subject << 1
        found = []
        subject.each { |x| found << x }
        expect(found).to eq [1]
      end

      it 'iterates over indexes and values' do
        subject << 'a'
        iter = subject.each
        expect(iter).to be_an Enumerator
        expect(iter.next).to eq [0, 'a']
        expect { iter.next }.to raise_error StopIteration
      end
    end

    describe '#length' do
      it 'is the length of the array' do
        expect { subject << 1 }.to change { subject.length }.from(0).to 1
      end
    end

    describe '#dig' do
      before { subject << { 'a' => 1 } }

      it 'accepts integers' do
        expect(subject.dig 0, 'a').to eq 1
      end

      it 'accepts strings' do
        expect(subject.dig '0', 'a').to eq 1
      end

      it 'rejects other kinds of keys' do
        expect { subject.dig :'0' }.to raise_error /Invalid array index/
      end
    end

    describe '#concat' do
      it 'accepts sets' do
        arr = described_class.new
        expect { arr.concat Set.new([1, 2]) }.to change { arr.length }.by 2
      end
    end
  end
end
