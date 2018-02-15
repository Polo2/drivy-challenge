require_relative '../models/car.rb'

class CarsController
  def initialize(cars_list)
    @cars_list = []
    cars_list.each { |car| @cars_list << Car.new(car) }
  end

  def all
    @cars_list
  end

  def find(id)
    @cars_list.select{ |car| car.id == id }[0]
  end
end
