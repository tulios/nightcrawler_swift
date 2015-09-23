module NightcrawlerSwift
  class Connection
    attr_writer :auth_response
    attr_reader :token_id, :expires_at, :catalog, :admin_url, :upload_url, :public_url, :internal_url

    def auth_response
      authenticate! if @auth_response.nil?
      @auth_response
    end

    def connect!
      authenticate!
      configure

      NightcrawlerSwift.logger.debug "[NightcrawlerSwift] Connected, token_id: #{token_id}"
      self
    end

    def connected?
      !self.token_id.nil? and self.expires_at > Time.now
    end

    def configure
      select_token
      select_catalog
      select_endpoints
      configure_urls
    end

    private
    def opts
      NightcrawlerSwift.options
    end

    def authenticate!
      url = opts.auth_url
      headers = {content_type: :json, accept: :json}
      response = Gateway.new(url).request {|r| r.post(auth_options.to_json, headers)}

      @auth_response = OpenStruct.new(JSON.parse(response.body))
    rescue StandardError => e
      raise Exceptions::ConnectionError.new(e)
    end

    def auth_options
      {
        auth: {
          tenantName: opts.tenant_name,
          passwordCredentials: {username: opts.username, password: opts.password}
        }
      }
    end

    def select_token
      @token_id = auth_response.access["token"]["id"]
      @expires_at = auth_response.access["token"]["expires"]
      @expires_at = DateTime.parse(@expires_at).to_time
    end

    def select_catalog
      catalogs = auth_response.access["serviceCatalog"]
      @catalog = catalogs.find {|catalog| catalog["type"] == "object-store"}
    end

    def select_endpoints
      raise Exceptions::ConfigurationError.new "No catalog of type 'object-store' found" if catalog.nil?
      @endpoints = catalog["endpoints"].first
    end

    def configure_urls
      @admin_url = opts.admin_url || @endpoints["adminURL"]
      @public_url = opts.public_url || @endpoints["publicURL"]
      @internal_url = opts.internal_url || @endpoints["internalURL"]
      @upload_url = "#{@admin_url}/#{opts.bucket}"
    end
  end
end
