module NightcrawlerSwift
  class List < Command

    def execute
      response = get connection.upload_url, headers: {accept: :json}
      JSON.parse(response.body)
    end

  end
end
