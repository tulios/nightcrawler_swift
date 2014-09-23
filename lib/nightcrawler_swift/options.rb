module NightcrawlerSwift
  class Options < OpenStruct

    def initialize params = {}
      params[:password] = ENV["NSWIFT_PASSWORD"] || params[:password]
      super defaults.merge(params)
      validate_max_age!
    end

    protected
    def defaults
      {
        retries: 5,
        max_retry_time: 30,
        verify_ssl: false
      }
    end

    private
    def validate_max_age!
      if self.max_age and not self.max_age.is_a?(Numeric)
        raise Exceptions::ConfigurationError.new "max_age should be an Integer"
      end
    end

  end
end
