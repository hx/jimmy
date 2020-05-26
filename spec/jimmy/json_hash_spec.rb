# frozen_string_literal: true

module Jimmy
  describe JsonHash do
    it 'does not allow numeric keys' do
      expect { subject[123] = true }
        .to raise_error TypeError, 'Invalid hash key of type Integer'
    end

    it 'does not allow values that cannot be represented as JSON' do
      expect { subject['abc'] = :abc }
        .to raise_error TypeError, 'Incompatible JSON type Symbol'
    end

    it 'converts symbol keys to camel case strings' do
      subject[:foo_bar] = 1
      expect(subject.as_json).to eq 'fooBar' => 1
    end

    it 'allows values responding to :as_json' do
      subject['abc'] = double(as_json: 123)
      expect(subject.as_json).to eq 'abc' => 123
    end

    it 'provides an iterator' do
      subject['a'] = 1
      iterator = subject.each
      expect(iterator.next).to eq ['a', 1]
      expect { iterator.next }.to raise_error StopIteration
    end

    it 'allows a block with a single argument to iterate over values' do
      subject['a'] = 1
      results = []
      subject.each do |num|
        results << num
      end
      expect(results).to eq [1]
    end

    it 'inspects as pure JSON' do
      subject['a'] = 1
      expect(subject.inspect).to eq '{"a":1}'
    end
  end
end
