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

    def nodes(node_ids=[])
      uri = URI(
        "#{base_uri}/monitoring/nodes/summary?node_ids=#{node_ids.join(',')}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def cluster(cluster_id)
      uri = URI(
        "#{base_uri}/monitoring/clusters/#{cluster_id}/summary"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def cluster_utilization(cluster_id)
      uri = URI(
        "#{base_uri}/monitoring/clusters/#{cluster_id}/utilization/percent_used/stats"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def system(sds_name)
      uri = URI(
        "#{base_uri}/monitoring/system/#{sds_name}/summary"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def system_utilization(sds_name)
      uri = URI(
        "#{base_uri}/monitoring/system/#{sds_name}/utilization/percent_used/stats"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

  end
end
