# frozen_string_literal: true

module Jimmy
  describe FileMap do
    let(:uri) { JsonURI.new 'http://example.com' }

    it "rejects directories that aren't directories" do
      expect { described_class.new 'jimmy.gemspec', 'file:///' }
        .to raise_error Error::BadArgument, /directory/
    end

    it 'uses file URIs by default' do
      skip 'Try running this on Linux or macOS' unless File::SEPARATOR == '/'

      expect(described_class.new(FIXTURES).index.uris.map(&:to_s))
        .to include "file://#{FIXTURES}/uuid#"
    end

    describe 'when trying to read an unreadable file' do
      let(:bad_loader) { double call: nil }
      let(:loaders) { FileMap::DEFAULT_LOADERS.merge('bad' => bad_loader) }
      let(:unreadable) { FIXTURES + 'unreadable.bad' }

      subject { FileMap.new FIXTURES, uri, loaders: loaders, live: true }

      before do
        @old_mode = unreadable.stat.mode
        unreadable.chmod 0o333 & @old_mode
      end

      after { unreadable.chmod @old_mode }

      it 'returns nil and issues a warning' do
        expect(subject).to receive(:warn).with "Jimmy cannot read #{unreadable}"
        expect(subject.resolve 'unreadable').to be nil
      end
    end

    describe 'with live-reloading' do
      subject { FileMap.new FIXTURES, uri, live: true }

      it 'can resolve relative URIs' do
        user = subject.resolve('user')
        expect(user).to be_a SchemaWithURI
        expect(user.uri).to eq JsonURI.new('http://example.com/user#')
        expect(user.schema['type']).to eq 'object'
      end

      it 'can produce an index' do
        expect(subject.index).to be_an Index
        expect(subject.index.keys).to eq [
          JsonURI.new('http://example.com/user#'),
          JsonURI.new('http://example.com/uuid#')
        ]
      end

      describe 'with a suffix' do
        subject do
          described_class.new FIXTURES, uri, suffix: '.json', live: true
        end

        it 'adds the suffix to URIs' do
          expect(subject.index)
            .to have_key JsonURI.new('http://example.com/user.json#')
        end

        it 'can resolve with or without the suffix' do
          expect(subject.resolve 'user').to be_a SchemaWithURI
          expect(subject.resolve 'user').to eq subject.resolve('user.json')
        end
      end

      it 'returns nil when resolving a nonexistent file' do
        expect(subject.resolve 'crickets').to be_nil
      end

      it 'raises when trying to resolve a file from elsewhere' do
        expect { subject.resolve 'https://example.com/user' }
          .to raise_error /URI is outside/
      end
    end

    describe 'without live-reloading' do
      subject { FileMap.new FIXTURES, uri }

      it 'can resolve relative URIs' do
        user = subject.resolve('user')
        expect(user).to be_a SchemaWithURI
        expect(user.uri).to eq JsonURI.new('http://example.com/user#')
        expect(user.schema['type']).to eq 'object'
      end

      it 'can produce an index' do
        expect(subject.index).to be_an Index
        expect(subject.index.keys).to eq [
          JsonURI.new('http://example.com/user#'),
          JsonURI.new('http://example.com/uuid#')
        ]
      end

      describe 'with a suffix' do
        subject do
          described_class.new FIXTURES, uri, suffix: '.json'
        end

        it 'adds the suffix to URIs' do
          expect(subject.index)
            .to have_key JsonURI.new('http://example.com/user.json#')
        end

        it 'can resolve with or without the suffix' do
          expect(subject.resolve 'user').to be_a SchemaWithURI
          expect(subject.resolve 'user').to be subject.resolve('user.json')
        end
      end

      it 'returns nil when resolving a nonexistent file' do
        expect(subject.resolve 'crickets').to be_nil
      end

      it 'raises when trying to resolve a file from elsewhere' do
        expect { subject.resolve 'https://example.com/user' }
          .to raise_error /URI is outside/
      end
    end
  end
end
