# frozen_string_literal: true

require 'json_schemer'

module Jimmy
  describe Schema do
    describe 'declaration' do
      it 'is not possible on a frozen schema' do
        expect { Schema.new.freeze.null }
          .to raise_error FrozenError, /frozen Jimmy::Schema/
      end

      describe '#initialize' do
        it 'can be initialized as true (match anything)' do
          expect(described_class.new(true).as_json).to be true
        end

        it 'can be initialized with JSON data' do
          expected = { 'not' => { 'type' => 'string' } }
          actual   = described_class.new(expected)
          expect(actual).to be_a described_class
          expect(actual.as_json).to eq expected
        end

        it 'rejects unknown types' do
          expect { described_class.new :foobar }
            .to raise_error Error::WrongType, 'Unexpected Symbol'
        end
      end

      describe '#title' do
        it 'sets the schema title' do
          subject.title 'Title'
          expect(subject.as_json).to eq 'title' => 'Title'
        end

        it 'only allows strings' do
          [nil, true, false, 1, 2.1, :foobar, [], {}].each do |bad_value|
            expect { subject.title bad_value }.to raise_error(
              Error::InvalidSchemaPropertyValue,
              "Expected #{bad_value.class} to be a string"
            )
          end
        end
      end

      describe '#read_only' do
        it 'sets the schema as read only' do
          subject.read_only true
          expect(subject.as_json).to eq 'readOnly' => true
          subject.read_only false
          expect(subject.as_json).to eq 'readOnly' => false
        end

        it 'does not allow non-boolean values' do
          [nil, 'foobar', 1, 2.1, :foobar, [], {}].each do |bad_value|
            expect { subject.read_only bad_value }.to raise_error(
              Error::InvalidSchemaPropertyValue,
              "Expected #{bad_value.class} to be boolean"
            )
          end
        end
      end

      describe '#nothing!' do
        it 'makes a reject-all schema' do
          expect(described_class.new.nothing).to eq Jimmy.nothing
        end
      end

      describe '#require_all' do
        it 'makes all explicitly defined properties required' do
          subject.object.property('foo', Schema.new).require_all
          expect(subject.as_json).to eq(
            'type'       => 'object',
            'properties' => {
              'foo' => true
            },
            'required'   => ['foo']
          )
        end
      end

      describe 'a complex example' do
        let :actual do
          j = Jimmy
          j.struct.require(
            id:  j.email.length(2..),
            num: j.range(4...10).multiple_of(2),
            arr: j.array.count(3..4).unique.items(j.string)
          ).nullable.not(false).allow(
            a_b: /foo/,
            ext: j.string.length(3),
            abc: j.array.count(3).items(
              [
                j.boolean,
                j.integer,
                j.range(1.0..)
              ]
            ),
            xyz: j.array.count(1..).items([j.integer], true),
            all: j.all_of(j.number, j.integer),
            one: j.one_of([j.number, j.null]),
            pat: j.pattern(/pat/),
            seq: j.if(
              j.object.allow(id: /@gmail\.com$/),
              0...100,
              1000...100_000
            )
          )
            .property(
              /^\w+_id$/ => j.integer
                .exclusive_minimum(0)
                .exclusive_maximum(1000)
            )
            .define(uuid: j.ref('uuid'))
            .property(:any, true, required: true)
            .description('test description')
            .read_only
            .write_only(false).write_only
            .enum(Set.new [j.struct])
            .example('hello')
            .default({})
            .if(true)
        end

        let :expected do
          {
            'description'          => 'test description',
            'readOnly'             => true,
            'writeOnly'            => true,
            'enum'                 => [
              {
                'type'                 => 'object',
                'additionalProperties' => false
              }
            ],
            'examples'             => ['hello'],
            'definitions'          => {
              'uuid' => { '$ref' => 'uuid#' }
            },
            'default'              => {},
            'if'                   => true,
            'additionalProperties' => false,
            'properties'           => {
              'id'  => {
                'minLength' => 2,
                'type'      => 'string',
                'format'    => 'email'
              },
              'num' => {
                'exclusiveMaximum' => 10,
                'minimum'          => 4,
                'multipleOf'       => 2,
                'type'             => 'integer'
              },
              'arr' => {
                'type'        => 'array',
                'minItems'    => 3,
                'maxItems'    => 4,
                'uniqueItems' => true,
                'items'       => { 'type' => 'string' }
              },
              'any' => true,
              'aB'  => {
                'type'    => 'string',
                'pattern' => 'foo'
              },
              'ext' => {
                'type'      => 'string',
                'minLength' => 3,
                'maxLength' => 3
              },
              'abc' => {
                'type'     => 'array',
                'minItems' => 3,
                'maxItems' => 3,
                'items'    => [
                  { 'type' => 'boolean' },
                  { 'type' => 'integer' },
                  { 'type' => 'number', 'minimum' => 1 }
                ]
              },
              'xyz' => {
                'type'            => 'array',
                'minItems'        => 1,
                'items'           => [{ 'type' => 'integer' }],
                'additionalItems' => true
              },
              'all' => {
                'allOf' => [{ 'type' => 'number' }, { 'type' => 'integer' }]
              },
              'one' => {
                'oneOf' => [{ 'type' => 'number' }, { 'type' => 'null' }]
              },
              'pat' => {
                'type'    => 'string',
                'pattern' => 'pat'
              },
              'seq' => {
                'if'   => {
                  'type'       => 'object',
                  'properties' => {
                    'id' => {
                      'type'    => 'string',
                      'pattern' => '@gmail\\.com$'
                    }
                  }
                },
                'then' => {
                  'type'             => 'integer',
                  'minimum'          => 0,
                  'exclusiveMaximum' => 100
                },
                'else' => {
                  'type'             => 'integer',
                  'minimum'          => 1000,
                  'exclusiveMaximum' => 100_000
                }
              }
            },
            'patternProperties'    => {
              '^\w+_id$' => {
                'type'             => 'integer',
                'exclusiveMinimum' => 0,
                'exclusiveMaximum' => 1000
              }
            },
            'required'             => %w[id num arr any],
            'type'                 => %w[object null],
            'not'                  => false
          }
        end

        it 'forms the expected schema' do
          expect(actual.as_json).to eq expected
        end

        it 'is a valid JSON schema (draft 7)' do
          schemer = JSONSchemer.schema(ROOT + 'schema07.json')
          errors  = schemer.validate(actual.as_json).to_a
          expect(errors).to be_empty
        end
      end

      describe 'array items' do
        before { subject.array }

        it 'does not allow a single-item after a match-all' do
          subject.items true
          expect { subject.item true }
            .to raise_error /Cannot add individual item schema/
        end

        it 'does not allow additional items with a match-all' do
          expect { subject.items true, true }
            .to raise_error /cannot specify an additional items schema/
        end
      end

      describe 'composites' do
        it 'do not allow absolutes' do
          expect { subject.any_of [true] }
            .to raise_error /Absolutes make no sense in composites/
        end
      end

      it 'rejects bad types' do
        expect { subject.type 'foo' }
          .to raise_error /Expected String to be one of/
      end

      it 'gets cranky about properties for types it does not specify' do
        expect { subject.min_items 1 }
          .to raise_error /only valid for array schemas/
      end

      it 'rejects empty enums' do
        expect { subject.enum [] }
          .to raise_error /Expected an array of at least 1 item/
      end

      it 'does not try to cast unknown values to schemas' do
        expect { subject.not Object.new }
          .to raise_error /Expected Object to be a schema/
      end

      it 'rejects require property names that are not allowed' do
        subject.additional_properties false
        expect { subject.require 'foo' }
          .to raise_error /Expected 'foo' to be an existing property/
      end

      it 'does not allow reassignment of definitions' do
        subject.define 'uuid', true
        expect { subject.define 'uuid', true }
          .to raise_error "Property 'definitions' already has a member 'uuid'"
      end

      it 'yields schemas when making a single definition' do
        subject.define :id, &:integer
        expect(subject.dig('definitions', 'id', 'type')).to eq 'integer'
      end

      it 'yields new schemas when making multiple definitions' do
        subject.definitions a: true, b: nil do |name, schema|
          expect(name).to eq 'b'
          schema.nothing
        end
        expect(subject.dig('definitions').as_json)
          .to eq 'a' => true, 'b' => false
      end

      it 'renders refs relatively' do
        foo    = Jimmy.string.pattern(/foo/)
        schema = Jimmy.object
          .define('foo', foo)
          .properties(
            a: foo,
            b: Jimmy.ref('http://example.com/bar#/definitions/foo')
          )
        expect(schema.as_json id: 'http://example.com/bar')
          .to include 'properties' => {
            'a' => { '$ref' => '#/definitions/foo' },
            'b' => { '$ref' => '#/definitions/foo' }
          }
      end

      describe 'string patterns' do
        it 'must be regular expressions' do
          expect { subject.string.pattern 'foo' }
            .to raise_error 'Expected String to be regular expression'
        end

        it 'must not have any options set' do
          expect { subject.string.pattern /foo/i }
            .to raise_error 'Expected /foo/i not to have any options'
        end
      end
    end

    describe 'automatic referencing' do
      it 'works as expected' do
        j        = Jimmy
        actual   = j.schema do |s|
          s.define 'pointless', s

          foo = j.const('foo!')
          s.define 'foo', foo
          s.object.property 'myFoo', foo

          bar = j.const('bar!')
          s.define 'a', j.schema.any_of([j.null, bar])
          s.property 'myBar', bar
          s.property 'children', j.array.items(s)
        end
        expected = {
          'definitions' => {
            'pointless' => { '$ref' => '#' },
            'foo'       => { 'const' => 'foo!' },
            'a'         => {
              'anyOf' => [
                { 'type' => 'null' },
                { 'const' => 'bar!' }
              ]
            }
          },
          'type'        => 'object',
          'properties'  => {
            'myFoo'    => { '$ref' => '#/definitions/foo' },
            'myBar'    => { '$ref' => '#/definitions/a/anyOf/1' },
            'children' => {
              'type'  => 'array',
              'items' => { '$ref' => '#' }
            }
          }
        }
        expect(actual.as_json).to eq expected
      end
    end

    describe '#get_fragment' do
      subject do
        Schema.new do |s|
          s.define 'stuff', Schema.new.any_of(
            [
              Jimmy.null,
              Jimmy.string.pattern(/junk/)
            ]
          )
        end
      end

      it 'returns the whole schema when given a blank pointer' do
        expect(subject.get_fragment '').to be subject
      end

      it 'can find definitions' do
        expect(subject.get_fragment '/definitions/stuff')
          .to be subject['definitions']['stuff']
      end

      it 'can dig into arrays' do
        expect(subject.get_fragment '/definitions/stuff/anyOf/0/type')
          .to eq 'null'
      end
    end

    describe 'operators' do
      describe '#==' do
        it 'is false for non-schemas' do
          expect(subject == :foo).to be false
        end
      end

      describe '!' do
        it 'turns anything into nothing' do
          expect(!Schema.new).to eq Jimmy.nothing
        end

        it 'turns nothing into anything' do
          expect(!!Schema.new) # rubocop:disable Style/DoubleNegation
            .to eq Schema.new
        end

        it 'returns the "not" schema if it and only it exists' do
          subject.not Jimmy.null
          expect(!subject).to eq Jimmy.null
        end

        it 'makes a "not" schema in other cases' do
          expect((!Jimmy.null).as_json).to eq 'not' => { 'type' => 'null' }
        end
      end

      describe 'composites' do
        let(:a) { Jimmy.const 'a' }
        let(:b) { Jimmy.const 'b' }
        let(:c) { Jimmy.const 'c' }

        it 'turns & into allOf' do
          expect(a & b).to eq Schema.new.all_of([a, b])
        end

        it 'turns | into anyOf' do
          expect(a | b).to eq Schema.new.any_of([a, b])
        end

        it 'turns ^ into oneOf' do
          expect(a ^ b).to eq Schema.new.one_of([a, b])
        end

        it 'nonsensically ignores identical schemas' do
          expect(a & a).to be a
          expect(a | a).to be a
          expect(a ^ a).to be a
        end

        it 'uses existing composites where possible' do
          expect(a & b & c).to eq Schema.new.all_of([a, b, c])
          expect(a | b | c).to eq Schema.new.any_of([a, b, c])
          expect(a ^ b ^ c).to eq Schema.new.one_of([a, b, c])
        end

        it 'respects operator precedence' do
          expect(a & b | c).to eq (a & b) | c
          expect(a | b & c).to eq a | (b & c)
        end
      end
    end

    describe '#as_json' do
      describe 'for a top-level "nothing" schema' do
        it 'comes out as a "not true"' do
          expected = {
            '$schema' => Schema::SCHEMA,
            '$id'     => 'file:///nada#',
            'not'     => true
          }
          expect(Jimmy.nothing.as_json(id: 'file:///nada')).to eq expected
        end
      end
    end

    describe 'literal referencing' do
      it 'is not allowed on non-empty schemas' do
        subject.null
        expect { subject.ref 'foo#' }.to raise_error /cannot have other prop/
      end

      it 'can be accessed with #target' do
        subject.ref 'a'
        expect(subject.target).to eq Json::URI.new('a#')
      end

      it 'sets the ref? predicate' do
        expect(subject).not_to be_ref
        subject.ref 'foo'
        expect(subject).to be_ref
      end
    end

    describe 'misc assignment' do
      it 'discards $id and $comment' do
        a             = Schema.new
        b             = Schema.new
        a['$id']      = 'http://foo/bar#'
        a['$comment'] = 'forget about me'
        expect(a).to eq b
      end

      it 'accepts $ref' do
        uri             = 'http://example.com/foo#'
        subject['$ref'] = uri
        expect(subject.target).to eq Json::URI.new(uri)
      end

      it 'rejects bad $schema values' do
        expect { subject['$schema'] = 'http://example.com/bad#' }
          .to raise_error Error::BadArgument, /Unsupported/
      end
    end

    it 'inspects as mostly its JSON value' do
      expect(Jimmy.nothing.inspect).to eq '#<Jimmy::Schema false>'
      expect(Jimmy.boolean.inspect).to eq '#<Jimmy::Schema {"type":"boolean"}>'
    end
  end
end
