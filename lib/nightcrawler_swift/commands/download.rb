module NightcrawlerSwift
  class Download < Command

    def execute path
      response = get "#{connection.public_url}/#{options.bucket}/#{path}"
      response.body

    rescue RestClient::ResourceNotFound => e
      raise Exceptions::NotFoundError.new(e)

    rescue StandardError => e
      raise Exceptions::ConnectionError.new(e)
    end

  end
end
