# frozen_string_literal: true

##
# version:  1.0
#
# This is the configuration file for the application
#
# After making changes to the file
# You must restart the application to refresh the settings.

# Settings for stage 1

MAX_NOT_EMPTY_DIRS = 5                                           # Maximum number allowed not empty dirs
CHECK_DIR_COUNT = 10                                             # Number of dirs to check
NEW_DIR_COUNT = 10                                              # Dirs will be created if necessary
WORKING_DIR = 'C:\\Users\\Michal\\Desktop\\dtp'                  # Working DIR
INITIAL_DIR_NUM = 48000                                          # First parent_dir
DIR_LIMIT = 999                                                  # Max DIR number (Preferred 999)

# Settings for stage 2

DELETE_TIME = "2023-08-09"                                       # All files before this date will be wiped
DIR_TO_WIPE = ["production"]                           # Table with folders to wipe
WARN_ON_RISK_DIR = true                                          # If this option is true. When directory Sources or Documents is set to wipe script will ask for confirmation
