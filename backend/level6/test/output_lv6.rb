require_relative '../main.rb'
puts 'test niveau 6'

expected_output = extract_datas_from_json('level6/output.json')
exercise_output = extract_datas_from_json('level6/output_lv6_before_testing.json')

if expected_output == exercise_output
  puts 'Succès ! la sortie output_lv6_before_testing.json est exactement égale au output.json demandé'
else
  puts 'echec : il reste des différences avec la sortie demandée... courage'
end
