##
## General support modules for Rails 6.
##

require 'rails'
require 'action_controller/railtie'
require 'action_mailer/railtie'

# ExecJS auto-detects upon require, so we explicitly set the runtime and load
# ourselves before any of the extensions have a chance to (i.e. coffee-rails).
#ENV['EXECJS_RUNTIME'] = 'Node'
#require 'execjs'

#require 'jquery-rails' # see Jquery::Rails::JQUERY_VERSION and related constants
#require 'coffee-rails'
#require 'sass-rails'
#require 'bootstrap-rails'
#require 'uglifier'

module FU
    module Rails

        autoload :Logging,    'fu/rails/logging'
        autoload :Controller, 'fu/rails/controller'
        autoload :Configurer, 'fu/rails/configurer'
        autoload :Middleware, 'fu/rails/middleware'
        autoload :Helpers,    'fu/rails/helpers'

    end
end
