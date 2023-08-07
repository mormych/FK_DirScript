# frozen_string_literal: true

require_relative 'config_manager'

def create_initial_structure
  Dir.mkdir INITIAL_DIR_NUM.to_s
  puts "Entering to work dir..."
  Dir.chdir INITIAL_DIR_NUM.to_s
  puts "Work dir #{Dir.pwd}"
  (0..NEW_DIR_COUNT - 1).each { |i|
    Dir.mkdir (INITIAL_DIR_NUM + i).to_s
    create_production_structure (INITIAL_DIR_NUM + i).to_s
    Dir.chdir ".." # Returning to previous directory
  }
  puts "done"
end

def create_production_structure current_dir
  puts "Entering to DIR: #{current_dir}"
  Dir.chdir current_dir
  puts "Creating structure..."
  Dir.mkdir "Production"
  Dir.mkdir "Source"
end

def check_child_dir parent_dir
  not_empty_dirs = 0
  puts "Entering to work dir"
  Dir.chdir parent_dir
  puts "Work dir: #{Dir.pwd}"
  puts "Checking for latest child dir... "
  puts Dir["*"].last + " Last dir"
  puts "Dirs count: " + Dir["*"].count.to_s
  latest_child_dir = (Dir["*"].last).to_i
  (0..CHECK_DIR_COUNT - 1).each { |i|
    puts "Latest child dir " + (latest_child_dir - i).to_s
    Dir.chdir (latest_child_dir - i).to_s
    unless content_is_empty?
      not_empty_dirs += 1
      puts "Katalog nie jest pusty"
    end
    Dir.chdir ".."
    if not_empty_dirs >= MAX_NOT_EMPTY_DIRS
      begin
        create_child_dirs latest_child_dir
      rescue Exception => e
        puts "Exception: #{e.message}"
        create_parent_dir
      end
      break
    end
  }
end

def create_child_dirs latest_child_dir
  puts "jestem tutaj: #{Dir.pwd}"
  puts "Latest child #{latest_child_dir}"
  (0..NEW_DIR_COUNT - 1).each { |i|
    if latest_child_dir + i > $actual_dir_num + DIR_LIMIT
      raise Exception, "Przepełnienie katalogu"
    end
    if Dir.exist? (latest_child_dir + i).to_s
      next
    else
      Dir.mkdir (latest_child_dir + i).to_s
    end
    create_production_structure (latest_child_dir + i).to_s
    Dir.chdir ".." # Returning to previous directory
  }
end

def create_parent_dir
  Dir.chdir ".."
  puts "Working directory: #{Dir.pwd}"
  latest_parent_dir = (Dir["*"].last.to_i) + 1000
  $actual_dir_num = latest_parent_dir
  Dir.mkdir latest_parent_dir.to_s
  Dir.chdir latest_parent_dir.to_s
  create_child_dirs latest_parent_dir
end

def content_is_empty?
  puts "Working dir: " + Dir.pwd
  puts "Checking dirs for content:"
  puts "Production empty?: " + Dir.empty?("Production").to_s
  puts "Source empty?    : " + Dir.empty?("Source").to_s
  if !Dir.empty? "Production" or !Dir.empty? "Source"
    return false
  end
  true
end

puts "FK_DirScript"
puts "Started... #{Time.now}"

if ARGV.length.eql? 0
  puts "Script mode: normal"
else
  puts "Script mode: interactive"
end

puts "Entering to work dir..."
Dir.chdir WORKING_DIR
puts "Work dir: #{Dir.pwd}"
if Dir.empty? Dir.pwd
  create_initial_structure
  exit 0
end

puts "Checking for latest parent dir... "
puts Dir["*"].last + " Last dir"
$actual_dir_num = Dir["*"].last.to_i
check_child_dir(Dir["*"].last).to_s

puts "All done."
exit 0