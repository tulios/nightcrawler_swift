module NightcrawlerSwift
  class Metadata < Command

    def execute path = nil
      resource_url = "#{connection.internal_url}/#{options.bucket}/#{path}"
      resource_url.gsub!(/\/$/, '') unless path

      response = head resource_url
      response.headers.symbolize_keys
    end

  end
end
