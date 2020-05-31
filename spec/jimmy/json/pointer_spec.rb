# frozen_string_literal: true

module Jimmy
  describe Json::Pointer do
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

      let(:foobar) { Json::Pointer.new '/foo/bar' }

      it 'can join strings' do
        expect(subject + '/bar').to eq foobar
      end

      it 'automatically adds slashes' do
        expect(subject + 'bar').to eq foobar
      end

      it 'accepts other pointers' do
        expect(subject + Json::Pointer.new('/bar')).to eq foobar
      end

      it 'accepts arrays' do
        expect(subject + ['bar']).to eq foobar
      end
    end

    describe 'shedding' do
      subject { described_class.new '/foo/bar' }

      it 'removes segments' do
        expect(subject - 1).to eq Json::Pointer.new('/foo')
        expect(subject - 2).to eq Json::Pointer.new('')
      end

      it 'can no-op' do
        expect(subject - 0).to eq Json::Pointer.new('/foo/bar')
      end

      it 'cannot go negative' do
        expect { subject - 3 }.to raise_error Error::BadArgument, /Out of range/
      end

      it 'works with join using negatives' do
        expect(subject.join -1).to eq Json::Pointer.new('/foo')
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
      expect { Json::Pointer.new :foobar }.to raise_error Error::WrongType
    end

    it 'does not accept strings that do not start with a slash' do
      expect { Json::Pointer.new 'foobar' }.to raise_error Error::BadArgument
    end

    describe '#inspect' do
      it 'includes the path' do
        expect(Json::Pointer.new('/foo').inspect)
          .to eq '#<Jimmy::Json::Pointer /foo>'
      end
    end

    describe '#empty?' do
      it 'is true for an empty instance' do
        expect(Json::Pointer.new('')).to be_empty
        expect(Json::Pointer.new('/')).not_to be_empty
      end
    end
  end
end
