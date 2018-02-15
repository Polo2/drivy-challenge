require "date"

class Rental
  attr_accessor :car, :actions
  attr_reader :car_id, :id, :start_date, :end_date, :distance, :deductible_reduction

  FIRST_DISCOUNT_AMOUNT = 0.9
  FIRST_DISCOUNT_RANGE = 1
  SECOND_DISCOUNT_AMOUNT = 0.7
  SECOND_DISCOUNT_RANGE = 4
  THIRD_DISCOUNT_AMOUNT = 0.5
  THIRD_DISCOUNT_RANGE = 10
  COMISSION_RATE = 0.3
  INSURANCE_RATE = 0.5
  ASSISTANCE_PRICE_PER_DAY = 100
  DEDUCTIBLE_REDUCTION_PER_DAY = 400

  def initialize(rental_params)
    @id = rental_params['id'].to_i
    @car_id = rental_params['car_id'].to_i
    @start_date = Date.parse(rental_params['start_date'])
    @end_date = Date.parse(rental_params['end_date'])
    @distance = rental_params['distance'].to_i
    @deductible_reduction = rental_params['deductible_reduction']
    @actions = []
    @rental_modifications = []
  end

  def amount_by_actor(actor)
    case actor
    when 'driver'
      amount_rental_for_driver + deductible_reduction_calculation
    when 'owner'
      amount_for_owner.round
    when 'insurance'
      amount_for_insurance.round
    when 'assistance'
      amount_for_assistance.round
    when 'drivy'
      amount_for_drivy.round
    end
  end

  def actions_for_output
    @actions.map do |action|
      { who: action.who, type: action.type, amount: action.amount }
    end
  end

  def nb_of_days
    (@end_date - @start_date + 1).to_i
  end

  private

  def amount_rental_for_driver
    price_for_distance = @distance * car.price_per_km
    price_for_time = decreasing_price_calculation(nb_of_days) * car.price_per_day
    price_for_distance + price_for_time.round
  end

  def amount_for_owner
    (amount_rental_for_driver * (1 - COMISSION_RATE))
  end

  def amount_for_insurance
    (INSURANCE_RATE * (amount_rental_for_driver * COMISSION_RATE))
  end

  def amount_for_assistance
    ASSISTANCE_PRICE_PER_DAY * nb_of_days
  end

  def amount_for_drivy
    (amount_rental_for_driver * COMISSION_RATE) - amount_for_insurance - amount_for_assistance + deductible_reduction_calculation
  end

  def decreasing_price_calculation(days)
    if days > THIRD_DISCOUNT_RANGE
      FIRST_DISCOUNT_RANGE + (SECOND_DISCOUNT_RANGE - FIRST_DISCOUNT_RANGE) * FIRST_DISCOUNT_AMOUNT + ((THIRD_DISCOUNT_RANGE - SECOND_DISCOUNT_RANGE) * SECOND_DISCOUNT_AMOUNT) + ((days - THIRD_DISCOUNT_RANGE) * THIRD_DISCOUNT_AMOUNT)
    elsif days > SECOND_DISCOUNT_RANGE
      FIRST_DISCOUNT_RANGE + (SECOND_DISCOUNT_RANGE - FIRST_DISCOUNT_RANGE) * FIRST_DISCOUNT_AMOUNT + ((days - SECOND_DISCOUNT_RANGE) * SECOND_DISCOUNT_AMOUNT)
    elsif days > FIRST_DISCOUNT_RANGE
      FIRST_DISCOUNT_RANGE + ((days - FIRST_DISCOUNT_RANGE) * FIRST_DISCOUNT_AMOUNT)
    else
      FIRST_DISCOUNT_RANGE
    end
  end

  def deductible_reduction_calculation
    @deductible_reduction ? DEDUCTIBLE_REDUCTION_PER_DAY * nb_of_days : 0
  end
end
