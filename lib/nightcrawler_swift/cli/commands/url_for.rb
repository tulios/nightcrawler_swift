module NightcrawlerSwift::CLI
  class UrlFor < NightcrawlerSwift::Command

    def execute path
      "#{connection.public_url}/#{options.bucket}/#{path}"
    end

  end
end
