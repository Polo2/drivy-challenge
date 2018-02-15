require_relative '../models/rental.rb'

class RentalsController
  def initialize(rentals_list)
    @rentals_list = []
    rentals_list.each { |rental| @rentals_list << Rental.new(rental) }
  end

  def attribute_cars(cars)
    @rentals_list.each do |rental|
      rental.car = cars.select { |car| car.id == rental.car_id }[0]
      rental.car.add_rental(rental)
    end
  end

  def all
    @rentals_list
  end

  def find(id)
    @rentals_list.select { |rental| rental.id == id }[0]
  end
end
