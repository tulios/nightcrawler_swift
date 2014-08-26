require "nightcrawler_swift"

namespace :nightcrawler_swift do
  namespace :rails do

    desc "Synchronizes the assets"
    task sync: ["assets:precompile", "environment"] do
      raise unless defined?(Rails)
      path = File.join(Rails.root, "public", Rails.configuration.assets.prefix)
      NightcrawlerSwift.sync path
    end

  end
end
