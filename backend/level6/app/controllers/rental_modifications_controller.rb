require_relative '../models/rental_modification.rb'

class RentalModificationsController
  def initialize(rental_modifications_list, rentals_list)
    @rental_modifications_list = []
    rental_modifications_list.each do |rental_modification|
      @rental_modifications_list << RentalModification.new(rental_modification, rentals_list.select { |rental| rental.id == rental_modification['rental_id'].to_i }[0])
    end
  end

  def all
    @rental_modifications_list
  end

  def find(id)
    @rental_modifications_list.select { |rental_modification| rental_modification.id == id }[0]
  end
end
