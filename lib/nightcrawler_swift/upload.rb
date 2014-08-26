module NightcrawlerSwift
  class Upload < Command

    def execute path, file
      response = put "#{connection.upload_url}/#{path}", body: file.read
      [200, 201].include?(response.code)
    end

  end
end
