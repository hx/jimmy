# frozen_string_literal: true

module Jimmy
  describe JsonPointer do
    describe 'parsing and stringification' do
      cases = {
        ''          => [],
        '/'         => [''],
        '/foo'      => ['foo'],
        '/foo//bar' => ['foo', '', 'bar'],
        '/foo/bar'  => %w[foo bar],
        '/f~0o'     => ['f~o'],
        '/f~0ob~1r' => ['f~ob/r']
      }
      cases.each do |str, arr|
        it "parses #{str.to_json} to #{arr.to_json}" do
          expect(described_class.new(str).to_a).to eq arr
        end

        it "stringifies #{arr.to_json} to #{str.to_json}" do
          expect(described_class.new(arr).to_s).to eq str
        end
      end
    end

    describe 'joining' do
      subject { described_class.new '/foo' }

      let(:foobar) { JsonPointer.new '/foo/bar' }

      it 'can join strings' do
        expect(subject + '/bar').to eq foobar
      end

      it 'automatically adds slashes' do
        expect(subject + 'bar').to eq foobar
      end

      it 'accepts other pointers' do
        expect(subject + JsonPointer.new('/bar')).to eq foobar
      end

      it 'accepts arrays' do
        expect(subject + ['bar']).to eq foobar
      end
    end

    describe 'shedding' do
      subject { described_class.new '/foo/bar' }

      it 'removes segments' do
        expect(subject - 1).to eq JsonPointer.new('/foo')
        expect(subject - 2).to eq JsonPointer.new('')
      end

      it 'can no-op' do
        expect(subject - 0).to eq JsonPointer.new('/foo/bar')
      end

      it 'cannot go negative' do
        expect { subject - 3 }.to raise_error ArgumentError, /Out of range/
      end

      it 'works with join using negatives' do
        expect(subject.join -1).to eq JsonPointer.new('/foo')
      end

      it 'rejects non-integer values' do
        expect { subject.shed 'bar' }
          .to raise_error /Expected a non-negative integer/
      end
    end

    describe '#remove_prefix' do
      it 'removes the given pointer if it matches from the front' do
        abc = described_class.new('/a/b/c')
        ab  = described_class.new('/a/b')
        ac  = described_class.new('/a/c')
        c   = described_class.new('/c')

        expect(abc.remove_prefix(ab)).to eq c
        expect(abc.remove_prefix(ac)).to be nil
      end
    end

    it 'does not accept symbols' do
      expect { JsonPointer.new :foobar }.to raise_error TypeError
    end

    it 'does not accept strings that do not start with a slash' do
      expect { JsonPointer.new 'foobar' }.to raise_error ArgumentError
    end

    describe '#inspect' do
      it 'includes the path' do
        expect(JsonPointer.new('/foo').inspect)
          .to eq '#<Jimmy::JsonPointer /foo>'
      end
    end

    describe '#empty?' do
      it 'is true for an empty instance' do
        expect(JsonPointer.new('')).to be_empty
        expect(JsonPointer.new('/')).not_to be_empty
      end
    end
  end
end
