require "optparse"
require "json"

require "nightcrawler_swift/cli/opt_parser"
require "nightcrawler_swift/cli/runner"
require "nightcrawler_swift/cli/formatters/basic"
require "nightcrawler_swift/cli/commands/url_for"

module NightcrawlerSwift
  module CLI
    CONFIG_FILE = ".nswiftrc"
    CACHE_FILE = ".nswift_cache"

    COMMANDS = {
      "list" => {
        description: "Lists all files of the bucket/container. Ex: nswift list",
        command: NightcrawlerSwift::List
      },

      "download" => {
        description: "Downloads a file by path. Format: nswift download <swift_path> Ex: nswift download assets/robots.txt > my-robots.txt",
        command: NightcrawlerSwift::Download
      },

      "upload" => {
        description: "Uploads some file. Format: nswift upload <real_path> <swift_path> Ex: nswift upload assets/robots.txt robots.txt",
        command: NightcrawlerSwift::Upload
      },

      "delete" => {
        description: "Deletes a file by path. Format: nswift delete <swift_path> Ex: nswift delete robots.txt",
        command: NightcrawlerSwift::Delete
      },

      "metadata" => {
        description: "Returns the object metadata in JSON format. Without <swift_path> returns the bucket/container metadata. Ex: nswift metadata assets/robots.txt",
        command: NightcrawlerSwift::Metadata
      },

      "url-for" => {
        description: "Returns the public url of an object. Format: nswift url-for <swift_path> Ex: nswift url-for robots.txt",
        command: NightcrawlerSwift::CLI::UrlFor
      }
    }

    def self.sample_rcfile
      JSON.pretty_generate({
        bucket: "<bucket/container name>",
        tenant_name: "<tenant name>",
        username: "<username>",
        password: "<password>",
        auth_url: "<auth url, ex: https://auth.url.com:123/v2.0/tokens>"
      })
    end
  end
end
