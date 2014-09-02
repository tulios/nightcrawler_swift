module NightcrawlerSwift
  class Connection
    attr_accessor :auth_response
    attr_reader :token_id, :expires_at, :catalog, :admin_url, :upload_url, :public_url

    def connect!
      authenticate!
      configure

      NightcrawlerSwift.logger.debug  "[NightcrawlerSwift] Connected, token_id: #{token_id}"
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
      auth_options = {
        tenantName: opts.tenant_name,
        passwordCredentials: {username: opts.username, password: opts.password}
      }

      response = RestClient.post(
        opts.auth_url, { auth: auth_options }.to_json,
        content_type: :json,
        accept: :json,
      )

      @auth_response = OpenStruct.new(JSON.parse(response.body))
    rescue StandardError => e
      raise Exceptions::ConnectionError.new(e)
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
      @admin_url = @endpoints["adminURL"]
      @upload_url = "#{@admin_url}/#{opts.bucket}"
      @public_url = @endpoints["publicURL"]
    end
  end
end
