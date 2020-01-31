# FU Common Dependencies and configuration goes here.
require 'sinatra/base'
require 'sinatra/flash'

require 'fu/utils'
require 'fu/log'
require 'fu/config'
require 'fu/db'
require 'fu/sinatra'
require 'fu/rails/helpers'

require 'app/server'

##
## Setup
##

# Put setup routines in ::Server#configure (app/server.rb).
