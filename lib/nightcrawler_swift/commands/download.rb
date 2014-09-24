module NightcrawlerSwift
  class Download < Command

    def execute path
      if path.nil? or path.empty?
        raise Exceptions::ValidationError.new "Download command requires a path parameter"
      end

      response = get "#{connection.internal_url}/#{options.bucket}/#{path}"
      response.body
    end

  end
end
