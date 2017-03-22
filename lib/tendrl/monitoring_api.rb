require 'net/http'
require 'uri'
module Tendrl
  class MonitoringApi

    attr_accessor :base_uri

    def initialize(config)
      scheme = config['api_server_scheme'] || 'http'
      hostname = config['api_server_addr']
      port = config['api_server_port']
      @base_uri = "#{scheme}://#{hostname}:#{port}"
    end

    def node_stats(node_ids=[])
      uri = URI(
        "#{base_uri}/monitoring/nodes/summary?node_ids=#{node_ids.join(',')}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def cluster_stats(cluster_ids=[])
      uri = URI(
        "#{base_uri}/monitoring/clusters/summary?cluster_ids=#{cluster_ids.join(',')}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

  end

end
