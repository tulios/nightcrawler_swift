module NightcrawlerSwift
  class Connection
    attr_accessor :opts, :auth_response, :token_id, :admin_url, :upload_url

    # Hash with: tenant_name, username, password, auth_url, bucket
    #
    def initialize opts = {}
      @opts = OpenStruct.new opts
    end

    def connect!
      response = RestClient.post(
        opts.auth_url,
        {
          auth: {
            tenantName: opts.tenant_name,
            passwordCredentials: {username: opts.username, password: opts.password}
          }
        }.to_json,

        content_type: :json,
        accept: :json,
      )

      @auth_response = OpenStruct.new(JSON.parse(response.body))
      @token_id = @auth_response.access["token"]["id"]
      @admin_url = @auth_response.access["serviceCatalog"].first["endpoints"].first["adminURL"]
      @upload_url = "#{@admin_url}/#{opts.bucket}"
    end
  end
end
