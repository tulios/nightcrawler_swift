module NightcrawlerSwift
  class Upload < Command

    def execute path, file
      path = path.gsub(/^\//, "")
      resource = RestClient::Resource.new "#{connection.upload_url}/#{path}", verify_ssl: false
      response = resource.put(file.read, "X-Storage-Token" => connection.token_id)
      [200, 201].include?(response.code)
    end

  end
end
