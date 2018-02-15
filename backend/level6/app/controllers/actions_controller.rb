require_relative '../models/action.rb'

class ActionsController
  ACTORS_LIST = %w[driver owner insurance assistance drivy]

  def initialize(rental_modifications_list)
    @actions_list = []
    rental_modifications_list.each do |rental_modification|
      ACTORS_LIST.each { |actor| @actions_list << Action.new(rental_modification, actor) }
    end
  end

  def all
    @actions_list
  end
end
