require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MiseteAccounts
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.email_regex = URI::MailTo::EMAIL_REGEXP

    config.x.hosts[:naka] = ENV.fetch('NAKA_HOST') { 'http://localhost:3000' }
    config.x.hosts[:naka_redirect_uri] = ENV.fetch('NAKA_REDIRECT_URI') { 'http://localhost:3000' }
  end
end
