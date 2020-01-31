$BOOTED_FROM_RAILS = true
$:.unshift "."
require "boot/init"

require_relative 'boot'

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie" # FFR: Amazon SES integration
#require "action_cable/engine" #  websockets
#require "action_text/engine" # RichText Editor tied to AR
require "rails/test_unit/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems you've limited to
# :test, :development, or :production.
Bundler.require(*Rails.groups)

module Frontend
    class Application < Rails::Application
        include ::FU::Rails::Configurer
        include ::FU::Rails::Middleware

        # Mount ourselves on a subURL when told to do so.  This will usually be
        # because we're running in a combined PHP+Ruby environment, where PHP
        # currently owns /.
        #
        # NOTE: So long as the app uses link helpers to generate HTTP links in
        # views (e.g. link_to()), everything will still just work!

        if $CONFIG[:mount_on]
            config.relative_url_root = $CONFIG[:mount_on]
        end

    end
end

APPNAME='Frontend'
