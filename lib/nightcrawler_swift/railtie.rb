require "rails"
require "active_support/ordered_hash"

module NightcrawlerSwift
  class Railtie < Rails::Railtie
    railtie_name :nightcrawler_swift
    config.nightcrawler_swift = ActiveSupport::OrderedOptions.new

    rake_tasks do
      load "nightcrawler_swift/tasks/asset_sync.rake"
    end

    initializer "nightcrawler_swift.configure" do |app|
      settings = app.config.nightcrawler_swift
      logger = settings.delete(:logger) || Rails.logger

      NightcrawlerSwift.configure settings
      NightcrawlerSwift.logger = logger
    end
  end
end
