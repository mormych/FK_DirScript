# frozen_string_literal: true

require 'date'
require 'fileutils'
require 'logger'
require_relative 'config_manager'


def create_initial_structure
  $logger.info "Creating parent DIR number: #{INITIAL_DIR_NUM}"
  Dir.mkdir INITIAL_DIR_NUM.to_s
  $logger.info 'Entering to parent DIR...'
  Dir.chdir INITIAL_DIR_NUM.to_s
  $logger.info 'Creating subdirectories...'
  (0..NEW_DIR_COUNT - 1).each { |i|
    Dir.mkdir (INITIAL_DIR_NUM + i).to_s
    create_production_structure (INITIAL_DIR_NUM + i).to_s
    Dir.chdir '..' # Returning to previous directory
  }
  $logger.info 'done'
end

def create_production_structure current_dir
  $logger.info "Entering to DIR: #{current_dir}"
  Dir.chdir current_dir
  $logger.info 'Creating structure...'
  Dir.mkdir 'document'
  Dir.mkdir 'production'
  Dir.mkdir 'source'
end

def check_child_dir parent_dir
  not_empty_dirs = 0
  $logger.info 'Entering to parent DIR...'
  Dir.chdir parent_dir
  $logger.info "Work DIR: #{Dir.pwd}"
  $logger.info 'Checking for latest child DIR... '
  $logger.info "Latest DIR: #{Dir['*'].last}"
  $logger.info 'Dirs count: ' + Dir['*'].count.to_s
  latest_child_dir = (Dir['*'].last).to_i
  (0..CHECK_DIR_COUNT - 1).each { |i|
    $logger.info 'Checking child DIR: ' + (latest_child_dir - i).to_s
    Dir.chdir (latest_child_dir - i).to_s
    unless content_is_empty?
      not_empty_dirs += 1
      $logger.info 'DIR is not empty'
    end
    Dir.chdir '..'
    if not_empty_dirs >= MAX_NOT_EMPTY_DIRS
      begin
        $logger.info 'The number of occupied folders has been exceeded'
        create_child_dirs latest_child_dir
      rescue Exception => e
        $logger.info "Exception: #{e.message}"
        create_parent_dir
      end
      break
    end
  }
end

def create_child_dirs latest_child_dir
  $logger.info "Parent DIR: #{Dir.pwd}"
  $logger.info "Latest child #{latest_child_dir}"
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
  $logger.info "Parent DIR  : #{Dir.pwd}"
  $logger.info "Latest child: #{latest_child_dir}"
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
  $logger.info "Working directory: #{Dir.pwd}"
  latest_parent_dir = (Dir['*'].last.to_i) + 1000
  $actual_dir_num = latest_parent_dir
  $logger.info "Creating parent DIR number: #{latest_parent_dir}"
  Dir.mkdir latest_parent_dir.to_s
  Dir.chdir latest_parent_dir.to_s
  create_initial_child_dirs latest_parent_dir
end

def content_is_empty?
  $logger.info 'Child DIR: ' + Dir.pwd
  $logger.info 'Checking dirs for content:'
  $logger.info 'document empty?  : ' + Dir.empty?('document').to_s
  $logger.info 'production empty?: ' + Dir.empty?('production').to_s
  $logger.info 'source empty?    : ' + Dir.empty?('source').to_s
  if !Dir.empty? 'production' or !Dir.empty? 'source' or !Dir.empty? 'document'
    return false
  end
  true
end

def logger_init
  file = File.open("script_log.txt", "a+")
  logger = Logger.new(file)
  logger.level = Logger::INFO
  logger
end

puts 'Initializing logger...'

$logger = logger_init

$logger.info "Logger initialized... #{Date.today}"
$logger.info 'Welcome to FK_DirScript'

$logger.info 'Stage 1. DIR checking'

$logger.info "Entering to work DIR from settings: #{WORKING_DIR}"
Dir.chdir WORKING_DIR
if Dir.empty? Dir.pwd
  create_initial_structure
  $logger.info "Done stage 1"
  $logger.info "Stage 2 skipped"
  $logger.info "\n"
  $logger.close
  exit 0
end

$logger.info 'Checking for latest parent DIR... '
$logger.info "Latest DIR: #{Dir['*'].last}"
$actual_dir_num = Dir['*'].last.to_i
check_child_dir(Dir['*'].last).to_s

$logger.info 'Done stage 1'

$logger.info 'Stage 2. DIR cleaning'

def start
  $logger.info "Entering to work dir: #{WORKING_DIR}"
  Dir.chdir(WORKING_DIR)
  $logger.info 'Checking for first parent dir... '
  $logger.info "First DIR: #{Dir['*'].at(0)}"
  $logger.info "DIR(S) count: #{Dir['*'].count}"
  $logger.info "Warming complete..."
  $logger.info "Cleaning..."
  $logger.info "\n"

  Dir["*"].each do |parent_dir|
    $logger.info "Entering to parent dir: #{parent_dir}"
    Dir.chdir(parent_dir)
    $logger.info "Work DIR is now: #{Dir.pwd}"
    $logger.info "Child DIR(S) count: #{Dir['*'].count}"
    Dir["*"].each do |child_dir|
      $logger.info "Entering to child dir: #{child_dir}"
      Dir.chdir(child_dir)
      $logger.info "Work DIR is now: #{Dir.pwd}"
      $logger.info "Cleaned dirs: #{cleaned_dirs}"
      $logger.info "OK. Returning"
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
      $logger.info "DIR \"#{dir_name}\" from child DIR #{Dir.pwd} will be wiped..."
      FileUtils.rm_r(dir_name)
      Dir.mkdir(dir_name)
      dirs.push(dir_name)
    end
  end
  dirs
end

$logger.info "Today is: #{Date.today}"

$logger.info "Warning. All files before #{DELETE_TIME} WILL BE CLEARED."

$logger.info "DIR(S) to WIPE: #{DIR_TO_WIPE}"

$logger.info "\n"

if (DIR_TO_WIPE.include?('source') || DIR_TO_WIPE.include?('document')) && WARN_ON_RISK_DIR
    print 'Warning. DIR source or document also will be wiped. Are you sure? true/false: '
    exit(0) unless gets.chomp == 'true'
end
$logger.info 'Warming up...'
start

$logger.info 'Done stage 2'

$logger.info "\n"
$logger.info 'All done.'
$logger.info "\n"

$logger.close


exit 0