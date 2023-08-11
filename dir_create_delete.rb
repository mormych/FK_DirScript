# frozen_string_literal: true

require 'date'
require 'fileutils'
require_relative 'config_manager'


def create_initial_structure
  puts "Creating parent DIR number: #{INITIAL_DIR_NUM}"
  Dir.mkdir INITIAL_DIR_NUM.to_s
  puts 'Entering to parent DIR...'
  Dir.chdir INITIAL_DIR_NUM.to_s
  puts 'Creating subdirectories...'
  (0..NEW_DIR_COUNT - 1).each { |i|
    Dir.mkdir (INITIAL_DIR_NUM + i).to_s
    create_production_structure (INITIAL_DIR_NUM + i).to_s
    Dir.chdir '..' # Returning to previous directory
  }
  puts 'done'
end

def create_production_structure current_dir
  puts "Entering to DIR: #{current_dir}"
  Dir.chdir current_dir
  puts 'Creating structure...'
  Dir.mkdir 'document'
  Dir.mkdir 'production'
  Dir.mkdir 'source'
end

def check_child_dir parent_dir
  not_empty_dirs = 0
  puts 'Entering to parent DIR...'
  Dir.chdir parent_dir
  puts "Work DIR: #{Dir.pwd}"
  puts 'Checking for latest child DIR... '
  puts "Latest DIR: #{Dir['*'].last}"
  puts 'Dirs count: ' + Dir['*'].count.to_s
  latest_child_dir = (Dir['*'].last).to_i
  (0..CHECK_DIR_COUNT - 1).each { |i|
    puts 'Checking child DIR: ' + (latest_child_dir - i).to_s
    Dir.chdir (latest_child_dir - i).to_s
    unless content_is_empty?
      not_empty_dirs += 1
      puts 'DIR is not empty'
    end
    Dir.chdir '..'
    if not_empty_dirs >= MAX_NOT_EMPTY_DIRS
      begin
        puts 'The number of occupied folders has been exceeded'
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
  puts "Parent DIR: #{Dir.pwd}"
  puts "Latest child #{latest_child_dir}"
  (1..NEW_DIR_COUNT).each { |i|
    if latest_child_dir + i > $actual_dir_num + DIR_LIMIT
      raise Exception, 'Przepełnienie katalogu'
    end
    if Dir.exist? (latest_child_dir + i).to_s
      next
    else
      Dir.mkdir (latest_child_dir + i).to_s
    end
    create_production_structure (latest_child_dir + i).to_s
    Dir.chdir '..' # Returning to previous directory
  }
end

def create_initial_child_dirs latest_child_dir
  puts "Parent DIR  : #{Dir.pwd}"
  puts "Latest child: #{latest_child_dir}"
  (0..NEW_DIR_COUNT - 1).each { |i|
    if latest_child_dir + i > $actual_dir_num + DIR_LIMIT
      raise Exception, 'Przepełnienie katalogu'
    end
    Dir.mkdir (latest_child_dir + i).to_s
    create_production_structure (latest_child_dir + i).to_s
    Dir.chdir '..' # Returning to previous directory
  }
end

def create_parent_dir
  Dir.chdir '..'
  puts "Working directory: #{Dir.pwd}"
  latest_parent_dir = (Dir['*'].last.to_i) + 1000
  $actual_dir_num = latest_parent_dir
  puts "Creating parent DIR number: #{latest_parent_dir}"
  Dir.mkdir latest_parent_dir.to_s
  Dir.chdir latest_parent_dir.to_s
  create_initial_child_dirs latest_parent_dir
end

def content_is_empty?
  puts 'Child DIR: ' + Dir.pwd
  puts 'Checking dirs for content:'
  puts 'document empty?  : ' + Dir.empty?('document').to_s
  puts 'production empty?: ' + Dir.empty?('production').to_s
  puts 'source empty?    : ' + Dir.empty?('source').to_s
  if !Dir.empty? 'production' or !Dir.empty? 'source' or !Dir.empty? 'document'
    return false
  end
  true
end

puts 'FK_DirScript'
puts "Started... #{Time.now}"

puts 'Stage 1. DIR checking'

puts "Entering to work DIR from settings: #{WORKING_DIR}"
Dir.chdir WORKING_DIR
if Dir.empty? Dir.pwd
  create_initial_structure
  exit 0
end

puts 'Checking for latest parent DIR... '
puts "Latest DIR: #{Dir['*'].last}"
$actual_dir_num = Dir['*'].last.to_i
check_child_dir(Dir['*'].last).to_s

puts 'Done stage 1'

puts 'Stage 2. DIR cleaning'

def start
  puts "Entering to work dir: #{WORKING_DIR}"
  Dir.chdir(WORKING_DIR)
  puts 'Checking for first parent dir... '
  puts "First DIR: #{Dir['*'].at(0)}"
  puts "DIR(S) count: #{Dir['*'].count}"
  puts "Warming complete..."
  puts "Cleaning..."
  puts

  Dir["*"].each do |parent_dir|
    puts "Entering to parent dir: #{parent_dir}"
    Dir.chdir(parent_dir)
    puts "Work DIR is now: #{Dir.pwd}"
    puts "Child DIR(S) count: #{Dir['*'].count}"
    Dir["*"].each do |child_dir|
      puts "Entering to child dir: #{child_dir}"
      Dir.chdir(child_dir)
      puts "Work DIR is now: #{Dir.pwd}"
      puts "Cleaned dirs: #{cleaned_dirs}"
      puts "OK. Returning"
      Dir.chdir("..")
    end
    Dir.chdir("..")
  end

end

def cleaned_dirs
  dirs = []
  DIR_TO_WIPE.each do |dir_name|
    modification_date = File.mtime(dir_name)
    if Date.parse(modification_date.strftime("%Y-%m-%d")) <= DateTime.parse(DELETE_TIME)
      puts "DIR \"#{dir_name}\" from child DIR #{Dir.pwd} will be wiped..."
      FileUtils.rm_r(dir_name)
      Dir.mkdir(dir_name)
      dirs.push(dir_name)
    end
  end
  dirs
end

puts "Today is: #{Date.today}"

puts "Warning. All files before #{DELETE_TIME} WILL BE CLEARED."

print "DIR(S) to WIPE: #{DIR_TO_WIPE}"

puts

if (DIR_TO_WIPE.include?('source') || DIR_TO_WIPE.include?('document')) && WARN_ON_RISK_DIR
    print 'Warning. DIR source or document also will be wiped. Are you sure? true/false: '
    exit(0) unless gets.chomp == 'true'
end
puts 'Warming up...'
start

puts 'Done stage 2'

puts
puts 'All done.'


exit 0