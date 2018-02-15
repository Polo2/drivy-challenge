require 'json'
require 'date'
require 'pry'
require_relative 'app/controllers/cars_controller'
require_relative 'app/controllers/rentals_controller'
require_relative 'app/controllers/actions_controller'
require_relative 'app/controllers/rental_modifications_controller'

def extract_datas_from_json(path)
  file = File.read(path)
  JSON.parse(file)
end

def write_output_as_json(output, path)
  File.open(path, 'wb') do |file|
    file.write(JSON.generate(output))
  end
end

cars = extract_datas_from_json("#{File.dirname(__FILE__)}/data.json")['cars']
cars_controller = CarsController.new(cars)

rentals_data = extract_datas_from_json("#{File.dirname(__FILE__)}/data.json")['rentals']
rentals_controller = RentalsController.new(rentals_data)
rentals_controller.attribute_cars(cars_controller.all)

rental_modifications_data = extract_datas_from_json("#{File.dirname(__FILE__)}/data.json")['rental_modifications']
rental_modifications_controller = RentalModificationsController.new(rental_modifications_data, rentals_controller.all)

ActionsController.new(rental_modifications_controller.all)
rental_modifications_output = { rental_modifications: [] }

rental_modifications_controller.all.each do |rental_modification|
  rental_modifications_output[:rental_modifications] << {
    id: rental_modification.id,
    rental_id: rental_modification.rental_id,
    actions: rental_modification.actions_for_output
  }
end

write_output_as_json(rental_modifications_output, "#{File.dirname(__FILE__)}/output_lv6_before_testing.json")
