module NightcrawlerSwift
  class Gateway

    attr_reader :resource

    def initialize url
      @resource = RestClient::Resource.new(
        url,
        verify_ssl: NightcrawlerSwift.options.verify_ssl,
        timeout: NightcrawlerSwift.options.timeout
      )
    end

    def request &block
      block.call(resource)

    rescue RestClient::Unauthorized => e
      raise Exceptions::UnauthorizedError.new(e)

    rescue RestClient::ResourceNotFound => e
      raise Exceptions::NotFoundError.new(e)

    rescue RestClient::UnprocessableEntity => e
      raise Exceptions::ValidationError.new(e)

    rescue => e
      raise Exceptions::ConnectionError.new(e)
    end

  end
end
