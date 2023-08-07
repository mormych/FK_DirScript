# frozen_string_literal: true

require_relative 'config_manager'

puts 'Script started in normal mode'

parent_dir = ""
child_dir = ""
parent_number = 0
child_number = 0

Dir.chdir WORKING_DIR

if Dir.empty? WORKING_DIR
  puts "dir empty"
  parent_dir = "#{WORKING_DIR}\\48000"
  parent_number = (File.basename parent_dir).to_i
  Dir.mkdir parent_dir
  Dir.chdir parent_dir
  (1..10).each do |i|
    Dir.mkdir parent_dir + "\\#{parent_number}"
    parent_number += 1
  end
  exit 0
end

parent_number = Dir.entries(WORKING_DIR).max
parent_dir = WORKING_DIR + "\\#{parent_number}"

puts "Latest parent directory... #{parent_number}"
puts "Entering to parent directory"
Dir.chdir parent_dir
puts "Checking number of child directories... #{Dir["*"].length}"

child_number = Dir.entries(parent_dir).max

array =  Dir["*"].reverse!

for i in 0..4
  puts "Empty dir: #{array[i]}? " + Dir.entries(parent_dir + "\\#{array[i]}").to_s
end