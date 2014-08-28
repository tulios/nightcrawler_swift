require 'digest'

module NightcrawlerSwift
  class Upload < Command

    def execute path, file
      content_type = MultiMime.by_file(file).content_type
      content = file.read
      etag = '"%s"' % Digest::MD5.new.update(content).hexdigest
      response = put "#{connection.upload_url}/#{path}", body: content, headers: {etag: etag, content_type: content_type}
      [200, 201].include?(response.code)
    end

  end
end
