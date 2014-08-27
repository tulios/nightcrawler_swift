module NightcrawlerSwift
  class Upload < Command

    def execute path, file
      content_type = MultiMime.by_file(file).content_type
      response = put "#{connection.upload_url}/#{path}", body: file.read, headers: {content_type: content_type}
      [200, 201].include?(response.code)
    end

  end
end
