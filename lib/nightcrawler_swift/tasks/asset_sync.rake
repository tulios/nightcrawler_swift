require "nightcrawler_swift"

namespace :nightcrawler_swift do
  namespace :rails do

    desc "Synchronizes the public directory with OpenStack Swift"
    task sync: ["environment"] do
      begin
        NightcrawlerSwift.sync File.join(Rails.root, "public")
      rescue => e
        STDERR.puts e.message
        exit 1
      end
    end

    desc "Run 'assets:precompile' and synchronizes the public directory with OpenStack Swift"
    task :asset_sync do
      Rake::Task["assets:precompile"].invoke
      Rake::Task["nightcrawler_swift:rails:sync"].invoke
    end

  end
end
