module NightcrawlerSwift
  class Delete < Command

    def execute path
      if path.nil? or path.empty?
        raise Exceptions::ValidationError.new "Delete command requires a path parameter"
      end

      response = delete "#{connection.upload_url}/#{path}", headers: { accept: :json }
      response.code >= 200 && response.code < 300
    end

  end
end
