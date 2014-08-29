require 'digest'

module NightcrawlerSwift
  class Upload < Command

    def execute path, file
      content_type = MultiMime.by_file(file).content_type
      content = file.read
      etag = '"%s"' % Digest::MD5.new.update(content).hexdigest
      headers = {etag: etag, content_type: content_type}
      headers.merge!({cache_control: "max-age=#{connection.opts.max_age}"}) if connection.opts.max_age
      response = put "#{connection.upload_url}/#{path}", body: content, headers: headers
      [200, 201].include?(response.code)
    end

  end
end
