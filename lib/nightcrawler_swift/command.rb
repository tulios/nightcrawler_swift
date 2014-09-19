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
      Gateway.new(url).request {|r| r.get args[:headers].merge(params: args[:params])}
    end

    def put url, args = {}
      prepare_args args
      Gateway.new(url).request {|r| r.put args[:body], args[:headers].merge(params: args[:params])}
    end

    def delete url, args = {}
      prepare_args args
      Gateway.new(url).request {|r| r.delete args[:headers].merge(params: args[:params])}
    end

    private

    def prepare_args args
      args[:headers] ||= {}
      args[:headers]["X-Storage-Token"] = connection.token_id
      args[:params] ||= {}
    end
  end
end
