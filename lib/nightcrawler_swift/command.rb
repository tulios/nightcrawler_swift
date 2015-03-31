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

    [
      :get,
      :head,
      :delete
    ].each do |http_verb|
      define_method http_verb do |*method_args|
        url = method_args.first
        args = method_args.last || {}

        prepare_args args
        Gateway.new(url).request {|r| r.send(http_verb, headers_and_params(args))}
      end
    end

    def put url, args = {}
      prepare_args args
      Gateway.new(url).request {|r| r.put args[:body], headers_and_params(args)}
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
