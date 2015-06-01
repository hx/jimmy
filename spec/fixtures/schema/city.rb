object do
  string :name, min_length: 2
  string :postcode, /^\d{4}$/
  integer :population
  geopoint :location
  country_code :country
  array :points_of_interest do
    object do
      string :title, 3...150
      integer :popularity, 1..5
      geopoint :location
      boolean :featured
      require :title
    end
  end
  include :timestamps
  require all - :location
end
