##
## Re-usable Rails Helpers for Views
##
## include in: app/helpers/application_helper.rb:ApplicationHelper

module FU::Rails
    module Helpers

        ##
        ## support for standard ways that we use the Rails session object
        ##   remembering the User, and various associated flags
        ##   marking a session as 'God'
        ##   actively impersonating a User
        ##
        ## usage of Session
        ##   session[:user_id]     is assumed to contain a User.id
        ##   session[:impersonate] may contain the User.id of a User being impersonated
        ##   session[:registered]  recevies User#registered?
        ##   session[:god]         can be set to true for God users
        ##
        ## assumptions
        ##   $CONFIG[:auth_as_user] will supercede session[:user_id] when present
        ##

        module Session
            def logged_in?
                session[:user_id] != nil
            end

            def fu_user
                @fu_user ||= User.get(session[:user_id]) rescue nil
            end

            def registered?
                fu_user.is_registered? rescue false
            end

            def reset_session
                $LOG.debug("%% resetting session")
                session.clear
            end

            # Fight session fixation by calling this whenever the user
            # context changes but we want to maintain the data in the
            # session so far.  Forces construction of new session id, but
            # copies all existing session data into the new one. E.g., when
            # someone logs in.
            def renew_session
                $LOG.debug("%% renewing session")
                session[:_csrf_token] = nil if session.key? :_csrf_token
                session.options[:renew] = true
                #session.options[:fixate] = true if $CONFIG.env == :test
            end

            # class ApplicationController
            #     before_filter :require_login[, only: [:method1, :method, ...]]
            #     ...
            # end
            def require_login
                unless logged_in?
                    redirect_to(login_url)
                end
            end

        end

        #
        # helper methods for presentational formatting
        #
        module Formatting
            # This differs from String#summarize by working on non-string
            # things.  OTOH, don't know if that's actually needed.
            def summarize(thing = "", length = 100, elipsis = true)
                return thing.to_s.summarize(length, elipsis)
            end

            def format_date(datetime)
                return "" unless datetime.is_a?(DateTime)
                return datetime.strftime("%-1m-%-1d-%y %l:%M %p")
            end
        end

    end
end
