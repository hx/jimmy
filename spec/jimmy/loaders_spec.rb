# frozen_string_literal: true

module Jimmy
  describe Loaders do
    describe described_class::Base do
      it 'cannot load anything on its own' do
        expect { described_class.call 'foo' }
          .to raise_error NotImplementedError
      end
    end

    describe described_class::Ruby do
      subject { described_class.new FIXTURES + 'nothing.rb' }

      it 'can load files other than its source' do
        expect(subject.load 'user.rb').to be_a Schema
      end
    end
  end
end
