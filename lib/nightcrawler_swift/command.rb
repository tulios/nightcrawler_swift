module NightcrawlerSwift
  class Command

    def connection
      NightcrawlerSwift.connection.tap do |conn|
        conn.connect! unless conn.connected?
      end
    end

    def options
      NightcrawlerSwift.options
    end

    def execute
      raise NotImplemented.new
    end

    protected

    def get url, params = {}
      prepare_params params
      Gateway.new(url).request {|r| r.get params[:headers]}
    end

    def put url, params = {}
      prepare_params params
      Gateway.new(url).request {|r| r.put params[:body], params[:headers]}
    end

    def delete url, params
      prepare_params params
      Gateway.new(url).request {|r| r.delete params[:headers]}
    end

    private

    def prepare_params params
      params[:headers] ||= {}
      params[:headers]["X-Storage-Token"] = connection.token_id
    end
  end
end
