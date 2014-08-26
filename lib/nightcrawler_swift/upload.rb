module NightcrawlerSwift
  class Upload

    def initialize connection
      @connection = connection
    end

    def upload path, file
      path = path.gsub(/^\//, "")
      url = "#{@connection.upload_url}/#{path}"
      response = RestClient.put(url, file.read, "X-Storage-Token" => @connection.token_id)
      [200, 201].include?(response.code)
    end

  end
end
