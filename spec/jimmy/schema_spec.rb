require 'spec_helper'

describe Jimmy::Schema do
  let :domain do
    Jimmy::Domain.new('https://example.kom').tap do |d|
      d.import SPEC_ROOT + 'fixtures/schema'
    end
  end

  describe 'integer schema' do
    subject { domain[:integer] }
    describe '#to_h' do
      it 'matches the expected output' do
        expected = {
            '$schema'          => 'http://json-schema.org/draft-04/schema#',
            'id'               => 'https://example.kom/integer.json#',
            'type'             => 'integer',
            'maximum'          => 100,
            'exclusiveMaximum' => true
        }
        expect(subject.to_h).to eq expected
      end
    end
  end

  describe 'complex schema' do

    subject { domain[:complex] }

    describe '#to_h' do
      it 'matches the expected output' do
        expected = {
            '$schema'              => 'http://json-schema.org/draft-04/schema#',
            'id'                   => 'https://example.kom/complex.json#',
            'type'                 => 'object',
            'properties'           => {
                'nothingRequired' => {
                    'type'                 => 'object',
                    'properties'           => {
                        'a' => {
                            'type'    => 'number',
                            'minimum' => 123,
                            'maximum' => 123
                        },
                        'b' => {
                            'type' => 'string',
                            'enum' => %w(alpha bravo charlie)
                        }
                    },
                    'required'             => [],
                    'additionalProperties' => true
                },
                'someRequired'    => {
                    'type'                 => 'object',
                    'properties'           => {
                        'a'             => {'type' => 'boolean'},
                        'b'             => {'type' => 'boolean'},
                        'dontRequireMe' => {'type' => 'boolean'}
                    },
                    'required'             => %w(a b),
                    'additionalProperties' => true
                },
                'basicString'     => {'type' => 'string'},
                'withPattern'     => {
                    'type'    => 'string',
                    'pattern' => '^foobar'
                },
                'withMax'         => {
                    'type'      => 'string',
                    'maxLength' => 5
                },
                'withMin'         => {
                    'type'      => 'string',
                    'minLength' => 5
                },
                'withRange'       => {
                    'type'      => 'string',
                    'minLength' => 5,
                    'maxLength' => 10
                },
                'nullsOrNumbers'  => {
                    'type'     => 'array',
                    'minItems' => 1,
                    'maxItems' => 6,
                    'items'    => {
                        'anyOf' => [
                            {'type' => 'null'},
                            {
                                'type'       => 'number',
                                'minimum'    => 0,
                                'maximum'    => 255,
                                'multipleOf' => 5
                            }
                        ]
                    }
                },
                'nullOrNumber'    => {
                    'anyOf' => [
                        {'type' => 'null'},
                        {
                            'type'             => 'integer',
                            'maximum'          => 13,
                            'exclusiveMaximum' => true
                        }
                    ]
                },
                'uniqueId'        => {'$ref' => '/types/uuid.json#'},
                'sixToTwelve'     => {'type' => 'integer', 'minimum' => 6, 'maximum' => 12}
            },
            'required'             => %w(withMax withMin withRange basicString),
            'additionalProperties' => false
        }
        expect(subject.to_h).to eq expected
      end
    end

  end

  describe 'city schema' do
    subject { domain[:city] }
    it 'matches the expected output' do
      expected = {
          '$schema'              => 'http://json-schema.org/draft-04/schema#',
          'id'                   => 'https://example.kom/city.json#',
          'type'                 => 'object',
          'properties'           => {
              'name'               => {
                  'type'      => 'string',
                  'minLength' => 2
              },
              'postcode'           => {
                  'type'    => 'string',
                  'pattern' => '^\\d{4}$'
              },
              'population'         => {'type' => 'integer'},
              'location'           => {'$ref' => '/types/geopoint.json#'},
              'country'            => {'$ref' => '/types/country_code.json#'},
              'points_of_interest' => {
                  'type'  => 'array',
                  'items' => {
                      'type'                 => 'object',
                      'properties'           => {
                          'title'      => {
                              'type'      => 'string',
                              'minLength' => 3,
                              'maxLength' => 149
                          },
                          'popularity' => {
                              'type'    => 'integer',
                              'minimum' => 1,
                              'maximum' => 5
                          },
                          'location'   => {'$ref' => '/types/geopoint.json#'},
                          'featured'   => {'type' => 'boolean'}
                      },
                      'required'             => %w(title),
                      'additionalProperties' => false
                  }
              },
              'created_at'         => {'$ref' => '/types/timestamp.json#'},
              'updated_at'         => {'$ref' => '/types/timestamp.json#'}
          },
          'required'             => %w(name postcode population country points_of_interest created_at updated_at),
          'additionalProperties' => false
      }
      expect(subject.to_h).to eq expected
    end

    describe 'validation' do

      let(:valid_schema) { {
          'name'               => 'Sydney',
          'postcode'           => '2000',
          'population'         => 5000000,
          'location'           => {'latitude' => -33.8271, 'longitude' => 151.2733},
          'country'            => 'AU',
          'points_of_interest' => [
              {
                  'title'      => 'Port Jackson',
                  'popularity' => 3,
                  'location'   => {'latitude' => -33.8271, 'longitude' => 151.2733},
                  'featured'   => true
              }
          ],
          'created_at'         => '2015-06-01T14:06:25+10:00',
          'updated_at'         => '2015-06-01T14:06:26+10:00',
      } }

      let(:invalid_schema) { valid_schema.merge({'postcode' => 2000}) }

      it 'validates a valid schema' do
        expect { subject.validate valid_schema }.not_to raise_error
      end

      it 'raises on invalid schemas' do
        expect { subject.validate invalid_schema }.to raise_error Jimmy::ValidationError do |exception|
          expect(exception.schema).to be subject
          expect(exception.data).to be invalid_schema
          expect(exception.errors.length).to be 1

          error = exception.errors.first
          expect(error.property).to eq 'postcode'
          expect(error.aspect).to match /type/i
          expect(error.message).to match /\bstring\b/
        end
      end

    end
  end

end
