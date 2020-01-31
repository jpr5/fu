require 'fu/rails/controller'

class ApplicationController < ActionController::Base
    include ::FU::Rails::Controller
    include ::FU::Rails::Helpers::Session
    include ApplicationHelper

    helper :all # import them all into views
    layout "application"

    ##
    ## Utility Methods for all controllers (and helpers)
    ##
    # All standard ones are in app/helpers/application_helpers.rb

    ##
    ## Filters & Exception handling (e.g. before...)
    ##

end
