Rails.application.configure do
    # Code is not reloaded between requests.
    config.cache_classes = true
    config.eager_load = true

    # Full error reports are disabled and caching is turned on.
    config.consider_all_requests_local       = false
    config.action_controller.perform_caching = true

    config.require_master_key = false

    # WARN: Should disable the serving of static files from the `/public` folder
    # by Rack middleware, since Apache or NGINX already handles this.  But
    # during our initial development, we'll be running via rackup quite a bit
    # (withint NGINX) so it's enabled for now.
    config.public_file_server.enabled = true # ENV['RAILS_SERVE_STATIC_FILES'].present?

    # Specifies the header that your server uses for sending files.
    # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
    # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

    config.assets.compile = false
    config.assets.debug = false
    config.assets.compress = true
    config.assets.digest = true

    # Enable serving of images, stylesheets, and JavaScripts from an asset server.
    # config.action_controller.asset_host = 'http://assets.example.com'

    # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
    # config.force_ssl = true

    # Use the lowest log level to ensure availability of diagnostic information
    # when problems arise.
    config.log_level = :info

    # Use a different cache store in production.
    # config.cache_store = :mem_cache_store

    # Use a real queuing backend for Active Job (and separate queues per environment).
    # config.active_job.queue_adapter     = :resque
    # config.active_job.queue_name_prefix = "fu_production"

    config.action_mailer.perform_caching = false

    # Ignore bad email addresses and do not raise email delivery errors.
    # Set this to true and configure the email server for immediate delivery to raise delivery errors.
    config.action_mailer.raise_delivery_errors = true

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation cannot be found).
    config.i18n.fallbacks = true

    # Send deprecation notices to registered listeners.
    config.active_support.deprecation = :notify

    config.logger = $LOG
    $LOG.console = true if ENV["RAILS_LOG_TO_STDOUT"].present?
end
