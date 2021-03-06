require File.expand_path("../boot", __FILE__)

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Remit
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified
    # here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record
    # auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    # Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from
    # config/locales/*.rb,yml are auto loaded.
    # my_locales = Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.load_path += my_locales
    # config.i18n.default_locale = :de

    # Use structure.sql instead of schema.rb, because we use some postgresql
    # stuff (ENUMS) that schema.rb can't handle
    config.active_record.schema_format = :sql
    # This format means that schema dumping is inconsistent between hosts, so
    # don't do it automatically on a migration
    config.active_record.dump_schema_after_migration = false

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Add custom validators to autoload path
    config.autoload_paths += %W["#{config.root}/app/validators/"]

    # Load mySociety config file and place the keys into Rails.configuration.x
    config_file = YAML.load_file(Rails.root.join("config", "general.yml"))
    MysocietyConfig = config_file[Rails.env].symbolize_keys!
    MysocietyConfig.each do |key, value|
      config.x.send("#{key}=".to_sym, value)
    end

    # Set default_url_options and default from email for ActionMailer and
    # controllers
    if config.x.hostname.present? && config.x.port.present?
      host_string = "#{config.x.hostname}:#{config.x.port}"
      Rails.application.routes.default_url_options[:host] = host_string
      config.action_mailer.default_url_options = { host: config.x.hostname,
                                                   port: config.x.port }
    elsif config.x.hostname.present?
      Rails.application.routes.default_url_options[:host] = config.x.hostname
      config.action_mailer.default_url_options = { host: config.x.hostname }
    else
      Rails.application.routes.default_url_options[:host] = "localhost"
      config.action_mailer.default_url_options = { host: "localhost" }
    end
    ActionMailer::Base.default from: config.x.from_email
  end
end
