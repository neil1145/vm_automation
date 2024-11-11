vm = 'node-2'
if ['node-1', 'node-2'].include?(vm)
  puts 'yes'
else
  puts 'no'
end

if 'node-3'.include?(vm)
  puts 'yes'
else
  puts 'no'
end