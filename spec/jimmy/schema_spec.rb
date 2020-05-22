# frozen_string_literal: true

module Jimmy
  describe Schema do
    describe 'declaration' do
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

      describe '#description'

      describe '#default'

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

      describe '#require_all' do
        it 'makes all explicitly defined properties required' do
          subject.object!.property('foo', Schema.new).require_all
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
        it 'forms the expected schema' do
          j        = Jimmy
          actual   = j.struct(
            id:  j.string.length(2..).email!,
            num: j.integer.range(5...10)
          ).nullable
          expected = {
            'additionalProperties' => false,
            'properties'           => {
              'id'  => {
                'minLength' => 2,
                'type'      => 'string',
                'format'    => 'email'
              },
              'num' => {
                'exclusiveMaximum' => 10,
                'minimum'          => 5,
                'type'             => 'integer'
              }
            },
            'required'             => %w[id num],
            'type'                 => %w[object null]
          }
          expect(actual.as_json).to eq expected
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
          s.object!.property 'myFoo', foo

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
  end
end
