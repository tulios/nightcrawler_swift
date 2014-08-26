module NightcrawlerSwift
  class Connection
    attr_accessor :opts, :auth_response, :token_id, :expires_at, :admin_url, :upload_url, :public_url

    # Hash with: bucket, tenant_name, username, password, auth_url
    #
    def initialize opts = {}
      @opts = OpenStruct.new opts
    end

    def connect!
      auth_response = authenticate!

      @token_id = auth_response.access["token"]["id"]
      @expires_at = auth_response.access["token"]["expires"]
      @expires_at = DateTime.parse(@expires_at).to_time

      @admin_url = auth_response.access["serviceCatalog"].first["endpoints"].first["adminURL"]
      @upload_url = "#{@admin_url}/#{opts.bucket}"
      @public_url = auth_response.access["serviceCatalog"].first["endpoints"].first["publicURL"]

      NightcrawlerSwift.logger.info  "Connected, token_id: #{@token_id}"
      self
    end

    def connected?
      !self.token_id.nil? and self.expires_at > Time.now
    end

    private

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

      OpenStruct.new(JSON.parse(response.body))
    rescue StandardError => e
      raise Exceptions::ConnectionError.new(e)
    end
  end
end
