module NightcrawlerSwift
  class Connection
    def self.connected_attr_reader(*args)
      args.each do |arg|
        define_method(arg.to_sym) do
          connect! unless connected?
          instance_variable_get("@#{arg}")
        end
      end
    end

    private_class_method :connected_attr_reader

    attr_writer :auth_response
    attr_reader :token_id, :expires_at
    connected_attr_reader :catalog, :admin_url, :upload_url, :public_url, :internal_url

    def auth_response
      @auth_response ||= nil
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

      @auth_response = OpenStruct.new(headers: response.headers, body: JSON.parse(response.body))
    rescue StandardError => e
      raise Exceptions::ConnectionError.new(e)
    end

    def auth_options
      {
        auth: {
          identity: {
              methods: [
                  "password"
              ],
              password: {
                  user: {
                      domain: {
                          id: "default"
                      },
                      name: opts.username,
                      password: opts.password
                  }
              }
          },
          scope: {
              project: {
                  domain: {
                      id: "default"
                  },
                  name: opts.tenant_name
              }
          }
        }
      }
    end

    def select_token
      @token_id = auth_response.headers[:x_subject_token]
      @expires_at = auth_response.body["token"]["expires_at"]
      @expires_at = DateTime.parse(@expires_at).to_time
    end

    def select_catalog
      catalogs = auth_response["body"]["token"]["catalog"]
      @catalog = catalogs.find {|catalog| catalog["type"] == "object-store"}
    end

    def select_endpoints
      raise Exceptions::ConfigurationError.new "No catalog of type 'object-store' found" if @catalog.nil?
      @endpoints = @catalog["endpoints"]
    end

    def configure_urls
      @admin_url = opts.admin_url || @endpoints.find {|e| e["interface"] == "admin"}["url"]
      @public_url = opts.public_url || @endpoints.find {|e| e["interface"] == "public"}["url"]
      @internal_url = opts.internal_url || @endpoints.find {|e| e["interface"] == "internal"}["url"]
      @upload_url = "#{@admin_url}/#{opts.bucket}"
    end
  end
end
