require 'net/http'
require 'uri'
module Tendrl
  class MonitoringApi

    attr_accessor :base_uri

    def initialize(config)
      @base_uri = config[:url]
    end

    def node_stats(node_ids=[])
      uri = URI(
        "#{base_uri}/monitoring/nodes/summary?nodes=#{node_ids.join(',')}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end

    def cluster_stats(cluster_ids=[])
      uri = URI(
        "#{base_uri}/monitoring/clusters/summary?clusters=#{cluster_ids.join(',')}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end

  end

end
