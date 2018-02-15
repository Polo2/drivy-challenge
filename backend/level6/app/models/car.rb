class Car
  attr_reader :id, :price_per_day, :price_per_km, :rentals

  def initialize(car_params = {})
    @id = car_params['id'].to_i
    @price_per_day = car_params['price_per_day'].to_i
    @price_per_km = car_params['price_per_km'].to_i
    @rentals = car_params['rentals'] || []
  end

  def add_rental(rental)
    rental.car = self
    @rentals << rental
  end
end
