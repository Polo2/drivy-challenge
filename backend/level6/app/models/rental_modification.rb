class RentalModification < Rental
  attr_accessor :rental, :car
  attr_reader :id, :rental_id, :start_date, :end_date, :distance, :deductible_reduction

  def initialize(rental_modification_params, rental)
    @rental = rental
    @rental_id = @rental.id
    @car = @rental.car
    @id = rental_modification_params['id'].to_i
    @start_date = rental_modification_params['start_date'].nil? ? @rental.start_date : Date.parse(rental_modification_params['start_date'])
    @end_date = rental_modification_params['end_date'].nil? ? @rental.end_date : Date.parse(rental_modification_params['end_date'])
    @distance = rental_modification_params['distance'].nil? ? @rental.distance : rental_modification_params['distance'].to_i
    @deductible_reduction = rental_modification_params['deductible_reduction'].nil? ? @rental.deductible_reduction : rental_modification_params['deductible_reduction']
    @actions = []
  end

  def actions_for_output
    @actions.map do |action|
      { who: action.who, type: action.delta_type, amount: action.delta_amount }
    end
  end
end
