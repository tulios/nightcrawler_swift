require "nightcrawler_swift"

namespace :nightcrawler_swift do
  namespace :rails do

    desc "Synchronizes the public directory with OpenStack Swift"
    task asset_sync: ["assets:precompile", "environment"] do
      begin
        NightcrawlerSwift.sync File.join(Rails.root, "public")
      rescue => e
        exit 1
      end
    end

  end
end
