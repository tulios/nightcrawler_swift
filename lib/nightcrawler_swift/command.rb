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

    # :nocov:
    def execute
      raise NotImplemented.new
    end
    # :nocov:

    protected

    def get url, args = {}
      prepare_args args
      Gateway.new(url).request {|r| r.get headers_and_params(args)}
    end

    def put url, args = {}
      prepare_args args
      Gateway.new(url).request {|r| r.put args[:body], headers_and_params(args)}
    end

    def delete url, args = {}
      prepare_args args
      Gateway.new(url).request {|r| r.delete headers_and_params(args)}
    end

    private
    def prepare_args args
      args[:headers] ||= {}
      args[:headers]["X-Storage-Token"] = connection.token_id
      args[:params] ||= {}
    end

    def headers_and_params args
      args[:headers].merge(params: args[:params])
    end
  end
end
