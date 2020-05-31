# frozen_string_literal: true

require 'json_schemer'
require 'securerandom'

module Jimmy
  describe SchemerFactory do
    let(:files) { FileMap.new FIXTURES, 'http://example.com' }
    let(:schema) { files['user'] }
    let(:cache_resolvers) { true }

    let :valid_user do
      {
        'id'    => SecureRandom.uuid,
        'email' => 'someone@example.com',
        'age'   => 15
      }
    end

    subject do
      described_class.new schema, files, cache_resolvers: cache_resolvers
    end

    let(:schemer) { subject.schemer }

    it 'fails when the json_schemer gem is not available' do
      allow(SchemerFactory).to receive(:available?).and_return false
      expect { subject }.to raise_error LoadError, /json_schemer gem/
    end

    it 'makes a JSONSchemer::Schema from the given schema' do
      expect(schemer).to be_a JSONSchemer::Schema::Base
    end

    it 'can validate a user' do
      expect(schemer.valid? valid_user).to be true
    end

    it 'is available by the Jimmy.schemer shortcut' do
      expect(Jimmy.schemer schema, files).to be_a JSONSchemer::Schema::Base
    end

    it 'understands the net/http shortcut' do
      uri = 'http://foo#'
      expect(Net::HTTP).to receive(:get).with(URI uri).and_return('{}')
      schema = Jimmy.ref(uri)
      expect(Jimmy.schemer(schema, 'net/http').valid?({})).to be true
    end

    it 'expects resolvers to respond to :resolve' do
      expect { Jimmy.schemer schema, -> {} }
        .to raise_error Error::BadArgument, /responding to :resolve/
    end

    it 'can step through multiple resolvers' do
      empty = double
      expect(empty).to receive(:resolve)
        .once.with(URI 'http://example.com/uuid#').and_return nil
      expect(Jimmy.schemer(schema, empty, files).valid? valid_user).to be true
    end

    it 'caches resolved schemas' do
      expect(files).to receive(:resolve).once.and_call_original
      2.times { schemer.valid? valid_user }
    end

    describe 'without resolver caching' do
      let(:cache_resolvers) { false }

      it 'resolves schemas every time' do
        expect(files).to receive(:resolve).twice.and_call_original
        2.times { schemer.valid? valid_user }
      end
    end

    it 'has no resolver by default' do
      expect { Jimmy.schemer(schema).valid? valid_user }
        .to raise_error JSONSchemer::UnknownRef, /uuid#/
    end
  end
end
