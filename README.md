# Jimmy the Gem

Meet your mate Jimmy. He's a top bloke.

Writing JSON schemas is as tedious as a tax audit. But now, thanks to everyone's new best friend Jimmy, it's easier than shooting the side of a barn with a very easy-to-use projectile weapon.

## Getting hooked up

You guessed it:

```bash
$ gem install jimmy
```

Here's another doozy:

```ruby
require 'jimmy'
```

Wasn't that a shock. Let's move on.

## The DSL

Jimmy replaces `.json` JSON schemas files with `.rb` files. Here's a simple example:

```ruby
# city.rb
object do
  string :name, min_length: 2
  string :postcode, /^\d{4}$/

  require all
end
```

This compiles to:

```json
{
  "$schema": "https://my.domain.kom/city#",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "minLength": 2
    },
    "postcode": {
      "type": "string",
      "pattern": "^\\d{4}$"
    },
    "required": ["name", "zipcode"],
    "additionalProperties": false
  }
}
```

Crikey! That's a bit of a difference. Let's take a look at a more complex (and contrived) example:

```ruby
# types/country_code.rb
string /^[A-Z]{2}$/

# types/geopoint.rb
object do
  number :latitude, -90..90
  number :longitude, -180..180
end

# city.rb
object do
  string :name, min_length: 2
  string :postcode, /^\d{4}$/
  integer :population
  geopoint :location
  country_code :country
  array :points_of_interest do
    object do
      string :title, 3..150
      integer :popularity, 1..5
      geopoint :location
      boolean :featured
      require :title
    end
  end
  require all - :location
end
```

Here's the full result (though we expect you get the gist of it by now):

```json
{
  "$schema": "https://my.domain.kom/city#",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "minLength": 2
    },
    "postcode": {
      "type": "string",
      "pattern": "^\\d{4}$"
    },
    "population": {
      "type": "integer"
    },
    "location": {
      "$ref": "/types/geopoint#"
    },
    "country": {
      "$ref": "/types/country_code#"
    },
    "points_of_interest": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "title": {
            "type": "string",
            "minLength": 3,
            "maxLength": 150
          },
          "popularity": {
            "type": "integer",
            "minimum": 1,
            "maximum": 5
          },
          "location": {
            "$ref": "/types/geopoint#"
          },
          "featured": {
            "type": "boolean"
          }
        },
        "required": [
          "title"
        ],
        "additionalProperties": false
      }
    }
  },
  "required": [
    "name",
    "postcode",
    "population",
    "country",
    "points_of_interest"
  ],
  "additionalProperties": false
}
```