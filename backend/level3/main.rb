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

# 6 levels for 1 job :

# method for level 1 : easy calculation of price for each rental

def price_calculation(rental, car)
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


# main program : writing output from input as hash and methods as tools :

rentals_output = rentals_data.map do |r|
  car = cars.select { |c|  c["id"] == r["car_id"]  }[0]
  {id: r["id"].to_i, price: price_calculation(r, car), commission: comission_calculation(price_calculation(r, car), r) }
end


write_output_as_json({"rentals" => rentals_output}, "#{File.dirname(__FILE__)}/output.json")


