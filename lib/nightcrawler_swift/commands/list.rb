module NightcrawlerSwift
  class List < Command

    def execute
      response = get connection.upload_url, headers: {accept: :json}
      JSON.parse(response.body)

    rescue RestClient::ResourceNotFound => e
      raise Exceptions::NotFoundError.new(e)

    rescue StandardError => e
      raise Exceptions::ConnectionError.new(e)
    end

  end
end
