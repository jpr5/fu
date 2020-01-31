##
## Standard FU Dependencies
##

## System



## FU

require 'fu/utils'
require 'fu/log'
require 'fu/config'
require 'fu/db'
require 'fu/scheduler'
require 'fu/aws'

## App-Local



##
## Setup
##

$DB.setup if $DB
$AWS.configure if $AWS
