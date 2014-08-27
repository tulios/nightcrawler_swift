require "nightcrawler_swift"

namespace :nightcrawler_swift do
  namespace :rails do

    desc "Synchronizes the public directory with OpenStack Swift"
    task asset_sync: ["assets:precompile", "environment"] do
      raise unless defined?(Rails)
      NightcrawlerSwift.sync File.join(Rails.root, "public")
    end

  end
end
