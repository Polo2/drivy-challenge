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

# extracting data as hash from data.json

cars = extract_datas_from_json("#{File.dirname(__FILE__)}/data.json")["cars"]
rentals_data = extract_datas_from_json("#{File.dirname(__FILE__)}/data.json")["rentals"]

# method as a tool : calculation of price for each rental
def price_calculation(rental, car)
  nb_of_days = (Date.parse(rental["end_date"]) - Date.parse(rental["start_date"])).to_i + 1
  price_for_time = nb_of_days * car["price_per_day"]
  price_for_distance = rental["distance"] * car["price_per_km"]
  price_for_time + price_for_distance
end


# main program : writing output from input as hash and methods as tools :
rentals_output = rentals_data.map do |r|
  car = cars.select { |c|  c["id"] == r["car_id"]  }
  {id: r["id"].to_i, price: price_calculation(r, car[0] ) }
end

write_output_as_json({"rentals" => rentals_output}, "#{File.dirname(__FILE__)}/output.json")


