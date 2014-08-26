module NightcrawlerSwift
  class List

    def initialize connection
      @connection = connection
    end

    def execute
      resource = RestClient::Resource.new @connection.upload_url, verify_ssl: false
      response = resource.get("X-Storage-Token" => @connection.token_id, accept: :json)
      if [200, 201].include?(response.code)
        JSON.parse(response.body)
      else
      end
    end

  end
end
