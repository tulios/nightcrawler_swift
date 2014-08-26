module NightcrawlerSwift
  class Delete

    def initialize connection
      @connection = connection
    end

    def execute path
      path = path.gsub(/^\//, "")
      resource = RestClient::Resource.new "#{@connection.upload_url}/#{path}", verify_ssl: false
      response = resource.delete("X-Storage-Token" => @connection.token_id, accept: :json)
      if [200, 201].include?(response.code)
        JSON.parse(response.body)
      else
      end
    end

  end
end
