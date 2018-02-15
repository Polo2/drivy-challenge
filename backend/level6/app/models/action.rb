class Action
  attr_accessor :rental, :rental_modification
  attr_reader :who, :type, :amount, :new_amount, :delta_amount, :delta_type

  def initialize(rental_modification, actor)
    @rental_modification = rental_modification
    @rental = @rental_modification.rental
    @who = actor
    @type = define_type(true)
    @amount = @rental.amount_by_actor(@who)

    @new_amount = @rental_modification.amount_by_actor(@who)
    @delta_type = define_type(@new_amount > @amount)
    @delta_amount = @new_amount > @amount ? (@new_amount - @amount) : (@amount - @new_amount)
    add_action_to_rental_modification
  end

  private

  def add_action_to_rental_modification
    @rental_modification.actions << self
  end

  def define_type(balance)
    if balance
      @who == 'driver' ? 'debit' : 'credit'
    else
      @who == 'driver' ? 'credit' : 'debit'
    end
  end
end
