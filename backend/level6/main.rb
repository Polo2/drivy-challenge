require "json"
require "date"

# 2 methods, conversion json < -- > hash

def extract_datas_from_json(path)
  file = File.read(path)
  data_details = JSON.parse(file)
  return data_details
end


def write_output_as_json(output, path)
  File.open(path, 'wb') do |file|
    file.write(JSON.generate(output))
  end
end

# refactoring : number of days

def number_of_days(rental)
  (Date.parse(rental["end_date"]) - Date.parse(rental["start_date"])).to_i + 1
end

# extracting data as hash from data.json

cars = extract_datas_from_json("#{File.dirname(__FILE__)}/data.json")["cars"]
rentals_data = extract_datas_from_json("#{File.dirname(__FILE__)}/data.json")["rentals"]
rental_modifications_data = extract_datas_from_json("#{File.dirname(__FILE__)}/data.json")["rental_modifications"]


# 6 levels for 1 job :

# method for level 1 : easy calculation of price for each rental

def price_calculation(rental, car)
  # nb_of_days = (Date.parse(rental["end_date"]) - Date.parse(rental["start_date"])).to_i + 1
  price_for_time = price_calculation_with_decreasing_pricing(number_of_days(rental)) * car["price_per_day"]
  price_for_distance = rental["distance"] * car["price_per_km"]
  (price_for_time.round + price_for_distance).to_i
end

# method for level 2 : price calcultation more complicated : new method with decreasing price

def price_calculation_with_decreasing_pricing(days)
  if days > 10
    return 1 + (3 * 0.9) + (6 * 0.7) + ((days - 10) * 0.5)
  elsif days > 4
    return 1 + (3 * 0.9) + ((days - 4) * 0.7)
  elsif days > 1
    return 1 + ((days - 1) * 0.9)
  else
    return 1
  end
end

# method for level 3: calculation of comission as hash for each rental

def comission_calculation(price, rental)
  comission = price * 0.3

  amount_for_insurance = 0.5 * comission
  amount_for_assistance = 100 * number_of_days(rental)
  amount_for_us = comission - amount_for_insurance - amount_for_assistance

  {"insurance_fee" => amount_for_insurance.round,
    "assistance_fee" => amount_for_assistance.round,
    "drivy_fee" => amount_for_us.round }
end

# method for level 4: deductible reduction

def option_calculation(rental, car)
  {"deductible_reduction" => (  rental["deductible_reduction"] ? 400 * number_of_days(rental) : 0 )}
end

# methods for level 5 : each action's amount is calculated with existing methods

def set_actions(rental, car)
  actions = []
  actions << new_action("driver", price_calculation(rental, car) + option_calculation(rental, car)["deductible_reduction"])
  actions << new_action("owner", price_calculation(rental, car) * 0.7 )
  actions << new_action("insurance", comission_calculation(price_calculation(rental, car), rental)["insurance_fee"]  )
  actions << new_action("assistance", comission_calculation(price_calculation(rental, car), rental)["assistance_fee"] )
  actions << new_action("drivy", comission_calculation(price_calculation(rental, car), rental)["drivy_fee"] + option_calculation(rental, car)["deductible_reduction"] )
  actions
end

def new_action(who, amount)
  type = (who == "driver") ? "debit" : "credit"
  {"who" => who, "type" => type, "amount" => amount.round }
end

# methods for level 6 : each rental_modification generate a new action's array

def update_actions(rental_modification, rental, car)

  old_actions = set_actions(rental, car)
  rental["start_date"] = rental_modification["start_date"] unless rental_modification["start_date"].nil?
  rental["end_date"] = rental_modification["end_date"] unless rental_modification["end_date"].nil?
  rental["distance"] = rental_modification["distance"] unless rental_modification["distance"].nil?
  modified_actions = set_actions(rental, car)

  modified_actions.map do |mod_action|
    old_action = old_actions.select { |action| action["who"] == mod_action["who"] }[0]
    upddate_action(old_action, mod_action)
  end

end

def upddate_action(old_action, mod_action)
  new_amount = mod_action["amount"] - old_action["amount"]
  if new_amount >= 0
    new_type = mod_action["type"]
  else
    new_amount = -new_amount
    new_type = (mod_action["type"] == "debit") ? "credit" : "debit"
  end
  {who: mod_action["who"], type: new_type , amount: new_amount}
end




# main program : writing output from input as hash and methods as tools :

rentals_output = rentals_data.map do |r|
  car = cars.select { |c|  c["id"] == r["car_id"]  }[0]
  {id: r["id"].to_i, actions: set_actions(r, car) }
end

rental_modifications_output = rental_modifications_data.map do |rm|
    rental = rentals_data.select { |r| r["id"] == rm["rental_id"] }[0]
    car = cars.select { |c|  c["id"] == rental["car_id"]  }[0]
    {id: rm["id"].to_i, rental_id: rm["rental_id"] ,actions: update_actions(rm, rental, car) }
end


# personal tests before writing output.json :
# puts rentals_output
# puts rental_modifications_data
# puts rental_modifications_output


write_output_as_json({"rental_modifications" => rental_modifications_output}, "#{File.dirname(__FILE__)}/output.json")


