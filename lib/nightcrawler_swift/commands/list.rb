module NightcrawlerSwift
  class List < Command

    def execute args = {}
      headers = { accept: :json }

      # http://docs.openstack.org/api/openstack-object-storage/1.0/content/GET_showContainerDetails__v1__account___container__storage_container_services.html#GET_showContainerDetails__v1__account___container__storage_container_services-Request
      params = {}
      [:limit, :marker, :end_marker, :prefix, :format, :delimiter, :path].each do |accepted_parameter|
        params[accepted_parameter] = args[accepted_parameter] if args[accepted_parameter]
      end

      response = get connection.upload_url, headers: headers, params: params
      JSON.parse(response.body)
    end

  end
end
