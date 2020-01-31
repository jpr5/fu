##
## Common code for root mailer (ApplicationMailer).
##

require 'fu/rails/logging'

module FU
module Rails
    module Mailer
        extend self

        def included(klass)
            klass.class_eval do
                # no-op for now..
            end
        end
    end
end
end
