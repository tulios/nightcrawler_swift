module NightcrawlerSwift
  class Upload < Command

    def execute path, file, opts = {}
      content = file.read
      headers = {etag: etag(content), content_type: content_type(file)}

      max_age = opts[:max_age] || options.max_age
      headers.merge!(cache_control: "public, max-age=#{max_age}") if max_age

      response = put "#{connection.upload_url}/#{path}", body: content, headers: headers
      [200, 201].include?(response.code)
    end

    private
    def content_type file
      MultiMime.by_file(file).content_type
    end

    def etag content
      Digest::MD5.hexdigest(content)
    end

  end
end
